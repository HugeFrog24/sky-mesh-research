# Rigged Mesh Encoding & Decoding in Sky
> Binary: `libBootloader-Live-0.11.0-155436` (Sky Live 0.11.0)
> Goal: understand how rigged meshes (skinned character meshes on a skeleton) are encoded, stored, and decoded at runtime — and assess feasibility of a Blender-compatible exporter.

---

## 1. High-Level Architecture

Sky's mesh system is built on a custom engine (not Unity/Unreal). The hierarchy is:

```
Mesh (resource)
  └── MeshData
        ├── MeshLod[0..N]      (per-LOD vertex/index/weight data)
        └── AnimPackData        (optional: skeleton + animations baked into the mesh)
              ├── SkeletonData   (bone hierarchy, rest poses, names)
              └── AnimKeyData[]  (per-animation keyframe data)
```

A `Mesh` is a resource loaded from binary pack files (`.mesh` inside `.pack` TAR archives). Each `Mesh` carries bake-time flags/tags that fundamentally change what data is present and how it's encoded. These flags are set at asset-bake time and are baked into the binary file header.

A `LevelMesh` is a placed instance of a mesh in a level, with additional per-instance properties (transform, shader, animation, physics). An `AvatarRender` manages the special case of avatar/Sky-kid meshes with outfit swapping.

A `Model` is a runtime render object created by `ModelBarn::CreateModel(meshName, shaderName, ...)` — it binds a mesh resource to a shader program and a transform.

---

## 2. Mesh Bake Flags / Tags — Complete Catalog

These are the `Mesh` member variables registered to the meta-system. Each is a `bool` stored in the mesh header and controls what data is present in the binary file.

| Flag | String name | Effect on encoding |
|------|------------|-------------------|
| `source` | `"source"` | Path to source FBX/asset (metadata only, not used at runtime) |
| `sharedSkeleton` | `"sharedSkeleton"` | If true, skeleton data is shared with another mesh (e.g. avatar body shares skeleton with cape). The mesh itself carries no skeleton — it references an external one. |
| `loadAsync` | `"loadAsync"` | Controls whether loading happens on a background thread |
| `stripGeometry` | `"stripGeometry"` | Strips all vertex position/normal/UV data. The mesh becomes a skeleton-only container (no renderable geometry). Used for animation-only assets. |
| `stripAnimation` | `"stripAnimation"` | Strips all animation data. The mesh has geometry but no baked animations. Static meshes or meshes animated entirely by code/physics. |
| `additive` | `"additive"` | Marks the animation pack as additive (layered on top of a base pose) |
| `uncompressedAnim` | `"uncompressedAnim"` | If true, animation keyframes are stored as full float quaternions (16 bytes/key). If false, they use a compressed 8-byte half-float format. |
| `computeOcclusions` | `"computeOcclusions"` | "CompOcc" — Generates occlusion data: a separate triangle mesh + per-vertex occlusion values appended after the LOD data. Used for ambient occlusion baking on characters. |
| `computeEdges` | `"computeEdges"` | Generates edge connectivity data (for silhouette/outline rendering or shadow volume extrusion). Stored as per-vertex edge index arrays. |
| `computeAdjacency` | `"computeAdjacency"` | Generates triangle adjacency data (extends the index buffer with neighbor info). Used for geometry-shader-based effects. |
| `compressPositions` | `"compressPositions"` | Quantizes vertex positions from float32 to a compressed format (`MeshPosCompressed`). Positions are dequantized at load time using the bounding box. |
| `compressUvs` | `"compressUvs"` | Quantizes UV coordinates from float32 to a compressed fixed-point format (`MeshUvCompressed` / `MeshUvFixed`). Decompressed at load time by `DecompressUvs()`. |
| `stripUv13` | `"stripUv13"` | "StripUV" — Strips UV channels 1 and 3 (keeps only UV0 and UV2). Reduces mesh size for assets that don't need lightmap or detail UVs. |
| `stripNormals` | `"stripNormals"` | Strips vertex normals entirely. Normals are recomputed at load time from geometry via `ComputeMeshNormals()`. |
| `registerCollision` | `"registerCollision"` | Registers the mesh geometry with the `CollisionGeoBarn` for physics raycasts |
| `forceIndex32` | `"forceIndex32"` | Forces 32-bit index buffers even for small meshes. Without this, meshes with <65536 vertices use 16-bit indices. |

### What "StripUV" and "CompOcc" Mean

- StripUV = `stripUv13` flag. The mesh has only UV channel 0 (and possibly UV2). UV channels 1 and 3 have been removed to save memory. This is common for characters where only one texture atlas is needed.
  
- CompOcc = `computeOcclusions` flag. An occlusion mesh is appended after the LOD data. This is a simplified triangle mesh with per-vertex float occlusion values, used for baked ambient occlusion on character models. At load time the data is read from the `tag_Occlusion` section of the binary.

---

## 3. Binary File Format — `.mesh` File Layout

The `.mesh` file is read in two stages: `Mesh::Load` reads the version, then delegates to `MeshData::LoadFromFileBuffer`.

### Outer Header (read by `Mesh::Load`)
```
[4 bytes]     uint32: version (valid range 0x19–0x1e for this build)
              Read first, validated: (version - 0x19) < 6
              Passed to LoadFromFileBuffer as param_3
```

From hex dump of actual .mesh file:
`1e 00 00 00 43 68 61 72 ...` → version=0x1e, then mesh name "Char..."

### Inner Header (read by `LoadFromFileBuffer`, starting at byte 4)
```
[0x40 bytes]  Mesh name / identifier (null-terminated string, padded to 64 bytes)
[4 bytes]     int32: LOD count (MeshData+0x40)
[1 byte]      bool: hasAnimation (controls bone weight reading AND AnimPackData)
[1 byte]      bool: hasOcclusion (controls whether occlusion data follows LODs)
```

NOTE: `hasAnimation` means the mesh has bone weight data and a skeleton
(AnimPackData), even if `stripAnimation` was set. A mesh with `stripAnimation=true`
will have `hasAnimation=true` (bone weights + skeleton) but the AnimPackData will
contain `animationCount=0` (no baked keyframes). The engine animates it via shared
animations.

### Compression wrapper (version > 0x1a)
```
[4 bytes]     int32: compressionMode (0 = uncompressed, 1 = compressed)
if compressionMode == 1:
    [4 bytes] uint32: compressedSize
    [4 bytes] uint32: uncompressedSize
    [compressedSize bytes]  Compressed LOD data → LZ4_decompress_safe()
```

Compression algorithm: LZ4.  
`Decompress(CompressionType, input, output, compressedSize, maxOutputSize)` → returns actual
decompressed byte count. CompressionType must be 0 or 1 (both use `LZ4_decompress_safe`).
Type ≥ 2 asserts `"Invalid compression type"`. Source: `Compression.cpp`.

### Per-LOD Data — `MeshData::LoadLodsFromBuffer`

Each LOD is a `MeshLod` struct of 0x130 bytes (stride). For each of `lodCount` LODs:

```
[4 bytes]     float: LOD switchDistance (INFINITY = auto-compute from bounding box)
[12 bytes]    vec3: bounding box min (AABB)
[12 bytes]    vec3: bounding box max (AABB)
```

Version ≥ 0x1c adds:
```
[12 bytes]    vec3: skinned bounding box min
[12 bytes]    vec3: skinned bounding box max
```

Version ≥ 0x1d adds:
```
[32 bytes]    extended bounds data (0x20 bytes at offset +0x34)
[32 bytes]    extended bounds data (0x20 bytes at offset +0x54)
```

### Counts and Format Fields
```
[4 bytes]     uint32: vertexCount        (MeshLod+0x74)
[4 bytes]     uint32: indexCount         (MeshLod+0x78)
[4 bytes]     int32:  indexFormat        (MeshLod+0x7c, 0=uint16, 1=uint32)
                      Defaults to 1 (uint32). Only READ from file if version > 0x1d (0x1e+).
                      For version ≤ 0x1d: always uint32, NOT serialized in file.
[4 bytes]     int32:  morphTargetCount   (MeshLod+0x80)
[4 bytes]     int32:  edgeCount          (MeshLod+0x84)  — from computeEdges
[4 bytes]     int32:  adjacencyCount     (MeshLod+0x88)  — from computeAdjacency
[4 bytes]     int32:  boneWeightCount    (MeshLod+0x8c)  — skinning bone weights
[4 bytes]     int32:  extraIndexCount    (MeshLod+0x90)  — extra triangle strips
```

Version ≥ 0x1c adds 3 bools + 3 ints for compressed channels:
```
[1 byte]      bool: hasNormals           (local_90, default=true)
[1 byte]      bool: hasSecondaryIndices  (local_8c, default=true)
[1 byte]      bool: hasCompressedData    (local_94, default=false)
[4 bytes]     int32: compressedPosCount  (MeshLod+0xa4)
[4 bytes]     int32: compressedUvCount   (MeshLod+0xa8)
[4 bytes]     int32: compressedExtraCount(MeshLod+0xac)
```

### Bone Influence Partition
```
[16 bytes]    uint32[4]: bone influence partition (MeshLod+0x94)
              [0] = count of vertices with 1 bone influence
              [1] = count of vertices with 2 bone influences
              [2] = count of vertices with 3 bone influences
              [3] = count of vertices with 4 bone influences
              Sum = total vertex count. Vertices MUST be sorted by
              bone influence count in all vertex buffers.
```

The skinning pipeline processes each group with a dedicated optimized loop.
Position quantization uses the AABB at +0x04/+0x10 instead — see compressed position format below.

### Vertex Buffers

All buffers are flat arrays read with `BinaryStream::m_SerializeBytes`:

| Buffer | Size formula | Struct | Description |
|--------|-------------|--------|-------------|
| Positions | `vertexCount * 16` | `MeshPos` | 4 floats per vertex: x, y, z, w (w=1.0 or bone index) — 16 bytes/vert |
| Normals (if hasNormals) | `vertexCount * 4` in file | `MeshNorm` (4B) | `{int8 nx, ny, nz, nw}`: 3 components stored directly, decode as `byte/128.0`. (Alloc is +4 for alignment) |
| UVs | `vertexCount * 16` | `MeshUv` | 4 floats per vertex: u0, v0, u1, v1 (two UV channels packed) |
| Bone data (if hasAnimation) | `vertexCount * 8` | `MeshWeight` (8B) | `{uint8 boneIdx[4], uint8 weight[4]}`: weights decode as `byte/255.0`; verts sorted by influence count |
| Index buffer | `indexCount * stride` | uint16 or uint32 | stride = 2 (uint16) or 4 (uint32) based on indexFormat |
| Secondary indices (if hasSecondaryIndices) | `indexCount * stride` | uint16 or uint32 | Additional index buffer (for dual-pass rendering or edge detection) |
| Morph target indices (if morphTargetCount > 0) | `vertexCount * stride` | uint16 or uint32 | Per-vertex morph target membership |
| Edge indices (if edgeCount > 0) | `vertexCount * stride` | uint16 or uint32 | Edge connectivity for silhouette |
| Adjacency (if adjacencyCount > 0) | `adjacencyCount * stride` | uint16 or uint32 | Triangle adjacency (count × 2 indices each) |
| Bone weights (if boneWeightCount > 0) | `boneWeightCount * 4` | `MeshWeight` | Separate weight array for software skinning |
| Extra strip indices (if extraIndexCount > 0) | `extraIndexCount × 2 × stride` | uint16 or uint32 | Additional triangle strip indices |

### Summed Area Array
```
[triCount * 4 bytes]  float[triCount]: cumulative triangle area array
                      Used for random-point-on-mesh sampling
                      (computed at load if version < 0x1d; read from file if ≥ 0x1d)
```

### Compressed Position/UV Channels (version ≥ 0x1d, if compressed counts > 0)

If `compressedPosCount > 0`:
```
[vertexCount * 4]   Compressed positions (4 bytes/vert, MeshPosCompressed)
[vertexCount]       Per-vertex W component bytes (1 byte/vert)
```

MeshPosCompressed encoding (from `ComputeCompressedPositions`):
```
  uint32 packed = (X_10bit << 20) | (Y_10bit << 10) | Z_10bit

  Encoding per component:
    normalized = clamp((pos - bbMin) / (bbMax - bbMin), 0, 1)
    bits = (int)(normalized * 1023.0)

  Decoding per component:
    pos = (bits / 1023.0) * (bbMax - bbMin) + bbMin

  bbMin/bbMax = AABB at MeshLod+0x04 / +0x10
  The per-vertex W byte is MeshPos byte 15 (the high byte of the float w field).
```

If `compressedUvCount > 0`:
```
[vertexCount * 4]   Compressed UVs (4 bytes/vert, MeshUvCompressed)
```

MeshUvCompressed encoding (fully traced from `ComputeCompressedUvs` + `DecompressUvs`):

Each compressed UV is 4 bytes = 4 × uint8, one byte per UV component (u0, v0, u1, v1).
Each byte is quantized to [0, 255] using per-channel bounding boxes stored in the MeshLod:

```
MeshLod UV bounding box layout (within "extended bounds" at +0x34 and +0x54):
  +0x34: float uv0_u_min     +0x54: float uv0_u_max
  +0x38: float uv0_v_min     +0x58: float uv0_v_max
  +0x3C: float uv2_u_min     +0x5C: float uv2_u_max
  +0x40: float uv2_v_min     +0x60: float uv2_v_max
  +0x44: float uv1_u_min     +0x64: float uv1_u_max
  +0x48: float uv1_v_min     +0x68: float uv1_v_max
  +0x4C: float uv3_u_min     +0x6C: float uv3_u_max
  +0x50: float uv3_v_min     +0x70: float uv3_v_max
```

Encoding: `byte = clamp((uv_value - uv_min) / (uv_max - uv_min), 0, 1) * 255`
Decoding: `uv_value = (byte / 255.0) * (uv_max - uv_min) + uv_min`

The encoder rounds min/max through float16 for GPU precision matching,
but for offline decoding the float32 bounds work fine.

If `compressedExtraCount > 0`:
```
[vertexCount * 4]   Additional compressed channel
```

### Occlusion Data (if hasOcclusion is true)

Appended after all LODs:
```
[4 bytes]     uint32: occlusionTriCount
[4 bytes]     uint32: occlusionVertCount
[occTriCount * 3 * 4]  Occlusion triangle indices (uint32[])
[occVertCount * 4]      Occlusion vertex values (float[])
```

### Animation Data (if hasAnimation is true)

Appended after geometry (and occlusion if present). Full `AnimPackData` blob,
traced byte-by-byte from the decompiled `AnimPackData::LoadFromBuffer`:

```
─── AnimPackData Header ───
[4 bytes]     uint32: version (valid range 7–11, assertion in AnimationPack.cpp)
[0x40 bytes]  Raw pack header (serialized into this+0x00..0x3F)

─── Skeleton Counts ───
[4 bytes]     int32: boneCount          (this+0x54)
[4 bytes]     int32: animationCount     (this+0x48)
[4 bytes]     int32: frameRate          (this+0x50)
[1 byte]      uint8: compressionType    (this+0x4C)
              (0 = uncompressed anims, 1 or 2 = LZ4-compressed anims)

if version >= 10:
  [4 bytes]   uint32: boneNameTableBytes (total bytes for all bone name strings)
              (default = boneCount * 64)
              (must be <= boneCount * 64, asserts on overflow)

─── Per-Bone Data (repeated boneCount times) ───
For each bone i (0..boneCount-1):
  [64 bytes]  Bone name: null-terminated string in 64-byte buffer
              → Stored into name table at accumulated offset
              → Name offset stored as uint16 in offset array

  [64 bytes]  Inverse bind (link) matrix: float[4][4] = 4×4 matrix, 64 bytes
              → Stored at boneInvBindMats[i] (0x40 bytes each)
              → NaN-validated per row (asserts "invalid link mat on bone")
              → SKIPPED (read + discarded) if animationCount == 0

  [4 bytes]   int32: parent bone index (1-INDEXED ENCODING)
              → Stored as (actual_parent_index + 1)
              → 0 = root bone (no parent)
              → N = parent is bone N-1
              → From BoneMask::SetWeightsRecursive:
                `parent = *(int*)(parentArray + i*4) - 1`
              → Stored at boneParentIndices[i]

─── Rest Pose Data (only if animationCount > 0) ───
[boneCount * 40 bytes]  Per-bone rest pose, serialized as:
              IMPORTANT: In-memory sizeof(SQT)=0x30=48, but SERIALIZED size = 40 bytes!
              BinaryStream::Serialize(Vector3&) writes 3 floats = 12 bytes (NO padding).
              BinaryStream::Serialize(Quat&)    writes 4 floats = 16 bytes.
              Per bone serialized layout:
                Scale     → 12 bytes (3 × float32, Vector3 serialization)
                Rotation  → 16 bytes (4 × float32, Quat serialization)
                Translation → 12 bytes (3 × float32, Vector3 serialization)
              Total per bone: 12 + 16 + 12 = 40 bytes serialized (not 48!)
              The 4-byte padding in each Vector3 exists only in memory, NOT in file.

─── Animation Keyframe Data ───
if compressionType is 1 or 2 (compressed):
  [4 bytes]   uint32: compressedAnimSize
  if version >= 9:
    [4 bytes]  uint32: uncompressedAnimSize (default 0x300000 = 3MB)
  [compressedAnimSize bytes]  LZ4-compressed animation block
              → Decompress(1, input, output, compressedSize, maxSize)
              → Decompressed block parsed by LoadAnimations()

if compressionType is 0 (or ≥3):
  Animation data follows directly in the stream (uncompressed)
              → Parsed by LoadAnimations() directly from the BinaryStream

─── Post-load ───
TryComputeMirroredAnims(this)  — computes left↔right bone mirror mapping
```

Skeleton in-memory layout:
```
this+0x54 : int32   boneCount
this+0x48 : int32   animationCount
this+0x50 : int32   frameRate
this+0x4C : uint8   compressionType
this+0x58 : ptr     restPoseData (boneCount × 0x30 bytes)
this+0x60 : ptr     boneParentIndices (boneCount × int32)
this+0x68 : ptr     boneInvBindMats (boneCount × 64 bytes = 4×4 float matrices)
this+0x70 : int32   nameCount (running count during load)
this+0x74 : int32   nameByteOffset (running offset into name table)
this+0x78 : ptr     boneNameOffsets (boneCount × uint16, offset into name table)
this+0x80 : ptr     boneNameTable (concatenated null-terminated strings)
```

GetBoneName(index) returns: `nameTable[nameOffsets[index]]` (uint16 offset lookup).

### Animation Keyframe Format — `LoadAnimations` + `ReadAnimation`

The animation data follows the skeleton in the stream. Outer structure:

