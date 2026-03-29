#!/usr/bin/env python3
"""
patch_all.py — Bonus patch script for "Reverse me i'm famous!" (Cybersecurity Piscine)

Generates patched versions of level1, level2, level3 that accept any valid password.
Run from the root of the project (expects binaries in ./binary/).

Usage:
    python3 patch_all.py

Output:
    level1/level1_patched
    level2/level2_patched
    level3/level3_patched
"""

import os
import sys


def patch_binary(src_path: str, dst_path: str, patches: list, label: str) -> None:
    """
    Apply a list of (offset, bytes) patches to src_path and write to dst_path.
    """
    with open(src_path, 'rb') as f:
        data = bytearray(f.read())

    for offset, original, replacement, description in patches:
        actual = data[offset:offset + len(original)]
        if actual != bytearray(original):
            print(f"  [ERROR] {label}: expected {bytes(original).hex()} "
                  f"at 0x{offset:x}, found {bytes(actual).hex()}")
            sys.exit(1)
        data[offset:offset + len(replacement)] = bytearray(replacement)
        print(f"  [{label}] 0x{offset:04x}: {bytes(original).hex()} "
              f"→ {bytes(replacement).hex()}  ({description})")

    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    with open(dst_path, 'wb') as f:
        f.write(data)
    os.chmod(dst_path, 0o755)
    print(f"  [{label}] Written: {dst_path}\n")


def main():
    base = os.path.dirname(os.path.abspath(__file__))
    binary_dir = os.path.join(base, 'binary')

    # ── level1 ───────────────────────────────────────────────────────────────
    # Patch: NOP the jne at 0x1244 (6 bytes)
    # Original: 0f 85 16 00 00 00  (jne +0x16)
    # Patched:  90 90 90 90 90 90  (6 × NOP)
    # Effect: always falls through to "Good job." regardless of strcmp result
    patch_binary(
        src_path=os.path.join(binary_dir, 'level1'),
        dst_path=os.path.join(base, 'level1', 'level1_patched'),
        patches=[
            (
                0x1244,
                [0x0f, 0x85, 0x16, 0x00, 0x00, 0x00],
                [0x90, 0x90, 0x90, 0x90, 0x90, 0x90],
                'jne -> 6×NOP: bypass strcmp result check'
            ),
        ],
        label='level1'
    )

    # ── level2 ───────────────────────────────────────────────────────────────
    # Patch: NOP the jne at 0x146d (6 bytes)
    # Original: 0f 85 0d 00 00 00  (jne +0x0d)
    # Patched:  90 90 90 90 90 90  (6 × NOP)
    # Effect: always falls through to ok() -> "Good job."
    patch_binary(
        src_path=os.path.join(binary_dir, 'level2'),
        dst_path=os.path.join(base, 'level2', 'level2_patched'),
        patches=[
            (
                0x146d,
                [0x0f, 0x85, 0x0d, 0x00, 0x00, 0x00],
                [0x90, 0x90, 0x90, 0x90, 0x90, 0x90],
                'jne -> 6×NOP: bypass final strcmp result check'
            ),
        ],
        label='level2'
    )

    # ── level3 ───────────────────────────────────────────────────────────────
    # Patch: replace 'test eax,eax' with 'xor eax,eax' at 0x14a5 (2 bytes)
    # Original: 85 c0  (test eax,eax — checks if eax==0 without changing it)
    # Patched:  31 c0  (xor eax,eax  — forces eax=0, always sets ZF)
    # Effect: the following 'je 0x155e' always fires -> ____syscall_malloc() -> "Good job."
    patch_binary(
        src_path=os.path.join(binary_dir, 'level3'),
        dst_path=os.path.join(base, 'level3', 'level3_patched'),
        patches=[
            (
                0x14a5,
                [0x85, 0xc0],
                [0x31, 0xc0],
                'test eax,eax -> xor eax,eax: force discriminant=0 in switch'
            ),
        ],
        label='level3'
    )

    print("All patches applied successfully.")
    print("Patched binaries require the same runtime environment as the originals")
    print("(32-bit libs for level1/level2, 64-bit for level3).")


if __name__ == '__main__':
    main()
