#!/usr/bin/env python3
"""Convert a raw little-endian binary into $readmemh format.

One 32-bit word per line, zero-padded to 8 hex digits, so the output can be
loaded directly into `instr_mem_behavioral.memory_array` (word addressed).
"""

import sys


def main(argv):
    if len(argv) != 3:
        print("usage: bin2hex.py <in.bin> <out.hex>", file=sys.stderr)
        return 2

    data = open(argv[1], "rb").read()
    if len(data) % 4:
        data += b"\x00" * (4 - len(data) % 4)

    with open(argv[2], "w") as f:
        for i in range(0, len(data), 4):
            word = int.from_bytes(data[i : i + 4], "little")
            f.write(f"{word:08x}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