```
─── Animation Header ───
[4 bytes]     uint32: animationCount     (this+0x90)
[4 bytes]     uint32: totalScaleKeyCount
[4 bytes]     uint32: totalRotationKeyCount
[4 bytes]     uint32: totalTranslationKeyCount
if version >= 10:
  [4 bytes]   uint32: totalCompressedTransKeyCount
[4 bytes]     uint32: keyedIndexDataSize

─── Per-Bone Rest Pose — SECOND COPY (boneCount entries) ───
  IMPORTANT: This is a SECOND serialization of rest poses, stored inside the
  (potentially LZ4-compressed) animation block. The first copy is in
  AnimPackData::LoadFromBuffer (outer stream, see §3 above).
  Both copies must be parsed. They are likely identical data.
  Stored at AnimPackKeys+0x08 (= AnimPackData+0xa0).
For each bone:
  [12 bytes]  Scale     (Vector3: 3 × float32)
  [16 bytes]  Rotation  (Quat:    4 × float32)
  [12 bytes]  Translation (Vector3: 3 × float32)
  (40 bytes per bone serialized, NOT 48)

─── Per-Animation Data (animationCount entries) ───
Each AnimationData = 128 bytes (0x80) in memory. Binary layout:
  [4 bytes]   int32: startFrame         (this+0x00)
  [4 bytes]   int32: endFrame           (this+0x04)
  [4 bytes]   int32: flags              (this+0x08, bit 0 = has compressed scales)

  if version >= 9:
    [12 bytes]  Vector3: root motion start (this+0x10), 3 × float32
    [12 bytes]  Vector3: root motion end   (this+0x20), 3 × float32
  if version >= 11:
    [12 bytes]  Vector3: anim AABB min     (this+0x30), 3 × float32
    [12 bytes]  Vector3: anim AABB max     (this+0x40), 3 × float32

  [boneCount bytes] per-bone keying mask → ComputeAllKeyedIndices()
              Each byte is a bitmask indicating which channels this bone has:
                Bit 3: initial scale key (static scale, set once)
                Bit 0: per-frame scale key (animated scale)
                Bit 4: initial rotation key (static rotation)
                Bit 1: per-frame rotation key (animated rotation)
                Bit 5: initial translation key (static translation)
                Bit 2: per-frame translation key (animated translation)

              ComputeAllKeyedIndices builds a bone-index lookup array:
                [initial_scale_bones...][per_frame_scale_bones...]
                [initial_rot_bones...][per_frame_rot_bones...]
                [initial_trans_bones...][per_frame_trans_bones...]
              Each entry = uint8 bone index.

              AnimationData fields set by ComputeAllKeyedIndices:
                +0x70: uint16 initialScaleKeyCount    (bones with bit 3)
                +0x72: uint16 initialRotKeyCount      (bones with bit 4)
                +0x74: uint16 initialTransKeyCount    (bones with bit 5)
                +0x76: uint16 perFrameScaleKeyCount   (bones with bit 0)
                +0x78: uint16 perFrameRotKeyCount     (bones with bit 1)
                +0x7a: uint16 perFrameTransKeyCount   (bones with bit 2)

  ─── Initial Frame Keys ───
  [initialScaleKeyCount * 12]        Scale keys: Vec3 (3 × float32)
  [initialRotKeyCount * 8 or 16]     Rotation keys: see below
  [initialTransKeyCount * 6 or 12]   Translation keys: see below

  ─── Per-Frame Keys (endFrame - startFrame + 1 frames) ───
  For each frame:
    [perFrameScaleKeyCount * 12]       Scale keys
    [perFrameRotKeyCount * 8 or 16]    Rotation keys
    [perFrameTransKeyCount * 6 or 12]  Translation keys
```

Keyframe channel sizes depend on `compressionType` (from AnimPackData+0x4C):

| Channel | compressionType != 2 | compressionType == 2 |
|---------|---------------------|---------------------|
| Rotation | 16 bytes: Quaternion as 4 × float32 | 8 bytes: Quaternion as 4 × float16 (half-precision) |
| Translation | 12 bytes: Vec3 as 3 × float32 | 6 bytes: Vec3 as 3 × float16 ONLY if BOTH compressionType==2 AND per-anim flags&1; otherwise 12 bytes float32 even when compressionType==2 |
| Scale | 12 bytes: Vec3 as 3 × float32 | 12 bytes: Vec3 as 3 × float32 (same) |

The "compressed" animation format is simply IEEE 754 half-precision (float16).
No exotic quantization — standard `numpy.float16` / Python `struct.unpack('<e')` decoding.

AnimPackKeys in-memory layout (key storage arrays):
```
+0x00 : uint32   boneCount
+0x08 : ptr      restPoseData (boneCount × 48 bytes)
+0x18 : ptr      uncompressedRotationKeys (count × 16 bytes)   — float32 quaternions
+0x20 : ptr      compressedRotationKeys (count × 8 bytes)      — float16 quaternions
+0x28 : ptr      scaleKeys (count × 12 bytes)                  — float32 vec3
+0x30 : ptr      translationKeys (count × 12 bytes)            — float32 vec3
+0x38 : ptr      compressedTranslationKeys (count × 6 bytes)   — float16 vec3
+0x40 : ptr      keyedIndexData
```

---

## 4. The Skinning Pipeline for Rigged Meshes

A "rigged mesh" in Sky is one where `hasAnimation == true`. The engine provides several skinning code paths:

| Function | Description |
|----------|-------------|
| `SkinMesh(outPos, meshLod, boneMatrices)` | Full software skinning: transforms positions by weighted bone matrices. Uses bone data embedded in the MeshLod struct. |
| `SkinMeshRigid(outPos, meshLod, boneMatrices)` | Rigid skinning: each vertex is bound to exactly one bone (no blending). Faster but less smooth. |
| `SkinMeshPosAndNormals(outPos, outNorm, meshLod, boneMatrices)` | Skins both positions and normals in one pass. |
| `SkinVertsNormsLoop<4>(outPos, inPos, outNorm, inNorm, weights, count, matrices)` | Inner loop for 4-bone-per-vertex skinning. The `<4>` template parameter = max bones per vertex. |
| `SkinMesh(outPos, inPos, weights, boneIndices, count, matrices)` | Explicit-parameter variant taking separate weight/index arrays. |

### Vertex position format — `MeshPos`

From `ComputeMeshBounds`, positions are accessed at stride 0x10 (16 bytes), with XYZ at offsets 0/4/8 within each vertex:
```c
pfVar3 = (float *)(meshLod->positions + 8);  // starts at byte 8 (Z component)
pfVar3[-2]  // X
pfVar3[-1]  // Y
pfVar3[0]   // Z
pfVar3 + 4  // next vertex (stride = 16 bytes)
```

So `MeshPos` = `{ float x, y, z, w }` — 16 bytes. The `w` component is typically 1.0, or may encode a bone index for rigid skinning.

### Bone weight format — `MeshWeight`

From `SkinVertsNormsLoop<4>` and `SkinMeshPosAndNormals`:
- `MeshWeight` = 8 bytes: `{ uint8 boneIndex[4], uint8 weight[4] }`
- Bytes 0–3: bone indices (each indexes into the bone matrix array)
- Bytes 4–7: bone weights (each `/ 255.0` to get float weight)
- Weights sum to ~255 (1.0 after normalization)

Vertex sorting by bone influence count:
Vertices in all buffers (positions, normals, UVs, weights) are sorted into groups by how
many bone influences they use. The partition counts at MeshLod+0x94 define group sizes:
```
  Vertices [0 .. count1)                     → 1 bone influence
  Vertices [count1 .. count1+count2)         → 2 bone influences
  Vertices [count1+count2 .. +count3)        → 3 bone influences
  Vertices [count1+count2+count3 .. +count4) → 4 bone influences
```
For 1-bone vertices, only `boneIndex[0]` and `weight[0]` are meaningful.
For 2-bone vertices, indices 0-1 and weights 0-1 are used, etc.

### Normal format — `MeshNorm`

`MeshNorm` = 4 bytes: `{ int8 nx, int8 ny, int8 nz, int8 nw }` — all 3 normal components
are stored directly. Z is NOT reconstructed.

Encoding (from `PackNormals` implementation):
```c
  // Normalize input vector
  float invLen = rsqrt(nx*nx + ny*ny + nz*nz);
  float scale = invLen * 127.99;
  // Pack into 4-byte word: X in byte 0, Y in byte 1, Z in byte 2, W in byte 3
  packed = (int)(nx * scale) | ((int)(ny * scale) << 8) | ((int)(nz * scale) << 16);
  // Clamped to [-128, 127] per component
```

Decoding (from `SkinMeshPosAndNormals` skinning code):
```c
  float nx = (float)(int8)byte0 * 0.0078125f;  // = byte / 128.0
  float ny = (float)(int8)byte1 * 0.0078125f;
  float nz = (float)(int8)byte2 * 0.0078125f;
  // byte3 (nw) is unused in skinning — possibly tangent sign
```

The 0.0078125 = 1/128 factor (decoding) vs 127.99 (encoding) introduces a sub-percent bias
that is negligible for normalized direction vectors.

### UV format — `MeshUv`

Standard UVs are 16 bytes per vertex: `{ float u0, v0, u1, v1 }` — two UV channels interleaved. When `stripUv13` is set, only channels 0 and 2 are present.

When `compressUvs` is set, UVs use `MeshUvCompressed` (4 bytes per vertex, quantized) and are expanded at load time by `DecompressUvs()`.

---

## 5. Shader Types / Render Passes

When creating a model, `ModelBarn::CreateModel(meshName, shaderName, ...)` selects the rendering pipeline. Shader names observed in the binary:

| Shader name | Usage | Notes |
|-------------|-------|-------|
| `"Mesh"` | Default mesh rendering | Standard opaque mesh with lighting |
| `"MeshSl"` | Skinned/lit mesh | Used for animated characters (CrabB, civilians) — "Sl" likely = "Skinned Lit" |
| `"MeshMotion"` | Motion-vector mesh | Used for motion blur on animated objects |
| `"DirectionalLighting"` | Simple directional lit | Static objects, no skinning |
| `"DirectionalLightingNoUv"` | Directional lit, no UVs | Objects without textures |
| `"UnlitAlpha"` | Unlit + alpha blend | Transparent effects (candle shafts, mushrooms) |
| `"UnlitAlphaColor"` | Unlit + alpha + vertex color | Flat-shaded transparent planes |
| `"UnlitAlphaFading"` | Unlit + alpha + distance fade | Light shafts |
| `"UnlitAlphaProjected"` | Unlit + alpha + projection | Projected decals |
| `"UnlitColor"` | Unlit + solid color | Debug spheres |
| `"Candle"` | Candle-specific shader | Flame rendering |
| `"Cham"` | Chameleon/color-shift shader | Used for chameleon effects |
| `"LitAlphaTest"` | Lit + alpha test | Flame ring bases |
| `"DarkStoneNoBake"` | Dark stone material | No lightmap bake |
| `"RepulsionField"` | Force field effect | Constellation gates |

The `ModelRenderPass` enum defines pipeline stages:
- `kModelRenderPass_Default` (0) — main color pass
- `kModelRenderPass_Motion` (1) — motion vector pass
- `kModelRenderPass_DepthPrepass` (2) — depth pre-pass
- `kModelRenderPass_Sprites` (3) — sprite/particle pass
- `kModelRenderPass_Count` (4)

---

## 6. Avatar (Sky Kid) Mesh Pipeline

Avatar meshes are the most complex case. The pipeline:

1. `AvatarOutfit` manages the cosmetic state (what the player is wearing). It holds outfit slot hashes and resolves them to mesh resource names.

2. `AvatarRender::GetMeshDataFromOutfit()` resolves the outfit state to actual mesh data, looking up meshes by name from the resource manager. Each outfit piece is a separate `Mesh` resource.

3. `AvatarRender::Update()` runs every frame:
   - Gets the current skeleton pose from `AvatarPose` (which runs the `AnimationInstance` blend tree)
   - Calls `SkinMeshPosAndNormals()` or `SkinVertsNormsLoop<4>()` to deform the mesh onto the skeleton
   - Submits the deformed mesh to the render lists

4. `AvatarRender::TriangleRangeForOutfit()` — determines which triangles of the combined avatar mesh belong to which outfit piece (for per-piece shader assignment).

5. `AvatarRender::RandomPosOnMesh()` — picks random positions on the avatar surface for particle emission (wing glow, charcoal effects).

6. The skeleton is managed by `AnimationInstance`:
   - `GetBoneCount()` — returns the bone count (max 256)
   - `GetBoneRestMatrixByIndex()` — returns the inverse bind pose matrix for a bone
   - Bone names are 64-byte null-terminated strings in the skeleton data

---

## 7. The Clump System (Scene Graph Containers)

`Clump` objects are Sky's scene-graph nodes. They're containers that group related objects (meshes, lights, events, etc.) into logical units for level loading. A clump can contain:
- `LevelMesh` instances
- `Event` nodes
- Lights, collision, etc.

`ClumpBarn` manages clump lifecycle: `CreateClump`, `CreateClumpWithSize`, `ReleaseClump`.

For mesh decoding purposes, clumps are not directly relevant — the mesh data is self-contained within the `Mesh` resource binary. Clumps reference meshes by name.

---

## 8. Feasibility Assessment — Blender Exporter/Decoder

### Extractable Data Summary

| Data | Complexity |
|------|-----------|
| Vertex positions (float32 × 3) | Low — 16 bytes/vert `{float x,y,z,w}`, stride 0x10 |
| Compressed positions | Low — 10-10-10 bit pack + AABB denormalization |
| Vertex normals | Low — 4 bytes `{int8 x,y,z,w}`, decode: `byte/128.0`, all 3 stored |
| UV coordinates | Low — 16 bytes/vert `{float u0,v0,u1,v1}` |
| Compressed UVs | Medium — per-channel bounding-box quantization |
| Triangle indices (uint16/uint32) | Low — size depends on `indexFormat` flag |
| Bone weights + indices | Low — 8 bytes: `{uint8 idx[4], uint8 wt[4]}`, wt/255.0 |
| Bone influence partition | Low — 4×uint32 at +0x94, vertices sorted by influence count |
| Skeleton hierarchy | Low — per-bone: 64B name + 64B inv-bind mat + 4B parent (1-indexed, 0=root) |
| LZ4 compression | Low — standard `LZ4_decompress_safe`, Type 0 or 1 |
| Animation (uncompressed) | Low — 4×float32 quat + 3×float32 vec3 |
| Animation (compressed) | Low — float16 (half-precision): 4×float16 quat + 3×float16 vec3. Standard IEEE 754 |
| Bounding boxes | Low |
| LOD data | Low — repeat per LOD, stride 0x130 |

### Key Format Notes

- No file magic: The `.mesh` binary has no magic bytes. You must know the version (0x19–0x1e) and parse sequentially.
- Version sensitivity: Format changes between versions. Each version adds fields (documented in §3).
- Pack files: Standard POSIX USTAR TAR archives — `tar xf` or Python `tarfile`. See §13.
- Compression: LZ4 throughout — both mesh LOD wrapper and animation data use `LZ4_decompress_safe()`.

### Verdict: Fully Feasible

All critical data formats are fully documented:

- Triangle mesh geometry — positions (float32 or 10-10-10 compressed), normals (3×int8, all stored), UVs (float32 or compressed), indices (u16/u32)
- Armature (skeleton) — bone names (64B strings), parent hierarchy (int32), inverse bind matrices (4×4 float)
- Vertex groups (bone weight painting) — `{uint8 idx[4], uint8 wt[4]}`, vertices sorted by influence count
- UV maps — up to 2 channels (4 channels if `stripUv13` is not set)
- LODs — multiple detail levels with bounding boxes
- Animations — uncompressed (float32) or compressed (float16 — standard IEEE 754 half-precision) + outer LZ4 wrapper

See §13 for pack files, §14 for textures/materials, §17–§18 for level maps, §27 for level materials.

### Recommended approach

1. Phase 1 — Pack file extraction: `.pack` files are standard TAR archives — use `tar xf` or Python `tarfile` module. See §13.

2. Phase 2 — Mesh geometry decoder (Python):
   - Parse the binary stream following the `LoadFromFileBuffer` / `LoadLodsFromBuffer` layout documented above
   - Handle version differences (0x19–0x1e)
   - Handle LZ4 compression wrapper (`pip install lz4`)
   - Output positions, normals, UVs, indices as arrays
   - Handle compressed positions (10-10-10 bit unpacking + AABB denormalization)

3. Phase 3 — Skeleton + weights decoder:
   - Parse `AnimPackData::LoadFromBuffer` byte-by-byte (format fully documented above)
   - Per bone: read 64B name, 64B inverse bind matrix (4×4 float), 4B parent index
   - Map vertex bone weights/indices to named bones
   - Handle bone influence partition (vertices sorted by influence count)

4. Phase 4 — Animation decoder:
   - Parse animation header (startFrame, endFrame, flags)
   - Read per-frame keyframe channels: scale (vec3), rotation (quat), translation (vec3)
   - If compressionType == 2: decode float16 rotations/translations with `struct.unpack('<e')` or `numpy.float16`
   - If compressionType == 0: read float32 directly

5. Phase 5 — Blender import script:
   - Create mesh from vertex/index arrays
   - Create armature from bone data (names, parents, inverse bind matrices)
   - Assign vertex groups from weights
   - Apply UV maps
   - Import animation as keyframed actions

---

## 9. MeshLod Internal Layout Summary (0x130 bytes)

| Offset | Size | Type | Field |
|--------|------|------|-------|
| +0x00 | 4 | float | LOD switch distance |
| +0x04 | 12 | vec3 | AABB min |
| +0x10 | 12 | vec3 | AABB max |
| +0x1c | 12 | vec3 | Skinned AABB min (v≥0x1c) |
| +0x28 | 12 | vec3 | Skinned AABB max (v≥0x1c) |
| +0x34 | 32 | — | Extended bounds A (v≥0x1d) |
| +0x54 | 32 | — | Extended bounds B (v≥0x1d) |
| +0x74 | 4 | uint32 | Vertex count |
| +0x78 | 4 | uint32 | Index count |
| +0x7c | 4 | int32 | Index format (0=u16, 1=u32) |
| +0x80 | 4 | int32 | Morph target count |
| +0x84 | 4 | int32 | Edge count |
| +0x88 | 4 | int32 | Adjacency count |
| +0x8c | 4 | int32 | Bone weight count |
| +0x90 | 4 | int32 | Extra strip index count |
| +0x94 | 16 | uint32[4] | Bone influence partition: [count_1bone, count_2bone, count_3bone, count_4bone] |
| +0xa4 | 4 | int32 | Compressed position count |
| +0xa8 | 4 | int32 | Compressed UV count |
| +0xac | 4 | int32 | Compressed extra count |
| +0xb0 | 8 | ptr | → Position buffer (`MeshPos[]`) |
| +0xb8 | 8 | ptr | → Normal buffer (`MeshNorm[]`) |
| +0xc0 | 8 | ptr | → UV buffer (`MeshUv[]`) |
| +0xc8 | 8 | ptr | → Compressed positions (`MeshPosCompressed[]`) |
| +0xd0 | 8 | ptr | → Compressed flags/data |
| +0xd8 | 8 | ptr | → Compressed UVs (`MeshUvCompressed[]`) |
| +0xe0 | 8 | ptr | → Compressed extra |
| +0xe8 | 8 | ptr | → Bone weight/index buffer |
| +0xf0 | 8 | ptr | → Primary index buffer |
| +0xf8 | 8 | ptr | → Secondary index buffer |
| +0x100 | 8 | ptr | → Morph target indices |
| +0x108 | 8 | ptr | → Edge/remap indices (vertexCount × uint16/uint32; also used as vertex remap by MeshBake system) |
| +0x110 | 8 | ptr | → Adjacency indices |
| +0x118 | 8 | ptr | → Bone weight array (separate) |
| +0x120 | 8 | ptr | → Extra strip indices |
| +0x128 | 8 | ptr | → Summed area array (float[triCount]) |

---

## 10. Per-Vertex Data Formats

