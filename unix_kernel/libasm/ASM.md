# Guía Completa de Ensamblador x86-64 para libasm

## Tabla de Contenidos

### 📚 Fundamentos (Empieza aquí)
1. [Introducción al Ensamblador](#introducción-al-ensamblador)
2. [¿Qué son los Registros?](#qué-son-los-registros)
3. [Tipos de Registros en x86-64](#tipos-de-registros-en-x86-64)
4. [Tabla Completa de Registros x86-64](#tabla-completa-de-registros-x86-64)
5. [Jerarquía y Subdivisiones de Registros](#jerarquía-y-subdivisiones-de-registros)

### 🔧 Conceptos Intermedios
6. [Direccionamiento de Memoria](#direccionamiento-de-memoria)
7. [Instrucciones Básicas](#instrucciones-básicas)
8. [Etiquetas y Control de Flujo](#etiquetas-y-control-de-flujo)
9. [Directivas del Ensamblador](#directivas-del-ensamblador)

### 🎯 Aplicación Práctica
10. [Convención de Llamada x86-64](#convención-de-llamada-x86-64)
11. [Ejemplos Prácticos del Proyecto](#ejemplos-prácticos-del-proyecto)
12. [Trucos y Optimizaciones](#trucos-y-optimizaciones-comunes)
13. [Debugging y Herramientas](#debugging-y-herramientas)
14. [Errores Comunes y Cómo Evitarlos](#errores-comunes-y-cómo-evitarlos)

### 📖 Referencias
15. [Recursos Adicionales](#recursos-adicionales)
16. [Canales de YouTube Recomendados](#-canales-de-youtube-recomendados)

---

## Introducción al Ensamblador

El **ensamblador** (Assembly o ASM) es un lenguaje de programación de bajo nivel que traduce directamente a código máquina. Cada instrucción en ensamblador corresponde casi exactamente a una instrucción que el procesador puede ejecutar.

### ¿Por qué usar ensamblador?

- **Rendimiento máximo**: Control total sobre cada operación del procesador
- **Acceso directo al hardware**: Sin abstracciones del sistema operativo
- **Tamaño mínimo**: Código extremadamente compacto
- **Comprensión profunda**: Entender cómo funciona realmente una computadora

### Relación con C

```c
// En C:
size_t ft_strlen(const char *s)
{
    size_t len = 0;
    while (s[len])
        len++;
    return len;
}
```

```nasm
; En ASM x86-64:
ft_strlen:
    xor     rax, rax          		; len = 0
.loop:
    cmp     byte [rdi + rax], 0   	; while (s[len] != 0)
    je      .end
    inc     rax               		; len++
    jmp     .loop
.end:
    ret                      		 ; return len
```

### 📺 Recursos Multimedia

**Videos recomendados en español:**

- [El lenguaje que habló por primera vez con las máquinas](https://youtu.be/-3ktP9oLKh4?si=i1IENzbSAMuBTsb5) - Assembly | Historia
- [Introducción a Assembly x86-64](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Conceptos fundamentales desde cero
- [Programación en Ensamblador - Serie Completa](https://www.youtube.com/playlist?list=PLZw5VfkTcc8Mzz6HS6-XNxfnEyHdyTlmP) - Curso completo estructurado
- [Assembly con NASM - Nivel Intermedio](https://www.youtube.com/watch?v=Xv0-MQGSE64) - Conceptos avanzados
- [¿Cómo funciona el código máquina?](https://www.youtube.com/watch?v=hNbn-EPcD14) - Explicación visual muy didáctica

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## ¿Qué son los Registros?

Los **registros** son pequeñas unidades de almacenamiento ultrarrápidas ubicadas **directamente dentro del procesador** (CPU).

### Analogía Visual

```
┌─────────────────────────────────────────────────────────────┐
│                    JERARQUÍA DE MEMORIA                     │
├─────────────────┬──────────────┬────────────┬───────────────┤
│ Tipo            │ Velocidad    │ Tamaño     │ Ubicación     │
├─────────────────┼──────────────┼────────────┼───────────────┤
│ Registros       │ ~1 ciclo     │ ~1 KB      │ Dentro de CPU │
│ Caché L1        │ ~4 ciclos    │ 32-64 KB   │ Dentro de CPU │
│ Caché L2        │ ~12 ciclos   │ 256-512 KB │ Dentro de CPU │
│ Caché L3        │ ~40 ciclos   │ 4-32 MB    │ Dentro de CPU │
│ RAM             │ ~200 ciclos  │ 4-64 GB    │ Placa madre   │
│ Disco SSD       │ ~100,000 c.  │ 256GB-4TB  │ Externo       │
└─────────────────┴──────────────┴────────────┴───────────────┘
```

### Características Principales

1. **Velocidad**: La memoria más rápida disponible
2. **Tamaño limitado**: Solo 16 registros de propósito general en x86-64
3. **Acceso directo**: La CPU opera solo con registros
4. **Nombres fijos**: No puedes renombrar `rax` a `mi_variable`

### ¿Por qué son importantes?

**Regla fundamental**: Toda operación aritmética/lógica **debe** realizarse en registros.

```nasm
; ❌ IMPOSIBLE - No puedes operar directamente entre memoria
add [var1], [var2]        ; ERROR: No compilará

; ✅ CORRECTO - Debes usar registros
mov rax, [var1]           ; Cargar var1 en registro
add rax, [var2]           ; Sumar var2 al registro
mov [resultado], rax      ; Guardar resultado en memoria
```

### 📺 Recursos Multimedia

**Videos sobre registros y memoria:**

- [Registros de la CPU explicados](https://www.youtube.com/watch?v=Egowa-XdTAI) - Fundamentos visuales en español
- [Memoria RAM y Jerarquía](https://www.youtube.com/watch?v=gCxFPcQj_ds) - Niveles de memoria y caché
- [Arquitectura x86: Registros](https://www.youtube.com/watch?v=hNbn-EPcD14) - Tutorial práctico completo

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## Tipos de Registros en x86-64

### 1. Registros de Propósito General (16 registros de 64 bits)

Los más importantes y usados en programación normal:

```
┌──────────────────────────────────────────────────────────────────────┐
│ Registro │ Nombre Original │ Uso Convencional                        │
├──────────┼─────────────────┼─────────────────────────────────────────┤
│ rax      │ Accumulator     │ Acumulador, valor de retorno            │
│ rbx      │ Base            │ Base, propósito general                 │
│ rcx      │ Counter         │ Contador en bucles                      │
│ rdx      │ Data            │ Datos, operaciones de extensión         │
│ rsi      │ Source Index    │ Índice fuente (2º parámetro)            │
│ rdi      │ Dest. Index     │ Índice destino (1er parámetro)          │
│ rbp      │ Base Pointer    │ Puntero base del stack frame            │
│ rsp      │ Stack Pointer   │ Puntero de pila (stack)                 │
│ r8-r15   │ (nuevos)        │ Registros adicionales x86-64            │
└──────────┴─────────────────┴─────────────────────────────────────────┘
```

**IMPORTANTE**: Los nombres son **FIJOS e INAMOVIBLES**. Son parte del hardware del procesador, no variables que puedes renombrar.

### 2. Registro de Instrucciones

- **rip**: Instruction Pointer - Apunta a la siguiente instrucción a ejecutar
  - No se modifica directamente (salvo con saltos/llamadas)
  - El procesador lo incrementa automáticamente

### 3. Registro de Banderas (Flags)

- **rflags**: 64 bits con banderas de estado

```
Banderas importantes:
┌────┬─────────────────────────────────────────────────────┐
│ ZF │ Zero Flag - Se activa si resultado es 0             │
│ CF │ Carry Flag - Se activa si hay acarreo               │
│ SF │ Sign Flag - Se activa si resultado es negativo      │
│ OF │ Overflow Flag - Se activa si hay desbordamiento     │
└────┴─────────────────────────────────────────────────────┘
```

### 4. Registros de Segmento (6 registros)

- `cs`, `ds`, `es`, `fs`, `gs`, `ss`
- Mayormente obsoletos en modo 64 bits
- Usados en modo protegido de 16/32 bits

### 5. Registros de Punto Flotante y SIMD

```
┌─────────┬──────────┬─────────────────────────────────────┐
│ Tipo    │ Tamaño   │ Registros                           │
├─────────┼──────────┼─────────────────────────────────────┤
│ x87 FPU │ 80 bits  │ st0 a st7                           │
│ SSE     │ 128 bits │ xmm0 a xmm15                        │
│ AVX     │ 256 bits │ ymm0 a ymm15 (extienden XMM)        │
│ AVX-512 │ 512 bits │ zmm0 a zmm31                        │
└─────────┴──────────┴─────────────────────────────────────┘
```

### 6. Registros de Control y Debug

- **Control**: `cr0`, `cr2`, `cr3`, `cr4`, `cr8`
- **Total aproximado**: ~50-80 registros según extensiones del procesador

### 📺 Recursos Multimedia

**Videos sobre tipos de registros:**

- [Registros en Assembly x86-64](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Explicación detallada en español
- [Flags y Registros Especiales](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Banderas de estado ZF, CF, SF
- [Visión Completa de Registros](https://www.youtube.com/watch?v=mhqDaGCWeFc) - Tutorial completo en español

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## Tabla Completa de Registros x86-64

Esta tabla muestra todos los registros de propósito general con sus subdivisiones y convenciones de uso según la System V ABI (Application Binary Interface) de x86-64.

### Registros y Sus Subdivisiones

| **64 bits** | **32 bits** | **16 bits** | **8 bits (baja/alta)** | **Función Principal** |
|-------------|-------------|-------------|------------------------|-------------------------------------------------------|
| **RAX**     | EAX         | AX          | AL, AH                 | Retorno de funciones / Acumulador                     |
| **RDI**     | EDI         | DI          | DIL, DIH (moderno)     | _Argumento de función (1º)_ / Destino                 |
| **RSI**     | ESI         | SI          | SIL, SIH (moderno)     | _Argumento de función (2º)_ / Fuente                  |
| **RDX**     | EDX         | DX          | DL, DH                 | _Argumento de función (3º)_                           |
| **RCX**     | ECX         | CX          | CL, CH                 | _Argumento de función (4º)_ / Contador                |
| **R8**      | R8D         | R8W         | R8B                    | _Argumento de función (5º)_                           |
| **R9**      | R9D         | R9W         | R9B                    | _Argumento de función (6º)_                           |
| **RBX**     | EBX         | BX          | BL, BH                 | Propósito general (preservable)                       |
| **RBP**     | EBP         | BP          | BPL, BPH (moderno)     | Puntero de base de pila (frame pointer)               |
| **RSP**     | ESP         | SP          | SPL, SPH (moderno)     | Puntero de pila (stack pointer)                       |
| **R10**     | R10D        | R10W        | R10B                   | Propósito general (volátil)                           |
| **R11**     | R11D        | R11W        | R11B                   | Propósito general (volátil)                           |
| **R12**     | R12D        | R12W        | R12B                   | Propósito general (preservable)                       |
| **R13**     | R13D        | R13W        | R13B                   | Propósito general (preservable)                       |
| **R14**     | R14D        | R14W        | R14B                   | Propósito general (preservable)                       |
| **R15**     | R15D        | R15W        | R15B                   | Propósito general (preservable)                       |

### Convención de Llamada - Argumentos de Función

Cuando llamas a una función en x86-64, los primeros 6 argumentos se pasan en registros:

```nasm
; Ejemplo: llamar a función_ejemplo(arg1, arg2, arg3, arg4, arg5, arg6)
mov     rdi, arg1        ; 1º argumento
mov     rsi, arg2        ; 2º argumento
mov     rdx, arg3        ; 3º argumento
mov     rcx, arg4        ; 4º argumento
mov     r8,  arg5        ; 5º argumento
mov     r9,  arg6        ; 6º argumento
call    funcion_ejemplo
```

Argumentos adicionales (7º en adelante) se pasan por el stack.

### Notas Importantes

#### Registros Preservables (Callee-saved)
La función **llamada** debe preservar el valor de estos registros si los usa:
- **RBX, RBP, R12, R13, R14, R15**
- Deben guardarse al inicio (push) y restaurarse al final (pop)

```nasm
mi_funcion:
    push    rbx              ; Guardar rbx
    push    r12              ; Guardar r12
    
    ; ... usar rbx y r12 ...
    
    pop     r12              ; Restaurar r12
    pop     rbx              ; Restaurar rbx
    ret
```

#### Registros Volátiles (Caller-saved)
La función **llamadora** debe guardar estos registros si necesita su valor después de la llamada:
- **RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11**
- La función llamada puede sobrescribirlos libremente

```nasm
funcion_llamadora:
    mov     rax, 42          ; Valor importante en rax
    push    rax              ; Guardar antes de call
    call    otra_funcion     ; Podría modificar rax
    pop     rax              ; Restaurar valor
    ; rax tiene el valor 42 de nuevo
```

#### Registros Especiales
- **RAX**: Siempre contiene el valor de retorno de las funciones
- **RSP**: NUNCA debe modificarse sin restaurar. Siempre debe estar alineado a 16 bytes antes de `call`
- **RBP**: Convencionalmente usado como frame pointer (aunque es opcional en x86-64)

### Ejemplo Completo

```nasm
; Función que suma dos números y guarda el resultado
; Prototipo: int sumar_y_guardar(int a, int b, int *resultado)
sumar_y_guardar:
    ; Parámetros:
    ; rdi = a (1º argumento)
    ; rsi = b (2º argumento)  
    ; rdx = resultado (3º argumento, puntero)
    
    ; No necesitamos preservar registros volátiles (rdi, rsi, rdx)
    ; porque son caller-saved
    
    mov     rax, rdi         ; rax = a
    add     rax, rsi         ; rax = a + b
    mov     [rdx], rax       ; *resultado = rax
    
    ; rax ya contiene el valor de retorno (a + b)
    ret
```

### Resumen Visual

```
╔══════════════════════════════════════════════════════════════════╗
║                  CONVENCIÓN DE LLAMADA x86-64                    ║
╠══════════════════════════════════════════════════════════════════╣
║  Argumentos (orden):  RDI → RSI → RDX → RCX → R8 → R9 → Stack    ║
║  Retorno:             RAX (enteros), XMM0 (flotantes)            ║
║  Preservables:        RBX, RBP, R12-R15                          ║
║  Volátiles:           RAX, RCX, RDX, RSI, RDI, R8-R11            ║
║  Stack Pointer:       RSP (alineado a 16 bytes antes de call)    ║
╚══════════════════════════════════════════════════════════════════╝
```

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## Jerarquía y Subdivisiones de Registros

Una característica única de x86-64: puedes acceder a **partes** de los registros de 64 bits.

### Esquema Visual de rax

```
┌───────────────────────────────────────────────────────────────────┐
│                            RAX (64 bits)                          │
│  63                                                             0 │
│ ┌─────────────────────────────────┬───────────────────────────┐   │
│ │         (bits 63-32)            │      EAX (32 bits)        │   │
│ │                                 │  31                     0 │   │
│ │                                 │ ┌───────────┬───────────┐ │   │
│ │                                 │ │  (16-31)  │ AX (16b)  │ │   │
│ │                                 │ │           │  15     0 │ │   │
│ │                                 │ │           │ ┌────┬────┤ │   │
│ │                                 │ │           │ │ AH │ AL │ │   │
│ │                                 │ │           │ │8bit│8bit│ │   │
│ │                                 │ │           │ └────┴────┘ │   │
│ └─────────────────────────────────┴─┴───────────┴───────────┘ │   │
└───────────────────────────────────────────────────────────────────┘
```

### Tabla de Subdivisiones

```
┌──────────┬──────┬──────┬─────────┬─────────┐
│ 64 bits  │ 32b  │ 16b  │ 8b alto │ 8b bajo │
├──────────┼──────┼──────┼─────────┼─────────┤
│ rax      │ eax  │ ax   │ ah      │ al      │
│ rbx      │ ebx  │ bx   │ bh      │ bl      │
│ rcx      │ ecx  │ cx   │ ch      │ cl      │
│ rdx      │ edx  │ dx   │ dh      │ dl      │
│ rsi      │ esi  │ si   │ -       │ sil     │
│ rdi      │ edi  │ di   │ -       │ dil     │
│ rbp      │ ebp  │ bp   │ -       │ bpl     │
│ rsp      │ esp  │ sp   │ -       │ spl     │
│ r8       │ r8d  │ r8w  │ -       │ r8b     │
│ r9       │ r9d  │ r9w  │ -       │ r9b     │
│ ... r15  │ ...  │ ...  │ -       │ ...     │
└──────────┴──────┴──────┴─────────┴─────────┘
```

### Ejemplo Práctico

```nasm
; Inicializar rax a un valor grande
mov rax, 0x123456789ABCDEF0

; Después de estas operaciones:
; rax = 0x123456789ABCDEF0
; eax = 0x9ABCDEF0 (32 bits bajos)
; ax  = 0xDEF0     (16 bits bajos)
; ah  = 0xDE       (bits 15-8)
; al  = 0xF0       (bits 7-0)

; Escribir en AL modifica solo el byte menos significativo
mov al, 0xFF
; Ahora rax = 0x123456789ABCDEFF

; ⚠️ IMPORTANTE: Escribir en EAX limpia los bits superiores
mov eax, 0x11111111
; Ahora rax = 0x0000000011111111 (bits 63-32 puestos a 0)
```

### Byte Menos Significativo

**Byte menos significativo**: El byte más a la derecha, de menor peso (bits 0-7).

```
Valor en rax: 0x123456789ABCDEF0
  (mayor peso)                    (menor peso)
```

### 📺 Recursos Multimedia

**Videos sobre subdivisiones de registros:**

- [Tamaños de Registros: 64, 32, 16, 8 bits](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Explicación práctica
- [RAX, EAX, AX, AH, AL explicados](https://www.youtube.com/watch?v=hNbn-EPcD14) - Conceptos visuales claros
- [Convenciones de Nombres x86](https://www.youtube.com/watch?v=mhqDaGCWeFc) - Guía completa

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## Direccionamiento de Memoria        ↑
  Byte más                        Byte menos
  significativo                   significativo (AL)
  (mayor peso)                    (menor peso)
```

---

## Direccionamiento de Memoria

### Sintaxis Intel vs AT&T

Este proyecto usa **sintaxis Intel** (la más legible):

```nasm
; Sintaxis Intel (NASM)
mov rax, rbx              ; destino, fuente
mov rax, [rdi + 8]        ; Lee memoria

; Sintaxis AT&T (GAS) - NO la usamos
movq %rbx, %rax           ; fuente, destino (invertido)
movq 8(%rdi), %rax        ; Lee memoria
```

### Modos de Direccionamiento

```nasm
; 1. INMEDIATO - Valor constante
mov rax, 42               ; rax = 42

; 2. REGISTRO - Copia entre registros
mov rax, rbx              ; rax = rbx

; 3. DIRECTO - Leer/escribir memoria
mov rax, [var]            ; rax = contenido de 'var'
mov [var], rax            ; var = rax

; 4. INDIRECTO - Dirección en registro
mov rax, [rdi]            ; rax = *rdi (como puntero en C)

; 5. INDEXADO - Base + desplazamiento
mov rax, [rdi + 8]        ; rax = *(rdi + 8)
mov rax, [rdi + rcx]      ; rax = *(rdi + rcx)

; 6. ESCALA - Base + índice * escala + desplazamiento
mov rax, [rdi + rcx*8 + 16]  ; rax = *(rdi + rcx*8 + 16)
;                            Útil para arrays: arr[i]
```

### Especificadores de Tamaño

```nasm
; Cuando no es obvio, especifica el tamaño:
mov byte [rdi], 0         ; Escribe 1 byte
mov word [rdi], 0         ; Escribe 2 bytes (16 bits)
mov dword [rdi], 0        ; Escribe 4 bytes (32 bits)
mov qword [rdi], 0        ; Escribe 8 bytes (64 bits)

; Ejemplo en ft_strcmp:
mov al, byte [rdi + rcx]  ; Lee 1 byte de la cadena
```

---

## Instrucciones Básicas

### Movimiento de Datos

```nasm
; MOV - Mover/copiar datos
mov rax, rbx              ; rax = rbx
mov rax, 42               ; rax = 42
mov rax, [rdi]            ; rax = *rdi

; MOVZX - Mover con extensión de ceros
movzx rax, al             ; Extiende AL (8 bits) a RAX (64 bits) con ceros
                          ; Si al = 0xFF, entonces rax = 0x00000000000000FF

; MOVSX - Mover con extensión de signo
movsx rax, al             ; Extiende con signo
                          ; Si al = 0xFF (-1), entonces rax = 0xFFFFFFFFFFFFFFFF

; LEA - Load Effective Address (calcular dirección)
lea rax, [rdi + rcx*8]    ; rax = dirección de (rdi + rcx*8)
                          ; NO lee memoria, solo calcula la dirección
```

### Operaciones Aritméticas

```nasm
; ADD - Sumar
add rax, rbx              ; rax = rax + rbx
add rax, 10               ; rax = rax + 10

; SUB - Restar
sub rax, rbx              ; rax = rax - rbx
sub rax, 5                ; rax = rax - 5

; INC - Incrementar en 1
inc rax                   ; rax = rax + 1 (más eficiente que add rax, 1)

; DEC - Decrementar en 1
dec rax                   ; rax = rax - 1

; MUL - Multiplicación sin signo
mul rbx                   ; rdx:rax = rax * rbx (resultado de 128 bits)

; IMUL - Multiplicación con signo
imul rax, rbx             ; rax = rax * rbx
imul rax, rbx, 10         ; rax = rbx * 10

; DIV - División sin signo
div rbx                   ; rax = rdx:rax / rbx, rdx = resto

; NEG - Negación (complemento a dos)
neg rax                   ; rax = -rax
```

### Operaciones Lógicas

```nasm
; AND - AND lógico bit a bit
and rax, rbx              ; rax = rax & rbx

; OR - OR lógico bit a bit
or rax, rbx               ; rax = rax | rbx

; XOR - XOR lógico bit a bit
xor rax, rbx              ; rax = rax ^ rbx
xor rax, rax              ; rax = 0 (truco común: más eficiente que mov rax, 0)

; NOT - Negación lógica (complemento a uno)
not rax                   ; rax = ~rax

; Desplazamientos
shl rax, 2                ; Shift Left: rax = rax << 2 (multiplicar por 4)
shr rax, 2                ; Shift Right: rax = rax >> 2 (dividir por 4)
sal rax, 2                ; Shift Arithmetic Left (igual que shl)
sar rax, 2                ; Shift Arithmetic Right (preserva signo)
```

### Comparación y Pruebas

```nasm
; CMP - Comparar (resta sin guardar resultado, solo actualiza flags)
cmp rax, rbx              ; Compara rax con rbx
                          ; Establece flags: ZF, SF, CF, OF

; TEST - Prueba lógica (AND sin guardar resultado)
test rax, rax             ; Prueba si rax es 0
                          ; ZF=1 si rax==0, ZF=0 si rax!=0
```

### Control de Flujo - Saltos

```nasm
; JMP - Salto incondicional
jmp etiqueta              ; Siempre salta a 'etiqueta'

; Saltos condicionales (después de CMP o TEST)
je   etiqueta             ; Jump if Equal (ZF=1)
jne  etiqueta             ; Jump if Not Equal (ZF=0)
jz   etiqueta             ; Jump if Zero (igual que je)
jnz  etiqueta             ; Jump if Not Zero (igual que jne)

jg   etiqueta             ; Jump if Greater (con signo)
jge  etiqueta             ; Jump if Greater or Equal
jl   etiqueta             ; Jump if Less
jle  etiqueta             ; Jump if Less or Equal

ja   etiqueta             ; Jump if Above (sin signo)
jae  etiqueta             ; Jump if Above or Equal
jb   etiqueta             ; Jump if Below
jbe  etiqueta             ; Jump if Below or Equal
```

### Llamadas y Retornos

```nasm
; CALL - Llamar a función
call funcion              ; Guarda dirección de retorno en stack y salta

; RET - Retornar de función
ret                       ; Recupera dirección de retorno y salta
```

### Operaciones con la Pila (Stack)

```nasm
; PUSH - Meter en la pila
push rax                  ; rsp -= 8; [rsp] = rax

; POP - Sacar de la pila
pop rax                   ; rax = [rsp]; rsp += 8
```

### 📺 Recursos Multimedia

**Videos sobre instrucciones Assembly:**

- [Instrucciones Básicas de Assembly](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - MOV, ADD, SUB en español
- [Operaciones Lógicas: AND, OR, XOR](https://www.youtube.com/watch?v=hNbn-EPcD14) - Con ejemplos prácticos
- [Saltos Condicionales e Incondicionales](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - JMP, JE, JNE explicados
- [La Pila en Assembly](https://www.youtube.com/watch?v=mhqDaGCWeFc) - PUSH, POP, CALL, RET

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## Convención de Llamada x86-64

La **System V AMD64 ABI** (usada en Linux/macOS) define cómo se pasan parámetros a funciones.

### Parámetros de Función

```
┌──────────────┬─────────────────────────────────────────┐
│ Parámetro    │ Registro                                │
├──────────────┼─────────────────────────────────────────┤
│ 1º parámetro │ rdi                                     │
│ 2º parámetro │ rsi                                     │
│ 3º parámetro │ rdx                                     │
│ 4º parámetro │ rcx                                     │
│ 5º parámetro │ r8                                      │
│ 6º parámetro │ r9                                      │
│ 7º y más     │ Stack (pila)                            │
├──────────────┼─────────────────────────────────────────┤
│ Valor retorno│ rax                                     │
│ Retorno float│ xmm0                                    │
└──────────────┴─────────────────────────────────────────┘
```

### Ejemplo: ft_strlen

```c
// Prototipo en C:
size_t ft_strlen(const char *s);

// Llamada desde C:
size_t len = ft_strlen("Hello");
```

```nasm
; Implementación en ASM:
; Al llamarse, rdi ya contiene el puntero a la cadena "Hello"

ft_strlen:
    xor     rax, rax              ; Contador = 0
.loop:
    cmp     byte [rdi + rax], 0   ; ¿Fin de cadena?
    je      .end                  ; Sí -> terminar
    inc     rax                   ; No -> incrementar contador
    jmp     .loop                 ; Repetir
.end:
    ret                           ; Retornar rax (longitud)
```

### Ejemplo: ft_strcpy

```c
// Prototipo en C:
char *ft_strcpy(char *dst, const char *src);

// Llamada:
ft_strcpy(buffer, "Hello");
//        ↓       ↓
//        rdi     rsi
```

```nasm
; Implementación:
ft_strcpy:
    mov     rax, rdi              ; Guardar dst para retornar
    xor     rcx, rcx              ; Índice = 0
.loop:
    mov     dl, byte [rsi + rcx]  ; Leer byte de src
    mov     byte [rdi + rcx], dl  ; Escribir en dst
    cmp     dl, 0                 ; ¿Es '\0'?
    je      .end
    inc     rcx
    jmp     .loop
.end:
    ret                           ; Retorna rax (dst original)
```

### Registros Preservados

```
┌──────────────────────────────────────────────────────────┐
│ Caller-saved (el llamador los guarda si los necesita):   │
│ rax, rcx, rdx, rsi, rdi, r8, r9, r10, r11                │
│                                                          │
│ Callee-saved (la función debe preservarlos):             │
│ rbx, rbp, r12, r13, r14, r15                             │
│                                                          │
│ Especiales:                                              │
│ rsp - Stack pointer (SIEMPRE debe preservarse)           │
└──────────────────────────────────────────────────────────┘
```

### 📺 Recursos Multimedia

**Videos sobre convención de llamadas:**

- [System V ABI Calling Convention](https://www.youtube.com/watch?v=HNIg3TXfduc) - Explicación completa (inglés)
- [Paso de Parámetros en x86-64](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Tutorial práctico en español
- [Stack Frame en Assembly](https://www.youtube.com/watch?v=mhqDaGCWeFc) - RBP y RSP explicados
- [Funciones en Assembly](https://www.youtube.com/watch?v=M5OTH8hLj20) - Preservación de registros
- [ABI Linux x86-64](https://www.youtube.com/watch?v=NuwvXEQxDKI) - Convenciones estándar

[⬆️ Volver arriba](#tabla-de-contenidos)
---

## Directivas del Ensamblador

Las directivas no son instrucciones de CPU, sino comandos para el **ensamblador** (NASM).

### Secciones

```nasm
; Define secciones del programa
section .text             ; Código ejecutable
section .data             ; Datos inicializados
section .bss              ; Datos no inicializados (Buffer Allocated by Symbol)
section .rodata           ; Datos de solo lectura (Read-Only Data)
```

### Visibilidad de Símbolos

```nasm
; GLOBAL - Hace un símbolo visible externamente
global ft_strlen          ; Ahora C puede llamar a ft_strlen

; EXTERN - Declara un símbolo definido en otro archivo
extern printf             ; Declaramos que printf existe en libc
```

### Definición de Datos

```nasm
section .data
    msg     db "Hello, World!", 0   ; Define byte(s)
    numero  dw 1234                 ; Define word (2 bytes)
    valor   dd 0x12345678           ; Define double word (4 bytes)
    grande  dq 0x123456789ABCDEF0   ; Define quad word (8 bytes)

section .bss
    buffer  resb 256                ; Reserve 256 bytes
    array   resd 100                ; Reserve 100 dwords (400 bytes)
```

### Constantes

```nasm
; EQU - Define constante
BUFFER_SIZE equ 1024
%define NEWLINE 10

; Uso:
mov rcx, BUFFER_SIZE      ; mov rcx, 1024
```

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## Etiquetas y Control de Flujo

### Etiquetas Globales vs Locales

```nasm
; ETIQUETA GLOBAL (sin punto inicial)
ft_strlen:
    xor rax, rax

; ETIQUETAS LOCALES (con punto inicial)
; Solo visibles dentro de la última etiqueta global
.loop:
    cmp byte [rdi + rax], 0
    je .end                   ; Salta a ft_strlen.end
    inc rax
    jmp .loop                 ; Salta a ft_strlen.loop
.end:
    ret

; Si hubiera otra función:
ft_strcmp:
    xor rcx, rcx
.loop:                        ; Esta es ft_strcmp.loop (diferente a la anterior)
    ; ...
```

### Estructura de Bucles

```nasm
; BUCLE WHILE
ft_strlen:
    xor rax, rax
.loop:                        ; while (true)
    cmp byte [rdi + rax], 0   ;   if (s[i] == 0)
    je .end                   ;     break;
    inc rax                   ;   i++;
    jmp .loop                 ; }
.end:
    ret
```

```nasm
; BUCLE FOR (simulado)
; for (i = 0; i < 10; i++)
    xor rcx, rcx              ; i = 0
.for_loop:
    cmp rcx, 10               ; i < 10?
    jge .for_end              ; No -> salir
    
    ; Cuerpo del bucle
    ; ...
    
    inc rcx                   ; i++
    jmp .for_loop             ; Repetir
.for_end:
```

### Condicionales IF-ELSE

```nasm
; if (rax == rbx) { ... } else { ... }
    cmp rax, rbx
    je .if_equal              ; if (rax == rbx)
    
    ; Bloque else
    mov rcx, 1
    jmp .end_if
    
.if_equal:
    ; Bloque if
    mov rcx, 0
    
.end_if:
    ; Continuar
```

### 📺 Recursos Multimedia

**Videos sobre control de flujo:**

- [Bucles en Assembly x86-64](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - FOR, WHILE implementados
- [Etiquetas y Saltos Condicionales](https://www.youtube.com/watch?v=hNbn-EPcD14) - Labels y JMP
- [Estructuras Condicionales](https://www.youtube.com/watch?v=WpYFQ_WiL5g&t=180s) - IF-ELSE en Assembly
- [Flags Register Explained](https://www.youtube.com/watch?v=mhqDaGCWeFc) - ZF, CF, SF, OF

[⬆️ Volver arriba](#tabla-de-contenidos)
---

## Ejemplos Prácticos del Proyecto

### ft_strlen - Análisis Línea por Línea

```nasm
; ==============================================================================
; size_t ft_strlen(const char *s)
; Parámetros: rdi = s
; Retorno: rax = longitud
; ==============================================================================

section .text
    global ft_strlen          ; Exportar símbolo para C

ft_strlen:
    xor     rax, rax          ; rax = 0 (contador de longitud)
                              ; xor rax, rax es más eficiente que mov rax, 0
                              ; Solo necesita 2 bytes vs 7 bytes
    
.loop:
    cmp     byte [rdi + rax], 0
    ; ├─ byte: Especifica que comparamos 1 byte
    ; ├─ [rdi + rax]: Dirección = s + longitud_actual
    ; │   rdi = puntero base a la cadena
    ; │   rax = índice/desplazamiento actual
    ; └─ 0: Comparar con '\0' (fin de cadena)
    
    je      .end
    ; Jump if Equal - Si el byte era 0, saltar a .end
    ; La instrucción CMP establece la bandera ZF=1 si eran iguales
    
    inc     rax
    ; Incrementar contador (equivalente a: rax = rax + 1)
    ; Más eficiente que add rax, 1
    
    jmp     .loop
    ; Salto incondicional - volver a .loop
    
.end:
    ret
    ; Retornar - rax ya contiene la longitud
```

**Comparación con C:**

```c
size_t ft_strlen(const char *s)
{
    size_t len = 0;                    // xor rax, rax
    while (s[len] != 0)                // .loop: cmp byte [rdi+rax], 0; je .end
    {
        len++;                         // inc rax
    }                                  // jmp .loop
    return len;                        // ret (rax)
}
```

### ft_strcmp - Análisis Completo

```nasm
; ==============================================================================
; int ft_strcmp(const char *s1, const char *s2)
; Parámetros: rdi = s1, rsi = s2
; Retorno: rax = diferencia (s1[i] - s2[i])
; ==============================================================================

section .text
    global ft_strcmp

ft_strcmp:
    xor     rax, rax          ; Limpiar rax (usaremos al para bytes)
    xor     rcx, rcx          ; Índice = 0

.loop:
    mov     al, byte [rdi + rcx]
    ; ├─ al: Registro de 8 bits (parte baja de rax)
    ; ├─ byte [rdi + rcx]: Lee 1 byte de s1[rcx]
    ; │   rdi = puntero a s1
    ; │   rcx = índice actual
    ; └─ Guarda en AL (bits 0-7 de rax)
    
    mov     dl, byte [rsi + rcx]
    ; ├─ dl: Registro de 8 bits (parte baja de rdx)
    ; └─ Lee 1 byte de s2[rcx]
    
    cmp     al, dl
    ; Compara los dos bytes leídos
    ; Establece flags según el resultado
    
    jne     .diff
    ; Jump if Not Equal - Si los bytes son diferentes, ir a .diff
    
    cmp     al, 0
    ; ¿El byte es '\0'? (¿llegamos al final?)
    
    je      .equal
    ; Si es '\0', ambas cadenas son iguales hasta aquí
    
    inc     rcx
    ; Avanzar al siguiente carácter
    
    jmp     .loop
    ; Repetir
    
.diff:
    ; Los bytes son diferentes - calcular diferencia
    movzx   rax, al
    ; Move with Zero Extend:
    ; ├─ Copia AL a RAX
    ; ├─ Extiende con ceros los bits superiores
    ; └─ Convierte el byte a entero sin signo de 64 bits
    ; Ejemplo: si al = 0xFF, rax = 0x00000000000000FF
    
    movzx   rdx, dl
    ; Lo mismo con DL -> RDX
    
    sub     rax, rdx
    ; rax = rax - rdx
    ; Resultado: diferencia entre caracteres
    ; < 0 si s1 < s2
    ; > 0 si s1 > s2
    
    ret
    ; Retornar diferencia en rax
    
.equal:
    ; Las cadenas son idénticas
    xor     rax, rax
    ; rax = 0 (cadenas iguales)
    
    ret
```

**Comparación con C:**

```c
int ft_strcmp(const char *s1, const char *s2)
{
    size_t i = 0;                                    // xor rcx, rcx
    
    while (1)                                        // .loop:
    {
        unsigned char c1 = s1[i];                    // mov al, byte [rdi+rcx]
        unsigned char c2 = s2[i];                    // mov dl, byte [rsi+rcx]
        
        if (c1 != c2)                                // cmp al, dl; jne .diff
            return (int)c1 - (int)c2;                // movzx rax,al; movzx rdx,dl; sub; ret
        
        if (c1 == 0)                                 // cmp al, 0; je .equal
            return 0;                                // xor rax,rax; ret
        
        i++;                                         // inc rcx
    }                                                // jmp .loop
}
```

### ft_strcpy - Manejo de Valor de Retorno

```nasm
; ==============================================================================
; char *ft_strcpy(char *dst, const char *src)
; Parámetros: rdi = dst, rsi = src
; Retorno: rax = dst (puntero original)
; ==============================================================================

section .text
    global ft_strcpy

ft_strcpy:
    mov     rax, rdi
    ; ¡IMPORTANTE! Guardar dst para retornarlo después
    ; La función debe retornar el puntero dst original
    ; Pero rdi será usado durante la copia, así que guardamos una copia en rax
    
    xor     rcx, rcx          ; Índice = 0

.loop:
    mov     dl, byte [rsi + rcx]
    ; Leer byte de src
    
    mov     byte [rdi + rcx], dl
    ; Escribir byte en dst
    ; Nota: ahora dst[rcx] contiene el mismo byte que src[rcx]
    
    cmp     dl, 0
    ; ¿El byte copiado es '\0'?
    ; Verificamos DL (no necesitamos leer de memoria otra vez)
    
    je      .end
    ; Si es '\0', terminamos (ya copiamos el terminador)
    
    inc     rcx
    ; Siguiente carácter
    
    jmp     .loop

.end:
    ret
    ; Retorna rax (que contiene el puntero dst original)
```

### ft_write - Syscall en Linux

```nasm
; ==============================================================================
; ssize_t ft_write(int fd, const void *buf, size_t count)
; Parámetros: rdi = fd, rsi = buf, rdx = count
; Retorno: rax = número de bytes escritos, o -1 si error
; ==============================================================================

section .text
    global ft_write
    extern __errno_location      ; Para manejar errno

ft_write:
    mov     rax, 1              ; Syscall number para write
    ; En Linux x86-64:
    ; syscall 1 = write
    ; syscall 0 = read
    ; syscall 60 = exit
    
    syscall
    ; Ejecuta la llamada al sistema
    ; Los parámetros ya están en rdi, rsi, rdx
    ; El resultado se devuelve en rax
    
    ; Comprobar si hubo error
    cmp     rax, 0
    jl      .error              ; Si rax < 0, hubo error
    
    ret                         ; Retorno exitoso
    
.error:
    ; Manejar errno (opcional, depende de los requisitos)
    neg     rax                 ; rax = -rax (convertir a positivo)
    mov     rdi, rax            ; Guardar código de error
    call    __errno_location    ; Obtener dirección de errno
    mov     [rax], rdi          ; *errno = código de error
    mov     rax, -1             ; Retornar -1
    ret
```

**Tabla de Syscalls Linux x86-64 (las más comunes):**

```
┌────────┬─────────────────────────────────────────────────┐
│ Número │ Syscall                                         │
├────────┼─────────────────────────────────────────────────┤
│ 0      │ read(fd, buf, count)                            │
│ 1      │ write(fd, buf, count)                           │
│ 2      │ open(filename, flags, mode)                     │
│ 3      │ close(fd)                                       │
│ 9      │ mmap(addr, length, prot, flags, fd, offset)     │
│ 12     │ brk(addr)                                       │
│ 60     │ exit(status)                                    │
└────────┴─────────────────────────────────────────────────┘
```

### ft_strdup - Uso de malloc

```nasm
; ==============================================================================
; char *ft_strdup(const char *s)
; Parámetros: rdi = s
; Retorno: rax = nueva cadena duplicada, o NULL si error
; ==============================================================================

section .text
    global ft_strdup
    extern malloc
    extern ft_strlen
    extern ft_strcpy

ft_strdup:
    ; Necesitamos preservar rdi (puntero a s) porque llamaremos a funciones
    push    rdi                 ; Guardar s en la pila
    
    ; Calcular longitud de s
    call    ft_strlen           ; rax = strlen(s)
    inc     rax                 ; +1 para el '\0'
    
    ; Alojar memoria
    mov     rdi, rax            ; Parámetro para malloc = tamaño
    call    malloc              ; rax = puntero a memoria nueva (o NULL)
    
    ; Verificar si malloc falló
    test    rax, rax            ; Equivalente a: cmp rax, 0
    jz      .error              ; Si rax == 0 (NULL), salir
    
    ; malloc exitoso - copiar cadena
    mov     rdi, rax            ; dst = memoria nueva
    pop     rsi                 ; src = s (recuperamos de la pila)
    
    push    rax                 ; Guardar puntero a memoria nueva
    call    ft_strcpy           ; Copiar s a la nueva memoria
    pop     rax                 ; Recuperar puntero
    
    ret                         ; Retornar puntero a nueva cadena
    
.error:
    pop     rdi                 ; Limpiar la pila (recuperar s)
    xor     rax, rax            ; rax = NULL
    ret
```

### 📺 Recursos Multimedia para el Proyecto libasm

**Videos específicos para implementar funciones:**

- [Implementando strlen en Assembly](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Tutorial paso a paso
- [String Functions en x86-64](https://www.youtube.com/watch?v=hNbn-EPcD14) - strcpy, strcmp
- [System Calls en Linux x86-64](https://www.youtube.com/watch?v=HNIg3TXfduc&t=300s) - read, write
- [Llamadas a malloc desde Assembly](https://www.youtube.com/watch?v=mhqDaGCWeFc) - Memoria dinámica

**Recursos generales del proyecto:**

- [Curso completo de Assembly x86-64](https://www.youtube.com/playlist?list=PLZVwXPbHD1KMsiVP48vjakBnWmVENvTdT) - Playlist completa
- [Programación de Sistemas](https://www.youtube.com/playlist?list=PLZVwXPbHD1KOyFJw3VKQMq3XcPFJoJYHk) - Syscalls y bajo nivel

[⬆️ Volver arriba](#tabla-de-contenidos)
---

## Trucos y Optimizaciones Comunes

### 1. Poner a Cero un Registro

```nasm
; ❌ Menos eficiente (7 bytes)
mov rax, 0

; ✅ Más eficiente (2 bytes)
xor rax, rax
```

**Razón**: `xor rax, rax` siempre da 0 (cualquier valor XOR consigo mismo = 0), pero usa solo 2 bytes de código vs 7 bytes de `mov rax, 0`.

### 2. Incrementar/Decrementar

```nasm
; Menos eficiente
add rax, 1                ; 4 bytes
sub rax, 1                ; 4 bytes

; Más eficiente
inc rax                   ; 3 bytes
dec rax                   ; 3 bytes
```

### 3. Multiplicar/Dividir por Potencias de 2

```nasm
; Multiplicar por 2, 4, 8, etc.
shl rax, 1                ; rax *= 2
shl rax, 2                ; rax *= 4
shl rax, 3                ; rax *= 8

; Dividir por 2, 4, 8, etc.
shr rax, 1                ; rax /= 2 (sin signo)
sar rax, 1                ; rax /= 2 (con signo)
```

### 4. Comparar con Cero

```nasm
; Menos eficiente
cmp rax, 0

; Más eficiente (más corto y rápido)
test rax, rax
```

### 5. Calcular Direcciones con LEA

```nasm
; Supongamos: calcular addr = base + index * 4 + 8
; Forma tradicional (varias instrucciones):
mov rax, rcx
shl rax, 2                ; rax = index * 4
add rax, rdi              ; rax = base + (index * 4)
add rax, 8                ; rax = base + (index * 4) + 8

; Con LEA (una sola instrucción):
lea rax, [rdi + rcx*4 + 8]
```

**LEA es especialmente útil para**:
- Aritmética rápida
- Calcular direcciones de arrays
- Multiplicar por 2, 3, 4, 5, 8, 9 eficientemente

```nasm
lea rax, [rdi + rdi]      ; rax = rdi * 2
lea rax, [rdi + rdi*2]    ; rax = rdi * 3
lea rax, [rdi + rdi*4]    ; rax = rdi * 5
```

### 📺 Recursos Multimedia

**Videos sobre optimizaciones y trucos:**

- [Optimización de Código Assembly](https://www.youtube.com/watch?v=mhqDaGCWeFc) - Técnicas avanzadas
- [XOR Trick y Zero Register](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Optimizaciones comunes
- [LEA Instruction - Advanced Uses](https://www.youtube.com/watch?v=HNIg3TXfduc&t=600s) - Cálculos eficientes
- [Bit Manipulation en Assembly](https://www.youtube.com/watch?v=hNbn-EPcD14) - Shifts y rotaciones

[⬆️ Volver arriba](#tabla-de-contenidos)

## Debugging y Herramientas

### GDB - GNU Debugger

```bash
# Compilar con símbolos de debug
nasm -f elf64 -g -F dwarf ft_strlen.s
gcc -no-pie -g ft_strlen.o main.c -o test

# Ejecutar con GDB
gdb ./test

# Comandos útiles en GDB:
break ft_strlen          # Punto de interrupción
run                      # Ejecutar programa
stepi                    # Ejecutar siguiente instrucción
info registers           # Ver todos los registros
print $rax               # Ver valor de rax
x/s $rdi                 # Examinar cadena en rdi
x/10i $rip               # Ver próximas 10 instrucciones
```

### Examinar Registros en GDB

```gdb
(gdb) info registers
rax            0x0      0
rbx            0x0      0
rcx            0x5      5
rdx            0x7fffffffde88   140737488346760
rsi            0x7fffffffde78   140737488346744
rdi            0x7fffffffde68   140737488346728
...
```

### Ver Código Desensamblado

```bash
# Desensamblar archivo objeto
objdump -d ft_strlen.o

# Ver con símbolos
objdump -d -M intel test
```

### 📺 Recursos Multimedia

**Videos sobre debugging y herramientas:**

- [GDB para Assembly - Guía Completa](https://www.youtube.com/watch?v=PorfLSr3DDI) - Debugging profesional
- [Depurando Assembly con GDB](https://www.youtube.com/watch?v=WpYFQ_WiL5g) - Tutorial práctico en español
- [NASM Tutorial Completo](https://www.youtube.com/watch?v=mhqDaGCWeFc) - Ensamblador NASM en español
- [Compiler Explorer (Godbolt) Tutorial](https://www.youtube.com/watch?v=kIoZDUd5DKw) - Análisis de código

[⬆️ Volver arriba](#tabla-de-contenidos)

## Errores Comunes y Cómo Evitarlos

### 1. Olvidar Preservar Registros

```nasm
; ❌ MAL - rbx debe preservarse
mi_funcion:
    mov rbx, 42              ; Modifica rbx
    ; ... código ...
    ret                      ; ¡No restauramos rbx!

; ✅ BIEN
mi_funcion:
    push rbx                 ; Guardar rbx
    mov rbx, 42
    ; ... código ...
    pop rbx                  ; Restaurar rbx
    ret
```

### 2. Desalinear el Stack Pointer

El stack debe estar **alineado a 16 bytes** antes de llamar funciones.

```nasm
; ❌ MAL - stack desalineado
mi_funcion:
    push rdi                 ; rsp -= 8 (ahora desalineado)
    call otra_funcion        ; ¡Puede causar crash!

; ✅ BIEN
mi_funcion:
    push rdi                 ; rsp -= 8
    sub rsp, 8               ; Alinear a 16 bytes
    call otra_funcion
    add rsp, 8
    pop rdi
    ret
```

### 3. No Especificar Tamaño en Memoria

```nasm
; ❌ AMBIGUO
mov [rdi], 0                 ; ¿1, 2, 4, u 8 bytes?

; ✅ CLARO
mov byte [rdi], 0            ; 1 byte
mov qword [rdi], 0           ; 8 bytes
```

### 4. Modificar Parámetros sin Guardarlos

```nasm
; Si necesitas retornar el parámetro original:
; ❌ MAL
ft_strcpy:
    ; ... usar rdi directamente ...
    ret                      ; ¿Qué retornamos?

; ✅ BIEN
ft_strcpy:
    mov rax, rdi             ; Guardar dst original
    ; ... usar rdi ...
    ret                      ; rax contiene dst
```

### 5. Olvidar el Terminador Nulo

```nasm
; Al copiar cadenas, asegúrate de copiar el '\0'
.loop:
    mov dl, [rsi + rcx]
    mov [rdi + rcx], dl
    cmp dl, 0                ; ✅ Verificar DESPUÉS de copiar
    je .end                  ; Así copiamos el '\0' también
    inc rcx
    jmp .loop
```

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## Recursos Adicionales

### Documentación Oficial

- [Intel 64 and IA-32 Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [AMD64 Architecture Programmer's Manual](https://www.amd.com/en/support/tech-docs)
- [System V ABI](https://gitlab.com/x86-psABIs/x86-64-ABI)

### Herramientas Online

- [Compiler Explorer (Godbolt)](https://godbolt.org/) - Ver código ASM generado por compiladores
- [Online x86 Assembler](https://defuse.ca/online-x86-assembler.htm)

### Referencias Rápidas

- [x86-64 Instruction Reference](https://www.felixcloutier.com/x86/)
- [NASM Documentation](https://www.nasm.us/docs.php)

### 📺 Cursos y Tutoriales Completos en Español

### 📺 Cursos y Tutoriales Completos en Español

**Cursos largos y series completas:**

- [Curso Assembly x86 - Completo](https://www.youtube.com/playlist?list=PLZw5VfkTcc8Mzz6HS6-XNxfnEyHdyTlmP) - Serie estructurada
- [Arquitectura de Computadores](https://www.youtube.com/playlist?list=PLHX61pZ-vcki5ONxG8W3xmVhZ7zrNxshT) - Fundamentos

**Tutoriales específicos:**

- [System Calls en Linux](https://www.youtube.com/watch?v=kUZHOsRtF5o) - Syscalls explicadas
- [Strings en Assembly](https://www.youtube.com/watch?v=NuwvXEQxDKI) - Manejo de cadenas
- [Stack y Memoria](https://www.youtube.com/watch?v=M5OTH8hLj20) - Gestión de memoria
- [Funciones y ABI](https://www.youtube.com/watch?v=FPgRCR2uE5g) - Llamadas a funciones

[⬆️ Volver arriba](#tabla-de-contenidos)

## Resumen Final

### Conceptos Clave

1. **Registros**: Memoria ultrarrápida dentro de la CPU (16 de propósito general)
2. **Nombres fijos**: No puedes renombrar `rax`, `rbx`, etc.
3. **Subdivisiones**: `rax` (64) → `eax` (32) → `ax` (16) → `ah`/`al` (8 bits)
4. **Convención de llamada**: Parámetros en `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
5. **Valor de retorno**: Siempre en `rax`

### Instrucciones Más Usadas en el Proyecto

```nasm
mov  rax, rbx       ; Mover/copiar
xor  rax, rax       ; Poner a cero
cmp  al, dl         ; Comparar
je   .label         ; Saltar si igual
jne  .label         ; Saltar si no igual
inc  rax            ; Incrementar
call funcion        ; Llamar función
ret                 ; Retornar
```

### Checklist para Escribir Funciones

- [ ] Preservar registros callee-saved si los usas (`rbx`, `rbp`, `r12-r15`)
- [ ] Guardar parámetros si necesitas retornarlos
- [ ] Alinear el stack a 16 bytes antes de `call`
- [ ] Especificar tamaño en accesos a memoria (`byte`, `word`, `dword`, `qword`)
- [ ] Retornar valor en `rax`
- [ ] Manejar casos especiales (punteros NULL, cadenas vacías, etc.)

[⬆️ Volver arriba](#tabla-de-contenidos)

---

## 🎓 Canales de YouTube Recomendados

### En Español 🇪🇸

- **[Programación ATS](https://www.youtube.com/@ProgramacionATS)** - Tutoriales de Assembly x86-64, proyectos prácticos y sistemas operativos
- **[Código Facilito](https://www.youtube.com/@codigofacilito)** - Cursos de programación de bajo nivel
- **[CodeNation](https://www.youtube.com/@CodeNation_)** - Arquitectura de computadores y Assembly
- **[DotCSV](https://www.youtube.com/@DotCSV)** - Conceptos de hardware y arquitectura explicados visualmente
- **[Dev Explained](https://www.youtube.com/@DevExplained_)** - Programación de sistemas desde cero

### Tutoriales Específicos en Español

- **[Assembly x86-64 - Tutorial Completo](https://www.youtube.com/watch?v=WpYFQ_WiL5g)** - Introducción práctica desde cero
- **[Programación en Ensamblador - Playlist](https://www.youtube.com/playlist?list=PLZw5VfkTcc8Mzz6HS6-XNxfnEyHdyTlmP)** - Serie completa paso a paso
- **[NASM Tutorial Intermedio](https://www.youtube.com/watch?v=Xv0-MQGSE64)** - Nivel intermedio con NASM

### En Inglés (con subtítulos disponibles) 🇬🇧

- **[Creel](https://www.youtube.com/@WhatsACreel)** - Assembly x86-64 moderno y claro
- **[Low Level Learning](https://www.youtube.com/@LowLevelLearning)** - Programación de sistemas, muy didáctico
- **[Nanobyte](https://www.youtube.com/@nanobyte-dev)** - OS development y Assembly desde cero
- **[Jacob Sorber](https://www.youtube.com/@JacobSorber)** - Programación en C y sistemas

### Herramientas Interactivas

- **[Compiler Explorer (Godbolt)](https://godbolt.org/)** - Visualiza código Assembly en tiempo real
- **[Felix Cloutier x86 Reference](https://www.felixcloutier.com/x86/)** - Referencia completa de instrucciones x86

---

**¡Éxito con tu proyecto libasm!** 🚀

Esta guía cubre todo lo necesario para entender y trabajar con ensamblador x86-64 en el contexto de tu proyecto. Consulta las secciones específicas según lo que necesites implementar.
