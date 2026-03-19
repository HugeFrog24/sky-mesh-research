"""Data classes for decoded Sky level data (BstBaked.meshes + Objects.level.bin)."""

from dataclasses import dataclass, field


@dataclass
class LightVertexData:
    """12-byte per-vertex baked lighting (MeshLight decode)."""

    r: float
    g: float
    b: float
    d: float
    ao: float
    shadow: float
    intensity: float
    normal: tuple[float, float, float]
    ambient: float


@dataclass
class MeshBakeLodEntry:
    """One LOD sub-entry within a MeshBake."""

    source_vert_count: int
    aux_byte_count: int
    light_data: list[LightVertexData] = field(default_factory=list)
    aux_data: bytes = b""


@dataclass
class MeshBakeEntry:
    """Instanced reference to a .mesh resource with baked lighting."""

    mesh_name: str
    submesh_id: int
    num_lods: int
    shared_bake_flag: bool
    lod_entries: list[MeshBakeLodEntry] = field(default_factory=list)


@dataclass
class TerrainVertex:
    """36-byte terrain vertex: position + normal + 5 attribute channels."""

    position: tuple[float, float, float]
    normal: tuple[float, float, float]
    custom0: tuple[int, int, int, int]
    custom1: tuple[int, int, int, int]
    color: tuple[int, int, int, int]
    uv0: tuple[float, float, float, float]
    uv1: tuple[float, float, float, float]


@dataclass
class OctreeBinEntry:
    """8-byte tessellation group entry."""

    triangle_count: int
    unused: int


@dataclass
class TerrainMeshData:
    """Self-contained level terrain geometry."""

    bst_guid: int
    is_hidden: bool
    is_forced_hidden: bool
    aabb_min: tuple[float, float, float]
    aabb_max: tuple[float, float, float]
    vertex_count: int
    index_count: int
    vertices: list[TerrainVertex] = field(default_factory=list)
    indices: list[int] = field(default_factory=list)

    octree_aabb_min: tuple[float, float, float] = (0.0, 0.0, 0.0)
    octree_aabb_max: tuple[float, float, float] = (0.0, 0.0, 0.0)
    octree_leaf_size: float = 0.0
    octree_grid_dim: tuple[int, int, int] = (0, 0, 0)
    octree_bins: list[OctreeBinEntry] = field(default_factory=list)

    tess_vertex_count: int = 0
    tess_index_u32_count: int = 0
    tess_tri_edge_count: int = 0
    tess_index_u32_data: list[int] = field(default_factory=list)
    tess_tri_edge_data: list[int] = field(default_factory=list)
    tess_vertex_data: list[int] = field(default_factory=list)


@dataclass
class SkirtVertex:
    """40-byte skirt vertex: terrain vertex + edge/blend channel."""

    position: tuple[float, float, float]
    normal: tuple[float, float, float]
    custom0: tuple[int, int, int, int]
    custom1: tuple[int, int, int, int]
    color: tuple[int, int, int, int]
    uv0: tuple[float, float, float, float]
    uv1: tuple[float, float, float, float]
    edge_blend: tuple[float, float, float, float]


@dataclass
class SkirtMeshData:
    """Terrain edge/skirt geometry."""

    vertex_count: int
    index_count: int
    vertices: list[SkirtVertex] = field(default_factory=list)
    indices: list[int] = field(default_factory=list)


@dataclass
class OccluderMeshData:
    """Visibility occluder (float3 pos + 4B pad per vert)."""

    vertex_count: int
    index_count: int
    positions: list[tuple[float, float, float]] = field(default_factory=list)
    indices: list[int] = field(default_factory=list)


@dataclass
class CloudVoxelData:
    """Cloud/volumetric data for a level LOD."""

    bin_min: tuple[int, int, int]
    bin_dim: tuple[int, int, int]
    voxel_data: bytes = b""
    cloud_index_count: int = 0
    cloud_indices: list[tuple[int, int, int]] = field(default_factory=list)

    dist_grid_size: int = 0
    amb_grid_size: int = 0
    cloud_param: float = 0.0

    dist_compressed: bytes = b""
    light_compressed: bytes = b""
    hardness_compressed: bytes = b""

    octree_node_count: int = 0
    octree_edge_count: int = 0
    octree_nodes: bytes = b""
    octree_edges: bytes = b""
    extra_param: int = 0


