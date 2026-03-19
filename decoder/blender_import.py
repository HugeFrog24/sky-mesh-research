"""Blender import addon for Sky: Children of the Light .mesh files.

Provides two importers:
  - Sky Mesh (.mesh): import a single mesh with skeleton and animations
  - Sky Outfit Assembler: composite a Sky Kid body + outfit pieces into
    one rigged scene with shared armature

Install:
  1. Copy the `sky_mesh/` package folder into Blender's Python site-packages,
     OR add the decoder/ directory to sys.path before importing.
  2. Run this script from Blender's scripting workspace, OR install as an addon.

Usage as addon:
  File → Import → Sky Mesh (.mesh)
  File → Import → Sky Outfit Assembler
"""

import colorsys
import json
import os
import sys
import traceback
from mathutils import Matrix, Vector, Quaternion as BQuaternion

_this_dir = os.path.dirname(os.path.abspath(__file__))
if _this_dir not in sys.path:
    sys.path.insert(0, _this_dir)

import bpy
from bpy.props import StringProperty, BoolProperty, IntProperty
from bpy_extras.io_utils import ImportHelper

from sky_mesh import parse_mesh_file
from sky_mesh.types import SkyMeshFile, MeshLodData, SkeletonData, AnimationClip
from sky_mesh.texture import TextureResolver, decode_ktx_texture

bl_info = {
    "name": "Sky Mesh Importer",
    "author": "",
    "version": (1, 0, 0),
    "blender": (3, 0, 0),
    "location": "File > Import > Sky Mesh (.mesh)",
    "description": "Import Sky: Children of the Light mesh files",
    "category": "Import-Export",
}


def _inv_bind_to_matrix(flat: list[float]) -> Matrix:
    """Convert a flat 16-float inverse bind matrix to a Blender Matrix (row-major)."""
    return Matrix((
        flat[0:4],
        flat[4:8],
        flat[8:12],
        flat[12:16],
    )).transposed()


def _create_mesh_object(
    mesh_data: SkyMeshFile,
    lod_index: int = 0,
) -> bpy.types.Object:
    """Create a Blender mesh object from decoded Sky mesh data."""
    lod = mesh_data.lods[lod_index]

    bpy_mesh = bpy.data.meshes.new(mesh_data.name)

    vertices = [(x, y, z) for x, y, z in lod.positions]
    faces = []
    for i in range(0, len(lod.indices), 3):
        faces.append((lod.indices[i], lod.indices[i + 1], lod.indices[i + 2]))

    bpy_mesh.from_pydata(vertices, [], faces)

    if lod.normals:
        bpy_mesh.normals_split_custom_set_from_vertices(
            [(nx, ny, nz) for nx, ny, nz in lod.normals]
        )

    if lod.uvs:
        uv_layer = bpy_mesh.uv_layers.new(name="UVMap")
        for poly in bpy_mesh.polygons:
            for loop_idx in poly.loop_indices:
                vert_idx = bpy_mesh.loops[loop_idx].vertex_index
                u0, v0, _u1, _v1 = lod.uvs[vert_idx]
                uv_layer.data[loop_idx].uv = (u0, 1.0 - v0)

    bpy_mesh.update()
    bpy_mesh.validate()

    obj = bpy.data.objects.new(mesh_data.name, bpy_mesh)
    return obj