| Struct | Size | Layout |
|--------|------|--------|
| `MeshPos` | 16 bytes | `float x, y, z, w` — w=1.0 or rigid bone index |
| `MeshPosOld` | 12 bytes | `float x, y, z` — pure position (no W byte). NOT legacy — actively used for cloth/cape simulation to store previous-frame positions. Copied from MeshPos by stripping the alpha byte. |
| `MeshPosCompressed` | 4 bytes | 10-10-10-2 packed: `(X<<20)\|(Y<<10)\|Z`, each 10 bits = `clamp((pos-bbMin)/(bbMax-bbMin), 0,1) * 1023` |
| `MeshNorm` | 4 bytes | `int8 nx, int8 ny, int8 nz, int8 nw` — all 3 components stored; encode: `(int)(n*127.99)`; decode: `byte/128.0` |
| `MeshUv` | 16 bytes | `float u0, v0, u1, v1` — two UV channels |
| `MeshUvFixed` | 16 bytes | 4 UV channels × 2 × float16: `{u0,v0,u1,v1,u2,v2,u3,v3}` as 8 × half-float. Used as intermediate before compression. `ComputeCompressedUvs` reads from this format and quantizes to MeshUvCompressed (4 × uint8). |
| `MeshUvCompressed` | 4 bytes | `uint8 u0, v0, u1, v1` — each byte = `clamp((uv - min) / (max - min), 0, 1) * 255`; bounds at MeshLod +0x34/+0x54 |
| `MeshWeight` | 8 bytes | `uint8 boneIdx[4], uint8 weight[4]` — weights decode as `byte / 255.0`; vertices sorted by influence count |
| `MeshVert` | 48 bytes | Interleaved: `MeshPos + MeshNorm + MeshUv` zipped by `ZipVerts()` |
| `MeshLight` | 12 bytes | Per-vertex baked lighting. Layout: `{Color32 rgbd(4B), uint8 ao, uint8 shadow, uint8 lightExp, uint8 lightMant, uint8 nx, uint8 ny, uint8 nz, uint8 ambient}`. RGBD = HDR color. Light intensity = `ldexpf(mant/255, exp^0x80 - 0x80) / 1000`. Normals = `byte/255*2-1`. Shadow = `(byte/255)²`. |

---

## 11. Key Functions for a Decoder Author

| Function | Purpose |
|----------|---------|
| `MeshData::LoadFromFileBuffer` | Top-level entry point — parse header, handle compression, dispatch to LOD loader |
| `MeshData::LoadLodsFromBuffer` | Per-LOD data reader — this IS the format spec |
| `AnimPackData::LoadFromBuffer` | Skeleton + animation reader |
| `DecompressUvs` | UV decompression (compressed → float) |
| `ComputeMeshBounds` | Demonstrates position buffer access pattern |
| `ComputeSummedAreaArray` | Demonstrates index + position buffer access together |
| `SkinMesh` / `SkinMeshPosAndNormals` | Demonstrates bone weight/matrix application |
| `ComputeMeshNormals` | Demonstrates normal computation from geometry |
| `ZipVerts` | Shows interleaved vertex format: Pos+Norm+UV → MeshVert |
| `Mesh::Load` | Resource-level loader: opens pack file, reads version, calls MeshData |
| `Mesh::GetFilenames` | Builds the full `.mesh` filename from resource name + bake flag suffixes |

---

## 12. Decoder Pseudocode — Complete Reference

Below is implementation-ready pseudocode covering all data formats.

### Position Decoding

```python
# Uncompressed (16 bytes/vert)
def read_positions(stream, vertex_count):
    positions = []
    for i in range(vertex_count):
        x, y, z, w = struct.unpack('<ffff', stream.read(16))
        positions.append((x, y, z))
    return positions

# Compressed (4 bytes/vert + 1 byte/vert W)
def read_compressed_positions(stream, vertex_count, aabb_min, aabb_max):
    positions = []
    packed_data = stream.read(vertex_count * 4)
    w_bytes = stream.read(vertex_count)
    for i in range(vertex_count):
        packed = struct.unpack_from('<I', packed_data, i * 4)[0]
        x10 = (packed >> 20) & 0x3FF
        y10 = (packed >> 10) & 0x3FF
        z10 = packed & 0x3FF
        x = (x10 / 1023.0) * (aabb_max[0] - aabb_min[0]) + aabb_min[0]
        y = (y10 / 1023.0) * (aabb_max[1] - aabb_min[1]) + aabb_min[1]
        z = (z10 / 1023.0) * (aabb_max[2] - aabb_min[2]) + aabb_min[2]
        positions.append((x, y, z))
    return positions
```

### Normal Decoding

```python
def read_normals(stream, vertex_count):
    normals = []
    data = stream.read(vertex_count * 4)
    for i in range(vertex_count):
        nx = struct.unpack_from('b', data, i * 4 + 0)[0] / 128.0
        ny = struct.unpack_from('b', data, i * 4 + 1)[0] / 128.0
        nz = struct.unpack_from('b', data, i * 4 + 2)[0] / 128.0
        # byte 3 (nw) is typically unused / tangent sign
        normals.append((nx, ny, nz))
    return normals
```

### Bone Weight Decoding

```python
def read_bone_weights(stream, vertex_count, bone_partition):
    weights = []
    data = stream.read(vertex_count * 8)
    count1, count2, count3, count4 = bone_partition
    for i in range(vertex_count):
        indices = struct.unpack_from('4B', data, i * 8)
        raw_wt  = struct.unpack_from('4B', data, i * 8 + 4)
        # Determine how many influences this vertex actually uses
        if i < count1:
            n = 1
        elif i < count1 + count2:
            n = 2
        elif i < count1 + count2 + count3:
            n = 3
        else:
            n = 4
        vertex_weights = []
        for j in range(n):
            vertex_weights.append((indices[j], raw_wt[j] / 255.0))
        weights.append(vertex_weights)
    return weights
```

### Compressed UV Decoding

```python
def read_compressed_uvs(stream, vertex_count, meshlod_uv_bounds):
    """
    meshlod_uv_bounds: dict with keys from MeshLod offsets:
      uv0_u_min (+0x34), uv0_v_min (+0x38), uv0_u_max (+0x54), uv0_v_max (+0x58)
      uv1_u_min (+0x44), uv1_v_min (+0x48), uv1_u_max (+0x64), uv1_v_max (+0x68)
    """
    uvs = []
    data = stream.read(vertex_count * 4)
    b = meshlod_uv_bounds
    for i in range(vertex_count):
        u0_byte, v0_byte, u1_byte, v1_byte = struct.unpack_from('4B', data, i * 4)
        u0 = (u0_byte / 255.0) * (b['uv0_u_max'] - b['uv0_u_min']) + b['uv0_u_min']
        v0 = (v0_byte / 255.0) * (b['uv0_v_max'] - b['uv0_v_min']) + b['uv0_v_min']
        u1 = (u1_byte / 255.0) * (b['uv1_u_max'] - b['uv1_u_min']) + b['uv1_u_min']
        v1 = (v1_byte / 255.0) * (b['uv1_v_max'] - b['uv1_v_min']) + b['uv1_v_min']
        uvs.append((u0, v0, u1, v1))
    return uvs
```

### Skeleton Decoding

```python
def read_skeleton(stream, version):
    ver = struct.unpack('<I', stream.read(4))[0]
    assert 7 <= ver <= 11
    header = stream.read(0x40)  # pack header

    bone_count = struct.unpack('<i', stream.read(4))[0]
    anim_count = struct.unpack('<i', stream.read(4))[0]
    frame_rate = struct.unpack('<i', stream.read(4))[0]
    compression_type = struct.unpack('B', stream.read(1))[0]

    bone_name_table_bytes = bone_count * 64
    if ver >= 10:
        bone_name_table_bytes = struct.unpack('<I', stream.read(4))[0]

    bones = []
    for i in range(bone_count):
        name_buf = stream.read(64)
        name = name_buf.split(b'\x00')[0].decode('ascii')

        if anim_count > 0:
            inv_bind_mat = struct.unpack('<16f', stream.read(64))  # 4x4 matrix
        else:
            stream.read(64)  # skip
            inv_bind_mat = None

        raw_parent = struct.unpack('<i', stream.read(4))[0]
        parent_idx = raw_parent - 1   # 1-indexed: 0 = root (-1), N = bone N-1
        bones.append({'name': name, 'parent': parent_idx, 'inv_bind': inv_bind_mat})

    # Rest pose (SQT per bone) — if animations exist
    rest_poses = []
    if anim_count > 0:
        for i in range(bone_count):
            # CRITICAL: Serialized as 12 + 16 + 12 = 40 bytes per bone (NOT 48!)
            # Vector3 serializes as 3 floats (12 bytes, no padding)
            # Quat serializes as 4 floats (16 bytes)
            sx, sy, sz = struct.unpack('<fff', stream.read(12))       # scale (3 floats)
            rx, ry, rz, rw = struct.unpack('<ffff', stream.read(16))  # rotation quat
            tx, ty, tz = struct.unpack('<fff', stream.read(12))       # translation (3 floats)
            rest_poses.append({
                'scale': (sx, sy, sz),
                'rotation': (rx, ry, rz, rw),
                'translation': (tx, ty, tz)
            })

    return bones, anim_count, frame_rate, compression_type, rest_poses
```

---

## 13. Pack File Format — `.pack` Files

### Pack files are standard POSIX TAR archives

The `ResourcePack::Load` function directly parses USTAR (POSIX tar) header fields at the correct offsets using `sscanf("%o")` (octal ASCII parsing), confirming that `.pack` files are standard tar archives.

### `ResourcePack::Load` (at offset 1496458)

```c
ResourcePack::Load(this, vfs, path, buffer, maxSize) {
    this->entryCount = 0;
    Vfs::ReadFile(vfs, path, buffer, maxSize, &readSize);
    this->basePtr = buffer;

    char* entry = buffer;
    while (entry[0x94] != '\0') {           // TAR checksum field ≠ 0 → valid entry
        entries[count].headerPtr = entry;
        sscanf(entry + 0x7C, "%o", &size);  // TAR size field (12 bytes, octal ASCII)
        sscanf(entry + 0x88, "%o", &mtime); // TAR mtime field (12 bytes, octal ASCII)
        entries[count].dataPtr = entry + 0x200;  // Data starts after 512-byte header
        entry += 0x200 + ((size + 0x1FF) & 0xFFFFFE00);  // Advance by header + padded data
        count++;
    }
    assert(count <= 0x800);  // kMaxPackEntries = 2048
}
```

### TAR header field mapping (standard USTAR)

| TAR Offset | Size | Field | Used by Sky |
|------------|------|-------|-------------|
| 0x00 | 100 | Filename (null-terminated) | Matched by `ResourcePack::GetFile` via `strncmp(..., 99)` |
| 0x64 | 8 | File mode (octal ASCII) | Not parsed |
| 0x6C | 8 | Owner UID (octal ASCII) | Not parsed |
| 0x74 | 8 | Group GID (octal ASCII) | Not parsed |
| 0x7C | 12 | File size (octal ASCII) | Parsed: `sscanf(entry+0x7C, "%o", &size)` |
| 0x88 | 12 | Modification time (octal ASCII) | Parsed: `sscanf(entry+0x88, "%o", &mtime)` |
| 0x94 | 8 | Checksum | Used as validity sentinel: `entry[0x94] != '\0'` |
| 0x9C | 1 | Type flag | Not parsed (all regular files) |
| 0x101 | 6 | "ustar" magic | Not checked |
| 0x200 | — | Start of file data | `entries[n].dataPtr = entry + 0x200` |

Data is padded to 512-byte boundaries: `alignedSize = (size + 511) & ~511`.

### `ResourcePack::GetFile` — File lookup

```c
ResourcePack::GetFile(this, name, outSize, outMtime) {
    for (i = 0; i < this->entryCount; i++) {
        if (strncmp(entries[i].headerPtr, name, 99) == 0) {
            *outSize = entries[i].size;
            *outMtime = entries[i].mtime;  // if requested
            return entries[i].dataPtr;     // pointer to file content in memory
        }
    }
    return NULL;  // not found
}
```

### ResourcePack entry struct (0x18 = 24 bytes per entry)

```
+0x00: char*   headerPtr   → points to tar header (filename at byte 0)
+0x08: uint32  fileSize    → parsed from octal at header+0x7C
+0x0C: uint32  modTime     → parsed from octal at header+0x88
+0x10: char*   dataPtr     → header + 0x200 (start of file content)
```

### Practical extraction

Since `.pack` files are standard tar, extraction is trivial:

```bash
# Command line
tar xf Data/Packs/SomePack.pack

# Python
import tarfile
with tarfile.open("Data/Packs/SomePack.pack", "r:") as tar:
    tar.extractall()
    # Individual files: tar.getmember("Data/Meshes/Bin/SomeModel.mesh")
```

### Resource naming convention (`GetResourcePackName`)

```c
GetResourcePackName(resourcePath, outPackName) {
    lastSlash = strrchr(resourcePath, '/');
    sprintf(outPackName, "Data/Packs/%s", lastSlash + 1);
    lastDot = strrchr(outPackName, '.');
    strncpy(lastDot, ".pack", 6);
}
```

Examples:
- `"Data/Resources/Persistent.lua"` → `"Data/Packs/Persistent.pack"`
- `"Data/Levels/Dawn/Resources.lua"` → `"Data/Packs/Resources.pack"`

### File path conventions (inside packs or loose on VFS)

| Resource type | Path pattern | Extension |
|--------------|-------------|-----------|
| Mesh | `Data/Meshes/Bin/{name}.mesh` | `.mesh` |
| Animation pack | `Data/Meshes/Bin/{name}.animpack` | `.animpack` |
| Animation list | `Data/Meshes/Bin/AnimationList.dat` | `.dat` |
| Image/Texture | `Data/Images/Bin/{name}.ktx` | `.ktx` |
| Level data | `Data/Levels/{level}/BstBaked.meshes` | `.meshes` |
| Resource script | `Data/Resources/{name}.lua` | `.lua` |
| Level resources | `Data/Levels/{level}/Resources.lua` | `.lua` |
| Outfit definitions | `Data/Resources/OutfitDefs.json` | `.json` |
| NPC definitions | `Data/Resources/NpcDefs.json` | `.json` |
| Shader programs | `Data/Shaders/{platform}/{name}.{stage}.{variant}` | varies |
| Fonts | `Data/Fonts/Bin/{name}` | varies |

### VFS layer — `Vfs::ReadFile`

The Virtual File System has two backends:

1. Android Asset Manager (`AAssetManager_open`) — reads from APK assets when base path is empty
2. File system (`fopen`) — reads from disk when base path is set:
   ```c
   snprintf(path, 0x200, "%s/%s", basePath, requestedFile);
   fopen(path, "r");
   ```

The base path is typically the game's data directory on device storage (e.g., OBB expansion file location). On a rooted device, game data can be found extracted under `/data/data/com.tgc.sky.android/` or the OBB location at `/sdcard/Android/obb/com.tgc.sky.android/`.

### Resource loading pipeline

1. Game calls `ResourceManager::LoadResources(luaState, "Data/Resources/Persistent.lua", heap, ...)`
2. `GetResourcePackName` converts to `"Data/Packs/Persistent.pack"`
3. If pack exists: `malloc(0x4000000)` (64MB), `Vfs::ReadFile` reads entire pack, `ResourcePack::Load` parses tar headers
4. Lua script executes: `resourceTable = {}`, dofile(script), `QueueResourcesForLoad(resourceTable)`
5. For each queued resource: if pack loaded → `ResourcePack::GetFile(name)` returns pointer+size; else → `ResourceManager::ReadFile` reads from VFS directly
6. Mesh resources: `Mesh::Load` → version check → `MeshData::LoadFromFileBuffer` (§3)

### Resource Lua scripts loaded at boot

```
Data/Resources/ImageDefs.lua        → image/texture definitions
Data/Resources/SoundDefs.lua        → sound definitions
Data/Resources/Boot.lua             → boot-time resources
Data/Resources/StreamableDefs.lua   → streamable resource definitions
Data/Resources/Persistent.lua      → persistent resources (always loaded)
Data/Levels/{level}/Resources.lua  → per-level resources (loaded/unloaded with levels)
```

---

## 14. Texture & Material System

### Texture file format: KTX1 with pre-transcoded GPU data

Textures are stored at `Data/Images/Bin/ETC2/{name}.ktx` (or `ASTC/` on devices
supporting ASTC). Files are KTX1 containers with pre-transcoded, GPU-ready
compressed texture data. The format subdirectory is selected at path construction
time by `Image::Load`.

Basis Universal is dead code at runtime. The binary contains the full
`basist::basisu_transcoder` library (statically linked), but no code path in
`Image::Load` or any texture-loading function calls it. Basis transcoding happens
at build time in the asset pipeline: source textures → `.basis` → per-platform
KTX1 outputs with ETC2 or ASTC data baked in.

The runtime flow:
1. Build path: `"Data/Images/Bin/" + formatDir + "/" + name + ".ktx"`
2. Load `.ktx` file, validate KTX1 header (magic, endianness, no cubemaps, no arrays)
3. Read `glInternalFormat` from KTX header offset 0x1C
4. `Texture::MapBuffer` (Vulkan staging buffer) → `memcpy` compressed data directly
5. If device lacks hardware ASTC support: software `ASTC::Decompress` → RGBA fallback
6. `Texture::UnmapBuffer` → GPU upload

The renderer is Vulkan-based (`VulkanRenderer::CreateTexture`), not OpenGL.
GL format enums in the KTX header are used only for format identification.

### Supported GL format enums (from KTX header)

| GL Enum | Format | Internal Code |
|---------|--------|---------------|
| `0x9274`/`0x9275` | `GL_COMPRESSED_RGB8_ETC2` / sRGB | 0x20 / 0x22 |
| `0x9278`/`0x9279` | `GL_COMPRESSED_RGBA8_ETC2_EAC` / sRGB | 0x21 / 0x23 |
| `0x93B0`/`0x93D0` | `GL_COMPRESSED_RGBA_ASTC_4x4` / sRGB | 0x24 / 0x29 |
| `0x93B4`/`0x93D4` | ASTC 5×4 / sRGB | 0x25 / 0x2A |
| `0x93B7`/`0x93D7` | ASTC 6×5 / sRGB | 0x26 / 0x2B |
| `0x93BB`/`0x93DB` | ASTC 8×5 / sRGB | 0x27 / 0x2C |
| `0x93BD`/`0x93DD` | ASTC 8×6 / sRGB | 0x28 / 0x2D |
| `0x8058` | RGBA8 (uncompressed) | 7 / 9 |
| `0x8C00`–`0x8C03` | DXT / S3TC | 0x18–0x1F |
| `0x8D62` | RGB565 | 1 |

### Texture path construction (from Image::Load)

```c
base = "Data/Images/Bin/";
fullPath = base + textureName + ".ktx";
```

On Android, textures are stored in a GPU-format-specific subdirectory:
```
Data/Images/Bin/ETC2/{name}.ktx    ← actual files on disk
```
The `ETC2/` subdirectory is selected based on the device's GPU texture format support.

### For a Blender decoder — texture handling

Files are KTX1 with ETC2 compressed data. For offline decoding to PNG:

1. Python `texture2ddecoder` + `Pillow` (used by the decoder CLI):
   ```python
   import texture2ddecoder
   from PIL import Image
   # Read KTX1 header, extract mip0 data, then:
   rgba = texture2ddecoder.decode_etc2(mip0_data, width, height)
   img = Image.frombytes("RGBA", (width, height), rgba, "raw", "BGRA")
   img.save("output.png")
   ```

2. PVRTexToolCLI (free from Imagination Technologies):
   ```bash
   PVRTexToolCLI -d output.png -i input.ktx
   ```

3. etcpack / etctool for standalone ETC2 decompression

### Material system — `LevelMaterial` and `LevelMesh`

Materials are defined in Lua/JSON resource scripts and stored as `LevelMaterial` objects:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Material identifier (referenced by meshes) |
| `shaderName` | string | Shader program name (see §5) |
| `baseColor` | vec4 | Base diffuse color multiplier |
| `shaderParams` | table | Key-value shader parameter overrides |
| `physicsMaterialOverride` | string | Physics material type |

`LevelMesh` instances reference materials by name and pass shader parameters:

| Field | Type | Description |
|-------|------|-------------|
| `shaderName` | string | Override shader (or inherit from material) |
| `material` | string | Name of `LevelMaterial` to use |
| `shaderParams` | table | Per-instance shader param overrides |

### Shader texture uniforms

Textures are bound at runtime through these shader uniform names:

