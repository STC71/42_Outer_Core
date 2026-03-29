#include <stdio.h>
#include <string.h>

/*
** Reverse-engineered source for binary: level1
** Architecture: ELF 32-bit x86 (PIE)
**
** Analysis method:
**   - objdump -d level1  -> disassembly of main()
**   - objdump -s -j .rodata level1  -> extract read-only data
**
** How it works:
**   The binary stores a hardcoded password string directly in .rodata
**   at file offset 0x2008 (virtual address 0x2008 in the PIE mapping).
**   Before calling printf(), the main() copies 14 bytes from .rodata
**   onto the stack (via four mov instructions) to build the reference
**   string "__stack_check\0".
**   It then reads user input with scanf("%s", buf), and compares the
**   input to the on-stack reference with strcmp().
**   If strcmp() returns 0 -> "Good job." else -> "Nope."
**
** Password: __stack_check
**
** Note: multiple passwords are possible if the binary were patched,
** but with this unmodified binary only "__stack_check" is valid.
*/

int main(void)
{
    /*
    ** The reference string is built on the stack from .rodata bytes.
    ** Equivalent to: char ref[] = "__stack_check";
    ** (the binary copies it word by word before scanf)
    */
    char ref[14];
    char input[100];

    ref[0]  = '_';
    ref[1]  = '_';
    ref[2]  = 's';
    ref[3]  = 't';
    ref[4]  = 'a';
    ref[5]  = 'c';
    ref[6]  = 'k';
    ref[7]  = '_';
    ref[8]  = 'c';
    ref[9]  = 'h';
    ref[10] = 'e';
    ref[11] = 'c';
    ref[12] = 'k';
    ref[13] = '\0';

    printf("Please enter key: ");
    scanf("%s", input);

    if (strcmp(input, ref) == 0)
        printf("Good job.\n");
    else
        printf("Nope.\n");

    return 0;
}
