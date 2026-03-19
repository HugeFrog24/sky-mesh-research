#!/usr/bin/env python3
"""Command-line interface for the Sky mesh decoder.

Usage:
    python cli.py info <file.mesh>          Print mesh info
    python cli.py dump <file.mesh> -o out/  Dump to OBJ (geometry only)
    python cli.py convert <file.mesh> -o out.glb  Convert to glTF (requires pygltflib)
"""

import argparse
import os
import sys


def cmd_info(args: argparse.Namespace) -> None:
    from sky_mesh import parse_mesh_file

    mesh = parse_mesh_file(args.file)
    print(mesh.summary())

    if args.verbose and mesh.skeleton:
        print(f"\n  Bone hierarchy:")
        for i, bone in enumerate(mesh.skeleton.bones):
            parent = (
                mesh.skeleton.bones[bone.parent_index].name
                if bone.parent_index >= 0
                else "(root)"
            )
            print(f"    [{i:3d}] {bone.name} -> parent: {parent}")


def _resolve_texture_for_mesh(mesh_name: str, data_dir: str, out_dir: str):
    """Try to find and decode the diffuse texture for a mesh.

    Returns (texture_filename, mtl_written) or (None, False).
    """
    from sky_mesh.texture import TextureResolver, decode_ktx_texture

    resolver = TextureResolver(data_dir)
    resolver.load()

    outfit = resolver.find_outfit_for_mesh(mesh_name)
    if not outfit or not outfit.textures:
        return None, False

    tex = outfit.textures[0]
    region = resolver.get_image_region(tex.diffuse)
    ktx_path = resolver.resolve_texture_path(tex.diffuse)
    if not ktx_path:
        return None, False

    crop = region.uv if region else None
    tex_filename = f"{mesh_name}_diffuse.png"
    tex_path = os.path.join(out_dir, tex_filename)
    decode_ktx_texture(ktx_path, tex_path, crop_uv=crop)
    print(f"  Texture: {tex_path}")
    return tex_filename, True


def cmd_dump_obj(args: argparse.Namespace) -> None:
    from sky_mesh import parse_mesh_file

    mesh = parse_mesh_file(args.file)
    lod_idx = args.lod
    if lod_idx >= len(mesh.lods):
        print(f"Error: LOD {lod_idx} not found (mesh has {len(mesh.lods)} LODs)")
        sys.exit(1)

    lod = mesh.lods[lod_idx]
    out_path = args.output or os.path.splitext(args.file)[0] + ".obj"
    out_dir = os.path.dirname(os.path.abspath(out_path))
    obj_basename = os.path.splitext(os.path.basename(out_path))[0]

    tex_filename = None
    mtl_filename = None
    if args.data_dir:
        tex_filename, ok = _resolve_texture_for_mesh(
            mesh.name, args.data_dir, out_dir
        )
        if ok:
            mtl_filename = obj_basename + ".mtl"
            mtl_path = os.path.join(out_dir, mtl_filename)
            with open(mtl_path, "w") as mf:
                mf.write(f"# Sky mesh material: {mesh.name}\n")
                mf.write(f"newmtl {mesh.name}\n")
                mf.write("Ka 1.0 1.0 1.0\n")
                mf.write("Kd 1.0 1.0 1.0\n")
                mf.write("Ks 0.0 0.0 0.0\n")
                mf.write("d 1.0\n")
                mf.write(f"map_Kd {tex_filename}\n")
            print(f"  Material: {mtl_path}")

    with open(out_path, "w") as f:
        f.write(f"# Sky mesh: {mesh.name}\n")
        f.write(f"# Version: 0x{mesh.version:02X}\n")
        f.write(f"# LOD {lod_idx}: {lod.vertex_count} verts, {lod.index_count // 3} tris\n\n")

        if mtl_filename:
            f.write(f"mtllib {mtl_filename}\n\n")

        for x, y, z in lod.positions:
            f.write(f"v {x:.6f} {y:.6f} {z:.6f}\n")

        if lod.normals:
            for nx, ny, nz in lod.normals:
                f.write(f"vn {nx:.6f} {ny:.6f} {nz:.6f}\n")

        if lod.uvs:
            for u0, v0, _u1, _v1 in lod.uvs:
                f.write(f"vt {u0:.6f} {1.0 - v0:.6f}\n")

        has_vt = bool(lod.uvs)
        has_vn = bool(lod.normals)

        f.write(f"\ng {mesh.name}\n")
        if mtl_filename:
            f.write(f"usemtl {mesh.name}\n")
        for i in range(0, len(lod.indices), 3):
            i0 = lod.indices[i] + 1
            i1 = lod.indices[i + 1] + 1
            i2 = lod.indices[i + 2] + 1
            if has_vt and has_vn:
                f.write(f"f {i0}/{i0}/{i0} {i1}/{i1}/{i1} {i2}/{i2}/{i2}\n")
            elif has_vn:
                f.write(f"f {i0}//{i0} {i1}//{i1} {i2}//{i2}\n")
            elif has_vt:
                f.write(f"f {i0}/{i0} {i1}/{i1} {i2}/{i2}\n")
            else:
                f.write(f"f {i0} {i1} {i2}\n")

    print(f"Wrote {out_path}")
    print(f"  {lod.vertex_count} vertices, {lod.index_count // 3} triangles")
    if tex_filename:
        print(f"  -> Import this OBJ in Blender and the texture is auto-applied.")