def _create_armature(
    skeleton: SkeletonData,
    mesh_name: str,
) -> bpy.types.Object:
    """Create a Blender armature from Sky skeleton data."""
    arm_data = bpy.data.armatures.new(f"{mesh_name}_Armature")
    arm_obj = bpy.data.objects.new(f"{mesh_name}_Armature", arm_data)

    bpy.context.collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    arm_obj.select_set(True)

    bpy.ops.object.mode_set(mode="EDIT")

    bone_matrices = {}

    for i, bone_data in enumerate(skeleton.bones):
        edit_bone = arm_data.edit_bones.new(bone_data.name)

        if bone_data.inv_bind_matrix:
            inv_mat = _inv_bind_to_matrix(bone_data.inv_bind_matrix)
            try:
                bind_mat = inv_mat.inverted()
            except ValueError:
                bind_mat = Matrix.Identity(4)
        elif i < len(skeleton.rest_poses):
            rp = skeleton.rest_poses[i]
            loc = Vector(rp.translation)
            rot = BQuaternion((rp.rotation[3], rp.rotation[0],
                               rp.rotation[1], rp.rotation[2]))
            scl = Vector(rp.scale)
            bind_mat = Matrix.LocRotScale(loc, rot, scl)
        else:
            bind_mat = Matrix.Identity(4)

        bone_matrices[i] = bind_mat

        head = bind_mat @ Vector((0, 0, 0))
        tail = bind_mat @ Vector((0, 0.05, 0))
        edit_bone.head = head
        edit_bone.tail = tail

    for i, bone_data in enumerate(skeleton.bones):
        if bone_data.parent_index >= 0:
            parent_name = skeleton.bones[bone_data.parent_index].name
            child_bone = arm_data.edit_bones.get(bone_data.name)
            parent_bone = arm_data.edit_bones.get(parent_name)
            if child_bone and parent_bone:
                child_bone.parent = parent_bone

    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


def _apply_vertex_groups(
    mesh_obj: bpy.types.Object,
    lod: MeshLodData,
    skeleton: SkeletonData,
) -> None:
    """Create vertex groups from bone weight data."""
    if not lod.bone_weights:
        return

    bone_groups = {}
    for bone in skeleton.bones:
        vg = mesh_obj.vertex_groups.new(name=bone.name)
        bone_groups[skeleton.bones.index(bone)] = vg

    for vert_idx, weight_data in enumerate(lod.bone_weights):
        for bone_idx, weight in zip(weight_data["indices"], weight_data["weights"]):
            if weight > 0.0 and bone_idx in bone_groups:
                bone_groups[bone_idx].add([vert_idx], weight, "REPLACE")


def _import_animations(
    arm_obj: bpy.types.Object,
    skeleton: SkeletonData,
    clips: list[AnimationClip],
) -> None:
    """Import animation clips as Blender actions."""
    if not clips:
        return

    for clip in clips:
        if not clip.keying:
            continue

        action = bpy.data.actions.new(name=clip.name)
        arm_obj.animation_data_create()
        arm_obj.animation_data.action = action

        bpy.context.view_layer.objects.active = arm_obj
        bpy.ops.object.mode_set(mode="POSE")

        frame_count = clip.end_frame - clip.start_frame + 1

        for bone_list_idx, bone_idx in enumerate(clip.keying.initial_rot_bones):
            if bone_idx >= len(skeleton.bones):
                continue
            bone_name = skeleton.bones[bone_idx].name
            pose_bone = arm_obj.pose.bones.get(bone_name)
            if not pose_bone or bone_list_idx >= len(clip.initial_rotation_keys):
                continue

            quat = clip.initial_rotation_keys[bone_list_idx]
            pose_bone.rotation_mode = "QUATERNION"
            pose_bone.rotation_quaternion = (quat[3], quat[0], quat[1], quat[2])
            pose_bone.keyframe_insert(
                data_path="rotation_quaternion", frame=clip.start_frame
            )

        for bone_list_idx, bone_idx in enumerate(clip.keying.initial_trans_bones):
            if bone_idx >= len(skeleton.bones):
                continue
            bone_name = skeleton.bones[bone_idx].name
            pose_bone = arm_obj.pose.bones.get(bone_name)
            if not pose_bone or bone_list_idx >= len(clip.initial_translation_keys):
                continue

            trans = clip.initial_translation_keys[bone_list_idx]
            pose_bone.location = trans
            pose_bone.keyframe_insert(
                data_path="location", frame=clip.start_frame
            )

        for bone_list_idx, bone_idx in enumerate(clip.keying.initial_scale_bones):
            if bone_idx >= len(skeleton.bones):
                continue
            bone_name = skeleton.bones[bone_idx].name
            pose_bone = arm_obj.pose.bones.get(bone_name)
            if not pose_bone or bone_list_idx >= len(clip.initial_scale_keys):
                continue

            scale = clip.initial_scale_keys[bone_list_idx]
            pose_bone.scale = scale
            pose_bone.keyframe_insert(
                data_path="scale", frame=clip.start_frame
            )

        for frame_offset in range(frame_count):
            frame_num = clip.start_frame + frame_offset
            if frame_offset >= len(clip.per_frame_rotation_keys):
                break
            frame_rots = clip.per_frame_rotation_keys[frame_offset]

            for bone_list_idx, bone_idx in enumerate(clip.keying.per_frame_rot_bones):
                if bone_idx >= len(skeleton.bones):
                    continue
                bone_name = skeleton.bones[bone_idx].name
                pose_bone = arm_obj.pose.bones.get(bone_name)
                if not pose_bone or bone_list_idx >= len(frame_rots):
                    continue

                quat = frame_rots[bone_list_idx]
                pose_bone.rotation_mode = "QUATERNION"
                pose_bone.rotation_quaternion = (quat[3], quat[0], quat[1], quat[2])
                pose_bone.keyframe_insert(
                    data_path="rotation_quaternion", frame=frame_num
                )

            if frame_offset < len(clip.per_frame_translation_keys):
                frame_trans = clip.per_frame_translation_keys[frame_offset]
                for bone_list_idx, bone_idx in enumerate(
                    clip.keying.per_frame_trans_bones
                ):
                    if bone_idx >= len(skeleton.bones):
                        continue
                    bone_name = skeleton.bones[bone_idx].name
                    pose_bone = arm_obj.pose.bones.get(bone_name)
                    if not pose_bone or bone_list_idx >= len(frame_trans):
                        continue
                    trans = frame_trans[bone_list_idx]
                    pose_bone.location = trans
                    pose_bone.keyframe_insert(
                        data_path="location", frame=frame_num
                    )

            if frame_offset < len(clip.per_frame_scale_keys):
                frame_scales = clip.per_frame_scale_keys[frame_offset]
                for bone_list_idx, bone_idx in enumerate(
                    clip.keying.per_frame_scale_bones
                ):
                    if bone_idx >= len(skeleton.bones):
                        continue
                    bone_name = skeleton.bones[bone_idx].name
                    pose_bone = arm_obj.pose.bones.get(bone_name)
                    if not pose_bone or bone_list_idx >= len(frame_scales):
                        continue
                    scale = frame_scales[bone_list_idx]
                    pose_bone.scale = scale
                    pose_bone.keyframe_insert(
                        data_path="scale", frame=frame_num
                    )

        bpy.ops.object.mode_set(mode="OBJECT")


