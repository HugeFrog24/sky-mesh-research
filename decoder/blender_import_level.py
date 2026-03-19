"""Blender import addon for Sky: Children of the Light level maps.

Imports a complete level from BstBaked.meshes + Objects.level.bin:
  - Terrain meshes with vertex colors and normals
  - Skirt (terrain edge) geometry
  - Occluder mesh (wireframe, hidden by default)
  - Placed objects (LevelMesh / Beamo) resolved from .mesh files
  - Baked lighting from MeshBake entries as vertex color layers

Install:
  1. Copy the `sky_mesh/` package into Blender's Python site-packages,
     OR add the decoder/ directory to sys.path before importing.
  2. Run from Blender scripting workspace, OR install as addon.

Usage as addon:
  File -> Import -> Sky Level Map

Usage as script:
  Set LEVEL_DIR and DATA_DIR below, then run in Blender.
"""

from __future__ import annotations

import colorsys
import math
import os
import sys
import traceback

_this_dir = os.path.dirname(os.path.abspath(__file__))
if _this_dir not in sys.path:
    sys.path.insert(0, _this_dir)

import bpy
from bpy.props import StringProperty, BoolProperty, EnumProperty
from bpy_extras.io_utils import ImportHelper
from mathutils import Matrix

from sky_mesh.level import parse_level_meshes
from sky_mesh.level_types import (
    LevelMeshFile, LevelLodData, MeshBakeEntry, LightVertexData,
    TerrainMeshData, TerrainVertex, SkirtMeshData, SkirtVertex,
    OccluderMeshData,
)
from sky_mesh.tgcl import parse_tgcl
from sky_mesh.level_types import TgclFile, TgclObject
from sky_mesh.mesh import parse_mesh_file

bl_info = {
    "name": "Sky Level Importer",
    "author": "Userlib-SML",
    "version": (1, 0, 0),
    "blender": (3, 0, 0),
    "location": "File > Import > Sky Level Map",
    "description": "Import Sky: Children of the Light level maps",
    "category": "Import-Export",
}

MATERIAL_ENUM_NAMES = {
    0x01: "RockFace",
    0x02: "Wall2", 0x03: "Wall3", 0x04: "Wall4",
    0x10: "Cliff",
    0x11: "Soil", 0x12: "SoilVar", 0x13: "WallBrick",
    0x14: "Wall", 0x15: "Gold", 0x16: "Glacier",
    0x17: "TileCeiling", 0x18: "TileFloor", 0x19: "WallTile",
    0x1a: "WallBrick2", 0x1b: "WetSoil", 0x1c: "CliffWet",
    0x1d: "WallLight", 0x1e: "Wood", 0x1f: "WallCopy",
    0x20: "Sand",
    0x21: "SandRain", 0x22: "Snow", 0x23: "SandBright",
    0x24: "SandAlt", 0x25: "CliffWetCopy",
    0x30: "Grass",
    0x31: "GrassRain", 0x32: "GrassDark", 0x33: "GrassAlt",
    0x34: "WallCopy2",
    0x50: "Cloud",
}


def _hsv_rad_to_rgb(h_rad: float, s: float, v: float) -> tuple[float, float, float]:
    """Convert HSV (hue in radians, saturation 0-1, value 0-1) to RGB 0-1."""
    h_norm = ((h_rad * 180.0 / math.pi) % 360.0) / 360.0
    return colorsys.hsv_to_rgb(h_norm, s, v)


# Base colors from MaterialDefBarn::RegisterDefs (default, no per-level overrides).
# HSV values use radians for hue, extracted from the 0.11.0 decompile.
MATERIAL_BASE_RGB: dict[int, tuple[float, float, float]] = {
    0x01: _hsv_rad_to_rgb(5.759587, 1.0, 1.0),
    0x10: _hsv_rad_to_rgb(3.036873, 0.25, 0.16),
    0x11: _hsv_rad_to_rgb(3.3335788, 0.24, 0.01),
    0x12: _hsv_rad_to_rgb(3.3335788, 0.24, 0.35),
    0x13: _hsv_rad_to_rgb(0.6108653, 0.0, 0.25),
    0x14: _hsv_rad_to_rgb(0.6108653, 0.0, 0.7),
    0x15: _hsv_rad_to_rgb(0.6108653, 1.0, 0.7),
    0x16: _hsv_rad_to_rgb(3.2288592, 0.225, 0.65),
    0x17: _hsv_rad_to_rgb(3.1415927, 0.0, 0.5),
    0x18: _hsv_rad_to_rgb(3.036873, 0.25, 0.12),
    0x19: _hsv_rad_to_rgb(3.1415927, 0.0, 0.5),
    0x1a: _hsv_rad_to_rgb(3.036873, 0.25, 0.16),
    0x1c: _hsv_rad_to_rgb(3.1415927, 0.42, 0.1),
    0x1d: _hsv_rad_to_rgb(0.6108653, 0.0, 0.7),
    0x1e: _hsv_rad_to_rgb(0.6108653, 0.0, 0.4),
    0x20: _hsv_rad_to_rgb(2.9670596, 0.05, 0.4),
    0x21: _hsv_rad_to_rgb(0.5235988, 0.05, 0.2),
    0x22: _hsv_rad_to_rgb(0.5235988, 0.05, 0.65),
    0x23: _hsv_rad_to_rgb(0.5235988, 0.0, 0.75),
    0x24: _hsv_rad_to_rgb(2.9670596, 0.03, 0.4),
    0x30: _hsv_rad_to_rgb(1.6231562, 0.4, 0.25),
    0x31: _hsv_rad_to_rgb(1.7453293, 0.3, 0.25),
    0x32: _hsv_rad_to_rgb(1.5707964, 0.4, 0.37),
    0x33: _hsv_rad_to_rgb(1.6231562, 0.4, 0.25),
    0x50: _hsv_rad_to_rgb(2.3561945, 0.0, 0.7),
}

# Fallback for enums that copy another without changing color
for _src, _dst in [(0x14, 0x02), (0x14, 0x03), (0x14, 0x04),
                    (0x14, 0x1f), (0x1c, 0x25), (0x14, 0x34),
                    (0x11, 0x1b)]:
    MATERIAL_BASE_RGB.setdefault(_dst, MATERIAL_BASE_RGB.get(_src, (0.5, 0.5, 0.5)))

DEFAULT_BASE_RGB = MATERIAL_BASE_RGB[0x20]  # Sand as fallback

# Default environment colors — used by the vertex shader to tint baked light.
# Decompiled from GrassSh.vulkan.vs.spv:
#   v_light0.rgb = RGBD_decode(a_light0) * mix(u_averageSkyColor, u_sunColor, AO)
# These are sensible defaults; actual values vary per level via EnvNode.
DEFAULT_SUN_COLOR = (1.1, 0.95, 0.75)
DEFAULT_SKY_COLOR = (0.45, 0.55, 0.75)

# u_matUvScale from MaterialDefBarn::RegisterDefs (confirmed via 0.11.0 decompile).
MATERIAL_UV_SCALE: dict[int, float] = {
    0x01: 1.0,   # RockFace
    0x10: 0.25,  # Cliff
    0x11: 0.25,  # Soil (inherits Cliff)
    0x1c: 0.25,  # CliffWet
    0x20: 0.25,  # Sand
    0x21: 0.25,  # SandRain
    0x22: 0.25,  # Snow
    0x23: 0.25,  # SandBright
    0x24: 0.25,  # SandAlt
    0x30: 1.0,   # Grass
    0x31: 1.0,   # GrassRain
    0x32: 1.0,   # GrassDark
    0x33: 1.0,   # GrassAlt
    0x50: 1.0,   # Cloud
}

# Shader type per material enum (from RegisterDefs +0x00).
MATERIAL_SHADER: dict[int, str] = {
    0x01: "RockFaceSh",
    0x10: "RockFaceSh", 0x11: "RockFaceSh", 0x12: "RockFaceSh",
    0x13: "RockFaceSh", 0x14: "RockFaceSh", 0x15: "RockFaceSh",
    0x16: "RockFaceSh", 0x17: "RockFaceSh", 0x18: "RockFaceSh",
    0x19: "RockFaceSh", 0x1a: "RockFaceSh", 0x1c: "RockFaceSh",
    0x1d: "RockFaceSh", 0x1e: "RockFaceSh", 0x1f: "RockFaceSh",
    0x20: "SandSh", 0x21: "SandSh", 0x22: "SandSh",
    0x23: "SandSh", 0x24: "SandSh",
    0x30: "GrassSh", 0x31: "GrassSh", 0x32: "GrassSh",
    0x33: "GrassSh", 0x34: "GrassSh",
    0x50: "CloudSh",
}