def cmd_convert_glb(args: argparse.Namespace) -> None:
    try:
        import pygltflib
        import numpy as np
    except ImportError:
        print("Error: pygltflib and numpy are required for glTF export.")
        print("  pip install pygltflib numpy")
        sys.exit(1)

    from sky_mesh import parse_mesh_file

    mesh = parse_mesh_file(args.file)
    lod = mesh.lods[args.lod]
    out_path = args.output or os.path.splitext(args.file)[0] + ".glb"

    pos_array = np.array(lod.positions, dtype=np.float32)
    idx_array = np.array(lod.indices, dtype=np.uint32)

    pos_min = pos_array.min(axis=0).tolist()
    pos_max = pos_array.max(axis=0).tolist()

    pos_bytes = pos_array.tobytes()
    idx_bytes = idx_array.tobytes()

    buffer_data = pos_bytes + idx_bytes
    buffer_views = [
        pygltflib.BufferView(
            buffer=0,
            byteOffset=0,
            byteLength=len(pos_bytes),
            target=pygltflib.ARRAY_BUFFER,
        ),
        pygltflib.BufferView(
            buffer=0,
            byteOffset=len(pos_bytes),
            byteLength=len(idx_bytes),
            target=pygltflib.ELEMENT_ARRAY_BUFFER,
        ),
    ]

    accessors = [
        pygltflib.Accessor(
            bufferView=0,
            componentType=pygltflib.FLOAT,
            count=len(lod.positions),
            type=pygltflib.VEC3,
            max=pos_max,
            min=pos_min,
        ),
        pygltflib.Accessor(
            bufferView=1,
            componentType=pygltflib.UNSIGNED_INT,
            count=len(lod.indices),
            type=pygltflib.SCALAR,
            max=[int(idx_array.max())],
            min=[int(idx_array.min())],
        ),
    ]

    bv_offset = len(buffer_data)
    acc_idx = 2

    norm_acc = None
    if lod.normals:
        norm_array = np.array(lod.normals, dtype=np.float32)
        norm_bytes = norm_array.tobytes()
        buffer_views.append(
            pygltflib.BufferView(
                buffer=0,
                byteOffset=bv_offset,
                byteLength=len(norm_bytes),
                target=pygltflib.ARRAY_BUFFER,
            )
        )
        accessors.append(
            pygltflib.Accessor(
                bufferView=acc_idx,
                componentType=pygltflib.FLOAT,
                count=len(lod.normals),
                type=pygltflib.VEC3,
            )
        )
        norm_acc = acc_idx
        acc_idx += 1
        buffer_data += norm_bytes
        bv_offset += len(norm_bytes)

    uv_acc = None
    if lod.uvs:
        uv_array = np.array([(u, v) for u, v, _, _ in lod.uvs], dtype=np.float32)
        uv_bytes = uv_array.tobytes()
        buffer_views.append(
            pygltflib.BufferView(
                buffer=0,
                byteOffset=bv_offset,
                byteLength=len(uv_bytes),
                target=pygltflib.ARRAY_BUFFER,
            )
        )
        accessors.append(
            pygltflib.Accessor(
                bufferView=acc_idx,
                componentType=pygltflib.FLOAT,
                count=len(lod.uvs),
                type=pygltflib.VEC2,
            )
        )
        uv_acc = acc_idx
        acc_idx += 1
        buffer_data += uv_bytes
        bv_offset += len(uv_bytes)

    attributes = pygltflib.Attributes(POSITION=0)
    if norm_acc is not None:
        attributes.NORMAL = norm_acc
    if uv_acc is not None:
        attributes.TEXCOORD_0 = uv_acc

    gltf = pygltflib.GLTF2(
        scene=0,
        scenes=[pygltflib.Scene(nodes=[0])],
        nodes=[pygltflib.Node(mesh=0, name=mesh.name)],
        meshes=[
            pygltflib.Mesh(
                primitives=[
                    pygltflib.Primitive(attributes=attributes, indices=1)
                ],
                name=mesh.name,
            )
        ],
        accessors=accessors,
        bufferViews=buffer_views,
        buffers=[pygltflib.Buffer(byteLength=len(buffer_data))],
    )
    gltf.set_binary_blob(buffer_data)
    gltf.save(out_path)
    print(f"Wrote {out_path}")
    print(f"  {lod.vertex_count} vertices, {lod.index_count // 3} triangles")


