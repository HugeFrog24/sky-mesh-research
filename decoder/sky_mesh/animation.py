"""Animation keyframe parser for Sky's AnimPackData format.

Handles both compressed (float16) and uncompressed (float32) keyframes,
per-bone keying masks, and the initial/per-frame key split.
"""

from sky_mesh.stream import BinaryStream
from sky_mesh.types import AnimationClip, BoneKeyingInfo


def compute_keyed_indices(mask_data: bytes, bone_count: int) -> BoneKeyingInfo:
    """Decode per-bone keying mask bytes into categorized bone-index lists.

    Each byte is a 6-bit mask:
      bit 3 → initial scale       bit 0 → per-frame scale
      bit 4 → initial rotation    bit 1 → per-frame rotation
      bit 5 → initial translation bit 2 → per-frame translation
    """
    info = BoneKeyingInfo()
    for bone_idx in range(bone_count):
        mask = mask_data[bone_idx]
        if mask & 0x08:
            info.initial_scale_bones.append(bone_idx)
        if mask & 0x01:
            info.per_frame_scale_bones.append(bone_idx)
        if mask & 0x10:
            info.initial_rot_bones.append(bone_idx)
        if mask & 0x02:
            info.per_frame_rot_bones.append(bone_idx)
        if mask & 0x20:
            info.initial_trans_bones.append(bone_idx)
        if mask & 0x04:
            info.per_frame_trans_bones.append(bone_idx)
    return info


def _read_scale_keys(
    stream: BinaryStream, count: int
) -> list[tuple[float, float, float]]:
    """Scale keys are always 3 × float32 = 12 bytes each."""
    return [stream.read_vec3() for _ in range(count)]


def _read_rotation_keys(
    stream: BinaryStream, count: int, compression_type: int
) -> list[tuple[float, float, float, float]]:
    if compression_type == 2:
        return [stream.read_quat_f16() for _ in range(count)]
    else:
        return [stream.read_quat() for _ in range(count)]


def _read_translation_keys(
    stream: BinaryStream,
    count: int,
    compression_type: int,
    compressed_trans: bool,
) -> list[tuple[float, float, float]]:
    if compressed_trans:
        return [stream.read_vec3_f16() for _ in range(count)]
    else:
        return [stream.read_vec3() for _ in range(count)]


def parse_animation_clip(
    stream: BinaryStream,
    bone_count: int,
    compression_type: int,
    version: int,
    frame_rate: int,
    clip_index: int,
) -> AnimationClip:
    """Parse a single AnimationData::ReadAnimation from the stream."""

    start_frame = stream.read_int32()
    end_frame = stream.read_int32()
    flags = stream.read_int32()

    root_motion_start: tuple[float, float, float] | None = None
    root_motion_end: tuple[float, float, float] | None = None
    aabb_min: tuple[float, float, float] | None = None
    aabb_max: tuple[float, float, float] | None = None

    if version >= 9:
        root_motion_start = stream.read_vec3()
        root_motion_end = stream.read_vec3()

    if version >= 11:
        aabb_min = stream.read_vec3()
        aabb_max = stream.read_vec3()

    compressed_trans = compression_type == 2 and (flags & 1) != 0

    mask_data = stream.read_bytes(bone_count)
    keying = compute_keyed_indices(mask_data, bone_count)

    init_scale_count = len(keying.initial_scale_bones)
    init_rot_count = len(keying.initial_rot_bones)
    init_trans_count = len(keying.initial_trans_bones)
    pf_scale_count = len(keying.per_frame_scale_bones)
    pf_rot_count = len(keying.per_frame_rot_bones)
    pf_trans_count = len(keying.per_frame_trans_bones)

    initial_scale = _read_scale_keys(stream, init_scale_count)
    initial_rot = _read_rotation_keys(stream, init_rot_count, compression_type)
    initial_trans = _read_translation_keys(
        stream, init_trans_count, compression_type, compressed_trans
    )

    frame_count = max(0, end_frame - start_frame + 1)
    pf_scales: list[list[tuple[float, float, float]]] = []
    pf_rots: list[list] = []
    pf_trans: list[list[tuple[float, float, float]]] = []

    for _ in range(frame_count):
        pf_scales.append(_read_scale_keys(stream, pf_scale_count))
        pf_rots.append(
            _read_rotation_keys(stream, pf_rot_count, compression_type)
        )
        pf_trans.append(
            _read_translation_keys(
                stream, pf_trans_count, compression_type, compressed_trans
            )
        )

    return AnimationClip(
        name=f"anim_{clip_index:03d}",
        start_frame=start_frame,
        end_frame=end_frame,
        flags=flags,
        frame_rate=frame_rate,
        root_motion_start=root_motion_start,
        root_motion_end=root_motion_end,
        aabb_min=aabb_min,
        aabb_max=aabb_max,
        keying=keying,
        initial_scale_keys=initial_scale,
        initial_rotation_keys=initial_rot,
        initial_translation_keys=initial_trans,
        per_frame_scale_keys=pf_scales,
        per_frame_rotation_keys=pf_rots,
        per_frame_translation_keys=pf_trans,
    )


def parse_animations(
    stream: BinaryStream,
    bone_count: int,
    compression_type: int,
    version: int,
    frame_rate: int,
) -> list[AnimationClip]:
    """Parse the LoadAnimations block (inside the potentially LZ4-compressed
    animation data).

    Layout:
      - Header: animation count + total key counts + keyed index data size
      - Second copy of rest poses (40 bytes/bone, parsed but discarded here)
      - Per-animation ReadAnimation calls
    """
    anim_count = stream.read_uint32()
    _total_scale_keys = stream.read_uint32()
    _total_rot_keys = stream.read_uint32()
    _total_trans_keys = stream.read_uint32()
    if version >= 10:
        _total_comp_trans_keys = stream.read_uint32()
    _keyed_index_size = stream.read_uint32()

    # Skip allocations (we read keys inline, not into pre-allocated pools)

    # Second rest pose copy (40 bytes per bone: Vec3 + Quat + Vec3)
    for _ in range(bone_count):
        stream.read_vec3()   # scale  (12 bytes)
        stream.read_quat()   # rotation (16 bytes)
        stream.read_vec3()   # translation (12 bytes)

    clips: list[AnimationClip] = []
    for i in range(anim_count):
        clip = parse_animation_clip(
            stream, bone_count, compression_type, version, frame_rate, i
        )
        clips.append(clip)

    return clips