# Texture KTX names per material enum (from RegisterDefs, offset-corrected).
# {enum: {uniform_name: ktx_basename}}
MATERIAL_TEXTURES: dict[int, dict[str, str]] = {
    0x01: {"u_topGeoTexture": "RockHeightCliffSh", "u_sideGeoTexture": "RockHeightCliffSh"},
    0x10: {"u_topGeoTexture": "CliffSh", "u_sideGeoTexture": "CliffSh"},
    0x1c: {"u_topGeoTexture": "CliffWetSh", "u_sideGeoTexture": "CliffWetSh"},
    0x20: {"u_normalTex": "Noise3Ch"},
    0x30: {"u_grassNorm1Tex": "GrassNorTex0", "u_grassNorm2Tex": "GrassNorTex1",
           "u_grassMaskTex": "GrassMask"},
}


def _get_material_rgb(material_enum: int) -> tuple[float, float, float]:
    """Look up material base color RGB from the RegisterDefs table."""
    return MATERIAL_BASE_RGB.get(material_enum, DEFAULT_BASE_RGB)


_active_sun_color = DEFAULT_SUN_COLOR
_active_sky_color = DEFAULT_SKY_COLOR


def _decode_baked_light(
    color: tuple[int, int, int, int],
    uv0: tuple[float, float, float, float],
) -> tuple[float, float, float]:
    """Decode RGBD baked light with sky/sun tinting (vertex shader pipeline).

    Returns linear HDR light color — multiply with matColor for final result.
    Uses per-level sun/sky colors when available from TGCL SetEnvDefault.
    """
    r, g, b, d = color
    r_n = r / 255.0
    g_n = g / 255.0
    b_n = b / 255.0
    d_n = max(d, 1) / 255.0
    d_inv = 1.0 / d_n

    hdr_r = r_n * r_n * d_inv
    hdr_g = g_n * g_n * d_inv
    hdr_b = b_n * b_n * d_inv

    ao = uv0[0]
    inv_ao = 1.0 - ao
    sun = _active_sun_color
    sky = _active_sky_color
    tint_r = sky[0] * inv_ao + sun[0] * ao
    tint_g = sky[1] * inv_ao + sun[1] * ao
    tint_b = sky[2] * inv_ao + sun[2] * ao

    return (hdr_r * tint_r, hdr_g * tint_g, hdr_b * tint_b)


def _decode_terrain_final_color(
    color: tuple[int, int, int, int],
    uv0: tuple[float, float, float, float],
    base_rgb: tuple[float, float, float],
) -> tuple[float, float, float]:
    """Compute final terrain vertex color = matColor × bakedLight."""
    lr, lg, lb = _decode_baked_light(color, uv0)
    return (base_rgb[0] * lr, base_rgb[1] * lg, base_rgb[2] * lb)


def _apply_env_colors(env: dict | None) -> None:
    """Set the active sun/sky colors from TGCL environment data.

    The raw TGCL sunColor values are very small for twilight levels (CandleSpace: ~0.004-0.058).
    The game's Ambience::Update multiplies by sunInt and atmospheric tinting.
    We approximate this: use raw values × sunInt, but apply a minimum brightness floor
    so the vertex colors remain visible in Blender without full tonemapping.
    """
    global _active_sun_color, _active_sky_color

    if env is None:
        _active_sun_color = DEFAULT_SUN_COLOR
        _active_sky_color = DEFAULT_SKY_COLOR
        return

    sc = env["sunColor"]
    si = env["sunInt"]

    # Scale by sunInt, then normalize so the brightest channel reaches
    # a reasonable range (~0.5-1.5) for Blender display.
    raw = (sc[0] * si, sc[1] * si, sc[2] * si)
    peak = max(raw[0], raw[1], raw[2], 0.001)
    scale = 0.9 / peak

    _active_sun_color = (raw[0] * scale, raw[1] * scale, raw[2] * scale)

    # averageSkyColor: use the approximate hemispherical average from tint gradient
    sky = env.get("averageSkyColor", (0.001, 0.002, 0.003))
    sky_peak = max(sky[0], sky[1], sky[2], 0.0001)
    sky_scale = 0.5 / sky_peak
    _active_sky_color = (sky[0] * sky_scale, sky[1] * sky_scale, sky[2] * sky_scale)


# Legacy lookup for placed objects (flat color without RGBD)
MATERIAL_COLORS: dict[str, tuple[float, float, float, float]] = {}
for _enum, _name in MATERIAL_ENUM_NAMES.items():
    _rgb = MATERIAL_BASE_RGB.get(_enum, (0.5, 0.5, 0.5))
    MATERIAL_COLORS[_name] = (_rgb[0], _rgb[1], _rgb[2], 1.0)


def _get_or_create_collection(parent: bpy.types.Collection, name: str) -> bpy.types.Collection:
    for child in parent.children:
        if child.name == name:
            return child
    coll = bpy.data.collections.new(name)
    parent.children.link(coll)
    return coll


def _tgcl_transform_to_matrix(flat16: list[float]) -> Matrix:
    """Convert a flat 16-float column-major transform to Blender Matrix."""
    return Matrix((
        (flat16[0], flat16[4], flat16[8],  flat16[12]),
        (flat16[1], flat16[5], flat16[9],  flat16[13]),
        (flat16[2], flat16[6], flat16[10], flat16[14]),
        (flat16[3], flat16[7], flat16[11], flat16[15]),
    ))


def _get_material(name: str, color: tuple[float, ...]) -> bpy.types.Material:
    """Get or create a simple material with a base color."""
    mat_name = f"Sky_{name}"
    mat = bpy.data.materials.get(mat_name)
    if mat:
        return mat
    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        bsdf.inputs["Roughness"].default_value = 0.8
    return mat


def _make_vertex_color_material(
    mat_name: str,
    layer_name: str,
    roughness: float,
    use_emission: bool = False,
) -> bpy.types.Material:
    """Create a material driven by a named vertex color / color attribute layer.

    If use_emission is True, vertex colors are routed to an Emission shader so
    that Blender's viewport lighting doesn't add a second light pass on top of
    the already-baked terrain colors.
    """
    mat = bpy.data.materials.get(mat_name)
    if mat:
        return mat
    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    tree = mat.node_tree
    for node in list(tree.nodes):
        tree.nodes.remove(node)

    out = tree.nodes.new("ShaderNodeOutputMaterial")
    out.location = (400, 0)

    attr = tree.nodes.new("ShaderNodeAttribute")
    attr.location = (-400, 0)
    attr.attribute_name = layer_name
    try:
        attr.attribute_type = 'GEOMETRY'
    except Exception:
        pass

    if use_emission:
        emit = tree.nodes.new("ShaderNodeEmission")
        emit.location = (0, 0)
        emit.inputs["Strength"].default_value = 1.0
        tree.links.new(attr.outputs["Color"], emit.inputs["Color"])
        tree.links.new(emit.outputs["Emission"], out.inputs["Surface"])
    else:
        bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
        bsdf.location = (0, 0)
        try:
            bsdf.inputs["Roughness"].default_value = roughness
        except Exception:
            pass
        tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
        tree.links.new(attr.outputs["Color"], bsdf.inputs["Base Color"])

    return mat


def _get_terrain_material() -> bpy.types.Material:
    """Terrain material: reads pre-computed FinalColor vertex attribute.

    Uses Emission shader so Blender's viewport lighting doesn't double-light
    the already-baked terrain colors.
    """
    return _make_vertex_color_material("Sky_Terrain_Baked", "FinalColor", 0.85, use_emission=True)


def _get_baked_light_material() -> bpy.types.Material:
    return _make_vertex_color_material("Sky_BakedLight_VertexColor", "BakedLight", 0.7)


def _find_texture_png(tex_name: str) -> str | None:
    """Find an extracted terrain texture PNG in scratchpad/textures/."""
    candidates = [
        os.path.join(_this_dir, "..", "textures", tex_name + ".png"),
        os.path.join(_this_dir, "textures", tex_name + ".png"),
    ]
    for c in candidates:
        if os.path.isfile(c):
            return os.path.abspath(c)
    return None


def _get_or_load_image(tex_name: str) -> bpy.types.Image | None:
    """Get or load a terrain texture as a Blender image datablock."""
    bl_name = f"Sky_{tex_name}"
    img = bpy.data.images.get(bl_name)
    if img:
        return img
    path = _find_texture_png(tex_name)
    if not path:
        return None
    img = bpy.data.images.load(path)
    img.name = bl_name
    img.colorspace_settings.name = 'Non-Color'
    return img


def _add_emission_from_vertex_color(tree, bsdf, layer_name: str):
    """Wire a vertex color attribute as emission into a Principled BSDF.

    Returns the ShaderNodeAttribute so callers can rewire if needed.
    """
    attr = tree.nodes.new("ShaderNodeAttribute")
    attr.location = (200, -300)
    attr.attribute_name = layer_name
    try:
        attr.attribute_type = 'GEOMETRY'
    except Exception:
        pass
    tree.links.new(attr.outputs["Color"], bsdf.inputs["Emission Color"])
    bsdf.inputs["Emission Strength"].default_value = 1.0
    return attr


