# Reverse me i'm famous! — Project Writeup

## Structure

```
.
├── binary/           ← original unmodified binaries (level1, level2, level3)
├── level1/
│   ├── password              ← valid password for level1
│   ├── source.c              ← reverse-engineered C source
│   ├── patch_explanation.md  ← bonus: patch methodology
│   └── level1_patched        ← bonus: patched binary (accepts any password)
├── level2/
│   ├── password
│   ├── source.c
│   ├── patch_explanation.md
│   └── level2_patched
├── level3/
│   ├── password
│   ├── source.c
│   ├── patch_explanation.md
│   └── level3_patched
└── patch_all.py      ← bonus: reproduces all patches from original binaries
```

---

## Mandatory Part

### level1 — ELF 32-bit x86 (easy)

**Algorithm:** Stores the reference string `__stack_check` in `.rodata`,
copies it onto the stack word-by-word before reading input, then calls
`strcmp(input, ref)`.

**Password:** `__stack_check`

**Tools used:** `objdump -d`, `objdump -s -j .rodata`

---

### level2 — ELF 32-bit x86 (medium)

**Algorithm:**
1. Reads up to 23 chars with `scanf("%23s", buf)`.
2. Checks `buf[0]=='0'` and `buf[1]=='0'`.
3. Reads groups of 3 chars from `buf[2..]`, converts each with `atoi()`,
   stores resulting bytes in a result buffer (pre-initialized with `'d'`).
4. Compares result buffer with `"delabere"` via `strcmp()`.

**Password:** `00101108097098101114101`

Derivation:
- Prefix `"00"` (mandatory checks)
- `'e'`=101 → `"101"`, `'l'`=108 → `"108"`, `'a'`=97 → `"097"`,
  `'b'`=98 → `"098"`, `'e'`=101 → `"101"`, `'r'`=114 → `"114"`,
  `'e'`=101 → `"101"`
- Total: `"00"` + `"101108097098101114101"` = 23 chars

**Tools used:** `objdump -d`, `strings`

---

### level3 — ELF 64-bit x86-64 (hard)

**Algorithm:** Identical encoding loop to level2, but:
- Prefix check: `buf[0]=='4'`, `buf[1]=='2'`
- Target string: `"********"` (8 × `'*'` = 8 × 0x2a = 8 × 42)
- Control flow: a `switch` on `strcmp` result with 9 cases; only `case 0`
  leads to "Good job."

**Password:** `42042042042042042042042`

Derivation:
- Prefix `"42"` (mandatory checks)
- `'*'`=42=0x2a → `"042"` × 7 groups
- Total: `"42"` + `"042"×7` = 23 chars

**Tools used:** `objdump -d`, `objdump -s -j .rodata`, Python3 for byte math

---

## Bonus Part

Each binary is patched so that it prints "Good job." for any input,
by modifying only the `.text` section (no library override, no LD_PRELOAD).

| Binary | Patch offset | Original bytes     | Patched bytes        | Technique          |
|--------|--------------|--------------------|----------------------|--------------------|
| level1 | `0x1244`     | `0f 85 16 00 00 00`| `90 90 90 90 90 90`  | NOP the `jne`      |
| level2 | `0x146d`     | `0f 85 0d 00 00 00`| `90 90 90 90 90 90`  | NOP the `jne`      |
| level3 | `0x14a5`     | `85 c0`            | `31 c0`              | `test`→`xor eax,eax`|

See each `patch_explanation.md` for full detail.

To reproduce the patched binaries from the originals:
```
python3 patch_all.py
```
