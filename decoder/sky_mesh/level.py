"""BstBaked.meshes (LVL06) parser for Sky: Children of the Light.

Parses the level terrain/geometry binary:
  - LVL06 header + TOC
  - Per-LOD LZ4-compressed sections
  - MeshBakes, TerrainMeshes, Skirts, Occluders, Cloud/Volumetric data

Reference: mesh_encoding_research.md §17
"""

import struct
import math

from sky_mesh.stream import BinaryStream
from sky_mesh.level_types import (
    LevelMeshFile,
    LevelLodData,
    TocEntry,
    MeshBakeEntry,
    MeshBakeLodEntry,
    LightVertexData,
    TerrainMeshData,
    TerrainVertex,
    OctreeBinEntry,
    SkirtMeshData,
    SkirtVertex,
    OccluderMeshData,
    CloudVoxelData,
)

try:
    import lz4.block

    _HAS_LZ4 = True
except ImportError:
    _HAS_LZ4 = False

LVL_MAGIC_PREFIX = b"LVL0"
MIN_LVL_VERSION = 0x33
MAX_LVL_VERSION = 0x36
TOC_OFFSET = 8
TOC_SIZE = 100
TOC_ENTRIES_OFFSET = 12
MAX_TOC_ENTRIES = 8
TOC_ENTRY_SIZE = 12
MAX_DECOMPRESSED_SIZE = 0xC00000


def _decompress_lz4(data: bytes, max_size: int = MAX_DECOMPRESSED_SIZE) -> bytes:
    if not _HAS_LZ4:
        raise ImportError("lz4 required: pip install lz4")
    return lz4.block.decompress(data, uncompressed_size=max_size)


def _decode_light_vertex(data: bytes, offset: int) -> LightVertexData:
    """Decode 12-byte LightVertexData (MeshLight)."""
    r_b = data[offset]
    g_b = data[offset + 1]
    b_b = data[offset + 2]
    d_b = data[offset + 3]

    ao = data[offset + 4] / 255.0
    shadow_raw = data[offset + 5] / 255.0
    shadow = shadow_raw * shadow_raw
    exp_byte = data[offset + 6] ^ 0x80
    mant_byte = data[offset + 7]
    intensity = math.ldexp(mant_byte / 255.0, exp_byte - 0x80) / 1000.0

    nx = data[offset + 8] / 255.0 * 2.0 - 1.0
    ny = data[offset + 9] / 255.0 * 2.0 - 1.0
    nz = data[offset + 10] / 255.0 * 2.0 - 1.0
    ambient = data[offset + 11] / 255.0

    return LightVertexData(
        r=r_b / 255.0, g=g_b / 255.0, b=b_b / 255.0, d=d_b / 255.0,
        ao=ao, shadow=shadow, intensity=intensity,
        normal=(nx, ny, nz), ambient=ambient,
    )


def _decode_terrain_vertex(data: bytes, offset: int) -> TerrainVertex:
    """Decode 36-byte terrain vertex."""
    x, y, z = struct.unpack_from("<fff", data, offset)
    nx = struct.unpack_from("<b", data, offset + 12)[0] / 128.0
    ny = struct.unpack_from("<b", data, offset + 13)[0] / 128.0
    nz = struct.unpack_from("<b", data, offset + 14)[0] / 128.0

    c0 = struct.unpack_from("<BBBB", data, offset + 16)
    c1 = struct.unpack_from("<BBBB", data, offset + 20)
    color = struct.unpack_from("<BBBB", data, offset + 24)
    uv0_raw = struct.unpack_from("<BBBB", data, offset + 28)
    uv1_raw = struct.unpack_from("<BBBB", data, offset + 32)

    uv0 = tuple(b / 255.0 for b in uv0_raw)
    uv1 = tuple(b / 255.0 for b in uv1_raw)

    return TerrainVertex(
        position=(x, y, z), normal=(nx, ny, nz),
        custom0=c0, custom1=c1, color=color,
        uv0=uv0, uv1=uv1,
    )


def _decode_skirt_vertex(data: bytes, offset: int) -> SkirtVertex:
    """Decode 40-byte skirt vertex (36B terrain + 4B edge/blend)."""
    tv = _decode_terrain_vertex(data, offset)
    eb_raw = struct.unpack_from("<bbbb", data, offset + 36)
    edge_blend = tuple(b / 128.0 for b in eb_raw)

    return SkirtVertex(
        position=tv.position, normal=tv.normal,
        custom0=tv.custom0, custom1=tv.custom1, color=tv.color,
        uv0=tv.uv0, uv1=tv.uv1, edge_blend=edge_blend,
    )