@dataclass
class LevelLodData:
    """All geometry within a single LOD of a level."""

    lod_index: int
    mesh_bakes: list[MeshBakeEntry] = field(default_factory=list)
    terrain_meshes: list[TerrainMeshData] = field(default_factory=list)
    skirts: list[SkirtMeshData] = field(default_factory=list)
    occluder: OccluderMeshData | None = None
    cloud: CloudVoxelData | None = None


@dataclass
class TocEntry:
    """Table of contents entry."""

    name: str
    offset: int
    compressed_size: int


@dataclass
class LevelMeshFile:
    """Top-level result of parsing a BstBaked.meshes file."""

    version: int
    bake_type: int
    global_aabb_min: tuple[float, float, float]
    global_aabb_max: tuple[float, float, float]
    toc_entries: list[TocEntry] = field(default_factory=list)
    lods: list[LevelLodData] = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            f"LevelMesh: LVL version 0x{self.version:02X} (bakeType={self.bake_type})",
            f"  Global AABB: ({self.global_aabb_min[0]:.1f}, {self.global_aabb_min[1]:.1f}, {self.global_aabb_min[2]:.1f})"
            f" -> ({self.global_aabb_max[0]:.1f}, {self.global_aabb_max[1]:.1f}, {self.global_aabb_max[2]:.1f})",
            f"  TOC entries: {len(self.toc_entries)}",
        ]
        for e in self.toc_entries:
            lines.append(f"    {e.name}: offset=0x{e.offset:X}, size={e.compressed_size}")
        for lod in self.lods:
            total_terrain_verts = sum(t.vertex_count for t in lod.terrain_meshes)
            total_terrain_tris = sum(t.index_count // 3 for t in lod.terrain_meshes)
            lines.append(f"  LOD{lod.lod_index}:")
            lines.append(f"    MeshBakes: {len(lod.mesh_bakes)}")
            lines.append(f"    TerrainMeshes: {len(lod.terrain_meshes)} ({total_terrain_verts} verts, {total_terrain_tris} tris)")
            lines.append(f"    Skirts: {len(lod.skirts)}")
            lines.append(f"    Occluder: {'yes' if lod.occluder else 'no'}")
            lines.append(f"    Cloud: {'yes' if lod.cloud else 'no'}")
        return "\n".join(lines)


# --- TGCL types ---


@dataclass
class TgclMemberVar:
    """Member variable descriptor from TGCL class table."""

    name: str
    var_type: int
    size: int
    array_element_type_id: int


@dataclass
class TgclClass:
    """Class descriptor from TGCL class table."""

    name: str
    first_member_var_index: int
    num_member_vars: int
    member_vars: list[TgclMemberVar] = field(default_factory=list)


@dataclass
class TgclObject:
    """A deserialized TGCL object instance."""

    class_index: int
    class_name: str
    instance_name: str
    fields: dict = field(default_factory=dict)


@dataclass
class TgclFile:
    """Top-level result of parsing an Objects.level.bin file."""

    magic: int
    num_classes: int
    num_member_vars: int
    num_objects: int
    num_ptr_fixups: int
    classes: list[TgclClass] = field(default_factory=list)
    objects: list[TgclObject] = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            f"TGCL: {self.num_classes} classes, {self.num_objects} objects, {self.num_ptr_fixups} fixups",
        ]
        class_counts: dict = {}
        for obj in self.objects:
            class_counts[obj.class_name] = class_counts.get(obj.class_name, 0) + 1
        for cname in sorted(class_counts, key=lambda c: -class_counts[c]):
            lines.append(f"  {cname}: {class_counts[cname]}")
        return "\n".join(lines)

    def objects_by_class(self, class_name: str) -> list[TgclObject]:
        return [o for o in self.objects if o.class_name == class_name]