def cmd_texture(args: argparse.Namespace) -> None:
    from sky_mesh.texture import TextureResolver, decode_ktx_texture

    resolver = TextureResolver(args.data_dir)
    resolver.load()

    outfit = resolver.get_outfit(args.outfit)
    if not outfit:
        print(f"Error: outfit '{args.outfit}' not found.")
        print(f"  Available ({len(resolver.outfits)}):")
        for name in sorted(resolver.outfits)[:20]:
            print(f"    {name}")
        if len(resolver.outfits) > 20:
            print(f"    ... and {len(resolver.outfits) - 20} more")
        sys.exit(1)

    if not outfit.textures:
        print(f"Outfit '{args.outfit}' has no textures defined.")
        sys.exit(1)

    tex = outfit.textures[0]
    region = resolver.get_image_region(tex.diffuse)
    ktx_path = resolver.resolve_texture_path(tex.diffuse)

    if not ktx_path:
        print(f"Error: could not find KTX file for texture '{tex.diffuse}'")
        sys.exit(1)

    crop = None
    if region and not args.full_atlas:
        crop = region.uv
        print(f"Texture: {tex.diffuse}")
        print(f"  Atlas: {region.image} -> {ktx_path}")
        print(f"  Region UV: ({crop[0]:.3f}, {crop[1]:.3f}) to ({crop[2]:.3f}, {crop[3]:.3f})")
    else:
        print(f"Texture: {tex.diffuse}")
        print(f"  File: {ktx_path}")

    out_path = args.output or f"{args.outfit}_diffuse.png"
    w, h = decode_ktx_texture(ktx_path, out_path, crop_uv=crop)
    print(f"  Wrote {out_path} ({w}x{h})")


def cmd_level_info(args: argparse.Namespace) -> None:
    from sky_mesh.level import parse_level_meshes

    level = parse_level_meshes(args.file)
    print(level.summary())

    if args.verbose:
        for lod in level.lods:
            print(f"\n--- LOD{lod.lod_index} Detail ---")
            if lod.mesh_bakes:
                print(f"  MeshBakes ({len(lod.mesh_bakes)}):")
                for mb in lod.mesh_bakes[:50]:
                    total_verts = sum(e.source_vert_count for e in mb.lod_entries)
                    print(f"    {mb.mesh_name} (sub={mb.submesh_id}, "
                          f"lods={mb.num_lods}, verts={total_verts}, "
                          f"shared={mb.shared_bake_flag})")
                if len(lod.mesh_bakes) > 50:
                    print(f"    ... and {len(lod.mesh_bakes) - 50} more")

            if lod.terrain_meshes:
                print(f"  TerrainMeshes ({len(lod.terrain_meshes)}):")
                for tm in lod.terrain_meshes[:20]:
                    tess = "tess" if tm.tess_index_u32_count > 0 else "raw"
                    print(f"    guid=0x{tm.bst_guid:08X}: {tm.vertex_count} verts, "
                          f"{tm.index_count // 3} tris ({tess}), "
                          f"hidden={tm.is_hidden}")
                if len(lod.terrain_meshes) > 20:
                    print(f"    ... and {len(lod.terrain_meshes) - 20} more")

            if lod.skirts:
                print(f"  Skirts ({len(lod.skirts)}):")
                for sk in lod.skirts[:10]:
                    print(f"    {sk.vertex_count} verts, {sk.index_count // 3} tris")

            if lod.occluder:
                oc = lod.occluder
                print(f"  Occluder: {oc.vertex_count} verts, {oc.index_count // 3} tris")

            if lod.cloud:
                cl = lod.cloud
                vol = cl.bin_dim[0] * cl.bin_dim[1] * cl.bin_dim[2]
                print(f"  Cloud: grid {cl.bin_dim[0]}x{cl.bin_dim[1]}x{cl.bin_dim[2]} "
                      f"({vol} voxels), {cl.cloud_index_count} active bins, "
                      f"distGrid={cl.dist_grid_size}, ambGrid={cl.amb_grid_size}")


