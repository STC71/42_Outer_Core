# Funciones Bonus - libasm

Este directorio contiene las implementaciones en ensamblador x86-64 de las funciones bonus del proyecto libasm, que incluyen conversión de bases y operaciones con listas enlazadas.

## Funciones Implementadas

### ft_atoi_base
```c
int ft_atoi_base(char *str, char *base);
```
Convierte una cadena en un número entero utilizando una base arbitraria. 

**Características**:
- Soporta signos múltiples (`+`, `-`)
- Ignora espacios en blanco iniciales
- Valida la base (no duplicados, no signos, longitud >= 2)
- Soporta bases 2-36

**Validación de base**:
- No puede contener `+` o `-`
- No puede contener espacios en blanco
- No puede tener caracteres duplicados
- Debe tener al menos 2 caracteres

**Ejemplo**:
```c
ft_atoi_base("2a", "0123456789abcdef");  // Devuelve 42 (hex)
ft_atoi_base("101010", "01");             // Devuelve 42 (binario)
```

---

### ft_list_push_front
```c
void ft_list_push_front(t_list **begin_list, void *data);
```
Añade un nuevo elemento al inicio de una lista enlazada.

**Estructura**:
```c
typedef struct s_list {
    void *data;
    struct s_list *next;
} t_list;
```

**Implementación**:
1. Asigna memoria para un nuevo nodo con `malloc`
2. Almacena el puntero a datos en `data`
3. Enlaza el nuevo nodo al inicio de la lista
4. Actualiza el puntero de inicio

**Dependencias externas**: `malloc`

**Gestión de stack**: Alineación a 16 bytes antes de llamar a `malloc`.

---

### ft_list_size
```c
int ft_list_size(t_list *begin_list);
```
Cuenta el número de elementos en una lista enlazada.

**Implementación**: Iteración simple recorriendo los punteros `next` hasta encontrar NULL.

**Retorno**: Número de elementos en la lista.

---

### ft_list_sort
```c
void ft_list_sort(t_list **begin_list, int (*cmp)());
```
Ordena una lista enlazada utilizando una función de comparación personalizada.

**Algoritmo**: Bubble Sort optimizado (se detiene cuando no hay intercambios).

**Función de comparación**:
La función `cmp` debe tener la siguiente firma:
```c
int cmp(void *data1, void *data2);
```

Y devolver:
- `< 0` si data1 < data2
- `0` si data1 == data2
- `> 0` si data1 > data2

**Implementación**:
1. Recorre la lista comparando elementos adyacentes
2. Intercambia los punteros `data` si están en orden incorrecto
3. Repite hasta que no haya intercambios

**Características técnicas**:
- **Alineación del stack**: Se utiliza `and rsp, -16` para garantizar alineación a 16 bytes antes de llamar a la función de comparación
- **Preservación de registros**: Guarda y restaura r12-r15 según ABI
- **Optimización**: Flag de cambio para terminar cuando la lista está ordenada

**Nota**: Los nodos no se mueven en memoria; solo se intercambian los punteros `data`.

---

### ft_list_remove_if
```c
void ft_list_remove_if(t_list **begin_list, void *data_ref,
                       int (*cmp)(), void (*free_fct)(void *));
```
Elimina todos los elementos de una lista que coincidan con `data_ref` según la función de comparación `cmp`.

**Parámetros**:
- `begin_list`: Puntero al puntero del inicio de la lista
- `data_ref`: Dato de referencia para comparar
- `cmp`: Función de comparación (mismo formato que `ft_list_sort`)
- `free_fct`: Función para liberar los datos del nodo eliminado

**Implementación**:
1. Itera por la lista comparando cada `data` con `data_ref`
2. Si coincide (`cmp` devuelve 0):
   - Desenlaza el nodo
   - Llama a `free_fct` para liberar los datos
   - Llama a `free` para liberar el nodo
   - Continúa con el siguiente nodo
3. Si no coincide, avanza al siguiente nodo

**Dependencias externas**: `free`

**Casos especiales**:
- Eliminar el primer nodo
- Eliminar nodos consecutivos
- Lista vacía o NULL

---

## Características Técnicas

- **Arquitectura**: x86-64
- **Sintaxis**: Intel (NASM)
- **Convención de llamada**: System V AMD64 ABI
- **Alineación del stack**: 16 bytes antes de llamadas externas
- **Gestión de memoria**: Uso de `malloc` y `free`

## Compilación

```bash
make bonus       # Compila funciones obligatorias + bonus
make test_bonus  # Compila y ejecuta tests de funciones bonus
```

## Estructura de Datos

```c
typedef struct s_list {
    void *data;           // Puntero a los datos (tipo genérico)
    struct s_list *next;  // Puntero al siguiente nodo
} t_list;
```

**Tamaños**:
- `data`: 8 bytes (puntero de 64 bits)
- `next`: 8 bytes (puntero de 64 bits)
- **Total**: 16 bytes por nodo

**Offsets**:
- `data`: offset 0
- `next`: offset 8

## Notas de Implementación

### Alineación del Stack
Las funciones que llaman a funciones externas (`malloc`, `free`, funciones de comparación) deben garantizar que el stack esté alineado a 16 bytes en el momento de la llamada. Esto es crítico para:
- Funciones de la librería estándar C
- Funciones que utilizan instrucciones SSE/AVX

**Técnica utilizada**:
```asm
push rbp
mov rbp, rsp
and rsp, -16      ; Alinea stack a 16 bytes
sub rsp, 48       ; Reserva espacio para variables locales
; ... código ...
leave             ; Restaura rbp y rsp
ret
```

### Preservación de Registros
Según System V AMD64 ABI, los registros **rbx, rbp, r12, r13, r14, r15** deben preservarse:
```asm
push r12
push r13
push r14
; ... usar registros ...
pop r14
pop r13
pop r12
```

### Gestión de Errores
Las funciones que utilizan `malloc` no establecen `errno` explícitamente. Si `malloc` devuelve NULL, la función puede:
- Retornar inmediatamente (ft_list_push_front)
- Saltar la operación actual (ft_list_remove_if)

## Ejemplo de Uso

```c
#include "libasm_bonus.h"

int main() {
    t_list *list = NULL;
    
    // Añadir elementos
    ft_list_push_front(&list, "world");
    ft_list_push_front(&list, "hello");
    
    // Contar elementos
    int size = ft_list_size(list);  // 2
    
    // Ordenar
    ft_list_sort(&list, ft_strcmp);
    
    // Resultado: ["hello", "world"]
    
    return 0;
}
```

## Complejidad

- **ft_atoi_base**: O(n + m) donde n = longitud de str, m = longitud de base
- **ft_list_push_front**: O(1)
- **ft_list_size**: O(n) donde n = número de nodos
- **ft_list_sort**: O(n²) Bubble Sort - peor caso
- **ft_list_remove_if**: O(n) donde n = número de nodos
