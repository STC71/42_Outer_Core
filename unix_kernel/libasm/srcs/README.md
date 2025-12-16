# Funciones Obligatorias - libasm

Este directorio contiene las implementaciones en ensamblador x86-64 de las funciones obligatorias del proyecto libasm.

## Funciones Implementadas

### ft_strlen
```c
size_t ft_strlen(const char *s);
```
Calcula la longitud de una cadena (sin incluir el carácter nulo final).

**Implementación**: Itera byte a byte buscando el terminador nulo `\0`.

---

### ft_strcpy
```c
char *ft_strcpy(char *dest, const char *src);
```
Copia una cadena desde `src` a `dest`, incluyendo el terminador nulo.

**Retorno**: Puntero al destino `dest`.

---

### ft_strcmp
```c
int ft_strcmp(const char *s1, const char *s2);
```
Compara dos cadenas lexicográficamente.

**Retorno**:
- `< 0` si s1 < s2
- `0` si s1 == s2
- `> 0` si s1 > s2

---

### ft_write
```c
ssize_t ft_write(int fd, const void *buf, size_t count);
```
Escribe hasta `count` bytes del buffer `buf` en el descriptor de archivo `fd`.

**Implementación**: Utiliza la syscall `write` (número 1) de Linux.

**Manejo de errores**: Establece `errno` mediante `__errno_location` en caso de error.

**Retorno**: Número de bytes escritos, o -1 en caso de error.

---

### ft_read
```c
ssize_t ft_read(int fd, void *buf, size_t count);
```
Lee hasta `count` bytes del descriptor de archivo `fd` al buffer `buf`.

**Implementación**: Utiliza la syscall `read` (número 0) de Linux.

**Manejo de errores**: Establece `errno` mediante `__errno_location` en caso de error.

**Retorno**: Número de bytes leídos, 0 en EOF, o -1 en caso de error.

---

### ft_strdup
```c
char *ft_strdup(const char *s);
```
Duplica una cadena en memoria dinámica.

**Implementación**:
1. Calcula longitud de la cadena con `ft_strlen`
2. Asigna memoria con `malloc`
3. Copia bytes con `ft_strcpy`

**Dependencias externas**: `malloc`

**Manejo de errores**: Establece `errno` si `malloc` falla.

**Retorno**: Puntero a la nueva cadena, o NULL en caso de error.

---

## Características Técnicas

- **Arquitectura**: x86-64
- **Sintaxis**: Intel (NASM)
- **Convención de llamada**: System V AMD64 ABI
- **Syscalls**: Linux (cuando aplicable)
- **Alineación del stack**: 16 bytes antes de llamadas externas

## Compilación

```bash
make all      # Compila solo funciones obligatorias
make test     # Compila y ejecuta tests de funciones obligatorias
```

## Registros Utilizados

Según System V AMD64 ABI:
- **rdi**: Primer parámetro
- **rsi**: Segundo parámetro
- **rdx**: Tercer parámetro
- **rax**: Valor de retorno
- **Preservados**: rbx, rbp, r12-r15

## Notas de Implementación

1. **Gestión de errores**: Las syscalls devuelven valores negativos en caso de error. El código convierte estos valores a positivos y los almacena en `errno` mediante `__errno_location`.

2. **Alineación del stack**: Antes de llamar a funciones externas como `malloc`, el stack debe estar alineado a 16 bytes. Se utiliza `sub rsp, 8` cuando es necesario.

3. **Optimización**: Los bucles están optimizados para minimizar saltos condicionales y accesos a memoria.