def cmd_level_dump(args: argparse.Namespace) -> None:
    from sky_mesh.level import parse_level_meshes

    level = parse_level_meshes(args.file)
    lod_idx = args.lod
    if lod_idx >= len(level.lods):
        print(f"Error: LOD {lod_idx} not found (level has {len(level.lods)} LODs)")
        sys.exit(1)

    lod = level.lods[lod_idx]
    out_path = args.output or "level_terrain.obj"
    out_dir = os.path.dirname(os.path.abspath(out_path)) or "."
    os.makedirs(out_dir, exist_ok=True)

    sources = []
    if args.type in ("terrain", "all"):
        sources.append(("terrain", lod.terrain_meshes))
    if args.type in ("skirt", "all"):
        sources.append(("skirt", lod.skirts))
    if args.type in ("occluder", "all") and lod.occluder:
        sources.append(("occluder", [lod.occluder]))

    if args.split:
        _dump_level_split(sources, out_dir, os.path.splitext(os.path.basename(out_path))[0])
    else:
        _dump_level_merged(sources, out_path)


def _dump_level_merged(sources, out_path: str) -> None:
    """Write all level geometry into a single OBJ file."""
    total_verts = 0
    total_tris = 0
    vert_offset = 0

    with open(out_path, "w") as f:
        f.write("# Sky level terrain export\n\n")

        for source_type, meshes in sources:
            for mi, mesh in enumerate(meshes):
                if source_type == "occluder":
                    positions = mesh.positions
                    indices = mesh.indices
                    normals = None
                    uvs = None
                else:
                    positions = [v.position for v in mesh.vertices]
                    normals = [v.normal for v in mesh.vertices]
                    uvs = [v.uv0 for v in mesh.vertices]
                    indices = mesh.indices

                f.write(f"\ng {source_type}_{mi}\n")
                for x, y, z in positions:
                    f.write(f"v {x:.6f} {y:.6f} {z:.6f}\n")

                if normals:
                    for nx, ny, nz in normals:
                        f.write(f"vn {nx:.6f} {ny:.6f} {nz:.6f}\n")

                if uvs:
                    for u0, v0, *_ in uvs:
                        f.write(f"vt {u0:.6f} {1.0 - v0:.6f}\n")

                has_vn = normals is not None
                has_vt = uvs is not None

                for i in range(0, len(indices), 3):
                    if i + 2 >= len(indices):
                        break
                    i0 = indices[i] + 1 + vert_offset
                    i1 = indices[i + 1] + 1 + vert_offset
                    i2 = indices[i + 2] + 1 + vert_offset
                    if has_vt and has_vn:
                        f.write(f"f {i0}/{i0}/{i0} {i1}/{i1}/{i1} {i2}/{i2}/{i2}\n")
                    elif has_vn:
                        f.write(f"f {i0}//{i0} {i1}//{i1} {i2}//{i2}\n")
                    else:
                        f.write(f"f {i0} {i1} {i2}\n")

                vert_offset += len(positions)
                total_verts += len(positions)
                total_tris += len(indices) // 3

    print(f"Wrote {out_path}")
    print(f"  {total_verts} vertices, {total_tris} triangles")


