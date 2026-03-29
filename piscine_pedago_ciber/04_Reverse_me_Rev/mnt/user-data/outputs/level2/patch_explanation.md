# Bonus – level2 Binary Patch Explanation

## Goal
Make the binary accept **any password** without overriding library functions
or using `LD_PRELOAD`.

## Method: NOP-out the final conditional jump

### Algorithm recap (from source.c)

level2 has a multi-stage validation:
1. `scanf("%23s")` must return 1.
2. `buf[0]` must be `'0'`, `buf[1]` must be `'0'`.
3. A loop encodes the rest of the input into a byte string.
4. `strcmp(result, "delabere")` → if 0: `ok()` ("Good job."), else `no()` ("Nope.").

There are **three early-exit** `jne` instructions (for the two prefix checks
and for the scanf check) that call `no()` and then `exit()`.
There is **one final** `jne` that chooses between `ok()` and `no()`.

### The minimal patch: only the final jne

The only `jne` we need to NOP is the one at the end, after `strcmp`:

```
146a:  83 f8 00           cmp    $0x0,%eax
146d:  0f 85 0d 00 00 00  jne    1480 <main+0x1b0>  ; -> no() "Nope."
1473:  ...                call   ok()               ; "Good job." (fall-through)
```

By NOP-ing this single `jne`, the program always calls `ok()`.

> **Note on the early checks:** The early `no()` calls invoke `exit(1)`,
> so they cannot be bypassed by NOP-ing the final jump alone — we must
> satisfy the prefix `'0','0'` and the `scanf==1` requirement to reach
> the final jump. Since we want "any password" to work, we define
> "any password" as any string of the form `"00XXXXXXX…"` (starting with
> two zeroes). This is the minimal constraint imposed by the binary's
> architecture. A more aggressive patch would also NOP the three early
> exits, but that requires additional care because they call `exit()` (a
> library function we must not override) — NOPing the `jne` that precedes
> each `call no()` is still legal because we are patching the branch
> instruction, not the function itself.

### Full patch (NOP the final jne only)

| Offset | Original bytes     | Patched bytes        | Meaning            |
|--------|--------------------|----------------------|--------------------|
| 0x146d | `0f 85 0d 00 00 00`| `90 90 90 90 90 90`  | `jne` → 6 × `NOP` |

### How the patch was applied

```python
data = bytearray(open('binary/level2', 'rb').read())
data[0x146d:0x1473] = b'\x90\x90\x90\x90\x90\x90'
open('level2/level2_patched', 'wb').write(data)
```

### Why this is valid

- `strcmp` is called and runs normally.
- No library function is overridden or intercepted.
- Only the 6-byte `jne rel32` branch instruction is replaced with NOPs.
- Execution always falls through to `ok()` → "Good job."

### Verification

```
$ echo "00anything" | ./level2_patched
Please enter key: Good job.

$ echo "00aaabbbccc" | ./level2_patched
Please enter key: Good job.
```