def _reconstruct_terrain_indices(
    octree_bins: list[OctreeBinEntry],
    tess_tri_edge_data: list[int],
    tess_index_u32_data: list[int],
    tess_vertex_data: list[int],
) -> list[int]:
    """Reconstruct indices from tessellation tables."""
    output: list[int] = []
    edge_offset = 0
    vertex_offset = 0

    for g, bin_entry in enumerate(octree_bins):
        edge_count = bin_entry.triangle_count

        for j in range(edge_count):
            edge_entry = tess_tri_edge_data[edge_offset + j]
            lookup_idx = edge_entry >> 1
            component = edge_entry & 1

            packed = tess_index_u32_data[vertex_offset + lookup_idx]
            if component == 0:
                vertex_index = packed & 0xFFFF
            else:
                vertex_index = (packed >> 16) & 0xFFFF

            output.append(vertex_index)

        edge_offset += edge_count
        if g < len(tess_vertex_data):
            vertex_offset += tess_vertex_data[g]

    return output


def _parse_mesh_bakes(stream: BinaryStream) -> list[MeshBakeEntry]:
    """Parse MeshBake section."""
    count = stream.read_uint32()
    bakes: list[MeshBakeEntry] = []

    for _ in range(count):
        name = stream.read_length_string()
        submesh_id = stream.read_int32()
        num_lods = stream.read_uint32()
        shared_flag = stream.read_bool()

        lod_entries: list[MeshBakeLodEntry] = []
        for _ in range(num_lods):
            src_vert_count = stream.read_uint32()
            aux_byte_count = stream.read_uint32()

            light_count = 1 if shared_flag else src_vert_count
            light_data_bytes = stream.read_bytes(light_count * 12)
            lights = [
                _decode_light_vertex(light_data_bytes, i * 12)
                for i in range(light_count)
            ]

            aux_data = stream.read_bytes(aux_byte_count)
            lod_entries.append(MeshBakeLodEntry(
                source_vert_count=src_vert_count,
                aux_byte_count=aux_byte_count,
                light_data=lights,
                aux_data=aux_data,
            ))

        bakes.append(MeshBakeEntry(
            mesh_name=name, submesh_id=submesh_id,
            num_lods=num_lods, shared_bake_flag=shared_flag,
            lod_entries=lod_entries,
        ))

    return bakes


def _parse_terrain_meshes(stream: BinaryStream) -> list[TerrainMeshData]:
    """Parse TerrainMesh section — 25-step exact stream order."""
    count = stream.read_uint32()
    meshes: list[TerrainMeshData] = []

    for _ in range(count):
        bst_guid = stream.read_uint32()
        is_hidden = stream.read_bit_bool()
        is_forced_hidden = stream.read_bit_bool()
        stream.read_bit_align()

        aabb_min = stream.read_vec3()
        aabb_max = stream.read_vec3()
        vertex_count = stream.read_uint32()
        index_count = stream.read_uint32()

        vert_data = stream.read_bytes(vertex_count * 36)
        vertices = [_decode_terrain_vertex(vert_data, i * 36) for i in range(vertex_count)]

        index_byte_size = stream.read_uint32()
        raw_index_data = stream.read_bytes(index_byte_size)

        octree_aabb_min = stream.read_vec3()
        octree_aabb_max = stream.read_vec3()
        octree_leaf_size = stream.read_float()
        grid_x = stream.read_uint32()
        grid_y = stream.read_uint32()
        grid_z = stream.read_uint32()

        bin_count = stream.read_uint32()
        octree_bins: list[OctreeBinEntry] = []
        for _ in range(bin_count):
            tc = stream.read_uint32()
            unused = stream.read_uint32()
            octree_bins.append(OctreeBinEntry(triangle_count=tc, unused=unused))

        tess_vertex_count = stream.read_uint32()
        tess_index_u32_count = stream.read_uint32()
        tess_tri_edge_count = stream.read_uint32()

        tess_index_u32_data: list[int] = []
        if tess_index_u32_count > 0:
            raw = stream.read_bytes(tess_index_u32_count * 4)
            tess_index_u32_data = list(struct.unpack(f"<{tess_index_u32_count}I", raw))

        tess_tri_edge_data: list[int] = []
        if tess_tri_edge_count > 0:
            raw = stream.read_bytes(tess_tri_edge_count * 2)
            tess_tri_edge_data = list(struct.unpack(f"<{tess_tri_edge_count}H", raw))

        tess_vertex_data: list[int] = []
        if tess_vertex_count > 0:
            raw = stream.read_bytes(tess_vertex_count * 4)
            tess_vertex_data = list(struct.unpack(f"<{tess_vertex_count}I", raw))

        if tess_index_u32_count == 0:
            idx_raw = stream.read_bytes(index_count * 2)
            indices = list(struct.unpack(f"<{index_count}H", idx_raw))
        else:
            indices = _reconstruct_terrain_indices(
                octree_bins, tess_tri_edge_data,
                tess_index_u32_data, tess_vertex_data,
            )

        meshes.append(TerrainMeshData(
            bst_guid=bst_guid,
            is_hidden=is_hidden,
            is_forced_hidden=is_forced_hidden,
            aabb_min=aabb_min, aabb_max=aabb_max,
            vertex_count=vertex_count, index_count=index_count,
            vertices=vertices, indices=indices,
            octree_aabb_min=octree_aabb_min, octree_aabb_max=octree_aabb_max,
            octree_leaf_size=octree_leaf_size,
            octree_grid_dim=(grid_x, grid_y, grid_z),
            octree_bins=octree_bins,
            tess_vertex_count=tess_vertex_count,
            tess_index_u32_count=tess_index_u32_count,
            tess_tri_edge_count=tess_tri_edge_count,
            tess_index_u32_data=tess_index_u32_data,
            tess_tri_edge_data=tess_tri_edge_data,
            tess_vertex_data=tess_vertex_data,
        ))

    return meshes