def _dump_level_split(sources, out_dir: str, prefix: str) -> None:
    """Write each submesh as a separate OBJ file."""
    file_count = 0
    for source_type, meshes in sources:
        for mi, mesh in enumerate(meshes):
            fname = f"{prefix}_{source_type}_{mi:04d}.obj"
            fpath = os.path.join(out_dir, fname)

            if source_type == "occluder":
                positions = mesh.positions
                indices = mesh.indices
                normals = None
            else:
                positions = [v.position for v in mesh.vertices]
                normals = [v.normal for v in mesh.vertices]
                indices = mesh.indices

            with open(fpath, "w") as f:
                f.write(f"# Sky level {source_type} {mi}\n\n")
                for x, y, z in positions:
                    f.write(f"v {x:.6f} {y:.6f} {z:.6f}\n")
                if normals:
                    for nx, ny, nz in normals:
                        f.write(f"vn {nx:.6f} {ny:.6f} {nz:.6f}\n")
                for i in range(0, len(indices), 3):
                    if i + 2 >= len(indices):
                        break
                    i0 = indices[i] + 1
                    i1 = indices[i + 1] + 1
                    i2 = indices[i + 2] + 1
                    if normals:
                        f.write(f"f {i0}//{i0} {i1}//{i1} {i2}//{i2}\n")
                    else:
                        f.write(f"f {i0} {i1} {i2}\n")

            file_count += 1

    print(f"Wrote {file_count} OBJ files to {out_dir}/")


def cmd_level_export(args: argparse.Namespace) -> None:
    """Full level export: terrain + placed objects to OBJ files in a directory."""
    from sky_mesh.level import parse_level_meshes
    from sky_mesh.tgcl import parse_tgcl
    from sky_mesh.mesh import parse_mesh_file

    level_dir = args.level_dir
    data_dir = args.data_dir
    out_dir = args.output or "level_export"
    os.makedirs(out_dir, exist_ok=True)
    mesh_dir = os.path.join(data_dir, "Meshes", "Bin")

    bst_path = os.path.join(level_dir, "BstBaked.meshes")
    tgcl_path = os.path.join(level_dir, "Objects.level.bin")
    level_name = os.path.basename(os.path.normpath(level_dir))

    level = parse_level_meshes(bst_path)
    lod = level.lods[0]

    bake_map = {}
    for mb in lod.mesh_bakes:
        bake_map[mb.submesh_id & 0xFFFFFFFF] = mb

    total_files = 0

    if not args.no_terrain:
        terrain_path = os.path.join(out_dir, f"{level_name}_terrain.obj")
        vert_offset = 0
        with open(terrain_path, "w") as f:
            f.write(f"# {level_name} terrain + skirts + occluder\n\n")
            for mi, tm in enumerate(lod.terrain_meshes):
                f.write(f"\ng terrain_{mi}\n")
                for v in tm.vertices:
                    f.write(f"v {v.position[0]:.6f} {v.position[1]:.6f} {v.position[2]:.6f}\n")
                for v in tm.vertices:
                    f.write(f"vn {v.normal[0]:.6f} {v.normal[1]:.6f} {v.normal[2]:.6f}\n")
                for i in range(0, len(tm.indices), 3):
                    if i + 2 < len(tm.indices):
                        i0 = tm.indices[i] + 1 + vert_offset
                        i1 = tm.indices[i + 1] + 1 + vert_offset
                        i2 = tm.indices[i + 2] + 1 + vert_offset
                        f.write(f"f {i0}//{i0} {i1}//{i1} {i2}//{i2}\n")
                vert_offset += tm.vertex_count
            for si, sk in enumerate(lod.skirts):
                f.write(f"\ng skirt_{si}\n")
                for v in sk.vertices:
                    f.write(f"v {v.position[0]:.6f} {v.position[1]:.6f} {v.position[2]:.6f}\n")
                for v in sk.vertices:
                    f.write(f"vn {v.normal[0]:.6f} {v.normal[1]:.6f} {v.normal[2]:.6f}\n")
                for i in range(0, len(sk.indices), 3):
                    if i + 2 < len(sk.indices):
                        i0 = sk.indices[i] + 1 + vert_offset
                        i1 = sk.indices[i + 1] + 1 + vert_offset
                        i2 = sk.indices[i + 2] + 1 + vert_offset
                        f.write(f"f {i0}//{i0} {i1}//{i1} {i2}//{i2}\n")
                vert_offset += sk.vertex_count
        print(f"  Terrain: {terrain_path}")
        total_files += 1

    if not args.no_objects and os.path.isfile(tgcl_path):
        scene = parse_tgcl(tgcl_path)
        placed = 0
        missing = 0

        all_objects = []
        for obj in scene.objects_by_class("LevelMesh"):
            rn = obj.fields.get("resourceName", "")
            if rn:
                all_objects.append((rn, obj.instance_name, obj.fields.get("transform"),
                                    obj.fields.get("bstGuid", 0)))
        for obj in scene.objects_by_class("Beamo"):
            mn = obj.fields.get("meshName", "")
            if mn:
                all_objects.append((mn, obj.instance_name, obj.fields.get("transform"),
                                    obj.fields.get("bstGuid", 0)))

        mesh_cache = {}
        for resource_name, inst_name, transform, bst_guid in all_objects:
            mesh_path = os.path.join(mesh_dir, f"{resource_name}.mesh")
            if not os.path.isfile(mesh_path):
                missing += 1
                continue

            if resource_name not in mesh_cache:
                try:
                    mesh_cache[resource_name] = parse_mesh_file(mesh_path)
                except Exception:
                    missing += 1
                    continue

            mesh_data = mesh_cache[resource_name]
            lod_data = mesh_data.lods[0]
            safe_name = inst_name.replace("/", "_").replace("\\", "_")
            obj_path = os.path.join(out_dir, f"{safe_name}.obj")

            with open(obj_path, "w") as f:
                f.write(f"# {inst_name} ({resource_name})\n")
                if transform and len(transform) == 16:
                    f.write(f"# transform: {' '.join(f'{v:.4f}' for v in transform)}\n")
                f.write(f"\ng {safe_name}\n")
                for x, y, z in lod_data.positions:
                    f.write(f"v {x:.6f} {y:.6f} {z:.6f}\n")
                if lod_data.normals:
                    for nx, ny, nz in lod_data.normals:
                        f.write(f"vn {nx:.6f} {ny:.6f} {nz:.6f}\n")
                for i in range(0, len(lod_data.indices), 3):
                    i0 = lod_data.indices[i] + 1
                    i1 = lod_data.indices[i + 1] + 1
                    i2 = lod_data.indices[i + 2] + 1
                    if lod_data.normals:
                        f.write(f"f {i0}//{i0} {i1}//{i1} {i2}//{i2}\n")
                    else:
                        f.write(f"f {i0} {i1} {i2}\n")
            placed += 1
            total_files += 1

        print(f"  Objects: {placed} placed, {missing} meshes not found")

    print(f"Wrote {total_files} files to {out_dir}/")