def import_sky_mesh(
    filepath: str,
    import_skeleton: bool = True,
    import_animations: bool = True,
    lod_index: int = 0,
) -> dict:
    """Import a Sky .mesh file into the current Blender scene.

    Returns a dict with the created objects.
    """
    mesh_data = parse_mesh_file(filepath)

    mesh_obj = _create_mesh_object(mesh_data, lod_index)
    bpy.context.collection.objects.link(mesh_obj)

    arm_obj = None
    if import_skeleton and mesh_data.skeleton and mesh_data.skeleton.bone_count > 0:
        arm_obj = _create_armature(mesh_data.skeleton, mesh_data.name)

        _apply_vertex_groups(mesh_obj, mesh_data.lods[lod_index], mesh_data.skeleton)

        mesh_obj.parent = arm_obj
        mod = mesh_obj.modifiers.new(name="Armature", type="ARMATURE")
        mod.object = arm_obj

        if import_animations and mesh_data.animations:
            _import_animations(arm_obj, mesh_data.skeleton, mesh_data.animations)

    return {
        "mesh": mesh_obj,
        "armature": arm_obj,
        "mesh_data": mesh_data,
    }


# ---------------------------------------------------------------------------
# Outfit assembler — multi-mesh with shared armature
# ---------------------------------------------------------------------------

def _resolve_mesh_path(mesh_name: str, mesh_dir: str) -> str | None:
    """Find the .mesh file for an outfit piece by name.

    Mesh filenames on disk include processing suffixes like
    _StripAnim_CompOcc_ZipPos_ZipUvs_StripNorm that aren't in OutfitDefs.
    """
    if not mesh_dir or not os.path.isdir(mesh_dir):
        return None

    exact = os.path.join(mesh_dir, mesh_name + ".mesh")
    if os.path.isfile(exact):
        return exact

    prefix = mesh_name + "_"
    for fname in os.listdir(mesh_dir):
        if fname.startswith(prefix) and fname.endswith(".mesh"):
            return os.path.join(mesh_dir, fname)

    return None