def _add_matcolor_base(tree, bsdf) -> None:
    """Wire MatColor vertex attribute into Principled BSDF Base Color."""
    attr = tree.nodes.new("ShaderNodeAttribute")
    attr.location = (200, -500)
    attr.attribute_name = "MatColor"
    try:
        attr.attribute_type = 'GEOMETRY'
    except Exception:
        pass
    tree.links.new(attr.outputs["Color"], bsdf.inputs["Base Color"])


def _build_triplanar_rockface_material(
    mat_name: str, top_tex_name: str, side_tex_name: str, uv_scale: float,
) -> bpy.types.Material:
    """Build a RockFaceSh-style material with tri-planar texture mapping.

    Node tree matches decompiled RockFaceSh.vulkan.vs/fs.spv:
      UV = worldPos * u_matUvScale
      weights = abs(normal)^4, normalized
      texColor = topTex(zy) * wX + sideTex(xz) * wY + topTex(xy) * wZ
    """
    mat = bpy.data.materials.get(mat_name)
    if mat:
        return mat
    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    tree = mat.node_tree
    for n in list(tree.nodes):
        tree.nodes.remove(n)

    out = tree.nodes.new("ShaderNodeOutputMaterial")
    out.location = (1200, 0)
    bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (800, 0)
    tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    attr_fc = _add_emission_from_vertex_color(tree, bsdf, "FinalColor")
    _add_matcolor_base(tree, bsdf)

    geom = tree.nodes.new("ShaderNodeNewGeometry")
    geom.location = (-1200, 300)
    scale_node = tree.nodes.new("ShaderNodeVectorMath")
    scale_node.location = (-900, 300)
    scale_node.operation = 'SCALE'
    scale_node.inputs["Scale"].default_value = uv_scale
    tree.links.new(geom.outputs["Position"], scale_node.inputs[0])

    sep = tree.nodes.new("ShaderNodeSeparateXYZ")
    sep.location = (-700, 300)
    tree.links.new(scale_node.outputs["Vector"], sep.inputs[0])

    uv_zy = tree.nodes.new("ShaderNodeCombineXYZ")
    uv_zy.location = (-500, 400)
    tree.links.new(sep.outputs["Z"], uv_zy.inputs["X"])
    tree.links.new(sep.outputs["Y"], uv_zy.inputs["Y"])

    uv_xz = tree.nodes.new("ShaderNodeCombineXYZ")
    uv_xz.location = (-500, 200)
    tree.links.new(sep.outputs["X"], uv_xz.inputs["X"])
    tree.links.new(sep.outputs["Z"], uv_xz.inputs["Y"])

    uv_xy = tree.nodes.new("ShaderNodeCombineXYZ")
    uv_xy.location = (-500, 0)
    tree.links.new(sep.outputs["X"], uv_xy.inputs["X"])
    tree.links.new(sep.outputs["Y"], uv_xy.inputs["Y"])

    top_img = _get_or_load_image(top_tex_name)
    side_img = _get_or_load_image(side_tex_name)

    if top_img and side_img:
        tex_zy = tree.nodes.new("ShaderNodeTexImage")
        tex_zy.location = (-200, 500)
        tex_zy.image = top_img
        tex_zy.extension = 'REPEAT'
        tree.links.new(uv_zy.outputs["Vector"], tex_zy.inputs["Vector"])

        tex_xz = tree.nodes.new("ShaderNodeTexImage")
        tex_xz.location = (-200, 200)
        tex_xz.image = side_img
        tex_xz.extension = 'REPEAT'
        tree.links.new(uv_xz.outputs["Vector"], tex_xz.inputs["Vector"])

        tex_xy = tree.nodes.new("ShaderNodeTexImage")
        tex_xy.location = (-200, -100)
        tex_xy.image = top_img
        tex_xy.extension = 'REPEAT'
        tree.links.new(uv_xy.outputs["Vector"], tex_xy.inputs["Vector"])

        # Blend weight from normal Y: abs(ny)^4
        sep_n = tree.nodes.new("ShaderNodeSeparateXYZ")
        sep_n.location = (-900, -100)
        tree.links.new(geom.outputs["Normal"], sep_n.inputs[0])

        abs_ny = tree.nodes.new("ShaderNodeMath")
        abs_ny.location = (-700, -100)
        abs_ny.operation = 'ABSOLUTE'
        tree.links.new(sep_n.outputs["Y"], abs_ny.inputs[0])

        pow_ny = tree.nodes.new("ShaderNodeMath")
        pow_ny.location = (-500, -100)
        pow_ny.operation = 'POWER'
        pow_ny.inputs[1].default_value = 4.0
        tree.links.new(abs_ny.outputs["Value"], pow_ny.inputs[0])

        mix_tri = tree.nodes.new("ShaderNodeMixRGB")
        mix_tri.location = (200, 300)
        mix_tri.blend_type = 'MIX'
        tree.links.new(pow_ny.outputs["Value"], mix_tri.inputs["Fac"])
        tree.links.new(tex_xz.outputs["Color"], mix_tri.inputs["Color1"])
        tree.links.new(tex_zy.outputs["Color"], mix_tri.inputs["Color2"])

        nmap = tree.nodes.new("ShaderNodeNormalMap")
        nmap.location = (400, 300)
        tree.links.new(mix_tri.outputs["Color"], nmap.inputs["Color"])
        tree.links.new(nmap.outputs["Normal"], bsdf.inputs["Normal"])

        # tex.z = AO/cavity (confirmed from RockFaceSh.fs decompile).
        # Modulates diffuse light intensity in the game shader.
        sep_tri = tree.nodes.new("ShaderNodeSeparateColor")
        sep_tri.location = (400, 100)
        tree.links.new(mix_tri.outputs["Color"], sep_tri.inputs["Color"])

        # Multiply FinalColor emission by cavity AO for crevice darkening
        ao_mul = tree.nodes.new("ShaderNodeMixRGB")
        ao_mul.location = (600, -300)
        ao_mul.blend_type = 'MULTIPLY'
        ao_mul.inputs["Fac"].default_value = 1.0
        tree.links.new(attr_fc.outputs["Color"], ao_mul.inputs["Color1"])

        # Build a grey value from .z channel for the multiply
        ao_combine = tree.nodes.new("ShaderNodeCombineColor")
        ao_combine.location = (500, 50)
        tree.links.new(sep_tri.outputs["Blue"], ao_combine.inputs["Red"])
        tree.links.new(sep_tri.outputs["Blue"], ao_combine.inputs["Green"])
        tree.links.new(sep_tri.outputs["Blue"], ao_combine.inputs["Blue"])
        tree.links.new(ao_combine.outputs["Color"], ao_mul.inputs["Color2"])

        # Rewire emission to use AO-modulated color
        tree.links.new(ao_mul.outputs["Color"], bsdf.inputs["Emission Color"])

        # tex.w = roughness (from RockFaceSh.fs decompile)
        mix_rough_tri = tree.nodes.new("ShaderNodeMixRGB")
        mix_rough_tri.location = (200, -50)
        mix_rough_tri.blend_type = 'MIX'
        tree.links.new(pow_ny.outputs["Value"], mix_rough_tri.inputs["Fac"])
        tree.links.new(tex_xz.outputs["Alpha"], mix_rough_tri.inputs["Color1"])
        tree.links.new(tex_zy.outputs["Alpha"], mix_rough_tri.inputs["Color2"])

        sep_rough = tree.nodes.new("ShaderNodeSeparateColor")
        sep_rough.location = (400, -50)
        tree.links.new(mix_rough_tri.outputs["Color"], sep_rough.inputs["Color"])
        tree.links.new(sep_rough.outputs["Red"], bsdf.inputs["Roughness"])
    else:
        bsdf.inputs["Roughness"].default_value = 0.85

    return mat


