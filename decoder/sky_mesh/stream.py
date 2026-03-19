"""Binary stream reader mirroring Sky's BinaryStream class.

Supports both byte-aligned reads (standard BinaryStream) and bit-level
reads (BitPacker) used by BstBaked.meshes terrain mesh serialization.
"""

from __future__ import annotations

import struct


class BinaryStream:
    """Sequential binary reader with typed deserialization methods.

    Mirrors the engine's BinaryStream, including the critical distinction
    between in-memory and serialized sizes:
      - Vector3: 12 bytes serialized (3 × float32), 16 bytes in memory
      - Quat:    16 bytes serialized (4 × float32)
      - SQT:     40 bytes serialized (12 + 16 + 12), 48 bytes in memory
    """

    def __init__(self, data: bytes, offset: int = 0):
        self._data = data
        self._pos = offset
        self._bit_pos = 0
        self._bit_buf = 0

    def read_bytes(self, count: int) -> bytes:
        end = self._pos + count
        if end > len(self._data):
            raise EOFError(
                f"Read past end: wanted {count} bytes at 0x{self._pos:X}, "
                f"only {len(self._data) - self._pos} remaining"
            )
        result = self._data[self._pos:end]
        self._pos = end
        return result

    def read_int32(self) -> int:
        return struct.unpack_from("<i", self._data, self._advance(4))[0]

    def read_uint32(self) -> int:
        return struct.unpack_from("<I", self._data, self._advance(4))[0]

    def read_uint16(self) -> int:
        return struct.unpack_from("<H", self._data, self._advance(2))[0]

    def read_float(self) -> float:
        return struct.unpack_from("<f", self._data, self._advance(4))[0]

    def read_float16(self) -> float:
        return struct.unpack_from("<e", self._data, self._advance(2))[0]

    def read_uint8(self) -> int:
        val = self._data[self._pos]
        self._pos += 1
        return val

    def read_int8(self) -> int:
        return struct.unpack_from("<b", self._data, self._advance(1))[0]

    def read_bool(self) -> bool:
        return self.read_uint8() != 0

    def read_vec3(self) -> tuple[float, float, float]:
        """Read Vector3: 3 × float32 = 12 bytes (NO padding in stream)."""
        pos = self._advance(12)
        return struct.unpack_from("<fff", self._data, pos)

    def read_quat(self) -> tuple[float, float, float, float]:
        """Read Quaternion: 4 × float32 = 16 bytes."""
        pos = self._advance(16)
        return struct.unpack_from("<ffff", self._data, pos)

    def read_vec3_f16(self) -> tuple[float, float, float]:
        """Read Vector3 as 3 × float16 = 6 bytes (compressed animation)."""
        pos = self._advance(6)
        return struct.unpack_from("<eee", self._data, pos)

    def read_quat_f16(self) -> tuple[float, float, float, float]:
        """Read Quaternion as 4 × float16 = 8 bytes (compressed animation)."""
        pos = self._advance(8)
        return struct.unpack_from("<eeee", self._data, pos)

    def read_matrix4x4(self) -> list[float]:
        """Read 4×4 float32 matrix = 64 bytes, returned as flat list of 16 floats."""
        pos = self._advance(64)
        return list(struct.unpack_from("<16f", self._data, pos))

    def read_string(self, size: int) -> str:
        """Read a fixed-size null-terminated string buffer."""
        data = self.read_bytes(size)
        null = data.find(b"\x00")
        if null >= 0:
            data = data[:null]
        return data.decode("ascii", errors="replace")

    def read_length_string(self) -> str:
        """Read a length-prefixed string: uint32 length + raw chars."""
        length = self.read_uint32()
        if length == 0:
            return ""
        data = self.read_bytes(length)
        return data.decode("ascii", errors="replace")

    def read_floats(self, count: int) -> list[float]:
        """Read `count` consecutive float32 values."""
        pos = self._advance(count * 4)
        return list(struct.unpack_from(f"<{count}f", self._data, pos))

    def skip(self, count: int) -> None:
        self._pos += count

    def tell(self) -> int:
        return self._pos

    def remaining(self) -> int:
        return len(self._data) - self._pos

    def slice(self, length: int) -> BinaryStream:
        """Create a sub-stream from the next `length` bytes, advancing this stream."""
        data = self.read_bytes(length)
        return BinaryStream(data)

    def read_int16(self) -> int:
        return struct.unpack_from("<h", self._data, self._advance(2))[0]

    def read_bit_bool(self) -> bool:
        """Read a single bit as a boolean (BitPacker style).

        The engine's BitPacker reads bits from the LSB of a byte. When bits
        are exhausted, the next byte is consumed. read_bit_align() discards
        remaining bits in the current byte.
        """
        if self._bit_pos == 0:
            self._bit_buf = self._data[self._pos]
            self._pos += 1
        val = (self._bit_buf >> self._bit_pos) & 1
        self._bit_pos += 1
        if self._bit_pos >= 8:
            self._bit_pos = 0
        return bool(val)

    def read_bit_align(self) -> None:
        """Discard remaining bits in the current byte (BitPacker byte-align)."""
        self._bit_pos = 0

    def _advance(self, count: int) -> int:
        pos = self._pos
        self._pos += count
        return pos