def _hsv_to_rgb(h_deg: float, s_pct: float, v_pct: float) -> tuple[float, float, float]:
    """Convert OutfitDefs HSV (h in degrees, s/v in 0-100) to linear RGB 0-1."""
    h = (h_deg % 360.0) / 360.0
    s = max(0.0, min(1.0, s_pct / 100.0))
    v = max(0.0, min(1.0, v_pct / 100.0))
    r, g, b = colorsys.hsv_to_rgb(h, s, v)
    return (r, g, b)


_texture_cache: dict[str, str] = {}


def _load_outfit_texture(
    diffuse_name: str,
    tex_resolver: "TextureResolver | None",
    cache_dir: str,
) -> "bpy.types.Image | None":
    """Resolve and decode an outfit diffuse texture to a Blender Image."""
    if not diffuse_name or not tex_resolver:
        return None

    existing = bpy.data.images.get(diffuse_name)
    if existing:
        return existing

    if diffuse_name in _texture_cache:
        png_path = _texture_cache[diffuse_name]
        if os.path.isfile(png_path):
            img = bpy.data.images.load(png_path)
            img.name = diffuse_name
            return img

    os.makedirs(cache_dir, exist_ok=True)
    png_path = os.path.join(cache_dir, diffuse_name + ".png")

    if os.path.isfile(png_path):
        print(f"[SkyOutfit] Loading cached texture: {png_path}")
        _texture_cache[diffuse_name] = png_path
        img = bpy.data.images.load(png_path)
        img.name = diffuse_name
        return img

    ktx_path = tex_resolver.resolve_texture_path(diffuse_name)
    if not ktx_path:
        print(f"[SkyOutfit] No KTX found for: {diffuse_name}")
        return None

    region = tex_resolver.get_image_region(diffuse_name)
    crop_uv = region.uv if region else None

    try:
        decode_ktx_texture(ktx_path, png_path, crop_uv=crop_uv)
        print(f"[SkyOutfit] Decoded texture: {diffuse_name} -> {png_path}")
    except Exception:
        print(f"[SkyOutfit] Failed to decode {diffuse_name}: see traceback")
        traceback.print_exc()
        return None

    if not os.path.isfile(png_path):
        return None

    _texture_cache[diffuse_name] = png_path
    img = bpy.data.images.load(png_path)
    img.name = diffuse_name
    return img


def _create_outfit_material(
    outfit_name: str,
    color_hsv: tuple[float, float, float],
    shader: str,
    diffuse_name: str = "",
    tex_resolver: "TextureResolver | None" = None,
    cache_dir: str = "",
) -> "bpy.types.Material":
    """Create a Blender material from outfit color, shader, and diffuse texture."""
    mat_name = f"Sky_{outfit_name}"
    mat = bpy.data.materials.get(mat_name)
    if mat:
        has_tex = any(
            n.type == "TEX_IMAGE" for n in mat.node_tree.nodes
        ) if mat.use_nodes and mat.node_tree else False
        if has_tex or not diffuse_name:
            return mat
        bpy.data.materials.remove(mat)

    mat = bpy.data.materials.new(mat_name)
    mat.use_nodes = True
    tree = mat.node_tree

    bsdf = tree.nodes.get("Principled BSDF")
    if bsdf is None:
        for n in list(tree.nodes):
            tree.nodes.remove(n)
        out = tree.nodes.new("ShaderNodeOutputMaterial")
        out.location = (600, 0)
        bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
        bsdf.location = (200, 0)
        tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    rgb = _hsv_to_rgb(*color_hsv)

    # Try loading the diffuse texture
    tex_image = _load_outfit_texture(diffuse_name, tex_resolver, cache_dir)
    if tex_image:
        tex_node = tree.nodes.new("ShaderNodeTexImage")
        tex_node.image = tex_image
        tex_node.location = (-300, 200)

        is_white_tint = (color_hsv[1] < 1.0 and color_hsv[2] > 99.0)
        if is_white_tint:
            tree.links.new(tex_node.outputs["Color"], bsdf.inputs["Base Color"])
        else:
            mix = tree.nodes.new("ShaderNodeMixRGB")
            mix.blend_type = 'MULTIPLY'
            mix.inputs["Fac"].default_value = 1.0
            mix.location = (-50, 200)
            tree.links.new(tex_node.outputs["Color"], mix.inputs["Color1"])
            mix.inputs["Color2"].default_value = (rgb[0], rgb[1], rgb[2], 1.0)
            tree.links.new(mix.outputs["Color"], bsdf.inputs["Base Color"])
    else:
        bsdf.inputs["Base Color"].default_value = (rgb[0], rgb[1], rgb[2], 1.0)

    if "Hair" in shader:
        bsdf.inputs["Roughness"].default_value = 0.4
        try:
            bsdf.inputs["Coat Weight"].default_value = 0.2
        except Exception:
            pass
    elif "Cape" in shader or "Wing" in shader or outfit_name.startswith("CharSkyKid_Wing"):
        bsdf.inputs["Roughness"].default_value = 0.6
    else:
        bsdf.inputs["Roughness"].default_value = 0.5

    return mat