| Uniform | Purpose |
|---------|---------|
| `u_diffuse1Tex` | Primary diffuse/albedo texture (sampled with UV channel 0) |
| `u_diffuse2Tex` | Secondary diffuse/mask texture |
| `u_normalTex` | Normal map texture |
| `u_diffuseColor` | Diffuse color tint (vec4) |
| `u_normTexScale` | Normal map intensity scale |
| `u_noise` | Noise texture (for capes, feathers, etc. — e.g., "FeatherNoise") |
| `u_capeIntegrityNoise` | Cape-specific integrity noise |
| `u_outfitColor0` | Primary outfit color override |
| `u_patternColor` | Pattern overlay color |
| `u_difOffset` | UV offset for diffuse texture |
| `u_maskOffset` | UV offset for mask texture |

### Mesh filename construction — `Mesh::GetFilenames`

The `.mesh` filename is built from the resource name + bake flag suffixes, appended in order:

| Mesh field offset | Flag suffix | Bake flag |
|-------------------|-------------|-----------|
| +0xA0 | `_StripGeo` | stripGeometry |
| +0xA1 | `_StripAnim` | stripAnimation |
| +0xA2 | `_UncompAnim` | uncompressedAnim |
| +0xA3 | `_Add` | additive |
| +0xA4 | `_CompOcc` | computeOcclusions |
| +0xA5 | `_CompEdges` | computeEdges |
| +0xA6 | `_CompAdj` | computeAdjacency |
| +0xA8 | `_ZipPos` | compressPositions |
| +0xA9 | `_ZipUvs` | compressUvs |
| +0xAA | `_StripUv13` | stripUv13 |
| +0xAB | `_StripNorm` | stripNormals |
| +0xAC | `_ForceIdx32` | forceIndex32 |

Final path: `Data/Meshes/Bin/{baseName}{flagSuffixes}.mesh`

Example from Persistent.lua:
```lua
resource "Mesh" "CharSkyKid_Body_ClassicShortPants" {
    source = "CharSkyKid_Body_ClassicShortPants.fbx",
    stripAnimation = true, computeOcclusions = true,
    compressPositions = true, compressUvs = true,
    stripUv13 = true, stripNormals = true
}
```
Produces filename: `CharSkyKid_Body_ClassicShortPants_StripAnim_CompOcc_ZipPos_ZipUvs_StripUv13_StripNorm.mesh`

### Avatar outfit texture pipeline — `OutfitDefs.json` schema (fully traced from APK)

`OutfitDefs.json` is a JSON array where each entry has this schema:

```json
{
    "name": "CharSkyKid_Body_ClassicShortPants",
    "type": "body",              // slot: "body", "hair", "horn", "arms", "neck", "prop"
    "isSkyKid": true,            // true = player outfit, false = NPC outfit
    "isDefault": true,           // true = starter outfit
    "mesh": ["CharSkyKid_Body_ClassicShortPants"],   // mesh resource name(s)
    "shader": "Avatar",          // shader program name
    "spiritShader": "SpiritBody",
    "texture": [
        {
            "attribute": "CharSkyKid_All_Default_Att",  // attribute/material map
            "diffuse": "CharSkyKid_Body_ClassicShortPants_Tex"  // diffuse texture
        }
    ],
    "mask": ["CharSkyKid_All_None_Msk"],     // mask texture (cape wear patterns, etc.)
    "pattern": ["Black"],                      // pattern overlay texture
    "norm": "UpNormal",                        // normal map name
    "color_hsv": [0.0, 0.0, 100.0],           // base color (HSV: hue, saturation, value%)
    "tint_hsv": [0.0, 0.0, 100.0],            // tint color (HSV)
    "pattern_hsv": [0.0, 0.0, 100.0],         // pattern color (HSV)
    "hairOffset": [0.0, 0.0, 0.0],            // hair attachment offset
    "hairScale": 1.0,
    "hornOffset": [0.0, 0.0, 0.0],
    "hornScale": 1.0,
    "maskOffset": [0.0, 0.0, 0.0],
    "maskScale": 1.0,
    "propOffset": [0.0, 0.0, 0.0],
    "wingOffset": [0.0, 0.0, 0.0],
    "wingScale": [1.0, 1.0, 1.0],
    "iconName": "UiOutfitBodyClassicPants",
    "season": "",                              // season event name (empty = permanent)
    "abilities": [],
    "disableBody": false,
    "disableEyes": true,
    "noSpineIk": false,
    "skipMotionBlur": false,
    "stationary": false,
    "wingStar": "",
    "idleAnim": "",
    "takeOutAnimSeq": "",
    "putBackAnimSeq": "",
    "fastPlayAnimSeq": "",
    "propZRotationOffsetInDegrees": 0.0
}
```

### CRITICAL: Texture Atlas + ImageRegion System

Textures in OutfitDefs are NOT direct file references — they are `ImageRegion` names
that map to sub-rectangles within texture atlases.

Declared in `Persistent.lua`:
```lua
-- Actual atlas textures (these are .ktx files on disk):
resource "Image" "CharSkyKid_Atlas_Tex"   -- diffuse atlas
resource "Image" "CharSkyKid_Atlas_Att"   -- attribute atlas

-- Sub-regions of the atlases:
resource "ImageRegion" "CharSkyKid_Body_ClassicShortPants_Tex"
    { image = "CharSkyKid_Atlas_Tex", uv = { 0.0, 0.0, 4/8, 4/8 } }
resource "ImageRegion" "CharSkyKid_All_Default_Att"
    { image = "CharSkyKid_Atlas_Att", uv = { 1/8, 2/8, 2/8, 3/8 } }
resource "ImageRegion" "CharSkyKid_All_None_Msk"
    { image = "CharSkyKid_Atlas_Att", uv = { 0.0, 0.0, 2/8, 2/8 } }
resource "ImageRegion" "CharSkyKid_Wing_Base_Tex"
    { image = "CharSkyKid_Atlas_Tex", uv = { 0.0, 4/8, 4/8, 8/8 } }
resource "ImageRegion" "CharSkyKid_Hair_Default_Att"
    { image = "CharSkyKid_Atlas_Att", uv = { 0/8, 2/8, 1/8, 3/8 } }
```

The `uv = { u_min, v_min, u_max, v_max }` defines the sub-rectangle.
The shader uses `u_difOffset` / `u_maskOffset` uniforms to transform mesh UVs into atlas space.

Some textures ARE standalone files (not atlas regions):
- Color ramps: `CharRampS1.ktx`, `RampHairTex.ktx`, `GrayD1.ktx`
- Standalone attributes: `CharSkyKid_Velvet_Att.ktx`, `CharSkyKid_Leather_Att.ktx`
- Normal maps: `HairNormalTex.ktx`, `UpNormal.ktx`
- Noise: `FeatherNoise.ktx`

### To apply textures in Blender

1. Parse `OutfitDefs.json` → find the outfit entry by `name`
2. Get `texture[0].diffuse` → look up in `Persistent.lua` to determine if it's an `ImageRegion` or direct `Image`
3. If `ImageRegion`: get the parent `image` name and `uv` rect
4. Extract the atlas `.ktx` file → transcode to PNG
5. Crop the PNG to the `uv` rectangle, OR apply a UV transform: `mesh_uv_final = mesh_uv * (uv_max - uv_min) + uv_min`
6. Create Blender material with the texture as diffuse, normal map from `norm` field
7. Apply `color_hsv` / `tint_hsv` as color modulation in the shader node graph

---

## 15. Critical Serialization Sizes — BinaryStream Overloads

From decompile of BinaryStream::Serialize overloads:

| Type | In-Memory Size | Serialized Size | Details |
|------|---------------|-----------------|---------|
| `int32` / `uint32` / `float` | 4 bytes | 4 bytes | Single Serialize() call |
| `Vector3` | 16 bytes (0x10) | 12 bytes | 3 × Serialize(float), NO padding |
| `Vector4` | 16 bytes | 16 bytes | 4 × Serialize(float) |
| `Quat` | 16 bytes (0x10) | 16 bytes | 4 × Serialize(float) |
| `SQT` (Scale+Quat+Trans) | 48 bytes (0x30) | 40 bytes | Vector3(12) + Quat(16) + Vector3(12) |

This distinction between in-memory and serialized sizes is critical for parsing.
The sizeof() debug string confirms memory sizes (Vector3=0x10, Quat=0x10, SQT=0x30),
but the BinaryStream serialization functions write FEWER bytes.

### Example: Real `.mesh` File Hex Dump

`CharSkyKid_Body_ClassicShortPants_StripAnim_CompOcc_ZipPos_ZipUvs_StripUv13_StripNorm.mesh`:
```
Offset 0x00: 1e 00 00 00  → version = 0x1e
Offset 0x04: "CharSkyKid_Body_ClassicShortPants\0" + padding (64 bytes)
Offset 0x44: 03 00 00 00  → LOD count = 3
Offset 0x48: 01           → hasAnimation = true (has bone weights + skeleton, not keyframes)
Offset 0x49: 00           → hasOcclusion = false
Offset 0x4A: 01 00 00 00  → compressionMode = 1 (LZ4)
Offset 0x4E: 80 f6 01 00  → compressedSize = 128640
Offset 0x52: 24 c7 02 00  → uncompressedSize = 181028
Offset 0x56: ...           → LZ4 compressed LOD data begins
```

`hasAnimation=true` despite `_StripAnim` in name because `stripAnimation` only
removes baked keyframes (animationCount=0 in AnimPackData). The skeleton structure
and bone weights are preserved for runtime animation.

### KTX Texture Format

Magic bytes of `.ktx` files in `Data/Images/Bin/ETC2/`:
```
AB 4B 54 58 20 31 31 BB 0D 0A 1A 0A  →  KTX1 format
01 02 03 04                            →  Little-endian
```

Files are KTX1 (not KTX2) containing ETC2 compressed texture data
(pre-transcoded for Android). For offline decoding:
- Use `PVRTexToolCLI -d output.png -i input.ktx` (Imagination PVRTexTool)
- Or `etcpack` / `etctool` for ETC2 decompression
- Or Python `Pillow` with `--enable-ktx` or the `pyktx` library
- The Basis Universal transcoder in the binary is for runtime use only

---

## 16. Complete Decoder Summary

| Component | Notes |
|-----------|-------|
| Pack file extraction | Standard TAR — `tar xf` or Python `tarfile` |
| Mesh geometry | All position/normal/UV/index formats documented (§3) |
| Compressed positions | 10-10-10 bit pack + AABB denormalization |
| Compressed UVs | 4×uint8 per vert, per-channel AABB at MeshLod+0x34/+0x54 |
| Skeleton | Bone names, parents, inverse bind matrices |
| Bone weights | 4 indices + 4 weights per vert, partition table |
| LZ4 compression | Standard `LZ4_decompress_safe` |
| Animation (uncompressed) | float32 quats + vec3s |
| Animation (compressed) | IEEE 754 float16 — standard half-precision |
| Texture extraction | `.ktx` files in TAR packs at `Data/Images/Bin/` |
| Texture decoding | KTX1 + ETC2/ASTC pre-transcoded; use `texture2ddecoder` + Pillow for PNG |
| Material mapping | OutfitDefs.json schema traced from APK |
| Texture ↔ Mesh binding | Atlas + ImageRegion system in Persistent.lua |
| Mesh filename mapping | `Mesh::GetFilenames` — name + flag suffixes |
| Rest pose format | SQT: in-memory 48B (padded), serialized 40B (12+16+12) |
| Animation keying mask | 6-bit per-bone mask, initial vs per-frame channels |
| sizeof(Vector3) / sizeof(Quat) | Memory: 16B each. Serialized: Vector3=12B, Quat=16B |
| Double rest pose in anim data | Two copies: outer stream (AnimPackData+0x58) and inner compressed block (AnimPackKeys+0x08) |
| .mesh file version header | First 4 bytes = uint32 version, read by Mesh::Load |
| KTX texture format | KTX1 with ETC2/ASTC data. Basis Universal = dead code at runtime (build-time only) (§14) |
| VFS / file access | APK assets or file system with base path |
| BstBaked.meshes (LVL06) | Level terrain geometry: TOC + per-LOD LZ4 sections (§17) |
| Objects.level.bin (TGCL) | Level scene graph: reflection-based object serialization (§18) |
| Standalone .animpack | Identical to embedded AnimPackData (§19) |
| AnimationList.dat | Master animation registry, binary format v5–7 (§20) |
| Shared skeleton | Build-time concept; both meshes contain full skeleton (§21) |
| StripGeometry behavior | Skeleton-only proxy mesh (no renderable geometry) (§21) |
| Bone parent encoding | 1-indexed: stored as parent+1, 0=root (§22) |
| BinaryStream strings | Length-prefixed (4B len + data) or fixed-width (null-padded) (§23) |
| Morph targets | Full absolute vertex data (not deltas), weight-blended (§24) |
| Edge/adjacency data | Edge = {vertMin, vertMax}, EdgeIndex = packed uint16 (§25) |
| MeshLight / LightVertexData | 12B: RGBD color + AO + shadow + HDR light + normal (§26) |
| MeshUvFixed | 16B: 4 UV channels × 2 × float16 (§10) |
| MeshPosOld | 12B: float3 (cloth/simulation previous-frame positions) (§10) |
| Terrain UV decoding | Plain byte/255.0 (standard unorm8) (§17) |
| MeshBake string format | BinaryStream length-prefixed (int32 + chars) (§17) |
| MeshBake vertex remap | MeshLod+0x108 edge/remap table, vertexCount entries (§17) |
| Tessellation reconstruction | Full algorithm + tessGroupData = octree bins at +0x80/+0x88 (§17) |
| TGCL array (type 3) | [uint32 count] in stream; elements as separate objects (§18) |
| LevelMesh fields | transform(Matrix4), resourceName, material(enum), etc. (§18) |
| Level material system | MaterialDefBarn (hardcoded enum) + LevelMaterial (TGCL) (§27) |
| BstGuid | uint32 level-local object identifier (§28) |
| Terrain mesh stream order | BstGuid+bools(1-bit) FIRST, then geometry. 25-step exact sequence (§17) |
| Cloud/volumetric data | Full 23-step stream format: int32 binMins, uint32 binDims, 3×LZ4 HC blobs (§17) |

All critical formats are validated against real files.

### Decoder Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Phase 0: Data access                                    │
│   Unpacked APK → .mesh and .ktx files directly on disk  │
│   OR .pack files → tar xf → individual resources        │
├─────────────────────────────────────────────────────────┤
│ Phase 1: Mesh geometry decoder (Python)                 │
│   Read uint32 version (first 4 bytes of .mesh file)     │
│   Parse header: 64B name, lodCount, hasAnim, hasOccl    │
│   LZ4 decompress LOD block if compressionMode == 1      │
│   Per LOD: positions, normals, UVs, indices, bone wts   │
│   Handle compressed positions (10-10-10 + AABB)         │
│   Handle compressed UVs (4×uint8 + UV bounding box)     │
│   CRITICAL: Vector3 serializes as 12B, Quat as 16B     │
├─────────────────────────────────────────────────────────┤
│ Phase 2: Skeleton + weights decoder                     │
│   AnimPackData → bone names, parents, inv-bind matrices │
│   Rest pose: 40 bytes/bone (12B scale + 16B rot + 12B) │
│   MeshWeight → bone indices + weights per vertex        │
│   Respect bone influence partition (sorted verts)       │
├─────────────────────────────────────────────────────────┤
│ Phase 3: Animation decoder                              │
│   Parse LoadAnimations header (counts, keyed indices)   │
│   Read SECOND rest pose copy (40 bytes/bone)            │
│   Outer LZ4 if compressionType 1 or 2                  │
│   Per-anim: keying mask → initial keys → per-frame keys │
│   Rotations: float32(16B) or float16(8B) per compType  │
│   Translations: float32(12B) or float16(6B)             │
│     (float16 only if compType==2 AND flags&1)           │
│   Scales: always float32(12B)                           │
├─────────────────────────────────────────────────────────┤
│ Phase 4: Texture decoder                                │
│   .ktx files are KTX1 with ETC2 data                   │
│   Decode with PVRTexTool / etcpack → PNG                │
│   Parse Persistent.lua for ImageRegion atlas mappings   │
│   Parse OutfitDefs.json for outfit → texture mapping    │
├─────────────────────────────────────────────────────────┤
│ Phase 5: Blender import                                 │
│   Create mesh, armature, vertex groups, UV maps         │
│   Apply textures as materials (with atlas UV transform) │
│   Import animations as keyframed actions                │
│   Export as .glb / .fbx / .blend                        │
└─────────────────────────────────────────────────────────┘
```

### Automation prerequisites

| Requirement | Solution | Effort |
|-------------|----------|--------|
| Python LZ4 decompression | `pip install lz4` | Trivial |
| Lua resource parser | Custom regex/parser for `resource "Type" "Name" { ... }` blocks in Persistent.lua | Medium |
| KTX1+ETC2 → PNG | `texture2ddecoder` + `Pillow` (Python) or `PVRTexToolCLI` | Low |
| JSON parsing | Standard `json` module for OutfitDefs.json | Trivial |
| Blender scripting | `bpy` (Blender Python API) | Medium |
| float16 decoding | `struct.unpack('<e')` (Python 3.6+) or `numpy.float16` | Trivial |
| Shared skeleton resolution | Build-time concept — skeleton is baked into both meshes; `sharedSkeleton` only affects load ordering | Low |

---

## 17. BstBaked.meshes — Level Mesh Format (LVL06)

Level terrain/geometry is stored in `BstBaked.meshes` files, one per level. Written by
`LevelData::Write()` and loaded by `LevelData::Load()` + `LevelData::LoadLod()`.

### Outer Container (BinaryFile with TOC)

```
[8 bytes]     Magic: "LVL06\0\0\0" (padded to 8 bytes)
              Minimum version: 0x33 (51), current: 0x36 (LVL version 6)
[100 bytes]   Table of Contents (TOC)
[4 bytes]     uint32: bakeType (only if file version > 0x34)
[16 bytes]    Vector3+pad: global AABB min
[12 bytes]    Vector3: global AABB max
```

Total header: 0x8C (140) bytes, read by `ResourceManager::ReadFileSegment`.

### TOC Format (100 bytes)

Supports up to 8 sections. First byte = entryCount.
Each TOC entry is 12 bytes:

| Offset | Size | Type | Field |
|--------|------|------|-------|
| +0x00 | 4 | char[4] | FourCC section name: `"LOD0"`, `"LOD1"`, `"VOL0"` etc. |
| +0x04 | 4 | uint32 | Byte offset within file (after header) |
| +0x08 | 4 | uint32 | Compressed size (bytes) |

LOD section names are generated as `"LOD" + ascii(N + '0')`.
Entries containing `"LOD"` → geometry sections. Entries containing `"VOL"` → volumetric/cloud data.

### Compression

Each LOD section is independently LZ4-compressed.
Max decompressed size per LOD: 0xC00000 (12 MB).

### LOD Section Data (decompressed, sequential)

#### A. Mesh Bakes (instanced references to `.mesh` resources)

```
[4 bytes]     uint32: meshBakeCount

Per MeshBake (0x30 = 48 bytes in memory):
  [4+N bytes] BinaryStream string: mesh resource name (int32 length prefix + chars)
  [4 bytes]   int32: submesh/resource ID
  [4 bytes]   uint32: numLods (LOD sub-entries)
  [1 byte]    bool: sharedBakeFlag (if true, all verts share same 12 bytes)

  Per LOD sub-entry (numLods entries):
    [4 bytes] uint32: sourceBakeVertCount (unique bake vertices)
    [4 bytes] uint32: auxByteCount (auxiliary data — tris culled, etc.)
    [N bytes] bakeVertData: sourceBakeVertCount × 12 bytes
              (or just 12 bytes if sharedBakeFlag == true)
    [N bytes] auxData: auxByteCount bytes