def cmd_scene_info(args: argparse.Namespace) -> None:
    from sky_mesh.tgcl import parse_tgcl

    scene = parse_tgcl(args.file)
    print(scene.summary())

    if args.verbose:
        level_meshes = scene.objects_by_class("LevelMesh")
        if level_meshes:
            print(f"\nLevelMesh objects ({len(level_meshes)}):")
            for obj in level_meshes[:50]:
                name = obj.fields.get("resourceName", obj.instance_name)
                guid = obj.fields.get("bstGuid", "?")
                mat = obj.fields.get("material", "?")
                transform = obj.fields.get("transform")
                pos_str = ""
                if transform and isinstance(transform, list) and len(transform) >= 16:
                    pos_str = f" pos=({transform[12]:.1f}, {transform[13]:.1f}, {transform[14]:.1f})"
                print(f"  {name} (guid=0x{guid:08X}, mat={mat}){pos_str}"
                      if isinstance(guid, int) else
                      f"  {name} (guid={guid}, mat={mat}){pos_str}")
            if len(level_meshes) > 50:
                print(f"  ... and {len(level_meshes) - 50} more")

        beamos = scene.objects_by_class("Beamo")
        if beamos:
            print(f"\nBeamo objects ({len(beamos)}):")
            for obj in beamos[:30]:
                name = obj.instance_name or obj.fields.get("resourceName", "?")
                guid = obj.fields.get("bstGuid", "?")
                mat_guid = obj.fields.get("materialBstGuid", "?")
                print(f"  {name} (guid={guid}, matGuid={mat_guid})")
            if len(beamos) > 30:
                print(f"  ... and {len(beamos) - 30} more")