def _parse_cloud_data(stream: BinaryStream, file_version: int) -> CloudVoxelData | None:
    """Parse cloud/volumetric section."""
    has_cloud = stream.read_uint32()
    if has_cloud == 0:
        return None

    bin_min_x = stream.read_int32()
    bin_min_y = stream.read_int32()
    bin_min_z = stream.read_int32()
    bin_dim_w = stream.read_uint32()
    bin_dim_h = stream.read_uint32()
    bin_dim_d = stream.read_uint32()

    voxel_size = bin_dim_w * bin_dim_h * bin_dim_d
    voxel_data = stream.read_bytes(voxel_size)

    cloud_index_count = stream.read_uint32()
    cloud_indices: list[tuple[int, int, int]] = []
    for _ in range(cloud_index_count):
        cx = stream.read_int16()
        cy = stream.read_int16()
        cz = stream.read_int16()
        cloud_indices.append((cx, cy, cz))

    dist_sz = stream.read_uint32()
    light_sz = stream.read_uint32()
    hard_sz = stream.read_uint32()

    dist_compressed = stream.read_bytes(dist_sz)
    light_compressed = stream.read_bytes(light_sz)
    hardness_compressed = stream.read_bytes(hard_sz)

    cloud_param = stream.read_float()
    dist_grid_size = stream.read_uint32()
    amb_grid_size = stream.read_uint32()

    octree_node_count = stream.read_uint32()
    octree_edge_count = stream.read_uint32()
    octree_nodes = stream.read_bytes(octree_node_count * 16)
    octree_edges = stream.read_bytes(octree_edge_count * 2)

    extra_param = 0
    if file_version > 0x35:
        extra_param = stream.read_uint8()

    return CloudVoxelData(
        bin_min=(bin_min_x, bin_min_y, bin_min_z),
        bin_dim=(bin_dim_w, bin_dim_h, bin_dim_d),
        voxel_data=voxel_data,
        cloud_index_count=cloud_index_count,
        cloud_indices=cloud_indices,
        dist_grid_size=dist_grid_size,
        amb_grid_size=amb_grid_size,
        cloud_param=cloud_param,
        dist_compressed=dist_compressed,
        light_compressed=light_compressed,
        hardness_compressed=hardness_compressed,
        octree_node_count=octree_node_count,
        octree_edge_count=octree_edge_count,
        octree_nodes=octree_nodes,
        octree_edges=octree_edges,
        extra_param=extra_param,
    )


def _parse_skirts(stream: BinaryStream) -> list[SkirtMeshData]:
    """Parse skirt data section."""
    count = stream.read_uint32()
    skirts: list[SkirtMeshData] = []

    for _ in range(count):
        vert_count = stream.read_uint32()
        vert_data = stream.read_bytes(vert_count * 40)
        vertices = [_decode_skirt_vertex(vert_data, i * 40) for i in range(vert_count)]

        idx_count = stream.read_uint32()
        idx_data = stream.read_bytes(idx_count * 2)
        indices = list(struct.unpack(f"<{idx_count}H", idx_data))

        skirts.append(SkirtMeshData(
            vertex_count=vert_count, index_count=idx_count,
            vertices=vertices, indices=indices,
        ))

    return skirts


