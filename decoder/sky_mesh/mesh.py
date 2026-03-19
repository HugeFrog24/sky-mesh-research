"""Main .mesh file parser for Sky: Children of the Light.

Implements the full parsing pipeline:
  Mesh::Load → version header
  MeshData::LoadFromFileBuffer → mesh name, LOD count, flags, compression
  MeshData::LoadLodsFromBuffer → per-LOD geometry, bone weights, indices
  AnimPackData::LoadFromBuffer → skeleton + animations (if present)

Supports mesh format versions 0x19 through 0x1e (Sky Live 0.11.0).
"""

import struct
from sky_mesh.stream import BinaryStream
from sky_mesh.types import (
    SkyMeshFile,
    MeshLodData,
    OcclusionData,
)
from sky_mesh.skeleton import parse_animpack

try:
    import lz4.block

    _HAS_LZ4 = True
except ImportError:
    _HAS_LZ4 = False

MIN_VERSION = 0x19
MAX_VERSION = 0x1E


def _decompress_lz4(data: bytes, uncompressed_size: int) -> bytes:
    if not _HAS_LZ4:
        raise ImportError(
            "lz4 package required for compressed meshes. Install with: pip install lz4"
        )
    return lz4.block.decompress(data, uncompressed_size=uncompressed_size)


def _decode_positions(
    data: bytes, vertex_count: int
) -> list[tuple[float, float, float]]:
    """Decode uncompressed MeshPos: 4 × float32 per vertex (x, y, z, w)."""
    positions = []
    for i in range(vertex_count):
        x, y, z, _w = struct.unpack_from("<ffff", data, i * 16)
        positions.append((x, y, z))
    return positions


def _decode_compressed_positions(
    packed_data: bytes,
    w_data: bytes,
    vertex_count: int,
    aabb_min: tuple[float, float, float],
    aabb_max: tuple[float, float, float],
) -> list[tuple[float, float, float]]:
    """Decode MeshPosCompressed: 10-10-10-2 bit packing + AABB denormalization."""
    positions = []
    dx = aabb_max[0] - aabb_min[0]
    dy = aabb_max[1] - aabb_min[1]
    dz = aabb_max[2] - aabb_min[2]
    for i in range(vertex_count):
        packed = struct.unpack_from("<I", packed_data, i * 4)[0]
        x10 = (packed >> 20) & 0x3FF
        y10 = (packed >> 10) & 0x3FF
        z10 = packed & 0x3FF
        x = (x10 / 1023.0) * dx + aabb_min[0]
        y = (y10 / 1023.0) * dy + aabb_min[1]
        z = (z10 / 1023.0) * dz + aabb_min[2]
        positions.append((x, y, z))
    return positions


def _decode_normals(
    data: bytes, vertex_count: int
) -> list[tuple[float, float, float]]:
    """Decode MeshNorm: 3 × int8, decode as byte / 128.0."""
    normals = []
    for i in range(vertex_count):
        nx = struct.unpack_from("<b", data, i * 4 + 0)[0] / 128.0
        ny = struct.unpack_from("<b", data, i * 4 + 1)[0] / 128.0
        nz = struct.unpack_from("<b", data, i * 4 + 2)[0] / 128.0
        normals.append((nx, ny, nz))
    return normals


def _decode_uvs(
    data: bytes, vertex_count: int
) -> list[tuple[float, float, float, float]]:
    """Decode MeshUv: 4 × float32 per vertex (u0, v0, u1, v1)."""
    uvs = []
    for i in range(vertex_count):
        u0, v0, u1, v1 = struct.unpack_from("<ffff", data, i * 16)
        uvs.append((u0, v0, u1, v1))
    return uvs


def _decode_compressed_uvs(
    data: bytes,
    vertex_count: int,
    uv_bounds_min: list[float],
    uv_bounds_max: list[float],
) -> list[tuple[float, float, float, float]]:
    """Decode MeshUvCompressed: 4 × uint8 per vertex with per-channel AABB.

    UV bounds layout (from MeshLod extended bounds at +0x34 and +0x54):
      Index 0: uv0_u_min/max   Index 1: uv0_v_min/max
      Index 2: uv2_u_min/max   Index 3: uv2_v_min/max
      (indices 4-7 are uv1/uv3, stripped when stripUv13 is set)
    """
    uvs = []
    for i in range(vertex_count):
        u0b, v0b, u1b, v1b = struct.unpack_from("<BBBB", data, i * 4)
        u0 = (u0b / 255.0) * (uv_bounds_max[0] - uv_bounds_min[0]) + uv_bounds_min[0]
        v0 = (v0b / 255.0) * (uv_bounds_max[1] - uv_bounds_min[1]) + uv_bounds_min[1]
        u1 = (u1b / 255.0) * (uv_bounds_max[2] - uv_bounds_min[2]) + uv_bounds_min[2]
        v1 = (v1b / 255.0) * (uv_bounds_max[3] - uv_bounds_min[3]) + uv_bounds_min[3]
        uvs.append((u0, v0, u1, v1))
    return uvs