HEAD_BONE_NAMES = frozenset({
    "charKidRigRef_M_hairCenter",
    "charKidRigRef_M_head",
    "charKidRigRef_M_headAUX",
})


def _mask_body_head(
    body_obj: "bpy.types.Object",
    lod: MeshLodData,
    skeleton: SkeletonData,
) -> None:
    """Create a 'HeadVerts' vertex group on the body and add an inverted Mask modifier.

    At runtime the game excludes head triangles from the body draw call when
    hair is equipped (AvatarRender::TriangleRangeForOutfit).  We replicate
    this by masking out vertices whose primary bone is a head/scalp bone.
    """
    head_bone_indices: set[int] = set()
    for i, bone in enumerate(skeleton.bones):
        if bone.name in HEAD_BONE_NAMES:
            head_bone_indices.add(i)

    if not head_bone_indices:
        return

    head_verts: list[int] = []
    for vi, bw in enumerate(lod.bone_weights):
        if any(idx in head_bone_indices for idx in bw["indices"]):
            head_verts.append(vi)

    if not head_verts:
        return

    vg = body_obj.vertex_groups.new(name="HeadVerts")
    vg.add(head_verts, 1.0, "REPLACE")

    mod = body_obj.modifiers.new(name="HideHead", type="MASK")
    mod.vertex_group = "HeadVerts"
    mod.invert_vertex_group = True


def _mask_occluded_by_hair(
    mask_obj: "bpy.types.Object",
    lod: MeshLodData,
) -> None:
    """Hide mask vertices that are covered by hair.

    The game's combined-buffer approach (TriangleRangeForOutfit) keeps
    mask and hair triangles non-overlapping.  The mask mesh wraps around
    the head from the front; only the forward face plate should remain
    visible when hair is equipped.  We hide vertices in the back half
    (Z) and top region (Y) of the mask shell using position thresholds.
    """
    positions = lod.positions
    n_verts = len(positions)

    z_vals = [p[2] for p in positions]
    y_vals = [p[1] for p in positions]
    z_min, z_max = min(z_vals), max(z_vals)
    y_min, y_max = min(y_vals), max(y_vals)
    z_range = z_max - z_min
    y_range = y_max - y_min

    z_cut = z_min + 0.55 * z_range
    y_top = y_min + 0.80 * y_range
    y_chin = y_min + 0.25 * y_range

    hide_verts: list[int] = []
    for vi in range(n_verts):
        py = positions[vi][1]
        pz = positions[vi][2]
        if pz > z_cut and py > y_chin:
            hide_verts.append(vi)
        elif py > y_top:
            hide_verts.append(vi)

    if not hide_verts:
        return

    vg = mask_obj.vertex_groups.new(name="OccludedByHair")
    vg.add(hide_verts, 1.0, "REPLACE")

    mod = mask_obj.modifiers.new(name="HideBehindHair", type="MASK")
    mod.vertex_group = "OccludedByHair"
    mod.invert_vertex_group = True


