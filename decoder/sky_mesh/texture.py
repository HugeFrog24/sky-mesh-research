"""Texture and material resolver for Sky outfit meshes.

Parses OutfitDefs.json for outfit->mesh->texture mapping and Persistent.lua
for ImageRegion atlas sub-rectangle lookups. Also provides KTX1/ETC2 texture
decoding to PNG.
"""

import json
import re
import os
import struct
from sky_mesh.types import OutfitDef, OutfitTexture, ImageRegion


class TextureResolver:
    """Resolves Sky outfit textures to actual image files and atlas regions.

    Usage:
        resolver = TextureResolver("path/to/assets/Data")
        resolver.load()

        outfit = resolver.get_outfit("CharSkyKid_Body_ClassicShortPants")
        diffuse_region = resolver.get_image_region(outfit.textures[0].diffuse)
        # → ImageRegion(name="..._Tex", image="CharSkyKid_Atlas_Tex",
        #               uv=(0.0, 0.0, 0.5, 0.5))
    """

    def __init__(self, data_path: str):
        """data_path: root Data/ directory (containing Resources/, Images/)."""
        self.data_path = data_path
        self.outfits: dict[str, OutfitDef] = {}
        self.image_regions: dict[str, ImageRegion] = {}
        self.standalone_images: dict[str, str] = {}

    def load(self) -> None:
        outfit_path = os.path.join(self.data_path, "Resources", "OutfitDefs.json")
        if os.path.exists(outfit_path):
            self._parse_outfit_defs(outfit_path)

        persistent_path = os.path.join(self.data_path, "Resources", "Persistent.lua")
        if os.path.exists(persistent_path):
            self._parse_persistent_lua(persistent_path)

    def get_outfit(self, name: str) -> OutfitDef | None:
        return self.outfits.get(name)

    def find_outfit_for_mesh(self, mesh_name: str) -> OutfitDef | None:
        """Find the outfit that references a given mesh name."""
        for outfit in self.outfits.values():
            if mesh_name in outfit.mesh:
                return outfit
        return None

    def get_image_region(self, name: str) -> ImageRegion | None:
        return self.image_regions.get(name)

    def resolve_texture_path(
        self, texture_name: str, platform: str = "ETC2"
    ) -> str | None:
        """Resolve a texture name to a .ktx file path on disk.

        If the name is an ImageRegion, returns the atlas texture path.
        If it's a standalone image, returns that directly.
        """
        region = self.image_regions.get(texture_name)
        if region:
            ktx = os.path.join(
                self.data_path, "Images", "Bin", platform, region.image + ".ktx"
            )
            if os.path.exists(ktx):
                return ktx

        ktx = os.path.join(
            self.data_path, "Images", "Bin", platform, texture_name + ".ktx"
        )
        if os.path.exists(ktx):
            return ktx

        return None

    def _parse_outfit_defs(self, path: str) -> None:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)

        for entry in data:
            name = entry.get("name", "")
            textures = []
            for t in entry.get("texture", []):
                textures.append(
                    OutfitTexture(
                        attribute=t.get("attribute", ""),
                        diffuse=t.get("diffuse", ""),
                    )
                )

            def _get_hsv(key: str) -> tuple[float, float, float]:
                v = entry.get(key, [0.0, 0.0, 100.0])
                return (float(v[0]), float(v[1]), float(v[2]))

            outfit = OutfitDef(
                name=name,
                type=entry.get("type", ""),
                mesh=entry.get("mesh", []),
                shader=entry.get("shader", ""),
                textures=textures,
                mask=entry.get("mask", []),
                pattern=entry.get("pattern", []),
                norm=entry.get("norm", ""),
                color_hsv=_get_hsv("color_hsv"),
                tint_hsv=_get_hsv("tint_hsv"),
                pattern_hsv=_get_hsv("pattern_hsv"),
            )
            self.outfits[name] = outfit

    def _parse_persistent_lua(self, path: str) -> None:
        """Extract ImageRegion declarations from Persistent.lua.

        Matches patterns like:
          resource "ImageRegion" "SomeName"
              { image = "AtlasName", uv = { 0.0, 0.0, 4/8, 4/8 } }
        """
        with open(path, encoding="utf-8", errors="replace") as f:
            content = f.read()

        pattern = re.compile(
            r'resource\s+"ImageRegion"\s+"([^"]+)"\s*'
            r"\{[^}]*image\s*=\s*\"([^\"]+)\"[^}]*uv\s*=\s*\{([^}]+)\}",
            re.DOTALL,
        )

        for m in pattern.finditer(content):
            name = m.group(1)
            image = m.group(2)
            uv_str = m.group(3)
            uv_vals = self._parse_uv_values(uv_str)
            if uv_vals and len(uv_vals) == 4:
                self.image_regions[name] = ImageRegion(
                    name=name,
                    image=image,
                    uv=tuple(uv_vals),
                )

        img_pattern = re.compile(
            r'resource\s+"Image"\s+"([^"]+)"'
        )
        for m in img_pattern.finditer(content):
            self.standalone_images[m.group(1)] = m.group(1)

    @staticmethod
    def _parse_uv_values(uv_str: str) -> list[float]:
        """Parse Lua UV values like '0.0, 0.0, 4/8, 4/8' into floats."""
        parts = [p.strip() for p in uv_str.split(",")]
        values = []
        for p in parts:
            if not p:
                continue
            if "/" in p:
                num, den = p.split("/", 1)
                try:
                    values.append(float(num.strip()) / float(den.strip()))
                except (ValueError, ZeroDivisionError):
                    values.append(0.0)
            else:
                try:
                    values.append(float(p))
                except ValueError:
                    values.append(0.0)
        return values


