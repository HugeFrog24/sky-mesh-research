"""
Sky: Children of the Light — mesh and level decoder.

Parses the proprietary binary formats used by Sky's engine
(bootloader version 0.11.0). Supports:
  - .mesh files: geometry, skeleton, bone weights, animation
  - BstBaked.meshes: level terrain, baked lighting, clouds
  - Objects.level.bin: level scene graph (TGCL)

Usage:
    from sky_mesh import parse_mesh_file, parse_level_meshes, parse_tgcl
    mesh = parse_mesh_file("path/to/model.mesh")
    level = parse_level_meshes("path/to/BstBaked.meshes")
    scene = parse_tgcl("path/to/Objects.level.bin")
"""

from sky_mesh.mesh import parse_mesh_file
from sky_mesh.types import SkyMeshFile, MeshLodData, BoneData, RestPose, AnimationClip
from sky_mesh.texture import TextureResolver
from sky_mesh.level import parse_level_meshes
from sky_mesh.tgcl import parse_tgcl
from sky_mesh.level_types import LevelMeshFile, LevelLodData, TerrainMeshData, TgclFile

__all__ = [
    "parse_mesh_file",
    "parse_level_meshes",
    "parse_tgcl",
    "SkyMeshFile",
    "MeshLodData",
    "BoneData",
    "RestPose",
    "AnimationClip",
    "TextureResolver",
    "LevelMeshFile",
    "LevelLodData",
    "TerrainMeshData",
    "TgclFile",
]