def _attach_mesh_to_armature(
    mesh_obj: "bpy.types.Object",
    arm_obj: "bpy.types.Object",
    lod: MeshLodData,
    skeleton: SkeletonData,
) -> None:
    """Parent a mesh to an existing armature with vertex groups."""
    _apply_vertex_groups(mesh_obj, lod, skeleton)
    mesh_obj.parent = arm_obj
    mod = mesh_obj.modifiers.new(name="Armature", type="ARMATURE")
    mod.object = arm_obj


def import_sky_outfit(
    mesh_dir: str,
    data_dir: str,
    body_name: str = "CharSkyKid_Body_ClassicShortPants",
    hair_name: str = "",
    wing_name: str = "",
    mask_name: str = "",
    horn_name: str = "",
    neck_name: str = "",
    extra_names: list[str] | None = None,
) -> dict:
    """Import a composed Sky Kid outfit into Blender.

    Loads the body mesh, creates a shared armature from it, then loads
    each outfit piece and parents it to the same armature.

    Args:
        mesh_dir: Path to Meshes/Bin/ directory
        data_dir: Path to assets/Data/ root (for OutfitDefs.json)
        body_name: OutfitDefs name for the body mesh
        hair_name: OutfitDefs name for hair (empty = skip)
        wing_name: OutfitDefs name for cape/wing (empty = skip)
        mask_name: OutfitDefs name for mask (empty = skip)
        horn_name: OutfitDefs name for horn (empty = skip)
        neck_name: OutfitDefs name for neck accessory (empty = skip)
        extra_names: Additional mesh names to load

    Returns dict with counts of imported pieces.
    """
    outfit_defs = {}
    defs_path = os.path.join(data_dir, "Resources", "OutfitDefs.json")
    if os.path.isfile(defs_path):
        with open(defs_path, encoding="utf-8") as f:
            raw = json.load(f)
        for entry in raw:
            outfit_defs[entry.get("name", "")] = entry

    tex_resolver = None
    try:
        tex_resolver = TextureResolver(data_dir)
        tex_resolver.load()
        print(f"[SkyOutfit] TextureResolver loaded: {len(tex_resolver.image_regions)} image regions")
    except Exception:
        print("[SkyOutfit] WARNING: TextureResolver failed to load")
        traceback.print_exc()

    cache_dir = os.path.join(data_dir, "..", "..", "_blender_tex_cache")
    cache_dir = os.path.normpath(cache_dir)
    print(f"[SkyOutfit] Texture cache dir: {cache_dir}")

    root_coll = bpy.context.collection
    outfit_coll = bpy.data.collections.new("SkyKid_Outfit")
    root_coll.children.link(outfit_coll)

    stats = {"body": False, "pieces": 0, "missing": []}

    def _get_mesh_names(outfit_name: str) -> list[str]:
        if outfit_name in outfit_defs:
            return outfit_defs[outfit_name].get("mesh", [outfit_name])
        return [outfit_name]

    def _get_outfit_entry(outfit_name: str) -> dict:
        return outfit_defs.get(outfit_name, {})

    def _get_diffuse(outfit_name: str) -> str:
        entry = _get_outfit_entry(outfit_name)
        textures = entry.get("texture", [])
        if textures:
            return textures[0].get("diffuse", "")
        return ""

    # --- Load body first (it provides the armature) ---
    body_meshes = _get_mesh_names(body_name)
    body_path = None
    for bm in body_meshes:
        body_path = _resolve_mesh_path(bm, mesh_dir)
        if body_path:
            break

    if not body_path:
        raise FileNotFoundError(
            f"Body mesh not found for '{body_name}'. "
            f"Searched: {body_meshes} in {mesh_dir}"
        )

    body_data = parse_mesh_file(body_path)
    body_obj = _create_mesh_object(body_data, 0)
    outfit_coll.objects.link(body_obj)

    arm_obj = None
    shared_skeleton = body_data.skeleton

    if shared_skeleton and shared_skeleton.bone_count > 0:
        arm_obj = _create_armature(shared_skeleton, "SkyKid")
        # Move armature to outfit collection
        if arm_obj.name in bpy.context.collection.objects:
            bpy.context.collection.objects.unlink(arm_obj)
        outfit_coll.objects.link(arm_obj)

        _attach_mesh_to_armature(body_obj, arm_obj, body_data.lods[0], shared_skeleton)

    # Apply body material
    body_entry = _get_outfit_entry(body_name)
    body_hsv = body_entry.get("color_hsv", [0, 0, 100])
    body_shader = body_entry.get("shader", "Avatar")
    body_mat = _create_outfit_material(
        body_name, tuple(body_hsv), body_shader,
        diffuse_name=_get_diffuse(body_name),
        tex_resolver=tex_resolver,
        cache_dir=cache_dir,
    )
    if body_obj.data.materials:
        body_obj.data.materials[0] = body_mat
    else:
        body_obj.data.materials.append(body_mat)

    if hair_name and shared_skeleton:
        _mask_body_head(body_obj, body_data.lods[0], shared_skeleton)

    stats["body"] = True

    # --- Load outfit pieces ---
    slot_map = {
        "hair": hair_name,
        "wing": wing_name,
        "mask": mask_name,
        "horn": horn_name,
        "neck": neck_name,
    }
    all_pieces = [(slot, name) for slot, name in slot_map.items() if name]
    if extra_names:
        all_pieces.extend(("extra", n) for n in extra_names)

    for slot, piece_name in all_pieces:
        piece_meshes = _get_mesh_names(piece_name)
        piece_path = None
        for pm in piece_meshes:
            piece_path = _resolve_mesh_path(pm, mesh_dir)
            if piece_path:
                break

        if not piece_path:
            stats["missing"].append(f"{slot}:{piece_name}")
            continue

        try:
            piece_data = parse_mesh_file(piece_path)
            piece_obj = _create_mesh_object(piece_data, 0)
            outfit_coll.objects.link(piece_obj)

            if arm_obj and shared_skeleton:
                piece_lod = piece_data.lods[0]
                piece_skel = piece_data.skeleton

                if piece_skel and piece_skel.bone_count > 0:
                    _attach_mesh_to_armature(
                        piece_obj, arm_obj, piece_lod, piece_skel
                    )
                else:
                    piece_obj.parent = arm_obj

            # Apply piece material
            piece_entry = _get_outfit_entry(piece_name)
            piece_hsv = piece_entry.get("color_hsv", [0, 0, 100])
            piece_shader = piece_entry.get("shader", "Avatar")
            piece_mat = _create_outfit_material(
                piece_name, tuple(piece_hsv), piece_shader,
                diffuse_name=_get_diffuse(piece_name),
                tex_resolver=tex_resolver,
                cache_dir=cache_dir,
            )
            if piece_obj.data.materials:
                piece_obj.data.materials[0] = piece_mat
            else:
                piece_obj.data.materials.append(piece_mat)

            if slot == "mask" and hair_name:
                _mask_occluded_by_hair(piece_obj, piece_data.lods[0])

            stats["pieces"] += 1
        except Exception:
            traceback.print_exc()
            stats["missing"].append(f"{slot}:{piece_name}(parse error)")

    return stats