```

The 12-byte per-vertex bake data is `LightVertexData` (baked lighting), NOT positions.
Actual positions come from the referenced `.mesh` resource's `MeshPos` buffer (stride 0x10).
The bake data encodes per-vertex baked light color/direction/intensity (see §26).

Vertex remap: The referenced `.mesh` file contains a vertex remap table at
`MeshLod+0x108` (stored as `vertexCount × uint16` or `uint32`, only present when
`MeshLod+0x84 > 0`). The bake assembly code in `PackBeamoLod` uses this remap to
scatter bake lighting onto mesh vertices:

```python
for mesh_vertex_i in range(vertex_count):
    if shared_bake_flag:
        light = bake_data[0]           # same 12 bytes for all verts
    else:
        bake_idx = remap_table[mesh_vertex_i]
        light = bake_data[bake_idx]    # 12 bytes of LightVertexData
```

When bake data is absent, default white lighting is used via `LightVertexData::Encode`.

#### B. Terrain Meshes (self-contained level geometry)

```
[4 bytes]     uint32: terrainMeshCount

Per TerrainMesh (0xD0 bytes in memory) — EXACT stream read order from LevelData::LoadLod:

  #1  [4 bytes]   uint32: BstGuid (LevelMesh reference)         → resolved to +0xB8
  #2  [1 bit]     bool: isHidden                                → +0xC0
  #3  [1 bit]     bool: isForcedHidden                          → +0xC1
      [6 bits]    (byte-align padding — BitPacker discards remaining bits)
  #4  [12 bytes]  Vector3: AABB min                             → +0x00
  #5  [12 bytes]  Vector3: AABB max                             → +0x10
  #6  [4 bytes]   uint32: vertexCount                           → +0x20
  #7  [4 bytes]   uint32: indexCount                            → +0x24
  #8  [V bytes]   vertexData: vertexCount × 36 bytes            → ptr at +0x28
  #9  [4 bytes]   uint32: indexByteSize                         → +0x38
  #10 [I bytes]   rawIndexData: indexByteSize bytes              → ptr at +0x40
  #11 [12 bytes]  Vector3: octree AABB min                      → +0x50
  #12 [12 bytes]  Vector3: octree AABB max                      → +0x60
  #13 [4 bytes]   float: octree leafSize                        → +0x70
  #14 [4 bytes]   uint32: octree gridDimX                       → +0x74
  #15 [4 bytes]   uint32: octree gridDimY                       → +0x78
  #16 [4 bytes]   uint32: octree gridDimZ                       → +0x7C
  #17 [4 bytes]   uint32: octreeBinCount (= tessGroupCount)     → +0x80
  #18 [B bytes]   octreeBinData: binCount × 8 bytes             → ptr at +0x88
                  Each 8B entry = {uint32 triangleCount, uint32 unused}
  #19 [4 bytes]   uint32: tessVertexCount                       → +0x90
  #20 [4 bytes]   uint32: tessIndexU32Count                     → +0x94
  #21 [4 bytes]   uint32: tessTriangleEdgeCount                 → +0x98
  #22 [U bytes]   tessIndexU32Data: tessIndexU32Count × 4       → ptr at +0xA0
  #23 [E bytes]   tessTriEdgeData: tessTriangleEdgeCount × 2    → ptr at +0xA8
  #24 [T bytes]   tessVertexData: tessVertexCount × 4           → ptr at +0xB0
  #25 CONDITIONAL: if tessIndexU32Count == 0:
        [ic × 2]  indexData: indexCount × 2 bytes (uint16)      → ptr at +0x30
      If tessIndexU32Count != 0: indices reconstructed, no read.
```

CRITICAL: BinaryStream uses BitPacker. Bools (#2, #3) are 1-bit reads.
After the two bools, remaining 6 bits of that byte are discarded (byte-align).
All subsequent reads are byte-aligned.

Octree bins = tessellation groups: `octreeBinCount` (+0x80) IS `tessGroupCount`.
The 8-byte bin entries at +0x88 ARE the `tessGroupData` the reconstruction algorithm
uses. Each entry = `{uint32 triangleCount, uint32 unused}`.

Terrain vertex format = 36 bytes (0x24) — from `TerrainBarn::FinalizeTerrainBatch`,
VertexData named `"BaseTerrain"`. Split into 2 GPU buffers (position + attributes):

```
Offset  Size  GPU Format        Semantic    Shader Attrib   Description
0x00    12    float3            Position    a_position      World-space XYZ
0x0C    4     snorm8×4 (0x18)   Normal      a_normal        Packed signed normal (4 × int8, decode: byte/128.0)
0x10    4     unorm8×4 (0x1C)   Custom0     a_material0     Per-vertex material enum [0] + params [1-3]
0x14    4     unorm8×4 (0x1C)   Custom1     a_material1     Material shader params
0x18    4     unorm8×4 (0x1C)   Color       a_light0        RGBD baked light color (R, G, B, Denominator)
0x1C    4     unorm8×4 (0x1C)   TexCoord0   a_light1        (AO, Shadow, LightExponent, LightMantissa)
0x20    4     unorm8×4 (0x1C)   TexCoord1   a_light2        (NormalX, NormalY, NormalZ, AmbientWeight)
```

From shader .ref files: The 5 attribute channels are baked lighting data
(a_light0/1/2) and material shader parameters (a_material0/1). The shader attribute
names come from `GrassSh.vulkan.ref` / `SandSh.vulkan.ref` / `RockFaceSh.vulkan.ref`
string tables, validated against hex-dumped CandleSpace vertex data and SPIR-V analysis.

a_material0 (Custom0, offset 0x10): Per-vertex material params.
  byte[0] = material enum (e.g. 0x30=Grass, 0x10=Cliff, 0x1C=CliffWet)
  byte[1] = secondary material enum (for blending, e.g. 0x30 on some verts)
  byte[2..3] = typically 1 (unused/padding)

a_material1 (Custom1, offset 0x14): More material params. Often (255, 0, 0, 0) or similar.

a_light0 (Color, offset 0x18): RGBD HDR baked light color.
Decode per `Color::FromRGBD` (line 1449719 of 0.11.0 decompile):
```
r_n = R_byte / 255.0;  g_n = G_byte / 255.0;  b_n = B_byte / 255.0
d_n = D_byte / 255.0;  d_inv = 1.0 / d_n
R_linear = r_n * r_n * d_inv      (i.e. (R/255)² / (D/255))
G_linear = g_n * g_n * d_inv
B_linear = b_n * b_n * d_inv
```
Channels are stored in gamma-2.0 space — the squaring converts to linear.
The reverse (`Color::AsRGBD`, line 1449675) does `byte = sqrt(ch / max_component) * 255`.
Typical values: R≈G≈B (neutral white light), D=255 (dim) to D=128 (bright HDR).

a_light1 (TexCoord0/UV0, offset 0x1C): AO at [0], Shadow at [1],
LightExponent at [2], LightMantissa at [3]. AO decode: `ao = byte / 255.0`.
Used for ambient/dynamic modulation, NOT the primary baked color.

a_light2 (TexCoord1/UV1, offset 0x20): Baked light normal XYZ at [0..2],
AmbientWeight at [3]. Normal decode: `n = byte/255*2-1`.

a_material0 / a_material1: Material matching system. `a_material0` holds up to 4
material enum IDs per vertex; `a_material1` holds corresponding blend weights. The
shader uses `equal(a_material0 * 256, u_materialId)` to select the active blend weight.
See §29–30 for full shader decompilation.

GPU format codes: `0x18` = signed normalized byte4, `0x1C` = unsigned normalized byte4.
Normal at 0x0C is copied byte-by-byte (int8 components).

Attribute decoding: plain `byte / 255.0` (standard unorm8). No AABB-based
dequantization like regular `.mesh` compressed UVs. The attribute copy loop in
`TerrainBarn::FinalizeTerrainBatch` copies bytes verbatim to the GPU buffer — the
hardware performs `float = byte / 255.0`. The a_material0/a_material1 channels are
consumed by the terrain shader for procedural texture mapping; they are NOT
traditional UV coordinates.

Tessellation index reconstruction algorithm (when `tessIndexU32Count > 0`):

The `tessTriangleEdgeTable` has exactly `indexCount` entries. Each uint16 encodes:
- Bits [15:1] = lookup index into `tessIndexU32Table` (relative to current group base)
- Bit [0] = component select (0 = low uint16 of packed pair, 1 = high uint16)

Each `tessIndexU32Table` entry stores two uint16 vertex indices packed into one uint32.

```python
def reconstruct_terrain_indices(tess_group_data, tess_tri_edge_table,
                                 tess_index_u32_table, tess_vertex_offsets):
    output = []
    edge_offset = 0
    vertex_offset = 0

    for g in range(tess_group_count):
        edge_count = tess_group_data[g]  # uint32: edges in this group

        for j in range(edge_count):
            edge_entry = tess_tri_edge_table[edge_offset + j]  # uint16
            lookup_idx = edge_entry >> 1
            component  = edge_entry & 1

            packed = tess_index_u32_table[vertex_offset + lookup_idx]  # uint32
            if component == 0:
                vertex_index = packed & 0xFFFF        # low uint16
            else:
                vertex_index = (packed >> 16) & 0xFFFF  # high uint16

            output.append(vertex_index)

        edge_offset += edge_count
        vertex_offset += tess_vertex_offsets[g]

    return output  # len == indexCount
```

`tessGroupData` = octree bin data at TerrainMesh+0x88, count = octreeBinCount at +0x80.
Each 8-byte entry = `{uint32 triangleCount, uint32 unused}`.
Assertion: `tessTriangleEdgeCount == indexCount`.

#### C. Cloud/Volumetric Data — exact stream format

```
[4 bytes]     uint32: hasCloudData (0 = skip)
If hasCloudData != 0:
  #1  [4 bytes]   int32: binMinX          (signed, sparse grid origin X)
  #2  [4 bytes]   int32: binMinY          (signed)
  #3  [4 bytes]   int32: binMinZ          (signed)
  #4  [4 bytes]   uint32: binDimW         (grid width)
  #5  [4 bytes]   uint32: binDimH         (grid height)
  #6  [4 bytes]   uint32: binDimD         (grid depth)
  #7  [W×H×D]     uint8[]: voxelData      (1 byte/voxel, density: clamp((dist+6)/10,0,1)*255.99)
  #8  [4 bytes]   uint32: cloudIndexCount  (active occupied bins)
  #9  [count×6]   int16[3] per entry: cloudIndices (x,y,z grid coords)
                  Linearize: x + (y + z*binDimH) * binDimW
  #10 [4 bytes]   uint32: distCompressedSize
  #11 [4 bytes]   uint32: lightCompressedSize
  #12 [4 bytes]   uint32: hardnessCompressedSize
  #13 [distSz]    LZ4 HC compressed distance voxels
                  Decompressed: cloudIndexCount × distGridSize³ bytes
  #14 [lightSz]   LZ4 HC compressed light voxels
                  Decompressed: cloudIndexCount × ambGridSize³ × 8 bytes
                  (8 bytes/sample: 4B → u_cloudAmb0, 4B → u_cloudAmb1)
  #15 [hardSz]    LZ4 HC compressed hardness voxels
                  Decompressed: cloudIndexCount × ambGridSize³ bytes
  #16 [4 bytes]   float: cloudParam       (→ u_cloudMat[3] shader uniform)
  #17 [4 bytes]   uint32: distGridSize    (per-bin sub-grid dim for distance)
  #18 [4 bytes]   uint32: ambGridSize     (per-bin sub-grid dim for ambient/light)
  #19 [4 bytes]   uint32: octreeNodeCount
  #20 [4 bytes]   uint32: octreeEdgeCount
  #21 [nc×16]     octreeNodes: nodeCount × 16 bytes
  #22 [ec×2]      octreeEdges: edgeCount × 2 bytes (uint16 each)
  #23 [1 byte]    uint8:  extraParam      (ONLY if file version > 0x35 / 53)
```

#### D. Skirt Data (terrain edge geometry)

```
[4 bytes]     uint32: skirtCount
Per SkirtData (0x20 = 32 bytes in memory):
  [4 bytes]   uint32: vertexCount
  [N bytes]   vertexData: vertexCount × 40 bytes (see skirt vertex layout below)
  [4 bytes]   uint32: indexCount
  [N bytes]   indexData: indexCount × 2 bytes (uint16)
```

Skirt vertex format = 40 bytes (0x28) — from `SkirtBarn::SetSkirtData`,
VertexData named `"ObjectSkirt"`. First 36 bytes identical to terrain vertex:

```
Offset  Size  GPU Format        Semantic    Description
0x00    12    float3            Position    World-space XYZ
0x0C    4     snorm8×4 (0x18)   Normal      Packed signed normal
0x10    4     unorm8×4 (0x1C)   Custom0     Material blend
0x14    4     unorm8×4 (0x1C)   Custom1     Additional attribute
0x18    4     unorm8×4 (0x1C)   Color       Vertex color
0x1C    4     unorm8×4 (0x1C)   TexCoord0   Packed UV0
0x20    4     unorm8×4 (0x1C)   TexCoord1   Packed UV1
0x24    4     snorm8×4 (0x18)   (0x19)      Skirt edge direction / blend weight
```

#### E. Occluder Mesh

```
[4 bytes]     uint32: hasOccluder (0 = none)
If present (0x18 bytes struct):
  [4 bytes]   uint32: vertexCount
  [4 bytes]   uint32: indexCount
  [N bytes]   vertexData: vertexCount × 16 bytes (float3 pos + 4 bytes GPU alignment padding)
  [N bytes]   indexData: indexCount × 2 bytes (uint16)
