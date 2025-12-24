# libasm

![Status](https://img.shields.io/badge/status-completed-success)
![Tests](https://img.shields.io/badge/tests-30%2F30_passing-success)
![Language](https://img.shields.io/badge/language-x86--64_Assembly-blue)

Implementación de funciones de la librería estándar de C en ensamblador x86-64 utilizando sintaxis Intel y NASM.

## 📋 Descripción

**libasm** es un proyecto educativo que consiste en reimplementar funciones básicas de la librería estándar de C (`libc`) en ensamblador puro x86-64. El objetivo es comprender en profundidad:

- Arquitectura x86-64 y su conjunto de instrucciones
- Convención de llamada System V AMD64 ABI
- Syscalls del kernel de Linux
- Gestión de memoria en bajo nivel
- Alineación del stack y preservación de registros

## 🎯 Funciones Implementadas

### Parte Obligatoria

| Función | Descripción | Syscall |
|---------|-------------|---------|
| `ft_strlen` | Calcula la longitud de una cadena | - |
| `ft_strcpy` | Copia una cadena a otra ubicación | - |
| `ft_strcmp` | Compara dos cadenas lexicográficamente | - |
| `ft_write` | Escribe en un descriptor de archivo | ✅ (write) |
| `ft_read` | Lee desde un descriptor de archivo | ✅ (read) |
| `ft_strdup` | Duplica una cadena en memoria dinámica | - |

### Parte Bonus

| Función | Descripción |
|---------|-------------|
| `ft_atoi_base` | Convierte string a entero en base arbitraria |
| `ft_list_push_front` | Añade un elemento al inicio de una lista |
| `ft_list_size` | Cuenta los elementos de una lista |
| `ft_list_sort` | Ordena una lista usando función de comparación |
| `ft_list_remove_if` | Elimina elementos que cumplan una condición |

## 🚀 Inicio Rápido

### Requisitos

- **Sistema operativo**: Linux (x86-64)
- **Ensamblador**: NASM (Netwide Assembler)
- **Compilador**: GCC
- **Make**: GNU Make

```bash
# Instalar dependencias en Ubuntu/Debian
sudo apt-get install nasm gcc make

# Instalar dependencias en Arch Linux
sudo pacman -S nasm gcc make
```

### Compilación

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/libasm.git
cd libasm

# Compilar solo funciones obligatorias
make

# Compilar con funciones bonus
make bonus

# Ejecutar tests
make test         # Tests obligatorios
make test_bonus   # Tests obligatorios + bonus
```

### Uso

```c
#include "libasm.h"
// o para funciones bonus
#include "libasm_bonus.h"

int main(void)
{
    char str[] = "Hello, libasm!";
    int len = ft_strlen(str);
    
    ft_write(1, str, len);
    ft_write(1, "\n", 1);
    
    return 0;
}
```

Compilar tu programa:
```bash
gcc tu_programa.c libasm.a -o ejecutable
./ejecutable
```

## 📁 Estructura del Proyecto

```
libasm/
├── Makefile              # Sistema de compilación
├── README.md             # Este archivo
├── SUMMARY.md            # Resumen detallado del proyecto
│
├── libasm.h              # Prototipos funciones obligatorias
├── libasm_bonus.h        # Prototipos funciones bonus
│
├── srcs/                 # Implementación funciones obligatorias
│   ├── README.md         # Documentación detallada
│   ├── ft_strlen.s
│   ├── ft_strcpy.s
│   ├── ft_strcmp.s
│   ├── ft_write.s
│   ├── ft_read.s
│   └── ft_strdup.s
│
├── bonus/                # Implementación funciones bonus
│   ├── README.md         # Documentación detallada
│   ├── ft_atoi_base_bonus.s
│   ├── ft_list_push_front_bonus.s
│   ├── ft_list_size_bonus.s
│   ├── ft_list_sort_bonus.s
│   └── ft_list_remove_if_bonus.s
│
└── tests/                # Suite de pruebas
    ├── README.md         # Documentación de tests
    ├── main.c            # Tests funciones obligatorias
    └── main_bonus.c      # Tests funciones bonus
```

## 🔧 Comandos del Makefile

```bash
make                # Compila funciones obligatorias
make all            # Alias de make
make bonus          # Compila obligatorias + bonus
make test           # Compila y ejecuta tests obligatorios
make test_bonus     # Compila y ejecuta tests completos
make clean          # Elimina archivos objeto (.o)
make fclean         # Elimina todo lo compilado
make re             # Recompila desde cero (fclean + all)
```

## 🧪 Tests

El proyecto incluye una suite completa de tests que verifica:

### Funciones Obligatorias (17 tests)
- ✅ Strings vacías
- ✅ Strings normales
- ✅ Strings largas (1000+ caracteres)
- ✅ Manejo de errores (errno)
- ✅ Casos límite

### Funciones Bonus (13 tests)
- ✅ Bases numéricas (binario, decimal, hexadecimal)
- ✅ Números negativos y signos múltiples
- ✅ Listas vacías y con múltiples elementos
- ✅ Ordenación alfabética
- ✅ Eliminación selectiva de elementos

**Resultado**: 30/30 tests pasan (100% ✅)

```bash
make test_bonus
```

## 📚 Documentación

Cada directorio contiene su propio README con:
- Descripción detallada de cada función
- Parámetros y valores de retorno
- Notas de implementación
- Ejemplos de uso
- Análisis de complejidad

### Documentación Disponible
- **[README.md](README.md)** - Visión general (este archivo)
- **[SUMMARY.md](SUMMARY.md)** - Resumen completo del proyecto
- **[srcs/README.md](srcs/README.md)** - Funciones obligatorias
- **[bonus/README.md](bonus/README.md)** - Funciones bonus
- **[tests/README.md](tests/README.md)** - Suite de pruebas

## 🎓 Aspectos Técnicos

### Arquitectura
- **CPU**: x86-64 (64 bits)
- **Sintaxis**: Intel (NASM)
- **ABI**: System V AMD64
- **OS**: Linux

### Convención de Llamada

| Registro | Uso | Caller/Callee Saved |
|----------|-----|---------------------|
| `rdi` | 1er argumento | Caller |
| `rsi` | 2do argumento | Caller |
| `rdx` | 3er argumento | Caller |
| `rax` | Valor de retorno | Caller |
| `rbx`, `rbp`, `r12-r15` | Uso general | **Callee** |

### Stack Alignment
- El stack debe estar alineado a **16 bytes** antes de `call`
- Crítico para funciones externas (`malloc`, `free`, etc.)

### Syscalls Linux

| Nombre | RAX | RDI | RSI | RDX |
|--------|-----|-----|-----|-----|
| read | 0 | fd | buf | count |
| write | 1 | fd | buf | count |

## 💡 Decisiones de Diseño

1. **Bubble Sort en ft_list_sort**
   - Algoritmo simple y comprensible en ensamblador
   - Optimizado con flag de cambio (early exit)
   - O(n²) peor caso, O(n) mejor caso

2. **Intercambio de punteros data, no nodos**
   - Más eficiente (menos instrucciones)
   - No requiere gestión de punteros prev
   - Código más simple y mantenible

3. **Uso de ft_strcmp en tests**
   - `strcmp` stdlib requiere stack alignment estricto
   - `ft_strcmp` es más predecible
   - Evita dependencias innecesarias

## 🐛 Problemas Conocidos y Soluciones

### Stack Alignment con Funciones Externas
**Problema**: Segfault al llamar a `malloc` o funciones de la librería estándar.

**Solución**: Asegurar alineación de 16 bytes antes de `call`:
```asm
push rbp
mov rbp, rsp
and rsp, -16      ; Forzar alineación
sub rsp, 48       ; Reservar espacio
; ... código ...
leave
ret
```

### Errno en Syscalls
**Problema**: Syscalls devuelven valores negativos en error.

**Solución**: Conversión explícita y uso de `__errno_location`:
```asm
neg rax              ; -errno -> +errno
mov rdi, rax
call __errno_location wrt ..plt
mov [rax], rdi
mov rax, -1          ; Retornar -1
```

## 📊 Estadísticas

- **Líneas de código**: ~2,020
- **Archivos fuente**: 13 (.s + .c)
- **Funciones**: 11 (6 + 5)
- **Tests**: 30
- **Documentación**: 4 READMEs + comentarios inline

## 🔗 Recursos

### Documentación Técnica
- [System V AMD64 ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf)
- [Linux Syscall Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)
- [NASM Documentation](https://www.nasm.us/doc/)
- [Intel x86-64 Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

### Tutoriales y Guías
- [x86-64 Assembly Language Programming with Ubuntu](http://www.egr.unlv.edu/~ed/assembly64.pdf)
- [Assembly Language Megaprimer for Linux](https://www.youtube.com/watch?v=VQAKkuLL31g)

## 🚧 Posibles Extensiones

- [ ] Implementar QuickSort o MergeSort para `ft_list_sort`
- [ ] Versiones SIMD (SSE/AVX) de funciones de string
- [ ] Funciones adicionales: `ft_memcpy`, `ft_memset`, `ft_memmove`
- [ ] Soporte para macOS (Mach-O format)
- [ ] Versión ARM64/AArch64
- [ ] Benchmarks de rendimiento vs libc
- [ ] Fuzzing automático 

## 👨‍💻 Autor

Proyecto desarrollado como parte del curriculum de **42**. sternero(2025) - 42 Málaga.

## 📄 Licencia

Este proyecto es de código abierto con fines educativos.

---

**Nota**: Todos los tests pasan exitosamente. El proyecto está completo y funcional.

```
╔════════════════════════════════════╗
║       LIBASM - 100% COMPLETE       ║
║       Tests: 30/30 PASSED ✅       ║
╚════════════════════════════════════╝
```