def cmd_texture_raw(args: argparse.Namespace) -> None:
    from sky_mesh.texture import decode_ktx_texture

    out_path = args.output or os.path.splitext(os.path.basename(args.file))[0] + ".png"
    w, h = decode_ktx_texture(args.file, out_path)
    print(f"Wrote {out_path} ({w}x{h})")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Sky: Children of the Light -- .mesh decoder"
    )
    sub = parser.add_subparsers(dest="command")

    p_info = sub.add_parser("info", help="Print mesh info")
    p_info.add_argument("file", help="Path to .mesh file")
    p_info.add_argument("-v", "--verbose", action="store_true")
    p_info.set_defaults(func=cmd_info)

    p_dump = sub.add_parser("dump", help="Export to OBJ")
    p_dump.add_argument("file", help="Path to .mesh file")
    p_dump.add_argument("-o", "--output", help="Output .obj path")
    p_dump.add_argument("--lod", type=int, default=0, help="LOD index (default: 0)")
    p_dump.add_argument("-d", "--data-dir",
                        help="Path to assets/Data dir -- auto-embeds texture via .mtl")
    p_dump.set_defaults(func=cmd_dump_obj)

    p_conv = sub.add_parser("convert", help="Export to glTF/GLB")
    p_conv.add_argument("file", help="Path to .mesh file")
    p_conv.add_argument("-o", "--output", help="Output .glb path")
    p_conv.add_argument("--lod", type=int, default=0, help="LOD index (default: 0)")
    p_conv.set_defaults(func=cmd_convert_glb)

    p_tex = sub.add_parser("texture", help="Decode outfit texture to PNG")
    p_tex.add_argument("data_dir", help="Path to assets/Data directory")
    p_tex.add_argument("outfit", help="Outfit name (e.g. CharSkyKid_Body_ClassicShortPants)")
    p_tex.add_argument("-o", "--output", help="Output .png path")
    p_tex.add_argument("--full-atlas", action="store_true",
                        help="Export full atlas instead of cropping to region")
    p_tex.set_defaults(func=cmd_texture)

    p_ktx = sub.add_parser("decode-ktx", help="Decode a raw .ktx file to PNG")
    p_ktx.add_argument("file", help="Path to .ktx file")
    p_ktx.add_argument("-o", "--output", help="Output .png path")
    p_ktx.set_defaults(func=cmd_texture_raw)

    p_lvl = sub.add_parser("level-info", help="Print BstBaked.meshes info")
    p_lvl.add_argument("file", help="Path to BstBaked.meshes file")
    p_lvl.add_argument("-v", "--verbose", action="store_true")
    p_lvl.set_defaults(func=cmd_level_info)

    p_ldump = sub.add_parser("level-dump", help="Export level terrain to OBJ")
    p_ldump.add_argument("file", help="Path to BstBaked.meshes file")
    p_ldump.add_argument("-o", "--output", help="Output .obj path (default: level_terrain.obj)")
    p_ldump.add_argument("--lod", type=int, default=0, help="LOD index (default: 0)")
    p_ldump.add_argument("--type", choices=["terrain", "skirt", "occluder", "all"],
                         default="all", help="Geometry type to export (default: all)")
    p_ldump.add_argument("--split", action="store_true",
                         help="Write each submesh as a separate OBJ file")
    p_ldump.set_defaults(func=cmd_level_dump)

    p_scene = sub.add_parser("scene-info", help="Print Objects.level.bin info")
    p_scene.add_argument("file", help="Path to Objects.level.bin file")
    p_scene.add_argument("-v", "--verbose", action="store_true")
    p_scene.set_defaults(func=cmd_scene_info)

    p_lvlexp = sub.add_parser("level-export",
                               help="Full level export (terrain + placed objects) to OBJ")
    p_lvlexp.add_argument("level_dir", help="Path to Levels/<LevelName>/ directory")
    p_lvlexp.add_argument("data_dir", help="Path to assets/Data/ root directory")
    p_lvlexp.add_argument("-o", "--output", help="Output directory (default: ./level_export)")
    p_lvlexp.add_argument("--no-terrain", action="store_true", help="Skip terrain")
    p_lvlexp.add_argument("--no-objects", action="store_true", help="Skip placed objects")
    p_lvlexp.set_defaults(func=cmd_level_export)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)

    args.func(args)


if __name__ == "__main__":
    main()
