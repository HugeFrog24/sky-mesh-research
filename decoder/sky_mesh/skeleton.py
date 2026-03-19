"""Skeleton (AnimPackData) parser for Sky's bone hierarchy + animation data.

Parses AnimPackData::LoadFromBuffer: header → per-bone data → rest poses →
optional LZ4-compressed animation block → LoadAnimations.
"""

from sky_mesh.stream import BinaryStream
from sky_mesh.types import (
    SkeletonData,
    BoneData,
    RestPose,
    AnimationClip,
)
from sky_mesh.animation import parse_animations

try:
    import lz4.block
    _HAS_LZ4 = True
except ImportError:
    _HAS_LZ4 = False


def _decompress_lz4(data: bytes, uncompressed_size: int) -> bytes:
    if not _HAS_LZ4:
        raise ImportError(
            "lz4 package required for compressed animation data. "
            "Install with: pip install lz4"
        )
    return lz4.block.decompress(data, uncompressed_size=uncompressed_size)


def parse_animpack(
    stream: BinaryStream,
) -> tuple[SkeletonData, list[AnimationClip]]:
    """Parse the full AnimPackData blob from the stream.

    Returns the skeleton data and a list of animation clips.
    """
    version = stream.read_uint32()

    _pack_header = stream.read_bytes(0x40)
    if not (7 <= version <= 11):
        raise ValueError(
            f"AnimPack version {version} out of range (expected 7–11)"
        )

    bone_count = stream.read_int32()
    anim_count = stream.read_int32()
    frame_rate = stream.read_int32()
    compression_type = stream.read_uint8()

    bone_name_table_bytes = bone_count * 64
    if version >= 10:
        bone_name_table_bytes = stream.read_uint32()

    bones: list[BoneData] = []
    for _ in range(bone_count):
        name = stream.read_string(64)

        if anim_count > 0:
            inv_bind = stream.read_matrix4x4()
        else:
            stream.skip(64)
            inv_bind = None

        raw_parent = stream.read_int32()
        parent_idx = raw_parent - 1  # stored as actual_parent+1; 0 means root (-1)
        bones.append(BoneData(name=name, parent_index=parent_idx, inv_bind_matrix=inv_bind))

    rest_poses: list[RestPose] = []
    if anim_count > 0:
        for _ in range(bone_count):
            scale = stream.read_vec3()
            rotation = stream.read_quat()
            translation = stream.read_vec3()
            rest_poses.append(RestPose(
                scale=scale, rotation=rotation, translation=translation
            ))

    skeleton = SkeletonData(
        bone_count=bone_count,
        animation_count=anim_count,
        frame_rate=frame_rate,
        compression_type=compression_type,
        version=version,
        bones=bones,
        rest_poses=rest_poses,
    )

    clips: list[AnimationClip] = []
    if anim_count > 0:
        if compression_type in (1, 2):
            compressed_size = stream.read_uint32()
            uncompressed_size = 0x300000
            if version >= 9:
                uncompressed_size = stream.read_uint32()

            compressed_data = stream.read_bytes(compressed_size)
            decompressed = _decompress_lz4(compressed_data, uncompressed_size)
            anim_stream = BinaryStream(decompressed)
            clips = parse_animations(
                anim_stream, bone_count, compression_type, version, frame_rate
            )
        else:
            clips = parse_animations(
                stream, bone_count, compression_type, version, frame_rate
            )

    return skeleton, clips
