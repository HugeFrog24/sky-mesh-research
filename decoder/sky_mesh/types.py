"""Data classes for decoded Sky mesh data."""

from dataclasses import dataclass, field


@dataclass
class MeshLodData:
    """Decoded geometry for a single Level-of-Detail."""

    switch_distance: float
    aabb_min: tuple[float, float, float]
    aabb_max: tuple[float, float, float]
    skinned_aabb_min: tuple[float, float, float]
    skinned_aabb_max: tuple[float, float, float]
    uv_bounds_min: list[float] | None = None
    uv_bounds_max: list[float] | None = None

    vertex_count: int = 0
    index_count: int = 0
    index_format: int = 1
    morph_target_count: int = 0
    edge_count: int = 0
    adjacency_count: int = 0
    bone_weight_count: int = 0
    extra_index_count: int = 0
    has_normals: bool = True
    has_secondary_indices: bool = True
    bone_influence_partition: tuple[int, int, int, int] = (0, 0, 0, 0)
    compressed_pos_count: int = 0
    compressed_uv_count: int = 0

    positions: list[tuple[float, float, float]] = field(default_factory=list)
    normals: list[tuple[float, float, float]] | None = None
    uvs: list[tuple[float, float, float, float]] = field(default_factory=list)
    bone_weights: list[dict] | None = None
    indices: list[int] = field(default_factory=list)


@dataclass
class BoneData:
    """A single bone in the skeleton hierarchy."""

    name: str
    parent_index: int
    inv_bind_matrix: list[float] | None = None


@dataclass
class RestPose:
    """Scale-Quaternion-Translation rest pose for one bone."""

    scale: tuple[float, float, float]
    rotation: tuple[float, float, float, float]
    translation: tuple[float, float, float]


@dataclass
class BoneKeyingInfo:
    """Per-bone keying mask decoded into bone-index arrays."""

    initial_scale_bones: list[int] = field(default_factory=list)
    per_frame_scale_bones: list[int] = field(default_factory=list)
    initial_rot_bones: list[int] = field(default_factory=list)
    per_frame_rot_bones: list[int] = field(default_factory=list)
    initial_trans_bones: list[int] = field(default_factory=list)
    per_frame_trans_bones: list[int] = field(default_factory=list)


@dataclass
class AnimationClip:
    """A decoded animation clip with per-bone keyframe data."""

    name: str
    start_frame: int
    end_frame: int
    flags: int
    frame_rate: int

    root_motion_start: tuple[float, float, float] | None = None
    root_motion_end: tuple[float, float, float] | None = None
    aabb_min: tuple[float, float, float] | None = None
    aabb_max: tuple[float, float, float] | None = None

    keying: BoneKeyingInfo | None = None

    initial_scale_keys: list[tuple[float, float, float]] = field(default_factory=list)
    initial_rotation_keys: list = field(default_factory=list)
    initial_translation_keys: list[tuple[float, float, float]] = field(default_factory=list)

    per_frame_scale_keys: list[list[tuple[float, float, float]]] = field(
        default_factory=list
    )
    per_frame_rotation_keys: list[list] = field(default_factory=list)
    per_frame_translation_keys: list[list[tuple[float, float, float]]] = field(
        default_factory=list
    )


@dataclass
class SkeletonData:
    """Complete skeleton with bone hierarchy and rest pose."""

    bone_count: int
    animation_count: int
    frame_rate: int
    compression_type: int
    version: int
    bones: list[BoneData] = field(default_factory=list)
    rest_poses: list[RestPose] = field(default_factory=list)


@dataclass
class OcclusionData:
    """Baked ambient occlusion mesh data."""

    tri_count: int
    vert_count: int
    indices: list[int] = field(default_factory=list)
    values: list[float] = field(default_factory=list)


@dataclass
class SkyMeshFile:
    """Top-level result of parsing a .mesh file."""

    name: str
    version: int
    has_animation: bool
    has_occlusion: bool
    lods: list[MeshLodData] = field(default_factory=list)
    skeleton: SkeletonData | None = None
    animations: list[AnimationClip] = field(default_factory=list)
    occlusion: OcclusionData | None = None

    @property
    def lod0(self) -> MeshLodData | None:
        return self.lods[0] if self.lods else None

    def summary(self) -> str:
        lines = [
            f"SkyMesh: {self.name!r} (v0x{self.version:02X})",
            f"  LODs: {len(self.lods)}",
        ]
        for i, lod in enumerate(self.lods):
            lines.append(
                f"    LOD{i}: {lod.vertex_count} verts, "
                f"{lod.index_count // 3} tris"
            )
        if self.skeleton:
            s = self.skeleton
            lines.append(f"  Skeleton: {s.bone_count} bones, {s.animation_count} anims")
        if self.animations:
            lines.append(f"  Animations: {len(self.animations)} clips")
            for clip in self.animations:
                frames = clip.end_frame - clip.start_frame + 1
                lines.append(f"    {clip.name}: frames {clip.start_frame}-{clip.end_frame} ({frames}f)")
        return "\n".join(lines)


@dataclass
class ImageRegion:
    """A sub-rectangle within a texture atlas."""

    name: str
    image: str
    uv: tuple[float, float, float, float]


@dataclass
class OutfitTexture:
    """Texture binding for an outfit piece."""

    attribute: str
    diffuse: str


@dataclass
class OutfitDef:
    """Parsed entry from OutfitDefs.json."""

    name: str
    type: str
    mesh: list[str]
    shader: str
    textures: list[OutfitTexture]
    mask: list[str]
    pattern: list[str]
    norm: str
    color_hsv: tuple[float, float, float]
    tint_hsv: tuple[float, float, float]
    pattern_hsv: tuple[float, float, float]