# ---------------------------------------------------------------------------
# Blender operators
# ---------------------------------------------------------------------------

class IMPORT_OT_sky_mesh(bpy.types.Operator, ImportHelper):
    bl_idname = "import_mesh.sky_mesh"
    bl_label = "Import Sky Mesh"
    bl_options = {"REGISTER", "UNDO"}

    filename_ext = ".mesh"
    filter_glob: StringProperty(default="*.mesh", options={"HIDDEN"})

    import_skeleton: BoolProperty(
        name="Import Skeleton",
        description="Import bone hierarchy and vertex weights",
        default=True,
    )
    import_animations: BoolProperty(
        name="Import Animations",
        description="Import baked animation clips",
        default=False,
    )
    lod_index: IntProperty(
        name="LOD Index",
        description="Which LOD to import (0 = highest detail)",
        default=0,
        min=0,
        max=10,
    )

    def execute(self, context):
        try:
            result = import_sky_mesh(
                self.filepath,
                import_skeleton=self.import_skeleton,
                import_animations=self.import_animations,
                lod_index=self.lod_index,
            )
            mesh_data = result["mesh_data"]
            self.report(
                {"INFO"},
                f"Imported {mesh_data.name}: "
                f"{mesh_data.lod0.vertex_count} verts, "
                f"{mesh_data.lod0.index_count // 3} tris"
                + (f", {mesh_data.skeleton.bone_count} bones" if mesh_data.skeleton else ""),
            )
        except Exception as e:
            self.report({"ERROR"}, str(e))
            return {"CANCELLED"}

        return {"FINISHED"}