def _parse_occluder(stream: BinaryStream) -> OccluderMeshData | None:
    """Parse occluder mesh section."""
    has_occluder = stream.read_uint32()
    if has_occluder == 0:
        return None

    vert_count = stream.read_uint32()
    idx_count = stream.read_uint32()

    positions: list[tuple[float, float, float]] = []
    for _ in range(vert_count):
        x, y, z = struct.unpack_from("<fff", stream.read_bytes(12), 0)
        stream.skip(4)
        positions.append((x, y, z))

    idx_data = stream.read_bytes(idx_count * 2)
    indices = list(struct.unpack(f"<{idx_count}H", idx_data))

    return OccluderMeshData(
        vertex_count=vert_count, index_count=idx_count,
        positions=positions, indices=indices,
    )


def _parse_lod_section(
    data: bytes, lod_index: int, file_version: int
) -> LevelLodData:
    """Parse a decompressed LOD section."""
    stream = BinaryStream(data)

    mesh_bakes = _parse_mesh_bakes(stream)
    terrain_meshes = _parse_terrain_meshes(stream)
    cloud = _parse_cloud_data(stream, file_version)
    skirts = _parse_skirts(stream)
    occluder = _parse_occluder(stream)

    return LevelLodData(
        lod_index=lod_index,
        mesh_bakes=mesh_bakes,
        terrain_meshes=terrain_meshes,
        skirts=skirts,
        occluder=occluder,
        cloud=cloud,
    )


def parse_level_meshes(filepath: str) -> LevelMeshFile:
    """Parse a BstBaked.meshes file and return all decoded level geometry.

    File layout:
      [4 bytes]   Magic "LVL0"
      [4 bytes]   Version encoded as ASCII digit at byte 4 (e.g. '6' = 0x36)
      [100 bytes] TOC: uint8 count + 3B reserved + up to 8 × 12B entries
      [4 bytes]   uint32 bakeType (only if version > 0x34)
      [12 bytes]  Vector3 global AABB min
      [12 bytes]  Vector3 global AABB max
      [per-LOD]   LZ4-compressed geometry sections at absolute file offsets
    """
    with open(filepath, "rb") as f:
        file_data = f.read()

    if len(file_data) < TOC_OFFSET + TOC_SIZE:
        raise ValueError(f"File too small: {len(file_data)} bytes")

    if file_data[:4] != LVL_MAGIC_PREFIX:
        raise ValueError(f"Bad magic: {file_data[:4]!r} (expected {LVL_MAGIC_PREFIX!r})")

    file_version = file_data[4]
    if not (MIN_LVL_VERSION <= file_version <= MAX_LVL_VERSION):
        raise ValueError(
            f"LVL version 0x{file_version:02X} out of range "
            f"(expected 0x{MIN_LVL_VERSION:02X}-0x{MAX_LVL_VERSION:02X})"
        )

    toc_entry_count = file_data[TOC_OFFSET]
    if toc_entry_count > MAX_TOC_ENTRIES:
        toc_entry_count = MAX_TOC_ENTRIES

    toc_entries: list[TocEntry] = []
    for i in range(toc_entry_count):
        off = TOC_ENTRIES_OFFSET + i * TOC_ENTRY_SIZE
        name = file_data[off:off + 4].decode("ascii", errors="replace").rstrip("\x00")
        entry_offset = struct.unpack_from("<I", file_data, off + 4)[0]
        comp_size = struct.unpack_from("<I", file_data, off + 8)[0]
        toc_entries.append(TocEntry(name=name, offset=entry_offset, compressed_size=comp_size))

    pos = TOC_OFFSET + TOC_SIZE

    bake_type = 0
    if file_version > 0x34:
        bake_type = struct.unpack_from("<I", file_data, pos)[0]
        pos += 4

    aabb_min = struct.unpack_from("<fff", file_data, pos)
    pos += 12
    aabb_max = struct.unpack_from("<fff", file_data, pos)
    pos += 12

    lods: list[LevelLodData] = []
    lod_idx = 0

    for entry in toc_entries:
        if "LOD" not in entry.name:
            continue

        section_data = file_data[entry.offset:entry.offset + entry.compressed_size]

        try:
            decompressed = _decompress_lz4(section_data, MAX_DECOMPRESSED_SIZE)
        except Exception as e:
            print(f"Warning: Failed to decompress {entry.name}: {e}")
            lod_idx += 1
            continue

        lod = _parse_lod_section(decompressed, lod_idx, file_version)
        lods.append(lod)
        lod_idx += 1

    return LevelMeshFile(
        version=file_version,
        bake_type=bake_type,
        global_aabb_min=aabb_min,
        global_aabb_max=aabb_max,
        toc_entries=toc_entries,
        lods=lods,
    )