# ---------------------------------------------------------------------------
#  KTX1 / ETC2 texture decoding
# ---------------------------------------------------------------------------

KTX1_MAGIC = b"\xAB\x4B\x54\x58\x20\x31\x31\xBB\x0D\x0A\x1A\x0A"

_GL_ETC1_RGB8 = 0x8D64
_GL_COMPRESSED_RGB8_ETC2 = 0x9274
_GL_COMPRESSED_SRGB8_ETC2 = 0x9275
_GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9276
_GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9277
_GL_COMPRESSED_RGBA8_ETC2_EAC = 0x9278
_GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = 0x9279


def decode_ktx_texture(
    ktx_path: str,
    output_path: str,
    crop_uv: tuple[float, float, float, float] | None = None,
) -> tuple[int, int]:
    """Decode a KTX1 (ETC2) texture to a PNG file.

    Args:
        ktx_path:    Path to the .ktx file.
        output_path: Where to save the .png.
        crop_uv:     Optional (u_min, v_min, u_max, v_max) in 0-1 range
                     to crop an atlas region.

    Returns:
        (width, height) of the output image.
    """
    try:
        import texture2ddecoder
    except ImportError:
        raise ImportError(
            "texture2ddecoder is required for KTX decoding.\n"
            "  pip install texture2ddecoder"
        )
    try:
        from PIL import Image
    except ImportError:
        raise ImportError(
            "Pillow is required for PNG output.\n"
            "  pip install Pillow"
        )

    with open(ktx_path, "rb") as f:
        data = f.read()

    if data[:12] != KTX1_MAGIC:
        raise ValueError(f"Not a KTX1 file: {ktx_path}")

    endian = struct.unpack_from("<I", data, 12)[0]
    if endian != 0x04030201:
        raise ValueError("Big-endian KTX files are not supported")

    gl_internal = struct.unpack_from("<I", data, 28)[0]
    width = struct.unpack_from("<I", data, 36)[0]
    height = struct.unpack_from("<I", data, 40)[0]
    kv_bytes = struct.unpack_from("<I", data, 60)[0]

    mip0_offset = 64 + kv_bytes
    mip0_size = struct.unpack_from("<I", data, mip0_offset)[0]
    mip0_data = data[mip0_offset + 4 : mip0_offset + 4 + mip0_size]

    if gl_internal in (_GL_COMPRESSED_RGB8_ETC2, _GL_COMPRESSED_SRGB8_ETC2):
        rgba = texture2ddecoder.decode_etc2(mip0_data, width, height)
    elif gl_internal in (_GL_COMPRESSED_RGBA8_ETC2_EAC, _GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC):
        rgba = texture2ddecoder.decode_etc2a8(mip0_data, width, height)
    elif gl_internal in (
        _GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2,
        _GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2,
    ):
        rgba = texture2ddecoder.decode_etc2a1(mip0_data, width, height)
    elif gl_internal == _GL_ETC1_RGB8:
        rgba = texture2ddecoder.decode_etc1(mip0_data, width, height)
    else:
        raise ValueError(
            f"Unsupported GL internal format 0x{gl_internal:04X} in {ktx_path}"
        )

    # texture2ddecoder returns BGRA; convert to RGBA
    img = Image.frombytes("RGBA", (width, height), rgba)
    r, g, b, a = img.split()
    img = Image.merge("RGBA", (b, g, r, a))

    if crop_uv:
        u0, v0, u1, v1 = crop_uv
        left = int(u0 * width)
        upper = int(v0 * height)
        right = int(u1 * width)
        lower = int(v1 * height)
        img = img.crop((left, upper, right, lower))
        width, height = img.size

    img.save(output_path)
    return width, height