class IMPORT_OT_sky_outfit(bpy.types.Operator):
    """Import a composed Sky Kid with body + outfit pieces"""

    bl_idname = "import_mesh.sky_outfit"
    bl_label = "Sky Outfit Assembler"
    bl_options = {"REGISTER", "UNDO"}

    data_dir: StringProperty(
        name="Data Directory",
        description="Path to assets/Data/ root (contains Meshes/Bin/ and Resources/)",
        subtype='DIR_PATH',
    )

    body: StringProperty(
        name="Body",
        description="Body outfit name from OutfitDefs (e.g. CharSkyKid_Body_ClassicShortPants)",
        default="CharSkyKid_Body_ClassicShortPants",
    )
    hair: StringProperty(
        name="Hair",
        description="Hair outfit name (leave empty to skip)",
        default="CharSkyKid_Hair_BraidSideSmall",
    )
    wing: StringProperty(
        name="Cape / Wing",
        description="Wing/cape outfit name (leave empty to skip)",
        default="CharSkyKid_Wing_ClassicOne_Default",
    )
    mask: StringProperty(
        name="Mask",
        description="Mask outfit name (leave empty to skip)",
        default="CharSkyKid_Mask_Basic",
    )
    horn: StringProperty(
        name="Horn",
        description="Horn outfit name (leave empty to skip)",
        default="",
    )
    neck: StringProperty(
        name="Neck",
        description="Neck accessory outfit name (leave empty to skip)",
        default="",
    )

    def execute(self, context):
        data_dir = self.data_dir
        if not data_dir or not os.path.isdir(data_dir):
            self.report({"ERROR"}, "Data directory not set or invalid")
            return {"CANCELLED"}

        mesh_dir = os.path.join(data_dir, "Meshes", "Bin")
        if not os.path.isdir(mesh_dir):
            self.report({"ERROR"}, f"Meshes/Bin not found in {data_dir}")
            return {"CANCELLED"}

        try:
            stats = import_sky_outfit(
                mesh_dir=mesh_dir,
                data_dir=data_dir,
                body_name=self.body,
                hair_name=self.hair,
                wing_name=self.wing,
                mask_name=self.mask,
                horn_name=self.horn,
                neck_name=self.neck,
            )

            parts = ["SkyKid:"]
            if stats["body"]:
                parts.append("body")
            if stats["pieces"]:
                parts.append(f"{stats['pieces']} outfit pieces")
            if stats["missing"]:
                parts.append(f"({len(stats['missing'])} not found)")

            self.report({"INFO"}, " ".join(parts))
        except Exception as e:
            self.report({"ERROR"}, str(e))
            traceback.print_exc()
            return {"CANCELLED"}

        return {"FINISHED"}

    def draw(self, context):
        layout = self.layout
        layout.prop(self, "data_dir")
        layout.separator()
        layout.label(text="Outfit Pieces (OutfitDefs names):")
        layout.prop(self, "body")
        layout.prop(self, "hair")
        layout.prop(self, "wing")
        layout.prop(self, "mask")
        layout.prop(self, "horn")
        layout.prop(self, "neck")

    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self, width=500)


def menu_func_import(self, context):
    self.layout.operator(IMPORT_OT_sky_mesh.bl_idname, text="Sky Mesh (.mesh)")
    self.layout.operator(IMPORT_OT_sky_outfit.bl_idname, text="Sky Outfit Assembler")


def register():
    bpy.utils.register_class(IMPORT_OT_sky_mesh)
    bpy.utils.register_class(IMPORT_OT_sky_outfit)
    bpy.types.TOPBAR_MT_file_import.append(menu_func_import)


def unregister():
    bpy.types.TOPBAR_MT_file_import.remove(menu_func_import)
    bpy.utils.unregister_class(IMPORT_OT_sky_outfit)
    bpy.utils.unregister_class(IMPORT_OT_sky_mesh)


if __name__ == "__main__":
    register()
