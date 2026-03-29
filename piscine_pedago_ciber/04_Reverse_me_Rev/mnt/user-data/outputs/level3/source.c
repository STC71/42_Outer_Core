#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
** Reverse-engineered source for binary: level3
** Architecture: ELF 64-bit x86-64 (PIE)
**
** Analysis method:
**   - objdump -d level3   -> full disassembly of all functions
**   - objdump -s -j .rodata level3  -> extracted all string literals
**   - Traced every branch and function call in main()
**
** ─── Functions found (decorative, called by the switch) ───────────────────
**
**   wt()              -> puts("********")          [the target string, rodata+0x4]
**   nice()            -> puts("nice")
**   try()             -> puts("try")
**   but()             -> puts("but")
**   this()            -> puts("this")
**   it()              -> puts("it")
**   not()             -> puts("not.")
**   that()            -> puts("that.")
**   easy()            -> puts("easy.")
**   ___syscall_malloc()  -> puts("Nope.") + exit(1)   [error/no handler]
**   ____syscall_malloc() -> puts("Good job.")          [success handler]
**
** ─── main() algorithm ────────────────────────────────────────────────────
**
**   1. printf("Please enter key: ")
**   2. scanf("%23s", buf)  — reads at most 23 chars into buf[0..23]
**      If scanf != 1 -> ___syscall_malloc() [Nope + exit]
**   3. buf[1] must be '2' (0x32); if not -> Nope+exit
**      buf[0] must be '4' (0x34); if not -> Nope+exit
**   4. fflush(stdin)
**   5. memset(result, 0, 9); result[0] = '*' (0x2a)
**      buf[41-1] = '\0'  (safety null)
**   6. Loop (same encoding as level2):
**        index = 2, i = 1
**        while (strlen(result) < 8) AND (index < strlen(buf)):
**          tmp[0..2] = buf[index..index+2]
**          result[i] = (char)atoi(tmp)
**          index += 3; i += 1
**   7. result[i] = '\0'
**   8. cmp_result = strcmp(result, "********")
**   9. switch(cmp_result):
**        case -2  -> ___syscall_malloc (Nope+exit)
**        case -1  -> ___syscall_malloc (Nope+exit)
**        case  0  -> ____syscall_malloc (Good job!)   ← WIN
**        case  1  -> ___syscall_malloc (Nope+exit)
**        case  2  -> ___syscall_malloc (Nope+exit)
**        case  3  -> ___syscall_malloc (Nope+exit)
**        case  4  -> ___syscall_malloc (Nope+exit)
**        case  5  -> ___syscall_malloc (Nope+exit)
**        case 0x73-> ___syscall_malloc (Nope+exit)
**        default  -> ___syscall_malloc (Nope+exit)
**
** ─── Password derivation ─────────────────────────────────────────────────
**
**   Target: result == "********"  (8 × 0x2a = 8 × 42)
**   result[0] = '*' = 42 (hardcoded)
**   result[1..7] must each be 42, encoded as 3-digit groups:
**     42 → "042"  (leading zero required to fill 3 chars)
**   buf[0] = '4', buf[1] = '2' (prefix checks)
**   Then 7 × "042":
**     "42" + "042"*7 = "42042042042042042042042"  (23 chars = %23s max)
**
**   Alternative valid passwords (atoi of any 3-char string == 42):
**     " 42" (space+42), "+42", "042" all give 42 → same result.
**
** Password: 42042042042042042042042
*/

/* ── Helper functions (present in the binary) ─────────────────────────── */

static void wt(void)
{
    puts("********");
}

static void nice_fn(void)
{
    puts("nice");
}

static void try_fn(void)
{
    puts("try");
}

static void but_fn(void)
{
    puts("but");
}

static void this_fn(void)
{
    puts("this");
}

static void it_fn(void)
{
    puts("it");
}

static void not_fn(void)
{
    puts("not.");
}

static void that_fn(void)
{
    puts("that.");
}

static void easy_fn(void)
{
    puts("easy.");
}

/* Nope handler: prints error and exits */
static void syscall_malloc_fail(void)
{
    puts("Nope.");
    exit(1);
}

/* Success handler: prints "Good job." */
static void syscall_malloc_ok(void)
{
    puts("Good job.");
}

/* ── Main ─────────────────────────────────────────────────────────────── */

int main(void)
{
    char    buf[24];
    char    result[9];
    int     ret;
    long    index;
    int     i;
    char    tmp[4];
    int     cmp_result;

    (void)wt;
    (void)nice_fn;
    (void)try_fn;
    (void)but_fn;
    (void)this_fn;
    (void)it_fn;
    (void)not_fn;
    (void)that_fn;
    (void)easy_fn;

    printf("Please enter key: ");
    ret = scanf("%23s", buf);
    if (ret != 1)
        syscall_malloc_fail();

    /* Prefix checks: buf[1]=='2', buf[0]=='4' */
    if (buf[1] != '2')
        syscall_malloc_fail();
    if (buf[0] != '4')
        syscall_malloc_fail();

    fflush(stdin);

    /* Build result buffer */
    memset(result, 0, 9);
    result[0] = '*';   /* 0x2a = 42 */
    buf[40]   = '\0';  /* safety (binary uses -0x41(%rbp) relative) */

    index = 2;
    i     = 1;

    while (strlen(result) < 8 && (size_t)index < strlen(buf))
    {
        tmp[0] = buf[index];
        tmp[1] = buf[index + 1];
        tmp[2] = buf[index + 2];
        tmp[3] = '\0';

        result[i] = (char)atoi(tmp);

        index += 3;
        i     += 1;
    }
    result[i] = '\0';

    cmp_result = strcmp(result, "********");

    /*
    ** The binary implements a switch on cmp_result.
    ** Only cmp_result == 0 leads to "Good job.".
    ** All other values (including -2, -1, 1, 2, 3, 4, 5, 0x73)
    ** call the Nope+exit path.
    */
    switch (cmp_result)
    {
        case -2: syscall_malloc_fail(); break;
        case -1: syscall_malloc_fail(); break;
        case  0: syscall_malloc_ok();   break;
        case  1: syscall_malloc_fail(); break;
        case  2: syscall_malloc_fail(); break;
        case  3: syscall_malloc_fail(); break;
        case  4: syscall_malloc_fail(); break;
        case  5: syscall_malloc_fail(); break;
        case 0x73: syscall_malloc_fail(); break;
        default: syscall_malloc_fail(); break;
    }

    return 0;
}