def _build_grass_material(mat_name: str, uv_scale: float) -> bpy.types.Material:
    """Build a GrassSh-style material. UV = worldPos.xz * matUvScale.

    From GrassSh.fs.glsl decompile:
      - Subsurface translucency: 3.0 * exp2((4*roughness - 10) * NdotV)
        Creates rim-lit grass glow when viewed against the light.
      - Roughness = 0.9 (from u_matRoughness uniform)
    """
    mat = bpy.data.materials.get(mat_name)
    if mat:
        return mat
    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    tree = mat.node_tree
    for n in list(tree.nodes):
        tree.nodes.remove(n)

    out = tree.nodes.new("ShaderNodeOutputMaterial")
    out.location = (1000, 0)
    bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (600, 0)
    bsdf.inputs["Roughness"].default_value = 0.9
    tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    # Subsurface scattering for grass translucency (from decompiled shader)
    try:
        bsdf.inputs["Subsurface Weight"].default_value = 0.4
        bsdf.inputs["Subsurface Radius"].default_value = (0.3, 0.5, 0.1)
        bsdf.inputs["Subsurface Scale"].default_value = 0.05
    except Exception:
        pass

    _add_emission_from_vertex_color(tree, bsdf, "FinalColor")
    _add_matcolor_base(tree, bsdf)

    geom = tree.nodes.new("ShaderNodeNewGeometry")
    geom.location = (-800, 200)
    sep = tree.nodes.new("ShaderNodeSeparateXYZ")
    sep.location = (-600, 200)
    tree.links.new(geom.outputs["Position"], sep.inputs[0])

    uv_xz = tree.nodes.new("ShaderNodeCombineXYZ")
    uv_xz.location = (-400, 200)
    tree.links.new(sep.outputs["X"], uv_xz.inputs["X"])
    tree.links.new(sep.outputs["Z"], uv_xz.inputs["Y"])

    scale_node = tree.nodes.new("ShaderNodeVectorMath")
    scale_node.location = (-200, 200)
    scale_node.operation = 'SCALE'
    scale_node.inputs["Scale"].default_value = uv_scale
    tree.links.new(uv_xz.outputs["Vector"], scale_node.inputs[0])

    mask_img = _get_or_load_image("GrassMask")
    norm0_img = _get_or_load_image("GrassNorTex0")
    norm1_img = _get_or_load_image("GrassNorTex1")

    if mask_img:
        tex_mask = tree.nodes.new("ShaderNodeTexImage")
        tex_mask.location = (0, 200)
        tex_mask.image = mask_img
        tex_mask.extension = 'REPEAT'
        tree.links.new(scale_node.outputs["Vector"], tex_mask.inputs["Vector"])

        sep_mask = tree.nodes.new("ShaderNodeSeparateColor")
        sep_mask.location = (200, 400)
        tree.links.new(tex_mask.outputs["Color"], sep_mask.inputs["Color"])
        try:
            tree.links.new(sep_mask.outputs["Blue"], bsdf.inputs["Subsurface Weight"])
        except Exception:
            pass

    # Coarse normal from GrassNorTex0 at 0.25× scale (from shader: uv * 0.25)
    if norm0_img:
        coarse_scale = tree.nodes.new("ShaderNodeVectorMath")
        coarse_scale.location = (-200, -100)
        coarse_scale.operation = 'SCALE'
        coarse_scale.inputs["Scale"].default_value = 0.25
        tree.links.new(uv_xz.outputs["Vector"], coarse_scale.inputs[0])

        tex_norm0 = tree.nodes.new("ShaderNodeTexImage")
        tex_norm0.location = (0, -100)
        tex_norm0.image = norm0_img
        tex_norm0.extension = 'REPEAT'
        tree.links.new(coarse_scale.outputs["Vector"], tex_norm0.inputs["Vector"])

    # Detail normal from GrassNorTex1 at medium scale (shader: uv * (0.5, 0.25))
    if norm1_img:
        detail_uv = tree.nodes.new("ShaderNodeVectorMath")
        detail_uv.location = (-200, -400)
        detail_uv.operation = 'SCALE'
        detail_uv.inputs["Scale"].default_value = uv_scale * 0.5
        tree.links.new(uv_xz.outputs["Vector"], detail_uv.inputs[0])

        tex_norm1 = tree.nodes.new("ShaderNodeTexImage")
        tex_norm1.location = (0, -400)
        tex_norm1.image = norm1_img
        tex_norm1.extension = 'REPEAT'
        tree.links.new(detail_uv.outputs["Vector"], tex_norm1.inputs["Vector"])

    # Blend normals: mix detail into coarse, weighted by density mask
    if norm0_img and norm1_img and mask_img:
        mix_norms = tree.nodes.new("ShaderNodeMixRGB")
        mix_norms.location = (200, -200)
        mix_norms.blend_type = 'MIX'
        tree.links.new(sep_mask.outputs["Blue"], mix_norms.inputs["Fac"])
        tree.links.new(tex_norm0.outputs["Color"], mix_norms.inputs["Color1"])
        tree.links.new(tex_norm1.outputs["Color"], mix_norms.inputs["Color2"])

        nmap = tree.nodes.new("ShaderNodeNormalMap")
        nmap.location = (400, -200)
        nmap.inputs["Strength"].default_value = 0.5
        tree.links.new(mix_norms.outputs["Color"], nmap.inputs["Color"])
        tree.links.new(nmap.outputs["Normal"], bsdf.inputs["Normal"])
    elif norm1_img:
        nmap = tree.nodes.new("ShaderNodeNormalMap")
        nmap.location = (400, -200)
        nmap.inputs["Strength"].default_value = 0.4
        tree.links.new(tex_norm1.outputs["Color"], nmap.inputs["Color"])
        tree.links.new(nmap.outputs["Normal"], bsdf.inputs["Normal"])
    elif mask_img:
        nmap = tree.nodes.new("ShaderNodeNormalMap")
        nmap.location = (300, 200)
        nmap.inputs["Strength"].default_value = 0.3
        tree.links.new(tex_mask.outputs["Color"], nmap.inputs["Color"])
        tree.links.new(nmap.outputs["Normal"], bsdf.inputs["Normal"])

    return mat


def _build_sand_material(mat_name: str, uv_scale: float) -> bpy.types.Material:
    """Build a SandSh-style material with noise normal texture.

    From SandSh.fs.glsl decompile:
      - Primary specular: GGX with roughness 0.25 → sharp sparkle
      - Secondary sheen: GGX with roughness ~0.3-0.65 (distance-dependent)
      - Strong normal perturbation: vertex×0.4 + tex×2 for sharp specular
      - The sharp normal causes the sparkly/glittery sand look
    """
    mat = bpy.data.materials.get(mat_name)
    if mat:
        return mat
    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    tree = mat.node_tree
    for n in list(tree.nodes):
        tree.nodes.remove(n)

    out = tree.nodes.new("ShaderNodeOutputMaterial")
    out.location = (1000, 0)
    bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (600, 0)
    # From decompile: primary specular roughness = 0.25 (sparkle)
    bsdf.inputs["Roughness"].default_value = 0.25
    # Specular IOR level for sand sparkle (F0 = 0.06 in shader)
    bsdf.inputs["Specular IOR Level"].default_value = 0.6
    # Coat for sheen glint layer (secondary specular in shader)
    try:
        bsdf.inputs["Coat Weight"].default_value = 0.3
        bsdf.inputs["Coat Roughness"].default_value = 0.5
    except Exception:
        pass
    tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    _add_emission_from_vertex_color(tree, bsdf, "FinalColor")
    _add_matcolor_base(tree, bsdf)

    geom = tree.nodes.new("ShaderNodeNewGeometry")
    geom.location = (-800, 200)
    sep = tree.nodes.new("ShaderNodeSeparateXYZ")
    sep.location = (-600, 200)
    tree.links.new(geom.outputs["Position"], sep.inputs[0])

    uv_xz = tree.nodes.new("ShaderNodeCombineXYZ")
    uv_xz.location = (-400, 200)
    tree.links.new(sep.outputs["X"], uv_xz.inputs["X"])
    tree.links.new(sep.outputs["Z"], uv_xz.inputs["Y"])

    scale_node = tree.nodes.new("ShaderNodeVectorMath")
    scale_node.location = (-200, 200)
    scale_node.operation = 'SCALE'
    scale_node.inputs["Scale"].default_value = uv_scale
    tree.links.new(uv_xz.outputs["Vector"], scale_node.inputs[0])

    noise_img = _get_or_load_image("Noise3Ch")
    if noise_img:
        tex = tree.nodes.new("ShaderNodeTexImage")
        tex.location = (0, 200)
        tex.image = noise_img
        tex.extension = 'REPEAT'
        tree.links.new(scale_node.outputs["Vector"], tex.inputs["Vector"])

        # Strong normal perturbation for sparkle (shader uses vertex×0.4 + tex×2)
        nmap = tree.nodes.new("ShaderNodeNormalMap")
        nmap.location = (300, 200)
        nmap.inputs["Strength"].default_value = 1.5
        tree.links.new(tex.outputs["Color"], nmap.inputs["Color"])
        tree.links.new(nmap.outputs["Normal"], bsdf.inputs["Normal"])

    return mat