def _decode_bone_weights(
    data: bytes,
    vertex_count: int,
    partition: tuple[int, int, int, int],
) -> list[dict]:
    """Decode MeshWeight: {uint8 boneIdx[4], uint8 weight[4]} per vertex.

    Vertices are sorted by influence count per the bone_influence_partition.
    """
    c1, c2, c3, _c4 = partition
    weights = []
    for i in range(vertex_count):
        off = i * 8
        idx = struct.unpack_from("<BBBB", data, off)
        wt = struct.unpack_from("<BBBB", data, off + 4)
        if i < c1:
            n = 1
        elif i < c1 + c2:
            n = 2
        elif i < c1 + c2 + c3:
            n = 3
        else:
            n = 4
        weights.append(
            {
                "indices": list(idx[:n]),
                "weights": [wt[j] / 255.0 for j in range(n)],
            }
        )
    return weights


def _decode_indices(
    data: bytes, index_count: int, index_format: int
) -> list[int]:
    """Decode index buffer (uint16 or uint32)."""
    if index_format == 0:
        return list(struct.unpack_from(f"<{index_count}H", data))
    else:
        return list(struct.unpack_from(f"<{index_count}I", data))


def _parse_lods(
    stream: BinaryStream,
    version: int,
    lod_count: int,
    has_animation: bool,
    has_occlusion: bool,
) -> tuple[list[MeshLodData], OcclusionData | None]:
    """Parse MeshData::LoadLodsFromBuffer — all LODs + optional occlusion."""

    lods: list[MeshLodData] = []

    for _lod_idx in range(lod_count):
        switch_dist = stream.read_float()

        aabb_min = stream.read_vec3()
        aabb_max = stream.read_vec3()

        if version >= 0x1C:
            skinned_min = stream.read_vec3()
            skinned_max = stream.read_vec3()
        else:
            skinned_min = aabb_min
            skinned_max = aabb_max

        uv_bounds_min: list[float] | None = None
        uv_bounds_max: list[float] | None = None

        if version >= 0x1C:
            if version > 0x1C:
                uv_bounds_min = list(stream.read_floats(8))
                uv_bounds_max = list(stream.read_floats(8))
            # version == 0x1c: no extended bounds

        vertex_count = stream.read_uint32()
        index_count = stream.read_uint32()

        index_format = 1
        if version > 0x1D:
            index_format = stream.read_int32()

        morph_target_count = stream.read_int32()
        edge_count = stream.read_int32()
        adjacency_count = stream.read_int32()
        bone_weight_count = stream.read_int32()
        extra_index_count = stream.read_int32()

        has_normals = True
        has_secondary_indices = True
        compressed_pos_count = 0
        compressed_uv_count = 0
        compressed_extra_count = 0

        if version > 0x1C:
            has_normals = stream.read_bool()
            has_secondary_indices = stream.read_bool()
            _has_compressed = stream.read_bool()
            compressed_pos_count = stream.read_int32()
            compressed_uv_count = stream.read_int32()
            compressed_extra_count = stream.read_int32()

        bone_partition = struct.unpack_from(
            "<IIII", stream.read_bytes(16)
        )

        index_stride = 2 if index_format == 0 else 4

        # --- Vertex buffers ---

        # Positions (uncompressed path)
        positions: list[tuple[float, float, float]] = []
        if version < 0x1D or compressed_pos_count == 0:
            pos_data = stream.read_bytes(vertex_count * 16)
            positions = _decode_positions(pos_data, vertex_count)

        # Normals
        normals = None
        if has_normals:
            norm_data = stream.read_bytes(vertex_count * 4)
            normals = _decode_normals(norm_data, vertex_count)

        # UVs (uncompressed path)
        uvs: list[tuple[float, float, float, float]] = []
        if version < 0x1D or compressed_uv_count == 0:
            uv_data = stream.read_bytes(vertex_count * 16)
            uvs = _decode_uvs(uv_data, vertex_count)

        # Bone weights
        bone_weights = None
        if has_animation:
            wt_data = stream.read_bytes(vertex_count * 8)
            bone_weights = _decode_bone_weights(wt_data, vertex_count, bone_partition)

        # Primary index buffer
        idx_data = stream.read_bytes(index_count * index_stride)
        indices = _decode_indices(idx_data, index_count, index_format)

        # Secondary index buffer
        if has_secondary_indices:
            stream.skip(index_count * index_stride)

        # Morph target indices
        if morph_target_count > 0:
            stream.skip(vertex_count * index_stride)

        # Edge indices
        if edge_count > 0:
            stream.skip(vertex_count * index_stride)

        # Adjacency indices
        if adjacency_count > 0:
            stream.skip(adjacency_count * index_stride)

        # Separate bone weight array
        if bone_weight_count > 0:
            stream.skip(bone_weight_count * 4)

        # Extra strip indices
        if extra_index_count > 0:
            stream.skip(extra_index_count * 2 * index_stride)

        # --- Skinned AABB computation for old versions (skip, not needed for export) ---

        # --- Summed area array ---
        tri_count = index_count // 3
        if version >= 0x1D:
            stream.skip(tri_count * 4)
        # version < 0x1d: computed, not in stream

        # --- Compressed channels (version >= 0x1d) ---
        if compressed_pos_count > 0:
            comp_pos_data = stream.read_bytes(vertex_count * 4)
            comp_w_data = stream.read_bytes(vertex_count)
            positions = _decode_compressed_positions(
                comp_pos_data, comp_w_data, vertex_count, aabb_min, aabb_max
            )

        if compressed_uv_count > 0:
            comp_uv_data = stream.read_bytes(vertex_count * 4)
            if uv_bounds_min and uv_bounds_max:
                uvs = _decode_compressed_uvs(
                    comp_uv_data, vertex_count, uv_bounds_min, uv_bounds_max
                )

        if compressed_extra_count > 0:
            stream.skip(vertex_count * 4)

        lod = MeshLodData(
            switch_distance=switch_dist,
            aabb_min=aabb_min,
            aabb_max=aabb_max,
            skinned_aabb_min=skinned_min,
            skinned_aabb_max=skinned_max,
            uv_bounds_min=uv_bounds_min,
            uv_bounds_max=uv_bounds_max,
            vertex_count=vertex_count,
            index_count=index_count,
            index_format=index_format,
            morph_target_count=morph_target_count,
            edge_count=edge_count,
            adjacency_count=adjacency_count,
            bone_weight_count=bone_weight_count,
            extra_index_count=extra_index_count,
            has_normals=has_normals,
            has_secondary_indices=has_secondary_indices,
            bone_influence_partition=bone_partition,
            compressed_pos_count=compressed_pos_count,
            compressed_uv_count=compressed_uv_count,
            positions=positions,
            normals=normals,
            uvs=uvs,
            bone_weights=bone_weights,
            indices=indices,
        )
        lods.append(lod)

    # --- Occlusion data (after all LODs) ---
    occlusion = None
    if has_occlusion:
        occ_tri = stream.read_uint32()
        occ_vert = stream.read_uint32()
        occ_idx_data = stream.read_bytes(occ_tri * 3 * 4)
        occ_val_data = stream.read_bytes(occ_vert * 4)
        occlusion = OcclusionData(
            tri_count=occ_tri,
            vert_count=occ_vert,
            indices=list(struct.unpack_from(f"<{occ_tri * 3}I", occ_idx_data)),
            values=list(struct.unpack_from(f"<{occ_vert}f", occ_val_data)),
        )

    return lods, occlusion


