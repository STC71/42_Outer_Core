# Bonus – level1 Binary Patch Explanation

## Goal
Make the binary accept **any password** without modifying library functions
or using `LD_PRELOAD`.

## Method: NOP-out the conditional jump

### Disassembly of the critical section (original binary)

```
1241:  83 f8 00           cmp    $0x0,%eax       ; test strcmp() return value
1244:  0f 85 16 00 00 00  jne    1260 <main+0xa0> ; if NOT equal -> Nope
124a:  ...                                        ; (fall-through) -> Good job.
...
1260:  ...                lea    -0x1fc9(%ebx),%eax
1263:  ...                call   printf           ; prints "Nope."
```

After `strcmp(input, ref)` the result is in `%eax`.
- `eax == 0`  → strings match → falls through to "Good job."
- `eax != 0`  → `jne` fires  → jumps to "Nope."

### Patch applied

| Offset | Original bytes     | Patched bytes        | Meaning            |
|--------|--------------------|----------------------|--------------------|
| 0x1244 | `0f 85 16 00 00 00`| `90 90 90 90 90 90`  | `jne` → 6 × `NOP` |

Replacing the 6-byte `jne rel32` with six `NOP` (0x90) instructions makes
the CPU **always fall through** to the "Good job." branch, regardless of
the value in `%eax` (i.e. regardless of what the user typed).

### How the patch was applied

```python
data = bytearray(open('binary/level1', 'rb').read())
data[0x1244:0x1250] = b'\x90\x90\x90\x90\x90\x90'
open('level1/level1_patched', 'wb').write(data)
```

### Why this is valid

- No library function is overridden.
- No `LD_PRELOAD` or environment trick is used.
- The binary is executed exactly as-is; the patch is inside the `.text`
  section and changes only the control-flow decision byte sequence.
- `strcmp` still runs normally; we simply ignore its return value by
  removing the branch that acts on it.

### Verification

```
$ echo "anything" | ./level1_patched
Please enter key: Good job.

$ echo "wrongpassword123" | ./level1_patched
Please enter key: Good job.
```
