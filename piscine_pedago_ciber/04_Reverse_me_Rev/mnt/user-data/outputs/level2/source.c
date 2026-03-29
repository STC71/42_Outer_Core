#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
** Reverse-engineered source for binary: level2
** Architecture: ELF 32-bit x86 (PIE)
**
** Analysis method:
**   - objdump -d level2  -> full disassembly
**   - strings level2     -> identified "delabere", "%23s", "Nope.", "Good job."
**   - Traced the algorithm from the main() disassembly
**
** Algorithm:
**   1. Reads up to 23 characters with scanf("%23s", buf).
**      If scanf does not return 1 -> exit (no).
**   2. Validates buf[0] == '0' and buf[1] == '0'.
**      If either check fails -> exit (no).
**   3. Builds a result buffer (9 bytes, zeroed) with result[0] = 'd' (0x64).
**   4. Loop: while (strlen(result) < 8) AND (loop_index < strlen(buf+1)):
**        - Takes 3 chars from buf at positions [index], [index+1], [index+2]
**          where index starts at 2 (so buf[2..4], buf[5..7], buf[8..10], ...)
**        - Calls atoi() on those 3 chars -> stores the byte value in result[i]
**        - index += 3, i += 1
**   5. strcmp(result, "delabere") == 0 -> "Good job." else "Nope."
**
** The target string "delabere" = {100,101,108,97,98,101,114,101} in ASCII decimal.
** result[0] = 'd' = 100 (hardcoded).
** result[1..7] filled by the loop from the encoded input.
**
** Password construction:
**   buf[0] = '0', buf[1] = '0'  (mandatory prefix)
**   Then 7 groups of 3-digit decimal ASCII codes:
**     'e'=101 -> "101"
**     'l'=108 -> "108"
**     'a'=97  -> "097"
**     'b'=98  -> "098"
**     'e'=101 -> "101"
**     'r'=114 -> "114"
**     'e'=101 -> "101"
**   Password = "00" + "101" + "108" + "097" + "098" + "101" + "114" + "101"
**            = "00101108097098101114101"  (23 chars, exactly %23s max)
**
** Note: other valid passwords exist, e.g. atoi(" 97") = 97,
** so leading spaces/zeros in the 3-char groups also work.
*/

static void no(void)
{
    printf("Nope.\n");
    exit(1);
}

static void ok(void)
{
    printf("Good job.\n");
}

int main(void)
{
    char    buf[24];
    char    result[9];
    int     ret;
    int     index;
    int     i;
    char    tmp[4];

    printf("Please enter key: ");
    ret = scanf("%23s", buf);
    if (ret != 1)
        no();

    /* buf[0] must be '0', buf[1] must be '0' */
    if (buf[1] != '0')
        no();
    if (buf[0] != '0')
        no();

    fflush(stdin);

    /* Initialize result buffer */
    memset(result, 0, 9);
    result[0] = 'd';    /* 0x64 */
    buf[23]   = '\0';   /* safety */

    index = 2;  /* start reading from buf[2] */
    i     = 1;  /* fill result starting at [1] */

    /* Loop: while result is shorter than 8 chars
             AND index < strlen(buf+1)             */
    while (strlen(result) < 8 && (size_t)index < strlen(buf + 1))
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

    if (strcmp(result, "delabere") == 0)
        ok();
    else
        no();

    return 0;
}