def parse_mesh_file(filepath: str) -> SkyMeshFile:
    """Parse a Sky .mesh file and return all decoded data.

    This is the main entry point. The file format is:
      [4 bytes]   uint32 version (0x19–0x1e)
      [0x40 bytes] mesh name (null-terminated, padded)
      [4 bytes]   uint32 LOD count
      [1 byte]    bool hasAnimation
      [1 byte]    bool hasOcclusion
      [...]       compression wrapper + LOD data + optional AnimPackData
    """
    with open(filepath, "rb") as f:
        file_data = f.read()

    stream = BinaryStream(file_data)

    version = stream.read_uint32()
    if not (MIN_VERSION <= version <= MAX_VERSION):
        raise ValueError(
            f"Mesh version 0x{version:02X} out of range "
            f"(expected 0x{MIN_VERSION:02X}–0x{MAX_VERSION:02X})"
        )

    mesh_name = stream.read_string(0x40)
    lod_count = stream.read_int32()
    has_animation = stream.read_bool()
    has_occlusion = stream.read_bool()

    # Compression wrapper (version > 0x1a)
    compression_mode = 0
    if version > 0x1A:
        compression_mode = stream.read_int32()

    if compression_mode == 1:
        compressed_size = stream.read_uint32()
        uncompressed_size = stream.read_uint32()
        compressed_data = stream.read_bytes(compressed_size)
        decompressed = _decompress_lz4(compressed_data, uncompressed_size)
        lod_stream = BinaryStream(decompressed)
        lods, occlusion = _parse_lods(
            lod_stream, version, lod_count, has_animation, has_occlusion
        )
    else:
        lods, occlusion = _parse_lods(
            stream, version, lod_count, has_animation, has_occlusion
        )

    skeleton = None
    animations = []
    if has_animation:
        skeleton, animations = parse_animpack(stream)

    return SkyMeshFile(
        name=mesh_name,
        version=version,
        has_animation=has_animation,
        has_occlusion=has_occlusion,
        lods=lods,
        skeleton=skeleton,
        animations=animations,
        occlusion=occlusion,
    )