```

### Vertex Format Summary

| Geometry Type | Bytes/Vert | Layout |
|---------------|-----------|--------|
| MeshBake | 12 | Baked light data (NOT position): `8B color/dir + 4B intensity` |
| TerrainMesh | 36 | `float3 pos + snorm8×4 normal + 5 × unorm8×4 attrs` |
| Skirt | 40 | Same as terrain + `snorm8×4 edge/blend` |
| Occluder | 16 | `float3 pos + 4B padding` |

---

## 18. Objects.level.bin — Level Scene Format (TGCL)

The scene placement file defines every object in a level: positions, rotations,
mesh/material references, and cross-object pointers. Loaded by
`LevelObjects::Load` → `LoadLevelObjectsBin`.

### TGCL Header (`LoToc`, 44 bytes)

```
[4 bytes]     uint32: magic = 0x4C434754 ("TGCL")
[4 bytes]     uint32: unknown (possibly version/flags)
[4 bytes]     uint32: numClasses
[4 bytes]     uint32: numMemberVars
[4 bytes]     uint32: numObjects
[4 bytes]     uint32: numPtrFixups
[4 bytes]     uint32: classTableOffset
[4 bytes]     uint32: memberVarTableOffset
[4 bytes]     uint32: stringTableOffset
[4 bytes]     uint32: podDataOffset
[4 bytes]     uint32: fileSize
```

Validated by assertions: `magic == 0x4C434754`, `fileSize == actual read size`.

### Data Sections

```
[LoToc header: 0x2C bytes]
[Class Table        @ classTableOffset]
[Member Var Table   @ memberVarTableOffset]
[String Table       @ stringTableOffset]
[POD Data Section   @ podDataOffset ... fileSize]
```

No compression. The entire file is read into a 4MB scratch buffer.

### Class Table (`LoClass`, 12 bytes each)

| Offset | Size | Type | Field |
|--------|------|------|-------|
| +0x00 | 4 | uint32 | nameOffset (into string table) |
| +0x04 | 4 | uint32 | firstMemberVarIndex |
| +0x08 | 4 | uint32 | numMemberVars |

Class names include: `"LevelMesh"`, `"Beamo"`, `"TerrainBlobPrefab"`,
`"LensFlair"`, `"KillBox"`, etc.

### Member Variable Table (`LoMemberVar`, 16 bytes each)

| Offset | Size | Type | Field |
|--------|------|------|-------|
| +0x00 | 4 | uint32 | type (0=POD, 1=string/enum, 2=object pointer, 3=array) |
| +0x04 | 4 | uint32 | nameOffset (into string table) |
| +0x08 | 4 | uint32 | size (byte size for POD types) |
| +0x0C | 4 | int32 | arrayElementTypeId (metaclass ID, or -1) |

Variable names include: `"transform"`, `"meshName"`, `"materialBstGuid"`,
`"shaderName"`, `"collision"`, etc.

### String Table

Flat blob of null-terminated ASCII strings. All nameOffset fields index into this.

### Per-Object Data (sequential in POD section)

For each of `numObjects` objects:

```
[4 bytes]     uint32: classIndex (into class table; 0xFFFFFFFF = null)
[variable]    Null-terminated string: object instance name
[variable]    Member variable data (per the class's member var definitions):
              - POD (type 0): raw bytes, `size` bytes (Matrix4=64B, Vector3=12B, float=4B...)
              - String (type 1): null-terminated string
              - Object pointer (type 2): uint32 object index (resolved in fixup pass)
              - Array (type 3): allocator + sub-elements
```

Transforms are stored as POD member variables. A `LevelMesh` object has a
`"transform"` field that is a `Matrix4` (64 bytes, 4×4 float row-major) representing
the full world transform. Mesh references are `"meshName"` strings.

Array members (type 3): The binary format is `[uint32 count]` (4 bytes) in the
POD data section. The count is passed to the class's `ArrayAllocator` function which
reserves space in the object. Array element objects are loaded as separate top-level
objects in the TGCL object list, with pointer resolution happening post-load via the
fixup pass.

### `LevelMesh` Serialized Fields (from meta registration)

| Offset | Field | Type | Notes |
|--------|-------|------|-------|
| 0x10 | `transform` | Matrix4 (64B) | World transform |
| 0x50 | `bstGuid` | uint32 | BST identifier (level-local unique ID) |
| 0x58 | `resourceName` | string | Mesh resource name (e.g. `"AP01_rock_a"`) |
| 0x70 | `material` | Material (enum byte) | Default: `kMaterial_Cliff` |
| 0xB8 | `useCustomShader` | bool | If true, uses custom shader params |
| 0xC0 | `shaderName` | string | Computed from material; read-only in editor |
| 0x1B0 | `shaderParams` | array | Per-mesh shader parameter overrides |

### Pointer Fixup Pass (24 bytes each)

After all objects are created:

| Offset | Size | Type | Field |
|--------|------|------|-------|
| +0x00 | 8 | ptr | Target address |
| +0x08 | 4 | uint32 | Object index (0xFFFFFFFF = null) |
| +0x10 | 8 | long | Base offset |

Resolves object pointer cross-references (parent-child, collision refs, etc.).

---

## 19. Standalone `.animpack` Files

Standalone animation packs are loaded from `Data/Meshes/Bin/<name>.animpack`.

The binary format is identical to the embedded AnimPackData in `.mesh` files.
Both code paths call `AnimPackData::LoadFromBuffer` with the same stream format.

The only difference:
- Standalone (`.animpack`): `AnimationPackType = 0`, stored in `AnimationPack` resource
- Embedded (in `.mesh`): `AnimationPackType = 1`, stored in `MeshData`

The type value (stored at `AnimPackData+0x40`) may affect runtime binding behavior
but does not change the binary serialization.

### Loading path

```
AnimationPack::Load:
  path = "Data/Meshes/Bin/" + name + ".animpack"
  data = ReadFile(path, scratchBuffer_3MB)
  AnimPackData::LoadFromBuffer(this+0x78, stream, heap, 0, path)
```

---

## 20. AnimationList.dat — Master Animation Registry

Binary file at `Data/Meshes/Bin/AnimationList.dat`. Loaded by
`AnimationManager::LoadAnimListBinary` into a 793,600-byte (0xC1C00) scratch buffer.

### Binary Format (version 5–7, current = 7)

```
[4 bytes]     uint32: version (5..7)
[4 bytes]     uint32: fileCount (< 512 = kMaxAnimationFiles)

Per animation file (fileCount entries):
  [string]    BinaryStream string: animation file name
  [4 bytes]   int32: clipCount (animation clips within this file)

  Per clip (clipCount entries):
    [string]  BinaryStream string: clip name
    [4 bytes] int32: field_04
    [4 bytes] int32: field_08
    [4 bytes] int32: blendFlags
    [4 bytes] float: speed (default 1.0)
    [1 byte]  uint8: layerType
    [4 bytes] uint8[4]: mixerFlags
    [4 bytes] float: maxBlend (default 2.0)
    [1 byte]  uint8: looping
    [1 byte]  uint8: mirrored
    if version >= 3:
      [1 byte] uint8: additionalFlag1
      [1 byte] uint8: additionalFlag2
    [4 bytes] int32: soundEffectCount
    if version >= 4:
      [4 bytes] uint8[4]: extraFlags
    if version >= 6:
      [1 byte] uint8: blendTreeFlag

    Per sound effect (soundEffectCount entries):
      [4 bytes] int32: triggerFrame
      [string]  eventName
      [string]  soundBank
      [4 bytes] float: volume
      [4 bytes] float: pitch
      [4 bytes] uint8[4]: spatialFlags
      [4 bytes] float: distance
      [1 byte]  uint8: flag
      [4 bytes] int32: paramCount
      [4 bytes] float: priority
      if version >= 7:
        [1 byte] uint8: additionalSoundFlag

  [4 bytes]   int32: emitterEffectCount
  Per emitter effect:
    [4 bytes] int32: triggerFrame
    [4 bytes] int32: type
    [string]  effectName
    [string]  attachBone
    [4 bytes] float: lifetime
    [4 bytes] float: startDelay
    [4 bytes] float: scale
    [1 byte]  uint8: attached
    [4 bytes] int32: paramCount
    [4 bytes] float: distance
```

Purpose: Maps animation file names to clip metadata (speed, looping, blend
settings, sound/particle triggers). Runtime calls `FindAnimationFile()` and
`FindAnimation()` for name-based lookup, `GetMetaData()` for playback parameters.

---

## 21. Shared Skeleton & StripGeometry

### sharedSkeleton (Mesh+0xAD)

A build-time concept, not a runtime pointer indirection. When `sharedSkeleton=true`:

1. The mesh `.mesh` file still contains its own full AnimPackData (skeleton + bone weights)
2. The same skeleton data is baked into both the source and shared mesh at build time
3. At runtime, `sharedSkeleton` only affects load ordering: the mesh defers its
   file load until a dependency flag is set, ensuring the source skeleton mesh is
   loaded first

No `GetSharedSkeleton` function exists. Both meshes independently contain identical
skeleton data in their binary files.

### stripGeometry (Mesh+0xA0)

When `stripGeometry=true`, the mesh binary is baked with no renderable geometry
(no LOD vertex/index data). What remains:
- AnimPackData (skeleton + animations) if `stripAnimation` is false
- Bone names, parent indices, inverse bind matrices, rest poses

This produces a skeleton-only proxy used for:
- Driving `AnimationInstance` bones for IK and attachments
- Animation playback without GPU rendering
- Shared animation rigs where only one mesh needs visible geometry

### Flag combination matrix

| stripGeometry | stripAnimation | Suffix | Content |
|:---:|:---:|---|---|
| false | false | *(none)* | Full mesh + skeleton + animation |
| false | true | `_StripAnim` | Full mesh + skeleton, no baked keyframes |
| true | false | `_StripGeo` | Skeleton + animation, no geometry |
| true | true | `_StripGeo_StripAnim` | Skeleton only |

---

## 22. Bone Parent Index Encoding

From `BoneMask::SetWeightsRecursive` (offset 514547):

```c
lVar7 = (long)*(int *)(parentArray + boneIndex * 4) + -1;
//                                                    ^^^
// Subtracts 1 from stored value to get actual parent
```

| Stored value | After -1 | Meaning |
|---|---|---|
| 0 | -1 | Root bone (no parent) |
| 1 | 0 | Parent is bone 0 |
| 2 | 1 | Parent is bone 1 |
| N | N-1 | Parent is bone N-1 |

The parent array is at `AnimPackData+0x60`, stored as `int32[]`, `boneCount` entries.

Validated empirically: decoding 1823 meshes with `parent - 1` produces anatomically
correct hierarchies (hip→root, knee→legRoot, chest→spine, etc.).

---

## 23. BinaryStream String Serialization

Two serialization modes for strings:

### `BinaryStream::Serialize(std::string*)` — Length-prefixed

Used by `AnimationList::Serialize` and other dynamic-length string fields.
Writes a 4-byte uint32 length prefix followed by the raw character data:

```
[4 bytes]   uint32: string length (excluding null terminator)
[N bytes]   char[]: raw string data (no null terminator in stream)
```

### `BinaryStream::SerializeCString(char*, uint maxLen)` — Fixed-width

Used for bone names, level names, player names, and other fixed-size buffers.
Reads/writes exactly `maxLen` bytes (null-padded):

```
[maxLen bytes]  char[]: null-terminated string, padded to maxLen
```

Common sizes: `0x40` (64B, bone names), `0x20` (32B, player names),
`0x100` (256B, messages), `0x10` (16B, short identifiers).

---

## 24. Morph Target Format

Morph targets store full absolute vertex data, not deltas. Each morph target
is a complete `Model` / `MeshLod` with its own vertex buffers:

```
Model+0x3C0 : ptr    m_morphTarget  → full Model with its own MeshData/MeshLod
Model+0x3C8 : float  morphWeight    (0.0 = base, 1.0 = full morph)
```

The morph target's LOD is accessed via:
```
morphTarget->meshData->lods[lodIndex]  (offset 0x48 + lodIndex * 0x130)
  positions at MeshLod+0xB0  (MeshPos[], stride 0x10)
  normals at MeshLod+0xB8    (MeshNorm[], stride 0x04)
```

Blending formula: `result = current * (1 - weight) + morphTarget * weight`

Constraint: The morph target must have the same vertex count as the base mesh
(assertion: `m_morphTarget->GetLod()->vertCount == vertCount`).

In the `.mesh` file, morph target data is a separate morph index buffer
(`morphTargetCount × vertexCount × indexStride` bytes) that maps base vertices
to morph target vertices. The morph target geometry itself is loaded from a
separate `.mesh` resource referenced by name.

---

## 25. Edge & Adjacency Data Formats

### Edge struct

Each unique edge is a pair of vertex indices, sorted so the smaller index comes first:

```
Edge<uint16> = 4 bytes:  { uint16 vertMin, uint16 vertMax }
Edge<uint32> = 8 bytes:  { uint32 vertMin, uint32 vertMax }
```

### EdgeIndex (per-index-buffer entry)

A packed reference to a unique edge, stored as uint16:

```
Bit 0:     Direction flag (0 = same order as Edge, 1 = reversed)
Bits 1-15: Index into the unique Edge array
```

Max unique edges: 32768 (0x8000). One EdgeIndex per index buffer entry
(i.e., per triangle vertex reference).

### ComputeEdges pipeline

`FindUniqueEdges<uint16/uint32>` processes the triangle index buffer:
1. Iterates all triangle edges (3 per triangle)
2. Deduplicates into a unique Edge array (vertMin < vertMax)
3. Produces an EdgeIndex array (same size as index buffer)

### Adjacency data

`computeAdjacency` extends the index buffer with neighbor triangle information.
Stored as `adjacencyCount × indexStride` bytes. Each adjacency entry encodes
the neighboring triangle across each edge, used for geometry-shader effects
(shadow volumes, silhouette extrusion).

---

## 26. MeshLight / LightVertexData — Full Decode

Per-vertex baked lighting data, used by `BstBaked.meshes` MeshBake entries and
level lighting. Decoded from `LightVertexData::LightVertexData(MeshLight const&)`
and encoded by `LightVertexData::Encode(MeshLight&)`:

```
Offset  Size  Type    Field               Decode formula
0x00    4     Color32 RGBD color          Color::FromRGBD(r, g, b, d)
0x04    1     uint8   Ambient occlusion   ao = byte / 255.0
0x05    1     uint8   Shadow intensity    shadow = (byte / 255.0)²
0x06    1     uint8   Light exponent      exp = byte ^ 0x80
0x07    1     uint8   Light mantissa      intensity = ldexpf(byte/255.0, exp - 0x80) / 1000.0
0x08    1     uint8   Normal X            nx = byte/255.0 * 2.0 - 1.0
0x09    1     uint8   Normal Y            ny = byte/255.0 * 2.0 - 1.0
0x0A    1     uint8   Normal Z            nz = byte/255.0 * 2.0 - 1.0
0x0B    1     uint8   Ambient weight      ambient = byte / 255.0
```

RGBD = Red, Green, Blue, Denominator — a compact HDR color encoding.
RGBD decode (`Color::FromRGBD`, line 1449719):
  `ch_linear = (ch_byte / 255.0)² / (D_byte / 255.0)` — gamma-2.0 encoding + D divisor.
RGBD encode (`Color::AsRGBD`, line 1449675):
  `D_denom = max(R, G, B, 1.0)`, `ch_byte = sqrt(ch / D_denom) * 255`, `D_byte = 255 / D_denom`.
Light intensity uses split mantissa+exponent for HDR range.
Used by `CollisionGeoInstance::GetVertLights`, `Lerp(MeshLight)`, and
`Berp(Vector3, MeshLight, MeshLight, MeshLight)` (barycentric interpolation).

---

## 27. Level Material & Texture Resolution Pipeline

### Two Material Systems

Sky uses two separate material systems for level geometry:

System A — `MaterialDefBarn` (hardcoded enum, physics + visual):
A hardcoded C++ enum of physical/visual surface types registered in
`MaterialDefBarn::RegisterDefs`. Each entry is 0xA0 bytes containing:

```
Offset  Type          Field                      Example
+0x00   char*         shader name (primary)      "RockFaceSh", "SandSh", "GrassSh"
+0x08   char*         texture 1 uniform name     "u_topGeoTexture"
+0x10   char*         texture 2 uniform name     "u_sideGeoTexture"
+0x18   char*         texture 3 uniform name     "u_grassNorm1Tex", "u_normalTex"
+0x20   char*         texture 4 uniform name     "u_grassNorm2Tex", "u_grassMaskTex"
+0x28   char*         texture 1 asset name       "CliffSh" (→ CliffSh.ktx)
+0x30   char*         texture 2 asset name       "CliffSh", "SoilSh"
+0x38   char*         texture 3 asset name       "GrassNorTex0", "Noise3Ch"
+0x40   char*         texture 4 asset name       "GrassNorTex1", "GrassMask", "SandMask"
+0x50   float4        base color (RGB, from HSV)  Color::HSV(5.759, 1.0, 1.0, 1.0)
+0x84   float         metalness
+0x88   float         roughness
+0x8C   float         UV scale                   u_matUvScale
+0x92   uint8         order/index
+0x94   uint16        extra flags                (e.g., 0x23 for Trials levels)
+0x97   uint8         material enum byte         e.g., 0x10 for Cliff
```

Material enum values and their default base colors (HSV hue in radians),
extracted from `RegisterDefs` in `libBootloader-Live-0.11.0-155436.so.c` line 946244:

```
Enum  Name          Shader           HSV(h_rad, s, v)           Textures
0x01  RockFace      RockFaceSh       (5.760, 1.00, 1.00)        u_topGeoTexture, u_sideGeoTexture
0x10  Cliff         CliffSh          (3.037, 0.25, 0.16)        u_topGeoTexture, u_sideGeoTexture
0x11  Soil          SoilSh           (3.334, 0.24, 0.01)        (copy of Cliff)
0x12  SoilVar       CliffSh          (3.334, 0.24, 0.35)        (copy of Cliff)
0x13  WallBrick     CliffSh          (0.611, 0.00, 0.25)        (copy of Wall)
0x14  Wall          WallSh           (0.611, 0.00, 0.70)        u_topGeoTexture, u_sideGeoTexture
0x15  Gold          GoldSh           (0.611, 1.00, 0.70)        (copy of Cliff)
0x16  Glacier       GlacierSh        (3.229, 0.225, 0.65)       (copy of Cliff)
0x17  TileCeiling   TileCeilingSh    (3.142, 0.00, 0.50)        (copy of Wall)
0x18  TileFloor     TileFloorSh      (3.037, 0.25, 0.12)        (copy of Wall)
0x19  WallTile      TileFloorSh      (3.142, 0.00, 0.50)        (copy of Wall)
0x1a  WallBrick2    WallBrickSh      (3.037, 0.25, 0.16)        (copy of Wall)
0x1b  WetSoil       RockFaceRainSh   (copy of 0x11)             (copy of Soil)
0x1c  CliffWet      CliffWetSh       (3.142, 0.42, 0.10)        (copy of Cliff)
0x1d  WallLight     WallSh           (0.611, 0.00, 0.70)        (copy of Wall)
0x1e  Wood          WoodSh           (0.611, 0.00, 0.40)        (copy of Wall)
0x20  Sand          SandSh           (2.967, 0.05, 0.40)        Noise3Ch, SandMask, u_normalTex, u_grassMaskTexture
0x21  SandRain      SandRainSh       (0.524, 0.05, 0.20)        (copy of Sand)
0x22  Snow          SandSh           (0.524, 0.05, 0.65)        (copy of Sand)
0x23  SandBright    SandSh           (0.524, 0.00, 0.75)        (copy of Sand)
0x24  SandAlt       SandSh           (2.967, 0.03, 0.40)        (copy of Sand)
0x30  Grass         GrassSh          (1.623, 0.40, 0.25)        GrassMask, GrassNorTex0, GrassNorTex1
0x31  GrassRain     GrassSh          (1.745, 0.30, 0.25)        (copy of Grass)
0x32  GrassDark     GrassSh          (1.571, 0.40, 0.37)        (copy of Grass)
0x33  GrassAlt      GrassSh          (1.623, 0.40, 0.25)        (copy of Grass)
0x50  Cloud         CloudSh          (2.356, 0.00, 0.70)        (standalone)
```

HSV decode: `h_degrees = h_rad × 180/π`, then standard HSV→RGB.
Note: base colors are intentionally dark — the baked RGBD lighting (a_light0)
provides all brightness. Final render: `u_matColor × RGBD_light × AO`.

Derived materials are created via `CopyDefFrom(target, source)` and inherit textures:
- Cliff (0x10) → Soil, SoilVar, Gold, Glacier, CliffWet
- Wall (0x14) → WallBrick, TileCeiling, TileFloor, WallTile, WallBrick2, WallLight, Wood
- Sand (0x20) → SandRain, Snow, SandBright, SandAlt
- Grass (0x30) → GrassRain, GrassDark, GrassAlt

Per-level color overrides are applied by matching the level name string against
hardcoded names (`"Night2"`, `"Dawn"`, `"RainMid"`, `"Prairie_ButterflyFields"`, etc.).
CandleSpace has no level-specific overrides (only `"CandleSpaceEnd"` does).

System B — `LevelMaterial` (per-level, stored in TGCL):
Named visual material definitions with these fields (from meta registration):

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `bstGuid` | uint32 | | Level-local unique ID |
| `name` | string | | Material name |
| `useCustomShader` | bool | false | Custom vs MaterialDefBarn fallback |
| `material` | Material (enum) | `kMaterial_Cliff` | Fallback material type |
| `baseColor` | Color (16B) | (1,1,1,1) | Base color (when custom shader) |
| `shaderName` | string | | Computed from material enum |
| `shaderParams` | array | | Custom shader params |

### Resolution Chain: `materialBstGuid` → Texture

```
Beamo/LevelMesh.materialBstGuid (uint32)
  └→ LevelModelBarn::GetLevelMaterial(bstGuid)
       └→ scans LevelMaterial array (stride 0x6F0), matches bstGuid
            ├─ if useCustomShader == true:
            │    return custom baseColor + shaderParams
            └─ if useCustomShader == false:
                 └→ MaterialDefBarn::GetDef(material_enum)
                      └→ GetMaterialUniforms(shaderName, def)
                           └→ returns (uniformName, type, textureName) tuples
                                └→ type 'd' (texture): ResourceManager::GetResource<Image>(texName)
                                     └→ loads Data/Images/Bin/ETC2/{texName}.ktx
```

### Terrain Blob Materials

`TerrainBlob` objects (procedural terrain) use two Material enums:
- `materialTop` (default: `kMaterial_Grass`) — applied to surfaces facing up
- `materialBottom` (default: `kMaterial_Cliff`) — applied to steep/side surfaces
- `materialAngle` (float) — threshold angle for top vs bottom
- `materialAngleGradient` (float) — blend gradient at transition

Both resolve through `MaterialDefBarn::GetDef(enum)` at render time.

### `LevelMesh::CreateModel` Material Flow

1. Load mesh resource by `resourceName`
2. Get `MaterialDefBarn::GetDef(this.material)` → MaterialDef
3. Copy shader name from MaterialDef, append `"Mesh"` suffix
   (e.g., `"CliffSh"` → `"CliffShMesh"`)
4. Create model via `ModelBarn::CreateModel(meshName, shaderName, transform)`
5. Call `MaterialDefBarn::GetMaterialUniforms(shaderName, def, uniforms, 16)`
6. For each uniform:
   - Float/vec types: `Model::SetUniform(name, value)`
   - Texture type (`'d'`): `ResourceManager::GetResource<Image>(texName)`
     → `Model::SetUniformTex(name, image)`

### For a Blender Level Decoder — Practical Texture Strategy

Level textures are hardcoded in `MaterialDefBarn::RegisterDefs`, not in data files.

Phase 1 (implemented in `blender_import_level.py`): Baked light + material color.
1. Read per-vertex material enum from `custom0[0]` (a_material0 byte 0)
2. Look up material base color RGB from RegisterDefs HSV table
3. Decode RGBD from `color` field (a_light0) using `Color::FromRGBD`:
   `ch_linear = (ch_byte/255)² / (D_byte/255)`
4. Apply environment light tinting (from decompiled vertex shader):
   `tinted = hdr × mix(skyColor, sunColor, AO)` where `AO = uv0[0]`
5. Compute final: `matColor × tinted`
6. Store as linear HDR `FinalColor` vertex color attribute (FLOAT_COLOR)
7. Use Emission shader to prevent Blender viewport double-lighting
8. Blender's Filmic/AgX view transform handles display tonemapping

Phase 2 (shader-driven textures):
All terrain shaders (Grass/Sand/RockFace/Cloud) have been decompiled via spirv-cross
and saved in `scratchpad/shaders/`. Material matching uses `a_material0` (up to 4
material IDs per vertex) and `a_material1` (blend weights), with `equal()` to select
the active weight. Full tonemap pipeline documented (§33).

Remaining work: extract `.ktx` textures to PNG, build Blender node trees for tri-planar
texture projection (world XZ × `u_matUvScale`, using grass mask + normals for displacement).

### SetMaterialShaderUniforms

`MaterialDefBarn::SetMaterialShaderUniforms(PipelineInstance*, MaterialDef&, ResourceManager*)`
sends these uniforms to the shader (decompile line 946933):

```
Uniform             Source in MaterialDef    Description
u_materialId        +0x97 (byte)             Material enum cast to float
u_matUvScale        +0x8C (float)            UV tiling scale
u_matColor          +0x50 (float3)           Base color (RGB, converted from HSV)
u_matMetalness      +0x84 (float)            Metalness
u_matRoughness      +0x88 (float)            Roughness
```

Textures are loaded via `ResourceManager::GetResource<Image>(texName)`:
- Slot at +0x08/+0x28: uniform name / texture name pair (e.g., "u_topGeoTexture" / KTX file)
- Slot at +0x10/+0x30: second texture pair
- Slot at +0x18/+0x38: third texture pair
- Slot at +0x20/+0x40: fourth texture pair

### Available Terrain Textures (v0.11.0 assets)

```
Data/Images/Bin/ETC2/
├── CliffSh.ktx           (350 KB)  — Cliff top/side texture
├── CliffWetSh.ktx                  — Wet cliff variant
├── RockHeightCliffSh.ktx           — Height-based cliff blending
├── GrassMask.ktx          (175 KB) — Grass pattern mask
├── GrassNorTex0.ktx                — Grass normal map 0
├── GrassNorTex1.ktx                — Grass normal map 1
├── SandMask.ktx           (699 KB) — Sand pattern mask
├── Noise3Ch.ktx                    — 3-channel noise (used by SandSh)
└── UpNormal.ktx                    — Default up-facing normal
```

### Terrain Shaders — Decompiled (spirv-cross, Vulkan SDK 1.4.341)

Shaders decompiled via `spirv-cross --version 460 <file>.spv` and saved
to `scratchpad/shaders/*.glsl`. Decompiled names are numeric (`_m0`, `_76`, etc.)
but mapped below via the `.ref` reflection files.

#### GrassSh Vertex Shader (GrassSh.vulkan.vs.spv)

Inputs (vertex attributes):
| Location | GLSL var | .ref name    | TerrainVertex field | Type  |
|----------|----------|-------------|---------------------|-------|
| 0        | `_120`   | a_position   | position            | vec3  |
| 1        | `_110`   | a_normal     | normal              | vec4  |
| 2        | `_76`    | a_light0     | color (RGBD bytes)  | vec4  |
| 3        | `_78`    | a_light1     | uv0 (norm 0-1)     | vec4  |
| 4        | `_80`    | a_light2     | uv1 (norm 0-1)     | vec4  |
| 5        | `_213`   | a_material0  | custom0 (raw bytes) | vec4  |
| 6        | `_235`   | a_material1  | custom1 (raw bytes) | vec4  |

Per-object uniforms (binding 0):
| Field | .ref name        | Type  |
|-------|-----------------|-------|
| _m0   | u_model          | mat4  |
| _m1   | u_modelIT        | mat4  |
| _m2   | u_matColor       | vec3  |
| _m3   | u_materialId     | float |
| _m4   | u_matUvScale     | float |
| _m5   | u_matMetalness   | float |

Key computations:

1. RGBD decode + environment tint (output → v_light0, location 4):
```glsl
v_light0.rgb = (a_light0.rgb² / a_light0.w) * mix(u_averageSkyColor, u_sunColor, a_light1.x)
v_light0.w   = a_light1.w * exp2(255 * a_light1.z - 128)   // HDR mantissa × 2^exponent
```
   - `a_light1.x` = AO: 0 → shadow (sky-tinted), 1 → lit (sun-tinted)
   - `u_averageSkyColor` = `_m45`, `u_sunColor` = `_m41` in PerFrameUniforms

2. Shadow passthrough (output → v_light1, location 5):
```glsl
v_light1.x = a_light1.y²    // shadow term, squared for contrast
```

3. Light normal decode (output → v_light2, location 6):
```glsl
v_light2.xyz = a_light2.xyz * 2.007874 - 1.007874   // [0,1] → [-1,1]
v_light2.w   = a_light2.w                             // ambient weight
```

4. Material matching (output → v_specColorInvMetal, location 2):
```glsl
mask = vec4(equal(ivec4(a_material0 * 256), ivec4(u_materialId)))
v_specColorInvMetal = vec4(u_matColor, dot(mask, a_material1))
```
   The 4 bytes of `a_material0` are 4 material IDs; whichever matches the
   current draw-pass `u_materialId`, the corresponding `a_material1` channel
   gives the blend weight. This enables multi-material terrain blending.

5. PBR F0 (output → v_color, location 3):
```glsl
v_color.xyz = mix(matColor * 0.015 + 0.035, matColor, metalness)   // Fresnel F0
v_color.w   = 1.0 - metalness
```

#### GrassSh Fragment Shader (GrassSh.vulkan.fs.spv)

Texture inputs:
| Binding | .ref name        | Purpose                          |
|---------|-----------------|----------------------------------|
| 3       | u_lightCSTex     | Clustered light list (per-tile)  |
| 4       | u_lightPRTex     | Light probe/point light data     |
| 5       | u_grassNorm1Tex  | Grass normal map 1               |
| 6       | u_grassNorm2Tex  | Grass normal map 2               |
| 7       | u_grassMaskTex   | Grass mask / displacement        |

Key computations:

1. Grass displacement: Samples `u_grassMaskTex` to get mask height and
   `u_grassNorm1Tex`/`u_grassNorm2Tex` for grass blade normals. Uses world-space
   XZ coordinates × `u_matUvScale` for tri-planar UV. Wind scroll from
   `u_windScroll0/1/2` animates the normals.

2. Clustered point lights: Reads per-tile light lists from `u_lightCSTex`,
   accumulates diffuse + shadow contributions.

3. PBR direct lighting:
```glsl
NdotL   = max(0, dot(displaced_normal, -u_sunDir))
diffuse = matColor * (1 - metalness) * NdotL
spec    = GGX(roughness, F0=v_color.xyz)    // GGX/Smith + Schlick Fresnel
direct  = u_sunColor * shadow * (diffuse + spec)
```

4. Ambient / baked lighting:
```glsl
ambient_albedo = matColor * ((1 - metalness) + env_reflection)
ambient = baked_light * ambient_albedo * min(shadow * 0.25 + 0.75, 1.0)
```
   Where `baked_light = v_light0.rgb + someColor * v_light0.w`

5. Output: `o_fragColor0 = vec4(direct + ambient, depth_for_fog)`

#### SandSh Fragment Shader (SandSh.vulkan.fs.spv)

Texture inputs:
| Binding | .ref name      | Purpose                              |
|---------|---------------|--------------------------------------|
| 0       | u_waterSim     | Water simulation (sand ripple/wet)   |
| 3       | u_lightCSTex   | Clustered light list                 |
| 4       | u_lightPRTex   | Point light data                     |
| 5       | u_normalTex    | Sand surface normal map              |

Key differences from GrassSh:
- Uses `u_waterSim` texture for dynamic water effects: samples height at position
  and adjacent texels, computes surface gradient, deforms the sand surface normal.
- Sand ripples are modulated by `v_norm.y²` (flatter surfaces get more water effect).
- Normal perturbation from `u_normalTex` sampled at world XZ coordinates.
- Has two specular lobes: a tight GGX (roughness=0.25²) and a wider one
  (roughness varies with distance, 0.3-0.65), giving sand its characteristic sheen.
- Final color: `sunColor * shadow * NdotL * (1 + tightSpec)` + `bakedLight * wideSpec`
  multiplied by matColor.

#### RockFaceSh Fragment Shader (RockFaceSh.vulkan.fs.spv)

Texture inputs:
| Binding | .ref name         | Purpose                        |
|---------|------------------|--------------------------------|
| 3       | u_probeCube        | Cubemap reflection probe       |
| 4       | u_lightCSTex       | Clustered light list           |
| 5       | u_lightPRTex       | Point light data               |
| 6       | u_sideGeoTexture   | Rock side face texture (RGBA)  |
| 7       | u_topGeoTexture    | Rock top face texture (RGBA)   |

Key differences from GrassSh:
- Tri-planar texture mapping: Normal components raised to 4th power for blend weights:
```glsl
weights = (normal⁴) / sum(normal⁴)
texColor = topTex(uvXY) * wX + sideTex(uvXZ) * wY + topTex(uvXY2) * wZ
```
  UVs are `worldPos * u_matUvScale` with axis-dependent sign flips.
- Normal map from texture: `.xy` channels decoded from [0,1] → [-1,1],
  `.z` reconstructed, transformed to world space via tangent frame.
- Roughness from texture: `roughness = max(0.03, texture.z * u_matRoughness)` —
  the blue channel of the geo texture modulates roughness per-pixel.
- Cubemap reflections: Samples `u_probeCube` at normal (ambient) and
  reflect(-eye, normal) (specular). Pre-divided in vertex shader for efficiency:
  `v_probeAmb = 1/cubemap(normal, mip=5)`, used as `ambient * matColor / v_probeAmb`.
- Full PBR: Two GGX lobes (direct sun + environment), plus environment BRDF
  approximation for indirect specular.
- Subsurface scattering term: `matColor * 5 * pow(max(0, -VdotL), 8) * max(0, -NdotL)`
  adds a back-lighting glow for thin rock edges.

#### RockFaceSh Vertex Shader — Tri-planar UV computation

```glsl
worldPos_scaled = worldPos * u_matUvScale
v_uvXY.xy = worldPos_scaled.zy * vec2(-sign(normal.x), -1)   // X-facing
v_uvXY.zw = worldPos_scaled.xz * vec2(sign(normal.y), 1)     // Y-facing (top)
v_uvZ      = worldPos_scaled.xy * vec2(sign(normal.z), -1)    // Z-facing
```

#### CloudSh — Fully vertex-lit (no textures)

Vertex shader computes the entire diffuse lighting in-shader:
```glsl
lightColor = RGBD_decode(a_light0) * mix(u_averageSkyColor, u_sunColor, AO)
lightColor += u_pointLightColor * (mantissa * 2^exponent)    // HDR term from a_light1.zw
shadow = a_light1.y²
halfLambert = shadow * (0.5 + 0.5 * mix(NdotL, 1.0, max(0, -VdotL)))
v_diffuse = matColor * (sunColor * halfLambert + lightColor)
```
Fragment shader is trivial: `o_fragColor0 = vec4(v_diffuse.xyz, depth)`

Uses same `equal(a_material0 * 256, u_materialId)` material matching.
Offsets position along normal for cloud puffiness.

#### TonemapMovie Fragment Shader (TonemapMovie.vulkan.fs.spv)

Full-screen post-processing pass applied after all scene rendering.

Texture inputs:
| Binding | .ref name      | Purpose                 |
|---------|---------------|-------------------------|
| 0       | u_lensLUT      | Lens distortion lookup  |
| 3       | u_texFull      | Scene color buffer      |
| 4       | u_texMotionBlur| Motion blur buffer      |
| 5       | u_bloomTex     | Bloom buffer            |

Key computations:

1. Lens distortion: UV warped via LUT based on distance from center.

2. Inverse scene decode: Scene buffer stored as `1/(1+hdr)` (inverse Reinhard),
   decoded back to linear HDR:
```glsl
hdr = (1.0 / max(0.0001, scene_color)) - 1.0
```

3. Bloom + exposure:
```glsl
combined = mix(hdr, bloom.rgb, bloom.a) * exposure   // exposure = u_postParams1.w
combined += motion_blur_contribution
```

4. Reinhard tonemapping (constant = 0.25, squared for contrast):
```glsl
mapped = combined / (combined + 0.25)
mapped *= mapped
```

5. Vignette: Elliptical mask from `u_postParams2.x/y/z`.

6. Dithering: Adds ±1/256 noise to break banding.

7. Gamma: `pow(result, u_postParams2.w)` — typically 1/2.2 for sRGB.

8. Channel swap: Final `RGB → BGR` (matches Vulkan swapchain format).

### Blender Approximation Strategy

The importer reproduces the ambient/baked lighting term only (no dynamic sun/specular):
```
result = matColor × RGBD_decode(a_light0) × mix(skyColor, sunColor, AO)
```
- Stored as linear HDR vertex colors (FLOAT_COLOR)
- Uses Emission shader to avoid Blender viewport double-lighting
- Blender's view transform (Filmic/AgX) handles display tonemapping

NOT reproduced (requires textures / dynamic state):
- Grass/sand/cliff texture detail from `.ktx` files
- PBR specular highlights (GGX)
- Dynamic sun contribution (depends on u_sunDir)
- Clustered point lights
- Wind animation
- Fog and atmospheric scattering
- Bloom and lens effects

---

## 28. BstGuid and Level Object Identification

A `BstGuid` is a uint32 that uniquely identifies an object within a level's data.
Used for:
- Cross-referencing objects across barns (e.g., `LevelLinkBarn::GetLevelLinkFromBstGuid`)
- Associating baked mesh data with placed objects
- Matching `Beamo` objects to their `LevelMaterial`

In the TGCL file, each `LevelMesh`/`Beamo`/`LevelMaterial` carries a `bstGuid` field.
The `materialBstGuid` on a `Beamo` is the `bstGuid` of a `LevelMaterial` in the same
level file. Resolution is a linear scan of the `LevelMaterial` array in
`LevelModelBarn::GetLevelMaterial`.

---

## 29. Complete Shader Decompilation Inventory

All 188 SPIR-V shaders (376 files: 188 VS + 188 FS) decompiled to GLSL via
`spirv-cross --version 460` (Vulkan SDK 1.4.341.0). Stored in `scratchpad/shaders/`.
Reflection names extracted from `.ref` files stored as `*.ref.txt`.

### Shader Categories

Terrain (level map geometry):
| Base         | Variants                                           |
|--------------|---------------------------------------------------|
| GrassSh      | Alpha, AlphaSkirt, Mesh, MeshAlpha                |
| SandSh       | Alpha, AlphaSkirt, Mesh, MeshAlpha                |
| RockFaceSh   | Alpha, AlphaSkirt, Mesh                           |
| CloudSh      | Alpha, AlphaSkirt                                 |
| GrassRainSh  | Alpha, AlphaSkirt                                 |
| SandRainSh   | Alpha, AlphaSkirt                                 |
| RockFaceRainSh| Alpha, AlphaSkirt                                |

Object/Mesh shaders:
| Shader        | Purpose                                          |
|---------------|--------------------------------------------------|
| Mesh          | Basic mesh, no spherical harmonics               |
| MeshAlpha     | Mesh with alpha blending                         |
| MeshSh        | Mesh with spherical harmonic lighting            |
| MeshShAlpha   | MeshSh + alpha                                   |
| MeshSl        | Mesh with shadow + lighting                      |
| MeshSlNoShadows | MeshSl without shadows                         |
| MeshCham      | Chameleon/color-shifting mesh                    |
| MeshChamSh    | Chameleon + SH lighting                          |
| MeshHeightChamSh | Height-based chameleon + SH                   |
| MeshRainSh    | Rain variant of MeshSh                           |
| MeshMagicGlow | Glowing magic mesh                               |
| MeshMotion    | Mesh with motion vectors                         |
| DarkStone     | Dark stone material                              |
| DarkStoneNoBake | Dark stone without baked lighting              |
| DarkstoneRain | Rain variant                                     |

Character/Spirit:
Avatar, AvatarCham, AvatarChamRef, AvatarDiamond, AvatarHair, AvatarHairRef,
AvatarRef, Spirit, SpiritBody, SpiritBodyAlpha, SpiritBodyRef, SpiritCore,
SpiritFrozen, SpiritMemoryMesh, SpiritParticle, SpiritProps, Creature, CreatureSl

Environment:
Ocean, OceanDark, OceanMesh, OceanMeshWet, OceanDarkMesh, OceanDarkMeshWet,
OceanOrbit, SkyboxCloud, Sun, CloudCore, CloudFluffy (+ Coarse, SuperCoarse,
Undulate variants), CloudCard, CloudQuad (Diamond, Fast, Fluffy, SoftFast)

VFX/Particles:
Candle, CandleAura, Flame, Flower, FlowerShadow, Beacon, Shout, Trail,
LightShroom, HeartAura, RepulsionField, Constellation, BirdFlock, Bub,
Tail, TailMotion, Sprite, ColorSprite, GlowSprite, MoteAnim, MoteMotion,
LensFlareDot, LensFlareStar, LensFlareSunDog, RainDrop, PuddleDrop

Post-processing:
Tonemap, TonemapBW, TonemapMovie, TonemapScreenshot, BloomDownOld, BloomUpOld,
LumFeedback, MotionBlur, MotionGen, MotionDilate, MotionDownsample,
TemporalAa, Fxaa, FxaaDisabled, FogVolume, FogUpsample, FogUpsampleCheap,
DepthDownsample, DepthDownsampleGather, DepthDownsampleQuarter, Resample

Lighting:
DirectionalLighting, DirectionalLightingNoUv, DirectionalLightingRail,
LitAlpha, LitAlphaColor, LitAlphaDual, LitAlphaFading, LitAlphaTest

UI/Debug:
Unlit (+ many variants), Cham, ChamAlpha, ChamAlphaDepth, ChamAlphaDepthColor,
ChamAlphaSdf, ChamShAlpha, DazzleCham, DazzleChamAlpha, DebugLine, DebugLineHud,
DebugText, HudMask, TguiBox, Portal, PortalGeo, ProjectedCircleZone,
CircleMotionGraphics, WaterSim, WaterSimReset, StaticMeshMotion

### Shared Patterns Across All Terrain Shaders

All terrain shaders (Grass/Sand/RockFace/Cloud + Rain variants) share:
1. Same vertex attribute layout (a_position, a_normal, a_light0/1/2, a_material0/1)
2. Same RGBD decode: `(a_light0.rgb)² / a_light0.w`
3. Same sky/sun tinting: `hdr * mix(u_averageSkyColor, u_sunColor, AO)`
4. Same material matching: `equal(a_material0 * 256, u_materialId)` → `dot(mask, a_material1)`
5. Same clustered light system (u_lightCSTex / u_lightPRTex) — except CloudSh
6. Same GGX/Smith BRDF for specular — except CloudSh (vertex-lit only)
7. Same shadow blend: `min(shadow * 0.25 + 0.75, 1.0)` for ambient term

---

## 30. Terrain Texture Pipeline

### MaterialDef Struct Layout

Each material definition in `MaterialDefBarn` is 0xA0 (160) bytes. The entry base
within RegisterDefs is at `this + index * 0xA0 + 0x10`. Verified by matching the
enum byte offset: code writes to `+0xA7` → field `0xA7 - 0x10 = 0x97` within the
struct, matching `SetMaterialShaderUniforms` reads from `param_2 + 0x97`.

Slot layout within MaterialDef:
- +0x00: shader name (string pointer)
- +0x08: Slot 1 uniform name
- +0x10: Slot 2 uniform name
- +0x18: Slot 3 uniform name
- +0x20: Slot 4 uniform name (if used)
- +0x28: Slot 1 resource name (KTX base name)
- +0x30: Slot 2 resource name
- +0x38: Slot 3 resource name
- +0x40: Slot 4 resource name
- +0x50..+0x5F: base color (Color::HSV → RGBA float)
- +0x7C: u_matUvScale (float)
- +0x84: roughness/metalness params
- +0x97: material enum byte

### Texture Assignments Per Material

| Material | Enum | Shader | Slot 1 | Slot 2 | Slot 3 |
|----------|------|--------|--------|--------|--------|
| RockFace | 0x01 | RockFaceSh | u_topGeoTexture → RockHeightCliffSh | u_sideGeoTexture → RockHeightCliffSh | — |
| Cliff | 0x10 | RockFaceSh | u_topGeoTexture → CliffSh | u_sideGeoTexture → CliffSh | — |
| CliffWet | 0x1c | RockFaceSh | u_topGeoTexture → CliffWetSh | u_sideGeoTexture → CliffWetSh | — |
| Sand | 0x20 | SandSh | u_normalTex → Noise3Ch | — | — |
| Grass | 0x30 | GrassSh | u_grassNorm1Tex → GrassNorTex0 | u_grassNorm2Tex → GrassNorTex1 | u_grassMaskTex → GrassMask |
| Cloud | 0x50 | CloudSh | — | — | — |

### u_matUvScale Values

| Material | Enum | u_matUvScale |
|----------|------|-------------|
| RockFace | 0x01 | 1.0 |
| Cliff/Soil | 0x10/0x11 | 0.25 |
| CliffWet | 0x1c | 0.25 |
| Sand/Snow/SandBright/SandAlt | 0x20–0x24 | 0.25 |
| Grass/GrassRain/GrassDark/GrassAlt | 0x30–0x33 | 1.0 |
| Cloud | 0x50 | 1.0 |

### Extracted Terrain Textures (KTX → PNG)

All extracted to `scratchpad/textures/`:

| File | Size | Contents |
|------|------|----------|
| GrassMask.png | 512×512 | Grass blade pattern (RGB mask, A=255) |
| GrassNorTex0.png | 512×512 | Grass normal map (RGB, A=255) |
| GrassNorTex1.png | 256×256 | Grass normal map 2 (RGB, A=255) |
| CliffSh.png | 512×512 | Cliff normal+height (RGBA, A=0-255: height channel) |
| CliffWetSh.png | 512×512 | Wet cliff variant (RGBA) |
| RockHeightCliffSh.png | 512×512 | Rock face normal+height (RGBA, A=0-255) |
| SandMask.png | 1024×1024 | Sand pattern (RGB, A=255) |
| Noise3Ch.png | 512×512 | 3-channel noise (RGB, A=255) |
| UpNormal.png | 4×4 | Unit up-normal lookup |

### Multi-Material Blend Pipeline

The engine renders terrain via multi-pass alpha compositing:
1. For each material type present in the level:
   - Set `u_materialId` = material enum (e.g., 0x30 for Grass)
   - Set `u_matColor` = material base RGB from RegisterDefs
   - Draw ALL terrain geometry using the material's shader
2. In the vertex shader:
   - `mask = equal(ivec4(a_material0 * 256), ivec4(u_materialId))` — which of 4 slots match
   - `blendWeight = dot(mask, a_material1)` — weight from matching slots
   - Output: `vec4(u_matColor, blendWeight)` as varying
3. In the base fragment shader (non-Alpha):
   - Only `.xyz` (matColor) is used; `.w` (blendWeight) is NOT referenced
4. In the Alpha fragment shader:
   - `.w` (blendWeight) IS used: combined with texture heights for output alpha
   - e.g., `alpha = ((tex1.z + tex2.z * 0.5) + blendWeight * 2.0 - 1.5) * 2.0`
   - Pixels with alpha ≤ 0.0001 are discarded
5. Pipeline composites each material pass via alpha blending

### Blender Implementation

Since Blender can't easily replicate multi-pass alpha compositing, the importer uses:
1. Per-vertex `MatColor`: stores the RegisterDefs base RGB for each vertex's `custom0[0]`
2. Per-vertex `FinalColor`: stores `MatColor × BakedLight` (RGBD decode + sky/sun tint)
3. Per-face material assignment: each triangle's material slot is determined by the
   majority vote of its three vertices' material enums, mapped to shader family
4. Textured materials per shader family:
   - `Sky_Terrain_Grass`: GrassMask.png as normal map, world-space XZ UVs
   - `Sky_Terrain_Rock_*`: tri-planar mapping with CliffSh/RockHeightCliffSh textures
   - `Sky_Terrain_Sand`: Noise3Ch.png as normal map, world-space XZ UVs
   - Fallback: plain Emission material from FinalColor
5. All textured materials use Principled BSDF with:
   - Emission = FinalColor (baked light, prevents double-lighting)
   - Base Color = MatColor (drives specular tint under viewport lighting)
   - Normal = texture-derived normal maps for surface detail
   - Emission Strength = 1.0
6. RockFace materials also use texture `.z` channel as AO/cavity multiplier
   on the emission (crevice darkening), and `.w` as roughness.

### Texture Channel Usage

CRITICAL: None of the three terrain shaders derive diffuse/albedo color from
textures. Surface color comes entirely from the vertex/material color (location 2).

| Shader | Texture .xy | .z | .w |
|--------|-------------|-----|-----|
| RockFaceSh | Normal map (tangent XY, Z reconstructed) | AO/cavity (multiplies diffuse) | Roughness |
| GrassSh | Flow/warp direction | Blend mask (grass density) | unused |
| SandSh | Normal direction | unused | unused |

---

## 31. Per-Level Environment from TGCL SetEnvDefault

### Data Source

Environment parameters are stored in `Objects.level.bin` (TGCL) as `SetEnvDefault`
objects. The one with `autoStart=1` is the active default. Levels may have multiple
`SetEnvDefault` objects; the first one is often uninitialized.

Also available: `SetEnvHull` (spatial override volumes) and `EnvNode` (animated
environment transitions with duration/fade).

### CandleSpace Environment

| Parameter | Value | Notes |
|-----------|-------|-------|
| sunColor | (0.0043, 0.0236, 0.0584) | Dim bluish (twilight level) |
| sunInt | 1.0 | Multiplied into final u_sunColor |
| sunAngleXZ | -3.0 degrees | Horizontal sun angle |
| sunAngleY | 15.0 degrees | Elevation angle |
| sunToMoon | 0.95 | 95% sun / 5% moon |
| exposure | 1.0 | Post-processing exposure |
| fogDensity | 1.0 | |
| fogHeight | 0.1 | |
| drawDistance | 15000.0 | |
| atmosphereDensity | 2.0 | |
| bloomIntensity | 0.035 | |

Sky gradient (5-band tintBot→tintTop, all very small = dim twilight):
- tintBot: (0.000213, 0.000033, 0.000015) — dark warm
- tintMidBot: (0.000655, 0.000254, 0.000046)
- tintMidMid: (0.001167, 0.001167, 0.000083)
- tintMidTop: (0.000446, 0.004132, 0.006310) — blue shift
- tintTop: (0.000684, 0.002423, 0.009672) — dark blue

### Ambience Processing Pipeline (from 0.11.0 decompile)

```
TGCL sunColor → u_atmosphereSunColor (raw copy)
             → × lerp(tintWeightedAvg, 1.0, extinction) × sunInt → u_sunColor

TGCL tintBot..tintTop → 7-Gaussian blend → 64-entry atmosphere LUT
                      → 256 hemisphere scatter samples → ÷256 → u_averageSkyColor
```

Key: `u_sunColor = sunColor × lerp(tintAvg, 1.0, exp2(-scatter)) × sunInt`

The small raw values (0.001-0.06) are correct — RGBD baked light produces high HDR
values (6-25×) that compensate when multiplied. The product gives visible brightness.

### Blender Implementation

1. Sun light: Direction from `sunAngleXZ`/`sunAngleY` (degrees), color from
   `sunColor × sunInt × 200` (scaled for Blender visibility), energy from sunInt.
2. Fog: Blender mist pass with `start = drawDist × 0.05`, `depth = drawDist × 0.5 × fogDensity`.
3. Compositor: Bloom glare node (threshold=1.0, mix=bloomIntensity×5) + Filmic view transform.
4. Exposure: Compositor exposure node when `exposure != 1.0`.

---

## 32. Shader-Specific Material Details (Full Decompile Analysis)

### GrassSh — Subsurface Translucency (from GrassSh.fs.glsl)

```glsl
float translucency = 3.0 * exp2((4.0 * roughness - 10.0) * max(0.0, NdotV));
vec3 ambient = matColor * (grassAlpha + translucency);
```

- With roughness = 0.9: exponent = (3.6 - 10) * NdotV = -6.4 * NdotV
- At grazing angle (NdotV ≈ 0): translucency ≈ 3.0 → strong rim/backlit glow
- At direct view (NdotV ≈ 1): translucency ≈ 0.036 → negligible
- Creates the characteristic "grass glowing when backlit" look

GrassMask .z channel: Used as blend mask for grass density (from shader),
modulates the grass variant mixing. Blender: drives `Subsurface Weight` per-pixel.

Blender approx: Principled BSDF with `Subsurface Weight = 0.4`,
`Subsurface Radius = (0.3, 0.5, 0.1)`, modulated by GrassMask .z channel.

### SandSh — Dual GGX Sparkle (from SandSh.fs.glsl)

```glsl
// Primary specular (sparkle): roughness = 0.25
float r1 = 0.25; float alpha1 = r1 * r1; // = 0.0625
// GGX NDF + Smith-GGX geometry + Fresnel (F0 = 0.06)
_773 = GGX_NDF(NdotH, alpha1);
_773 *= fresnel(0.06, VdotH);
_773 /= Smith_G(NdotH, alpha1);

// Secondary sheen: roughness = 0.3 + distance * 0.35 (capped at ~0.65)
float r2 = 0.3 + min(1, log2(1 + dist/30)) * 0.35;
_838 = GGX_NDF(NdotH2, r2*r2);
_838 *= fresnel(0.2, NdotV);
_838 /= Smith_G(NdotH2, r2*r2);

// Sheen denominator (rim enhancement):
vec3 sheen = (NdotV + _838) / (dot(unnorm_normal, view) * 0.2 + 0.06);
```

- Sharp sparkle from very low roughness (0.25) with high-frequency perturbed normal
- Strong normal perturbation: `normalize(vertex_normal × 0.4 + tex_normal × 2.0)`
- Sand multiplies final color by matColor at the end (line 279: `_871 *= matColor`)

Blender approx: Principled BSDF with `Roughness = 0.25`,
`Specular IOR Level = 0.6`, `Coat Weight = 0.3, Coat Roughness = 0.5`,
`Normal Map Strength = 1.5` (strong perturbation for sparkle).

### CloudSh — Simple Pass-Through (from CloudSh.fs/vs.glsl)

Fragment shader is trivial: `output = vec4(v_color.xyz, depth)`.
All lighting is computed in the vertex shader:
```glsl
// Same RGBD decode + sky/sun tinting as terrain
vec3 light = (RGB² / D) * mix(u_averageSkyColor, u_sunColor, AO);
// Additive emissive from probe
light += u_averageProbeColor * (uv0.w * exp2(255 * uv0.z - 128));
// Directional diffuse with rim/forward-scatter
float diff = normalY² * (0.5 + 0.5 * mix(NdotL, 1.0, max(0, -VdotL)));
// Forward scatter rim
float rim = 0.025 / (0.025 - (-1 - VdotL));
rim /= 0.025 * log(2/0.025 + 1);
// Final: matColor * (sunColor * diff + bakedLight) + sunColor * 2 * rim * normalY²
```

Vertex push-back for volume: `pos -= normal * 4 * max(0.5, 1 - 0.0125 * dist²)`.

Blender approx: Principled BSDF with `Roughness = 1.0`,
`Transmission Weight = 0.3`, Emission from FinalColor vertex attribute.

---

## 33. Tonemapping Pipeline (from Tonemap.fs.glsl / TonemapMovie.fs.glsl)

### Render Target Encoding

The game renders to a framebuffer with encoding `encoded = 1 / (1 + HDR)`.
This maps HDR [0, ∞) to [0, 1].

### Tonemap Shader Steps

```glsl
// 1. Decode HDR from render target
vec3 HDR = (1.0 / max(0.0001, encoded)) - 1.0;

// 2. Bloom mix (separate blur pass)
vec3 scene = mix(HDR, bloom.xyz, bloom.w) * exposure;  // _m2.w

// 3. Add glow buffer (separate glow pass)
scene += glow_buffer.xyz * colorTint;  // _m2.xyz

// 4. Modified Reinhard tonemap with 0.25 white point
vec3 LDR = scene / (scene + 0.25);
LDR *= LDR;  // square for contrast boost

// 5. Vignette (smoothstep from screen center)
float vig = smoothstep(edge, center, length(screenUV));
LDR *= vig;

// 6. Dithering (1/256 noise for banding reduction)
LDR += hash(fragCoord) / 256.0;
```

TonemapMovie additionally applies: `pow(LDR, gamma)` + BGR channel swap.

### Key Difference from Filmic

The game's `(x/(x+0.25))²` is more aggressive than Blender's Filmic:
- At x=0.1: game → 0.04, Filmic → ~0.06
- At x=0.5: game → 0.44, Filmic → ~0.45
- At x=2.0: game → 0.79, Filmic → ~0.85

Filmic Medium Contrast is the closest built-in approximation. For exact match,
a custom color curve node would be needed.

---

## 34. Per-Vertex Emissive Contribution (from Vertex Shader Analysis)

### HDR Intensity Factor

All terrain vertex shaders compute an additional HDR intensity from `a_light1`:
```glsl
float intensity = a_light1.w * exp2(255.0 * a_light1.z - 128.0);
```

This packs a float mantissa+exponent into two unorm8 values:
- `a_light1.z`: exponent (0.5 → 2⁰ = 1.0, 0.75 → 2^(63.25) → huge)
- `a_light1.w`: mantissa

### Usage Per Shader

| Shader | Usage |
|--------|-------|
| GrassSh/SandSh/RockFaceSh (fragment) | `bakedLight += u_averageProbeColor × intensity` |
| CloudSh (vertex) | Same, but in vertex shader |

`u_averageProbeColor` is a runtime uniform from the nearest light probe
(at offset +0x58f90 in the Ambience object). Cannot be extracted from
static level data. Known gap in Blender reproduction.

For CandleSpace: would be warm orange/yellow from candle light probes.

---

## 35. Blender Import — Per-Level Environment Color Integration

### Problem

Raw TGCL `sunColor` for twilight levels is very dim (e.g., CandleSpace 0.004-0.058).
The game multiplies by `sunInt` and atmospheric processing to get visible brightness.
Using raw values directly would make vertex colors too dark in Blender.

### Solution

`_apply_env_colors(env)` normalizes the TGCL colors:
```python
raw = sunColor * sunInt
peak = max(raw.r, raw.g, raw.b, 0.001)
sunColor_blender = raw * (0.9 / peak)  # normalized to ~0.9 peak

sky_peak = max(avgSky.r, avgSky.g, avgSky.b, 0.0001)
skyColor_blender = avgSky * (0.5 / sky_peak)  # normalized to ~0.5 peak
```

This preserves the color hue/ratio from the level data while maintaining
visible brightness. Falls back to defaults `(1.1, 0.95, 0.75)` / `(0.45, 0.55, 0.75)`
when TGCL is unavailable.

---

## 36. Water Rendering Pipeline (from 0.11.0 decompile)

### TGCL Water Objects

- Class `Water` in `Objects.level.bin` — transform row 3 (indices 12-14) = world position
- `waterType` field: 0 = default water, 2 = ooze (dark variant)
- `SetOceanRender` class: `render` field (0 = hidden, 1 = visible) — gates the entire ocean

#### Level survey:
| Level | Water objects | SetOceanRender | Notes |
|-------|--------------|----------------|-------|
| CandleSpace | None | None | No water |
| Rain | 2 (Y≈92.2) | 1 (render=0) | Has water at sea level |
| Dawn | 2 (garbage xform) | None | Transform data corrupt |

### Ocean Mesh Generation (from `Ocean::Initialize`)

- Mesh: 96×96 vertex grid (`Plane10x10` asset), 9216 vertices, 18050 triangles
- Vertex format: position (vec3) + normal (vec4) only — no UVs (computed procedurally)
- Centered at Water.transform position, scaled to cover level bounds

### Ocean Vertex Shader (`Ocean.vs.glsl`)

- Wave displacement: sine-based vertical offset `sin(time + pos.x*freq) * amplitude`
- LOD fade: amplitude → 0 between 10-25 unit camera distance
- 3 UV sets for ripple textures: computed from world pos + `u_windScroll0/1/2`
- `u_oceanOffset`: vec4(center.x, center.z, radius, unused) — dynamic wind tracking

### Ocean Fragment Shader (`Ocean.fs.glsl`)

Key textures:
- `u_waterSimNorm`: WaterSim gradient output (wave normals)
- `u_normalTex`: tileable ripple normal map
- `u_probeCube`: reflection cubemap
- `u_opaqueTexRGBDepth`: scene behind water (refraction)
- `u_causticTex`: caustics pattern

Rendering pipeline:
1. Read scene depth + color for refraction
2. Construct surface normal from `u_waterSimNorm` + `u_normalTex` ripples
3. Fresnel: `mix(0.01, 0.6, (1 - NdotV)^7)` — strong reflection at grazing
4. Specular Fresnel: `mix(0.04, 0.8, (1 - VdotH)^7)` — sun specular
5. Water body color: hardcoded `vec3(0.01, 0.03, 0.06)` (dark blue-green)
6. Chromatic absorption: R absorbed first through depth
7. Cubemap reflection blended by Fresnel factor
8. Caustics projected onto underwater geometry
9. Edge glow at shore

### WaterSim Fragment Shader (`WaterSim.fs.glsl`)

- 2D fluid simulation (GPU ping-pong)
- State: height (.x), secondary (.y), velocity (.z), amplitude/age (.w)
- Laplacian filter for wave propagation + damping
- Rain drop disturbances
- Output: height displacement + gradients for Ocean normal construction

### Ocean Enable Mechanism (from decompile)

- `Ocean+0x700` is the render enable flag. Initialized to 0 in both
  `Ocean::Initialize` and `Ocean::OnLevelLoad`.
- `Ocean::BuildScene` gates on `(this[0x700] != 0) && kDisplayOcean`.
- `SetOceanRender` is a TGCL event class with `Tool_AutoStartEvent` metadata
  and a `render` member (bool). When it auto-starts, it sets `Ocean+0x700`.
- CandleSpace has NO `Water` or `SetOceanRender` objects in its TGCL.
  The visible ocean likely comes from scene composition (parent level),
  Lua scripting, or terrain geometry that looks like water.
- Importer provides `water_height_override` for levels lacking TGCL water data.

### Level ID Mapping (from `GetLevelId`)

| Level ID | Levels | Ocean Shader |
|----------|--------|-------------|
| 0 | WorldEmpty | Ocean |
| 1 | CandleSpace | Ocean |
| 2 | Dawn, HubReveal, DawnCave, RetailDemo_Dawn | Ocean |
| 6 | Dusk* levels | OceanDark |
| 8 | Storm* levels | OceanDark |

### Blender Implementation

Since water simulation, reflections, refractions, caustics are runtime-only,
the Blender importer creates a static approximation:
- 96×96 grid plane at TGCL Water Y height, covering terrain bounds + 10% padding
- Material: Principled BSDF with IOR=1.33, Roughness=0.02, Transmission=0.85
- Base Color: (0.02, 0.06, 0.12) — shader's (0.01, 0.03, 0.06) scaled for Blender
- Ooze variant: darker (0.005, 0.005, 0.01), rougher (0.15)
- Smooth shading enabled

---

## 37. Blender Reproduction Scope

### Implemented in Blender Importer

- RGBD baked light decode (squared RGB, division by D)
- Sun/sky tinting from vertex AO (`mix(skyColor, sunColor, AO)`)
- Per-level environment colors from TGCL SetEnvDefault
- Per-vertex material color from RegisterDefs HSV→RGB
- Per-face material assignment (majority vote of vertex enums)
- Tri-planar texture mapping for RockFaceSh (normal, AO, roughness)
- World-space XZ normal maps for GrassSh and SandSh
- Grass subsurface translucency (Subsurface Weight + GrassMask .z)
- Sand dual GGX sparkle (low roughness + coat + strong normals)
- Cloud material (pass-through emission)
- Sun light direction and color
- Fog/mist settings
- Bloom compositor node
- Filmic tonemapping approximation
- Water surface planes from TGCL Water objects
- Ocean PBR material (IOR, transmission, Fresnel-like, body color)
- Ooze water variant support

### Not Reproducible from Static Data

These require runtime GPU state and cannot be extracted from level files:

- `u_averageProbeColor` — runtime light probe data
- Clustered point/spot lights (`u_lightCSTex`, `u_lightPRTex`) — runtime tile-based data
- Dynamic shadows from sun
- Water wave simulation (`u_waterSimTerms*`) — runtime fluid sim, GPU ping-pong
- Water reflections/refractions — require runtime cubemap + scene depth
- Water caustics — projected texture, runtime dependent
- Character/creature shaders (OutfitSh, HairSh, etc.)

### Possible Future Improvements

- Custom tonemapping curve `(x/(x+0.25))²` via compositor math nodes
- Better atmospheric scattering for `u_averageSkyColor` (7-Gaussian LUT)
- SH probe coefficients from level data (if extractable from TGCL probes)
- GrassSh: two-layer normal blending (GrassNorTex0 + GrassNorTex1 with warp)
- SandSh: heightmap-based shadow/AO modulation (requires separate heightmap)
- Animated water using Blender wave modifier as approximation of WaterSim
