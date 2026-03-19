"""Objects.level.bin (TGCL) parser for Sky: Children of the Light.

Parses the level scene graph binary — object placements, transforms,
mesh references, material bindings, and cross-object pointers.

Reference: mesh_encoding_research.md §18
"""

import struct

from sky_mesh.stream import BinaryStream
from sky_mesh.level_types import TgclFile, TgclClass, TgclMemberVar, TgclObject

TGCL_MAGIC = 0x4C434754
TGCL_HEADER_SIZE = 44
LO_CLASS_SIZE = 12
LO_MEMBER_VAR_SIZE = 16

VAR_TYPE_POD = 0
VAR_TYPE_STRING = 1
VAR_TYPE_OBJ_PTR = 2
VAR_TYPE_ARRAY = 3


def _read_null_terminated(data: bytes, offset: int) -> tuple[str, int]:
    """Read a null-terminated string from raw bytes."""
    end = data.index(b"\x00", offset)
    return data[offset:end].decode("ascii", errors="replace"), end + 1


def _read_string_from_table(string_table: bytes, offset: int) -> str:
    """Read a null-terminated string from the string table."""
    end = string_table.index(b"\x00", offset)
    return string_table[offset:end].decode("ascii", errors="replace")


def parse_tgcl(filepath: str) -> TgclFile:
    """Parse an Objects.level.bin TGCL file.

    File format:
      [44 bytes]  LoToc header (magic, counts, offsets)
      [class table]    numClasses × 12B LoClass entries
      [member var table] numMemberVars × 16B LoMemberVar entries
      [string table]   Flat null-terminated strings
      [POD data]       Per-object sequential data
    """
    with open(filepath, "rb") as f:
        file_data = f.read()

    if len(file_data) < TGCL_HEADER_SIZE:
        raise ValueError(f"File too small: {len(file_data)} bytes")

    magic = struct.unpack_from("<I", file_data, 0)[0]
    if magic != TGCL_MAGIC:
        raise ValueError(f"Bad magic: 0x{magic:08X} (expected 0x{TGCL_MAGIC:08X})")

    (
        _, unknown,
        num_classes, num_member_vars, num_objects, num_ptr_fixups,
        class_table_off, member_var_table_off, string_table_off,
        pod_data_off, file_size,
    ) = struct.unpack_from("<11I", file_data, 0)

    if file_size != 0 and file_size != len(file_data):
        pass

    string_table_end = pod_data_off if pod_data_off > string_table_off else len(file_data)
    string_table = file_data[string_table_off:string_table_end]

    classes: list[TgclClass] = []
    for i in range(num_classes):
        off = class_table_off + i * LO_CLASS_SIZE
        name_offset, first_mv, num_mv = struct.unpack_from("<III", file_data, off)
        name = _read_string_from_table(string_table, name_offset)
        classes.append(TgclClass(
            name=name, first_member_var_index=first_mv,
            num_member_vars=num_mv,
        ))

    all_member_vars: list[TgclMemberVar] = []
    for i in range(num_member_vars):
        off = member_var_table_off + i * LO_MEMBER_VAR_SIZE
        var_type, name_offset, size, arr_elem_type = struct.unpack_from("<IIIi", file_data, off)
        name = _read_string_from_table(string_table, name_offset)
        all_member_vars.append(TgclMemberVar(
            name=name, var_type=var_type, size=size,
            array_element_type_id=arr_elem_type,
        ))

    for cls in classes:
        start = cls.first_member_var_index
        end = start + cls.num_member_vars
        cls.member_vars = all_member_vars[start:end]

    objects: list[TgclObject] = []
    pos = pod_data_off

    for obj_i in range(num_objects):
        if pos + 4 > len(file_data):
            break

        class_index = struct.unpack_from("<I", file_data, pos)[0]
        pos += 4

        if class_index == 0xFFFFFFFF:
            objects.append(TgclObject(
                class_index=-1, class_name="(null)",
                instance_name="", fields={},
            ))
            continue

        if class_index >= len(classes):
            objects.append(TgclObject(
                class_index=class_index,
                class_name=f"(unknown class {class_index})",
                instance_name="", fields={},
            ))
            continue

        cls = classes[class_index]
        instance_name, pos = _read_null_terminated(file_data, pos)

        fields = {}
        for mv in cls.member_vars:
            if pos >= len(file_data):
                break

            if mv.var_type == VAR_TYPE_POD:
                raw = file_data[pos:pos + mv.size]
                pos += mv.size
                fields[mv.name] = _decode_pod_field(mv.name, mv.size, raw)

            elif mv.var_type == VAR_TYPE_STRING:
                val, pos = _read_null_terminated(file_data, pos)
                fields[mv.name] = val

            elif mv.var_type == VAR_TYPE_OBJ_PTR:
                ref_idx = struct.unpack_from("<I", file_data, pos)[0]
                pos += 4
                fields[mv.name] = ref_idx if ref_idx != 0xFFFFFFFF else None

            elif mv.var_type == VAR_TYPE_ARRAY:
                arr_count = struct.unpack_from("<I", file_data, pos)[0]
                pos += 4
                fields[mv.name] = {"_array_count": arr_count}

        objects.append(TgclObject(
            class_index=class_index, class_name=cls.name,
            instance_name=instance_name, fields=fields,
        ))

    return TgclFile(
        magic=magic,
        num_classes=num_classes,
        num_member_vars=num_member_vars,
        num_objects=num_objects,
        num_ptr_fixups=num_ptr_fixups,
        classes=classes,
        objects=objects,
    )


def _decode_pod_field(name: str, size: int, raw: bytes):
    """Best-effort decode of a POD field based on name and size."""
    if size == 64 and "transform" in name.lower():
        return list(struct.unpack("<16f", raw))

    if size == 12:
        return struct.unpack("<fff", raw)

    if size == 16:
        return struct.unpack("<ffff", raw)

    if size == 4:
        as_float = struct.unpack("<f", raw)[0]
        as_int = struct.unpack("<I", raw)[0]
        if name in ("bstGuid", "materialBstGuid", "flags", "collision"):
            return as_int
        if abs(as_float) < 1e10 and as_float != 0:
            return as_float
        return as_int

    if size == 1:
        return raw[0]

    if size == 2:
        return struct.unpack("<H", raw)[0]

    return raw