def _build_ocean_material(mat_name: str, water_type: int = 0) -> bpy.types.Material:
    """Build an Ocean water material from decompiled Ocean.fs.glsl.

    From the shader:
      - Water body color: hardcoded vec3(0.01, 0.03, 0.06) — dark blue-green
      - Fresnel: F0 = 0.01, power = 7
      - Very low roughness (specular exponent 20-500)
      - Chromatic absorption: R >> G >> B (red absorbed first)
      - waterType 0=default/water, ooze=dark variant
    """
    mat = bpy.data.materials.get(mat_name)
    if mat:
        return mat
    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    tree = mat.node_tree
    for n in list(tree.nodes):
        tree.nodes.remove(n)

    out = tree.nodes.new("ShaderNodeOutputMaterial")
    out.location = (600, 0)
    bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (200, 0)
    tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    is_ooze = (water_type == 2)

    if is_ooze:
        bsdf.inputs["Base Color"].default_value = (0.005, 0.005, 0.01, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.15
    else:
        # From Ocean.fs: vec3(0.01, 0.03, 0.06) scaled up for Blender visibility
        bsdf.inputs["Base Color"].default_value = (0.02, 0.06, 0.12, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.02

    bsdf.inputs["IOR"].default_value = 1.33
    bsdf.inputs["Specular IOR Level"].default_value = 0.5

    try:
        bsdf.inputs["Transmission Weight"].default_value = 0.85
    except Exception:
        pass

    # Emission for baked sky reflection approximation
    bsdf.inputs["Emission Strength"].default_value = 0.0

    mat.use_backface_culling = True

    # Surface settings for viewport
    try:
        mat.surface_render_method = 'DITHERED'
    except Exception:
        pass

    return mat


def _build_cloud_material(mat_name: str) -> bpy.types.Material:
    """Build a CloudSh-style material.

    From CloudSh.fs/vs decompile: all lighting is baked into vertex colors.
    Fragment shader is a simple pass-through. Adds forward-scattering rim light
    and emissive contribution in the vertex shader.
    Cloud geometry has slight vertex offset toward the viewer for volume effect.
    """
    mat = bpy.data.materials.get(mat_name)
    if mat:
        return mat
    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    mat.blend_method = 'BLEND' if hasattr(mat, 'blend_method') else 'OPAQUE'
    tree = mat.node_tree
    for n in list(tree.nodes):
        tree.nodes.remove(n)

    out = tree.nodes.new("ShaderNodeOutputMaterial")
    out.location = (800, 0)
    bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (500, 0)
    bsdf.inputs["Roughness"].default_value = 1.0
    try:
        bsdf.inputs["Transmission Weight"].default_value = 0.3
    except Exception:
        pass
    tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    _add_emission_from_vertex_color(tree, bsdf, "FinalColor")
    _add_matcolor_base(tree, bsdf)

    return mat


def _get_textured_terrain_material(mat_enum: int) -> bpy.types.Material:
    """Get or create the appropriate textured terrain material."""
    shader = MATERIAL_SHADER.get(mat_enum, "GrassSh")
    uv_scale = MATERIAL_UV_SCALE.get(mat_enum, 1.0)
    textures = MATERIAL_TEXTURES.get(mat_enum)

    if shader == "RockFaceSh" and textures:
        top = textures.get("u_topGeoTexture", "CliffSh")
        side = textures.get("u_sideGeoTexture", "CliffSh")
        return _build_triplanar_rockface_material(
            f"Sky_Terrain_Rock_{top}", top, side, uv_scale)
    elif shader == "GrassSh":
        return _build_grass_material("Sky_Terrain_Grass", uv_scale)
    elif shader == "SandSh":
        return _build_sand_material("Sky_Terrain_Sand", uv_scale)
    elif shader == "CloudSh":
        return _build_cloud_material("Sky_Terrain_Cloud")
    else:
        return _get_terrain_material()


# ---------------------------------------------------------------------------
# Terrain import
# ---------------------------------------------------------------------------

def _populate_terrain_vertex_colors(bm, vertices) -> list[int]:
    """Store FinalColor and MatColor vertex attributes.

    Returns per-vertex material enum list (custom0[0] for each vertex).
    """
    per_vert_mats: list[int] = []
    try:
        lyr_fc = bm.color_attributes.new(name="FinalColor", type='FLOAT_COLOR', domain='POINT')
        lyr_mc = bm.color_attributes.new(name="MatColor", type='FLOAT_COLOR', domain='POINT')

        for vi, vert in enumerate(vertices):
            mat_enum = vert.custom0[0]
            per_vert_mats.append(mat_enum)

            per_vert_rgb = _get_material_rgb(mat_enum)
            lyr_mc.data[vi].color = (per_vert_rgb[0], per_vert_rgb[1], per_vert_rgb[2], 1.0)

            fr, fg, fb = _decode_terrain_final_color(vert.color, vert.uv0, per_vert_rgb)
            lyr_fc.data[vi].color = (fr, fg, fb, 1.0)
    except Exception:
        traceback.print_exc()

    return per_vert_mats


def _shader_key(mat_enum: int) -> str:
    """Map a material enum to its shader family for material slot grouping."""
    return MATERIAL_SHADER.get(mat_enum, "GrassSh")


def _assign_per_face_materials(obj, faces, per_vert_mats) -> None:
    """Assign per-face material slots based on vertex material enums.

    Each face uses the shader determined by the majority material of its vertices.
    Matching the game's multi-pass rendering: each shader type gets its own
    material slot, and faces are assigned to the correct slot.
    """
    if not per_vert_mats:
        return

    shader_to_slot: dict[str, int] = {}
    face_shaders: list[str] = []

    for face in faces:
        vote: dict[str, int] = {}
        for vi in face:
            if vi < len(per_vert_mats):
                sk = _shader_key(per_vert_mats[vi])
                vote[sk] = vote.get(sk, 0) + 1
        winner = max(vote, key=vote.get) if vote else "GrassSh"
        face_shaders.append(winner)

        if winner not in shader_to_slot:
            me = per_vert_mats[face[0]] if face[0] < len(per_vert_mats) else 0x30
            for vi in face:
                if vi < len(per_vert_mats) and _shader_key(per_vert_mats[vi]) == winner:
                    me = per_vert_mats[vi]
                    break
            mat = _get_textured_terrain_material(me)
            obj.data.materials.append(mat)
            shader_to_slot[winner] = len(obj.data.materials) - 1

    for fi, shader_name in enumerate(face_shaders):
        if fi < len(obj.data.polygons):
            obj.data.polygons[fi].material_index = shader_to_slot[shader_name]


def _create_terrain_mesh(
    tm: TerrainMeshData, idx: int, collection: bpy.types.Collection,
    base_rgb: tuple[float, float, float] = DEFAULT_BASE_RGB,
) -> bpy.types.Object | None:
    if tm.is_hidden and tm.is_forced_hidden:
        return None

    name = f"Terrain_{idx:04d}_g{tm.bst_guid:08X}"
    bm = bpy.data.meshes.new(name)

    positions = [v.position for v in tm.vertices]
    faces = []
    for i in range(0, len(tm.indices), 3):
        if i + 2 < len(tm.indices):
            a, b, c = tm.indices[i], tm.indices[i + 1], tm.indices[i + 2]
            if a != b and b != c and a != c:
                faces.append((a, b, c))
    bm.from_pydata(positions, [], faces)
    bm.update()

    try:
        for poly in bm.polygons:
            poly.use_smooth = True
    except Exception:
        pass

    per_vert_mats = _populate_terrain_vertex_colors(bm, tm.vertices)

    bm.validate()

    obj = bpy.data.objects.new(name, bm)
    try:
        _assign_per_face_materials(obj, faces, per_vert_mats)
    except Exception:
        traceback.print_exc()
        try:
            obj.data.materials.append(_get_terrain_material())
        except Exception:
            pass
    collection.objects.link(obj)

    if tm.is_hidden:
        obj.hide_viewport = True
        obj.hide_render = True

    return obj


# ---------------------------------------------------------------------------
# Skirt import
# ---------------------------------------------------------------------------

def _create_skirt_mesh(
    sk: SkirtMeshData, idx: int, collection: bpy.types.Collection,
    base_rgb: tuple[float, float, float] = DEFAULT_BASE_RGB,
) -> bpy.types.Object:
    name = f"Skirt_{idx:04d}"
    bm = bpy.data.meshes.new(name)

    positions = [v.position for v in sk.vertices]
    faces = []
    for i in range(0, len(sk.indices), 3):
        if i + 2 < len(sk.indices):
            a, b, c = sk.indices[i], sk.indices[i + 1], sk.indices[i + 2]
            if a != b and b != c and a != c:
                faces.append((a, b, c))
    bm.from_pydata(positions, [], faces)
    bm.update()

    try:
        for poly in bm.polygons:
            poly.use_smooth = True
    except Exception:
        pass

    per_vert_mats = _populate_terrain_vertex_colors(bm, sk.vertices)

    bm.validate()

    obj = bpy.data.objects.new(name, bm)
    try:
        _assign_per_face_materials(obj, faces, per_vert_mats)
    except Exception:
        try:
            obj.data.materials.append(_get_terrain_material())
        except Exception:
            pass
    collection.objects.link(obj)
    return obj


# ---------------------------------------------------------------------------
# Occluder import
# ---------------------------------------------------------------------------

def _create_occluder_mesh(
    occ: OccluderMeshData, collection: bpy.types.Collection,
) -> bpy.types.Object:
    bm = bpy.data.meshes.new("Occluder")
    faces = []
    for i in range(0, len(occ.indices), 3):
        if i + 2 < len(occ.indices):
            faces.append((occ.indices[i], occ.indices[i + 1], occ.indices[i + 2]))
    bm.from_pydata(occ.positions, [], faces)
    bm.update()
    bm.validate()

    obj = bpy.data.objects.new("Occluder", bm)
    obj.display_type = 'WIRE'
    obj.hide_viewport = True
    obj.hide_render = True
    collection.objects.link(obj)
    return obj


# ---------------------------------------------------------------------------
# Placed object (LevelMesh / Beamo) import
# ---------------------------------------------------------------------------

_mesh_cache: dict[str, object | None] = {}


def _resolve_mesh_file(resource_name: str, mesh_dir: str) -> str | None:
    path = os.path.join(mesh_dir, f"{resource_name}.mesh")
    return path if os.path.isfile(path) else None


def _load_mesh_cached(resource_name: str, mesh_dir: str):
    if resource_name in _mesh_cache:
        return _mesh_cache[resource_name]
    path = _resolve_mesh_file(resource_name, mesh_dir)
    if not path:
        _mesh_cache[resource_name] = None
        return None
    try:
        mesh_data = parse_mesh_file(path)
        _mesh_cache[resource_name] = mesh_data
        return mesh_data
    except Exception:
        _mesh_cache[resource_name] = None
        return None


def _create_placed_object(
    resource_name: str,
    instance_name: str,
    transform_flat: list[float],
    mesh_dir: str,
    collection: bpy.types.Collection,
    bake_map: dict[int, MeshBakeEntry],
    bst_guid: int,
    material_enum: int = 0x10,
) -> bpy.types.Object | None:
    mesh_data = _load_mesh_cached(resource_name, mesh_dir)
    if mesh_data is None:
        return None

    lod = mesh_data.lods[0]
    bm = bpy.data.meshes.new(instance_name)

    positions = list(lod.positions)
    faces = []
    for i in range(0, len(lod.indices), 3):
        if i + 2 < len(lod.indices):
            a, b, c = lod.indices[i], lod.indices[i + 1], lod.indices[i + 2]
            if a != b and b != c and a != c:
                faces.append((a, b, c))
    bm.from_pydata(positions, [], faces)
    bm.update()

    try:
        for poly in bm.polygons:
            poly.use_smooth = True
    except Exception:
        pass

    try:
        if lod.uvs:
            uv_layer = bm.uv_layers.new(name="UVMap")
            for poly in bm.polygons:
                for loop_idx in poly.loop_indices:
                    vi = bm.loops[loop_idx].vertex_index
                    u0, v0, _u1, _v1 = lod.uvs[vi]
                    uv_layer.data[loop_idx].uv = (u0, 1.0 - v0)
    except Exception:
        pass

    bake_entry = bake_map.get(bst_guid)
    has_bake = False
    try:
        if bake_entry and bake_entry.lod_entries:
            lod_bake = bake_entry.lod_entries[0]
            if lod_bake.light_data:
                vc_layer = bm.color_attributes.new(
                    name="BakedLight", type='BYTE_COLOR', domain='POINT',
                )
                light_data = lod_bake.light_data
                shared = bake_entry.shared_bake_flag or len(light_data) == 1

                for vi in range(lod.vertex_count):
                    if shared:
                        lv = light_data[0]
                    elif vi < len(light_data):
                        lv = light_data[vi]
                    else:
                        vc_layer.data[vi].color = (0.5, 0.5, 0.5, 1.0)
                        continue

                    scale = max(lv.intensity, 0.001)
                    lit_r = min(lv.r * scale * (1.0 - lv.shadow) + lv.ambient * lv.ao * 0.3, 1.0)
                    lit_g = min(lv.g * scale * (1.0 - lv.shadow) + lv.ambient * lv.ao * 0.3, 1.0)
                    lit_b = min(lv.b * scale * (1.0 - lv.shadow) + lv.ambient * lv.ao * 0.3, 1.0)
                    vc_layer.data[vi].color = (lit_r, lit_g, lit_b, 1.0)
                has_bake = True
    except Exception:
        pass

    bm.validate()

    obj = bpy.data.objects.new(instance_name, bm)

    try:
        if has_bake:
            obj.data.materials.append(_get_baked_light_material())
        else:
            mat_name = MATERIAL_ENUM_NAMES.get(material_enum, "Default")
            color = MATERIAL_COLORS.get(mat_name, (0.6, 0.6, 0.6, 1.0))
            obj.data.materials.append(_get_material(mat_name, color))
    except Exception:
        pass

    try:
        if transform_flat and len(transform_flat) == 16:
            obj.matrix_world = _tgcl_transform_to_matrix(transform_flat)
    except Exception:
        pass

    collection.objects.link(obj)
    return obj


# ---------------------------------------------------------------------------
# Environment setup (sun, fog, tonemapping) from TGCL SetEnvDefault
# ---------------------------------------------------------------------------

def _extract_env_from_tgcl(tgcl_scene) -> dict | None:
    """Extract environment parameters from the first valid SetEnvDefault."""
    if tgcl_scene is None:
        return None
    for obj in tgcl_scene.objects:
        if obj.class_name != "SetEnvDefault":
            continue
        auto = obj.fields.get("autoStart", 0)
        sc = obj.fields.get("sunColor", (0, 0, 0, 1))
        if auto != 1:
            continue
        if not isinstance(sc, (list, tuple)) or len(sc) < 3:
            continue
        if any(abs(v) > 100 for v in sc[:3]):
            continue

        env = {
            "sunColor": (sc[0], sc[1], sc[2]),
            "sunInt": float(obj.fields.get("sunInt", 1.0)),
            "sunAngleXZ": float(obj.fields.get("sunAngleXZ", 0.0)),
            "sunAngleY": float(obj.fields.get("sunAngleY", 45.0)),
            "sunToMoon": float(obj.fields.get("sunToMoon", 0.5)),
            "exposure": float(obj.fields.get("exposure", 1.0)),
            "fogDensity": float(obj.fields.get("fogDensity", 0.0)),
            "fogHeight": float(obj.fields.get("fogHeight", 0.0)),
            "drawDistance": float(obj.fields.get("drawDistance", 10000.0)),
            "bloomIntensity": float(obj.fields.get("bloomIntensity", 0.0)),
            "atmosphereDensity": float(obj.fields.get("atmosphereDensity", 1.0)),
        }

        tints = []
        for k in ("tintBot", "tintMidBot", "tintMidMid", "tintMidTop", "tintTop"):
            t = obj.fields.get(k, (0, 0, 0, 1))
            if isinstance(t, (list, tuple)) and len(t) >= 3:
                tints.append((float(t[0]), float(t[1]), float(t[2])))
        if tints:
            avg_r = sum(t[0] for t in tints) / len(tints)
            avg_g = sum(t[1] for t in tints) / len(tints)
            avg_b = sum(t[2] for t in tints) / len(tints)
            env["averageSkyColor"] = (avg_r, avg_g, avg_b)

        return env
    return None


def _setup_sun_light(env: dict, level_name: str) -> None:
    """Create a Blender Sun lamp from SetEnvDefault sun parameters.

    Sun direction from decompiled Ambience::Update:
      dir.x = -cos(angleXZ) * cos(angleY)
      dir.y = -sin(angleY)
      dir.z = -sin(angleXZ) * cos(angleY)
    Angles in degrees (confirmed from CandleSpace: -3.0, 15.0).
    """
    sun_data = bpy.data.lights.new(name=f"{level_name}_Sun", type='SUN')

    sc = env["sunColor"]
    si = env["sunInt"]
    sun_data.color = (
        min(sc[0] * si * 200.0, 1.0),
        min(sc[1] * si * 200.0, 1.0),
        min(sc[2] * si * 200.0, 1.0),
    )
    sun_data.energy = max(si * 5.0, 0.5)

    sun_obj = bpy.data.objects.new(f"{level_name}_Sun", sun_data)
    bpy.context.scene.collection.objects.link(sun_obj)

    ax = math.radians(env["sunAngleXZ"])
    ay = math.radians(env["sunAngleY"])
    sun_obj.rotation_euler = (
        math.pi / 2 - ay,
        0.0,
        -ax,
    )


def _setup_fog(env: dict) -> None:
    """Configure Blender world mist from SetEnvDefault fog parameters."""
    scene = bpy.context.scene
    if not scene.world:
        scene.world = bpy.data.worlds.new("Sky_World")

    world = scene.world
    world.use_nodes = True

    scene.eevee.use_volumetric_shadows = True

    scene.render.use_compositing = True
    scene.use_nodes = True

    draw_dist = env.get("drawDistance", 15000.0)
    fog_density = env.get("fogDensity", 1.0)

    scene.world.mist_settings.use_mist = True
    scene.world.mist_settings.start = draw_dist * 0.05
    scene.world.mist_settings.depth = draw_dist * 0.5 * fog_density
    scene.world.mist_settings.falloff = 'QUADRATIC'


def _setup_compositor_tonemap(env: dict) -> None:
    """Set up Blender compositor nodes for the game's tonemapping.

    Decompiled from TonemapMovie.fs.spv:
      encoded = 1.0 / (1.0 + hdr)
      tonemapped = (encoded / (encoded + 0.25))^2
      output = pow(tonemapped * exposure, 1/2.2)

    In Blender we approximate this with the built-in Tonemap node
    using Reinhard type and the Filmic view transform.
    """
    scene = bpy.context.scene
    scene.render.use_compositing = True
    scene.use_nodes = True

    tree = scene.node_tree
    if tree is None:
        return

    for n in list(tree.nodes):
        tree.nodes.remove(n)

    rl = tree.nodes.new("CompositorNodeRLayers")
    rl.location = (0, 0)

    exposure_val = env.get("exposure", 1.0)

    if exposure_val != 1.0:
        exp_node = tree.nodes.new("CompositorNodeExposure")
        exp_node.location = (300, 0)
        exp_node.inputs["Exposure"].default_value = math.log2(max(exposure_val, 0.01))
        tree.links.new(rl.outputs["Image"], exp_node.inputs["Image"])
        last_output = exp_node.outputs["Image"]
    else:
        last_output = rl.outputs["Image"]

    glare = tree.nodes.new("CompositorNodeGlare")
    glare.location = (600, 0)
    glare.glare_type = 'BLOOM'
    glare.quality = 'LOW'
    bloom_int = env.get("bloomIntensity", 0.035)
    glare.mix = max(bloom_int * 5.0, 0.01)
    glare.threshold = 1.0
    tree.links.new(last_output, glare.inputs["Image"])

    comp = tree.nodes.new("CompositorNodeComposite")
    comp.location = (900, 0)
    tree.links.new(glare.outputs["Image"], comp.inputs["Image"])

    viewer = tree.nodes.new("CompositorNodeViewer")
    viewer.location = (900, -200)
    tree.links.new(glare.outputs["Image"], viewer.inputs["Image"])

    try:
        scene.view_settings.view_transform = 'Filmic'
        scene.view_settings.look = 'Medium Contrast'
    except Exception:
        pass


# ---------------------------------------------------------------------------
# Water extraction and mesh creation
# ---------------------------------------------------------------------------

def _extract_water_objects(tgcl_scene) -> list[dict]:
    """Extract Water objects from TGCL scene graph.

    Returns list of dicts with keys: transform (4x4 tuple), waterType (int),
    and y_height (float) — the water surface Y position.
    """
    if tgcl_scene is None:
        return []

    waters = []
    for obj_data in tgcl_scene.objects:
        if obj_data.class_name != "Water":
            continue
        xform = obj_data.fields.get("transform")
        water_type = obj_data.fields.get("waterType", 0)
        if isinstance(water_type, float):
            water_type = int(water_type)

        y_height = 0.0
        if xform and len(xform) >= 16:
            # Row-major 4x4 matrix — row 3 (indices 12-14) = translation
            tx, ty, tz = float(xform[12]), float(xform[13]), float(xform[14])
            # Sanity check: reject garbage transforms
            if abs(tx) > 1e6 or abs(ty) > 1e6 or abs(tz) > 1e6:
                continue
            y_height = ty
        else:
            continue

        waters.append({
            "transform": xform,
            "waterType": water_type,
            "y_height": y_height,
        })

    # Also check for SetOceanRender visibility flag
    ocean_visible = True
    for obj_data in tgcl_scene.objects:
        if obj_data.class_name == "SetOceanRender":
            render_flag = obj_data.fields.get("render", 1)
            if isinstance(render_flag, float):
                render_flag = int(render_flag)
            if render_flag == 0:
                ocean_visible = False
                break

    if not ocean_visible:
        return []

    return waters


def _compute_terrain_bounds(lod) -> tuple[float, float, float, float] | None:
    """Compute (min_x, max_x, min_z, max_z) from all terrain and skirt vertices."""
    min_x = min_z = float('inf')
    max_x = max_z = float('-inf')
    count = 0
    for tm in lod.terrain_meshes:
        for v in tm.vertices:
            x, y, z = v.position
            min_x = min(min_x, x)
            max_x = max(max_x, x)
            min_z = min(min_z, z)
            max_z = max(max_z, z)
            count += 1
    for sk in lod.skirts:
        for v in sk.vertices:
            x, y, z = v.position
            min_x = min(min_x, x)
            max_x = max(max_x, x)
            min_z = min(min_z, z)
            max_z = max(max_z, z)
            count += 1
    if count == 0:
        return None
    return (min_x, max_x, min_z, max_z)


def _create_water_plane(
    water_info: dict,
    idx: int,
    collection: bpy.types.Collection,
    terrain_bounds: tuple[float, float, float, float] | None,
) -> bpy.types.Object:
    """Create a water surface plane at the specified Y height.

    From the decompile: ocean mesh is a 96x96 vertex grid (Plane10x10 asset).
    We create a subdivided plane covering the terrain bounds, extended by 20%.
    """
    y_height = water_info["y_height"]
    water_type = water_info["waterType"]
    grid_res = 96

    if terrain_bounds:
        min_x, max_x, min_z, max_z = terrain_bounds
        extent_x = max_x - min_x
        extent_z = max_z - min_z
        pad = max(extent_x, extent_z) * 0.1
        min_x -= pad
        max_x += pad
        min_z -= pad
        max_z += pad
    else:
        min_x, max_x = -500.0, 500.0
        min_z, max_z = -500.0, 500.0

    # Build grid vertices
    verts = []
    for iz in range(grid_res):
        fz = min_z + (max_z - min_z) * iz / (grid_res - 1)
        for ix in range(grid_res):
            fx = min_x + (max_x - min_x) * ix / (grid_res - 1)
            verts.append((fx, y_height, fz))

    faces = []
    for iz in range(grid_res - 1):
        for ix in range(grid_res - 1):
            a = iz * grid_res + ix
            b = a + 1
            c = a + grid_res + 1
            d = a + grid_res
            faces.append((a, b, c, d))

    name = f"Water_{idx:02d}_t{water_type}"
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()

    try:
        for poly in mesh.polygons:
            poly.use_smooth = True
    except Exception:
        pass

    mat = _build_ocean_material(f"Sky_Ocean_t{water_type}", water_type)
    mesh.materials.append(mat)

    obj = bpy.data.objects.new(name, mesh)
    collection.objects.link(obj)

    return obj


# ---------------------------------------------------------------------------
# Top-level import
# ---------------------------------------------------------------------------

def import_sky_level(
    level_dir: str,
    data_dir: str,
    import_terrain: bool = True,
    import_skirts: bool = True,
    import_occluder: bool = True,
    import_objects: bool = True,
    import_beamos: bool = True,
    import_water: bool = True,
    water_height_override: float | None = None,
    lod_index: int = 0,
) -> dict:
    """Import a complete Sky level into the current Blender scene.

    Args:
        level_dir: Path to Levels/<LevelName>/ directory
        data_dir: Path to assets/Data/ root directory
        import_terrain: Import terrain mesh geometry
        import_skirts: Import terrain edge (skirt) geometry
        import_occluder: Import visibility occluder (hidden by default)
        import_objects: Import placed LevelMesh objects
        import_beamos: Import placed Beamo objects
        import_water: Import water surfaces from TGCL Water objects
        water_height_override: Manual Y height for water plane (for levels
            without TGCL Water objects, e.g. CandleSpace). None = auto only.
        lod_index: Which LOD to import (0 = highest)
    """
    level_name = os.path.basename(os.path.normpath(level_dir))
    bst_path = os.path.join(level_dir, "BstBaked.meshes")
    tgcl_path = os.path.join(level_dir, "Objects.level.bin")
    mesh_dir = os.path.join(data_dir, "Meshes", "Bin")

    if not os.path.isfile(bst_path):
        raise FileNotFoundError(f"BstBaked.meshes not found in {level_dir}")

    root_coll = _get_or_create_collection(bpy.context.scene.collection, level_name)
    terrain_coll = _get_or_create_collection(root_coll, f"{level_name}_Terrain")
    skirt_coll = _get_or_create_collection(root_coll, f"{level_name}_Skirts")
    occluder_coll = _get_or_create_collection(root_coll, f"{level_name}_Occluder")
    objects_coll = _get_or_create_collection(root_coll, f"{level_name}_Objects")
    beamo_coll = _get_or_create_collection(root_coll, f"{level_name}_Beamos")
    water_coll = _get_or_create_collection(root_coll, f"{level_name}_Water")

    level = parse_level_meshes(bst_path)
    if lod_index >= len(level.lods):
        raise ValueError(f"LOD {lod_index} not found (level has {len(level.lods)} LODs)")
    lod = level.lods[lod_index]

    bake_map: dict[int, MeshBakeEntry] = {}
    for mb in lod.mesh_bakes:
        key = mb.submesh_id & 0xFFFFFFFF
        bake_map[key] = mb

    stats = {
        "level_name": level_name,
        "terrain_count": 0,
        "terrain_verts": 0,
        "skirt_count": 0,
        "occluder": False,
        "objects_placed": 0,
        "objects_missing": 0,
        "beamos_placed": 0,
        "beamos_missing": 0,
        "bakes_applied": 0,
        "water_planes": 0,
    }

    # Build BstGuid → material enum map from TGCL for terrain coloring
    guid_to_material: dict[int, int] = {}
    tgcl_scene = None
    env = None
    if os.path.isfile(tgcl_path):
        try:
            tgcl_scene = parse_tgcl(tgcl_path)
            env = _extract_env_from_tgcl(tgcl_scene)
            for obj_data in tgcl_scene.objects:
                if obj_data.class_name in ("LevelMesh", "TerrainBlob"):
                    guid = obj_data.fields.get("bstGuid", 0)
                    if isinstance(guid, float):
                        guid = int(guid)
                    guid = guid & 0xFFFFFFFF
                    if obj_data.class_name == "TerrainBlob":
                        mat_val = obj_data.fields.get("materialTop", 0x30)
                    else:
                        mat_val = obj_data.fields.get("material", 0x10)
                    if isinstance(mat_val, float):
                        mat_val = int(mat_val)
                    guid_to_material[guid] = mat_val
        except Exception:
            pass

    _apply_env_colors(env)

    if import_terrain:
        for i, tm in enumerate(lod.terrain_meshes):
            mat_enum = guid_to_material.get(tm.bst_guid & 0xFFFFFFFF, 0x20)
            base_rgb = _get_material_rgb(mat_enum)
            obj = _create_terrain_mesh(tm, i, terrain_coll, base_rgb=base_rgb)
            if obj:
                stats["terrain_count"] += 1
                stats["terrain_verts"] += tm.vertex_count

    if import_skirts:
        for i, sk in enumerate(lod.skirts):
            _create_skirt_mesh(sk, i, skirt_coll, base_rgb=DEFAULT_BASE_RGB)
            stats["skirt_count"] += 1

    if import_occluder and lod.occluder:
        _create_occluder_mesh(lod.occluder, occluder_coll)
        stats["occluder"] = True

    scene = tgcl_scene
    if scene is None and os.path.isfile(tgcl_path) and (import_objects or import_beamos):
        scene = parse_tgcl(tgcl_path)

    if scene and import_objects:
        for obj_data in scene.objects_by_class("LevelMesh"):
            resource_name = obj_data.fields.get("resourceName", "")
            if not resource_name:
                continue
            transform = obj_data.fields.get("transform")
            bst_guid = obj_data.fields.get("bstGuid", 0)
            if isinstance(bst_guid, float):
                bst_guid = int(bst_guid)
            bst_guid = bst_guid & 0xFFFFFFFF
            material_enum = obj_data.fields.get("material", 0x10)
            if isinstance(material_enum, float):
                material_enum = int(material_enum)

            placed = _create_placed_object(
                resource_name=resource_name,
                instance_name=obj_data.instance_name or resource_name,
                transform_flat=transform,
                mesh_dir=mesh_dir,
                collection=objects_coll,
                bake_map=bake_map,
                bst_guid=bst_guid,
                material_enum=material_enum,
            )
            if placed:
                stats["objects_placed"] += 1
                if bst_guid in bake_map:
                    stats["bakes_applied"] += 1
            else:
                stats["objects_missing"] += 1

    if scene and import_beamos:
        for obj_data in scene.objects_by_class("Beamo"):
            mesh_name = obj_data.fields.get("meshName", "")
            if not mesh_name:
                continue
            transform = obj_data.fields.get("transform")
            bst_guid = obj_data.fields.get("bstGuid", 0)
            if isinstance(bst_guid, float):
                bst_guid = int(bst_guid)
            bst_guid = bst_guid & 0xFFFFFFFF
            material_enum = 0x10

            placed = _create_placed_object(
                resource_name=mesh_name,
                instance_name=obj_data.instance_name or mesh_name,
                transform_flat=transform,
                mesh_dir=mesh_dir,
                collection=beamo_coll,
                bake_map=bake_map,
                bst_guid=bst_guid,
                material_enum=material_enum,
            )
            if placed:
                stats["beamos_placed"] += 1
                if bst_guid in bake_map:
                    stats["bakes_applied"] += 1
            else:
                stats["beamos_missing"] += 1

    _mesh_cache.clear()

    # Water planes from TGCL Water objects or manual override
    if import_water:
        water_objects = _extract_water_objects(tgcl_scene) if tgcl_scene else []
        if not water_objects and water_height_override is not None:
            water_objects = [{
                "transform": None,
                "waterType": 0,
                "y_height": water_height_override,
            }]
        if water_objects:
            terrain_bounds = _compute_terrain_bounds(lod)
            for wi, winfo in enumerate(water_objects):
                try:
                    _create_water_plane(winfo, wi, water_coll, terrain_bounds)
                    stats["water_planes"] += 1
                except Exception:
                    traceback.print_exc()

    # Extract environment from TGCL and set up scene lighting/fog/compositing
    env = _extract_env_from_tgcl(tgcl_scene)
    if env:
        try:
            _setup_sun_light(env, level_name)
        except Exception:
            traceback.print_exc()
        try:
            _setup_fog(env)
        except Exception:
            traceback.print_exc()
        try:
            _setup_compositor_tonemap(env)
        except Exception:
            traceback.print_exc()

    return stats


# ---------------------------------------------------------------------------
# Blender addon operator
# ---------------------------------------------------------------------------

class IMPORT_OT_sky_level(bpy.types.Operator, ImportHelper):
    bl_idname = "import_scene.sky_level"
    bl_label = "Import Sky Level"
    bl_options = {"REGISTER", "UNDO"}

    filename_ext = ".meshes"
    filter_glob: StringProperty(default="*BstBaked*;*.meshes", options={"HIDDEN"})

    data_dir: StringProperty(
        name="Data Directory",
        description="Path to assets/Data/ root (needed for placed objects)",
        subtype='DIR_PATH',
    )

    import_terrain: BoolProperty(name="Terrain", default=True)
    import_skirts: BoolProperty(name="Skirts", default=True)
    import_occluder: BoolProperty(name="Occluder", default=True)
    import_objects: BoolProperty(
        name="Placed Objects (LevelMesh)",
        description="Import objects referenced in Objects.level.bin",
        default=True,
    )
    import_beamos: BoolProperty(
        name="Placed Objects (Beamo)",
        description="Import beamo objects with baked lighting",
        default=True,
    )
    import_water: BoolProperty(
        name="Water Surfaces",
        description="Import water planes from TGCL Water objects",
        default=True,
    )
    water_height: bpy.props.FloatProperty(
        name="Water Height Override",
        description="Manual Y height for water plane. -999 = auto from TGCL only. "
                    "Set a value for levels without Water objects (e.g. CandleSpace)",
        default=-999.0,
    )

    def execute(self, context):
        level_dir = os.path.dirname(self.filepath)

        data_dir = self.data_dir
        if not data_dir:
            candidate = os.path.normpath(os.path.join(level_dir, "..", ".."))
            if os.path.isdir(os.path.join(candidate, "Meshes", "Bin")):
                data_dir = candidate

        try:
            wh = None if self.water_height <= -998.0 else self.water_height
            stats = import_sky_level(
                level_dir=level_dir,
                data_dir=data_dir,
                import_terrain=self.import_terrain,
                import_skirts=self.import_skirts,
                import_occluder=self.import_occluder,
                import_objects=self.import_objects,
                import_beamos=self.import_beamos,
                import_water=self.import_water,
                water_height_override=wh,
            )

            parts = [f"{stats['level_name']}:"]
            if stats["terrain_count"]:
                parts.append(f"{stats['terrain_count']} terrain ({stats['terrain_verts']} verts)")
            if stats["skirt_count"]:
                parts.append(f"{stats['skirt_count']} skirts")
            if stats["objects_placed"]:
                parts.append(f"{stats['objects_placed']} objects")
            if stats["beamos_placed"]:
                parts.append(f"{stats['beamos_placed']} beamos")
            if stats["bakes_applied"]:
                parts.append(f"{stats['bakes_applied']} bake-lit")
            if stats["water_planes"]:
                parts.append(f"{stats['water_planes']} water")
            if stats["objects_missing"] or stats["beamos_missing"]:
                parts.append(
                    f"({stats['objects_missing'] + stats['beamos_missing']} meshes not found)"
                )

            self.report({"INFO"}, ", ".join(parts))

        except Exception as e:
            self.report({"ERROR"}, str(e))
            traceback.print_exc()
            import sys
            print(f"\n=== SKY IMPORTER ERROR ===\n{traceback.format_exc()}", file=sys.stderr)
            return {"CANCELLED"}

        return {"FINISHED"}

    def draw(self, context):
        layout = self.layout
        layout.prop(self, "data_dir")
        layout.separator()
        layout.label(text="Import Options:")
        layout.prop(self, "import_terrain")
        layout.prop(self, "import_skirts")
        layout.prop(self, "import_occluder")
        layout.prop(self, "import_objects")
        layout.prop(self, "import_beamos")
        layout.prop(self, "import_water")
        if self.import_water:
            layout.prop(self, "water_height")


def menu_func_import(self, context):
    self.layout.operator(IMPORT_OT_sky_level.bl_idname, text="Sky Level Map")


def register():
    bpy.utils.register_class(IMPORT_OT_sky_level)
    bpy.types.TOPBAR_MT_file_import.append(menu_func_import)


def unregister():
    bpy.types.TOPBAR_MT_file_import.remove(menu_func_import)
    bpy.utils.unregister_class(IMPORT_OT_sky_level)


if __name__ == "__main__":
    register()
