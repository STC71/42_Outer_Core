# Tests - libasm

Este directorio contiene los programas de prueba para verificar el correcto funcionamiento de las funciones implementadas en libasm.

## Archivos

### main.c
Programa de pruebas para las **funciones obligatorias**.

**Funciones probadas**:
- `ft_strlen` - Longitud de cadenas
- `ft_strcpy` - Copia de cadenas
- `ft_strcmp` - Comparación de cadenas
- `ft_write` - Escritura en descriptores de archivo
- `ft_read` - Lectura de descriptores de archivo
- `ft_strdup` - Duplicación de cadenas

**Casos de prueba incluidos**:
- Cadenas normales
- Cadenas vacías
- Cadenas largas (1000+ caracteres)
- Manejo de errores (errno)
- Casos límite

**Compilación y ejecución**:
```bash
make test
```

**Salida esperada**:
```
╔════════════════════════════════════╗
║       LIBASM MANDATORY TESTS       ║
╚════════════════════════════════════╝

=== Testing ft_strlen ===
ft_strlen("Hello"): 5 ✓
ft_strlen(""): 0 ✓
...

╔════════════════════════════════════╗
║         ALL TESTS PASSED!          ║
╚════════════════════════════════════╝
```

---

### main_bonus.c
Programa de pruebas para las **funciones bonus**.

**Funciones probadas**:
- `ft_atoi_base` - Conversión de bases
- `ft_list_push_front` - Añadir al inicio de lista
- `ft_list_size` - Tamaño de lista
- `ft_list_sort` - Ordenación de lista
- `ft_list_remove_if` - Eliminación condicional

**Casos de prueba incluidos**:

#### ft_atoi_base
- Base hexadecimal (0-9, a-f)
- Base binaria (0-1)
- Base decimal (0-9)
- Números negativos
- Signos múltiples
- Bases inválidas

#### Operaciones con listas
- Listas vacías
- Listas con múltiples elementos
- Ordenación alfabética
- Eliminación de elementos específicos
- Liberación de memoria

**Compilación y ejecución**:
```bash
make test_bonus
```

**Salida esperada**:
```
╔════════════════════════════════════╗
║       LIBASM BONUS TESTS           ║
╚════════════════════════════════════╝

=== Testing ft_atoi_base ===
ft_atoi_base("2a", "0123456789abcdef"): 42 ✓
ft_atoi_base("101010", "01"): 42 ✓
...

╔════════════════════════════════════╗
║         TESTS COMPLETED            ║
╚════════════════════════════════════╝
```

---

## Estructura de Tests

### Formato de Salida
Los tests utilizan códigos de color ANSI para mejor legibilidad:
- **Azul**: Encabezados de secciones
- **Verde**: Tests exitosos (✓)
- **Rojo**: Tests fallidos (✗)
- **Amarillo**: Advertencias

### Funciones de Utilidad

#### print_list()
Imprime el contenido de una lista enlazada para debugging.

#### free_data()
Función de liberación de memoria para `ft_list_remove_if`.

#### cmp_str()
Función de comparación de strings para `ft_list_sort` y `ft_list_remove_if`.
**Nota**: Utiliza `ft_strcmp` en lugar de `strcmp` de la librería estándar para garantizar compatibilidad con el stack alignment.

---

## Verificación de Resultados

### Tests Obligatorios
Cada función se prueba contra su equivalente de la librería estándar de C:
- `ft_strlen` vs `strlen`
- `ft_strcpy` vs `strcpy`
- `ft_strcmp` vs `strcmp`
- `ft_write` vs `write`
- `ft_read` vs `read`
- `ft_strdup` vs `strdup`

### Tests Bonus
Las funciones bonus se verifican mediante:
1. **Valores esperados**: Resultados conocidos para entradas específicas
2. **Propiedades**: Invariantes que deben mantenerse (ej: tamaño de lista después de push_front)
3. **Comparaciones manuales**: Verificación visual de listas ordenadas

---

## Compilación

Los tests se compilan automáticamente cuando se ejecuta:
```bash
make test        # Solo tests obligatorios
make test_bonus  # Tests obligatorios + bonus
```

**Flags de compilación**:
```bash
gcc -Wall -Wextra -Werror tests/main.c libasm.a -o test
gcc -Wall -Wextra -Werror tests/main_bonus.c libasm.a -o test_bonus
```

---

## Debugging

Para ejecutar tests bajo un debugger:
```bash
# Compilar con símbolos de debug
gcc -g tests/main.c libasm.a -o test

# Ejecutar con gdb
gdb ./test

# Ejecutar con valgrind (detección de leaks)
valgrind --leak-check=full ./test_bonus
```

---

## Casos de Error

Los tests verifican el correcto manejo de errores:

### ft_write / ft_read
- **Descriptor inválido**: fd = -1
- **Buffer NULL**: buf = NULL
- **Verificación**: `errno` se establece correctamente

### ft_strdup
- **Memoria insuficiente**: Simulado con malloc wrapper (no incluido en tests básicos)
- **Verificación**: Retorna NULL y establece `errno`

### ft_atoi_base
- **Base vacía**: base = ""
- **Base con un solo carácter**: base = "0"
- **Base con caracteres inválidos**: base = "01234+6789"
- **Verificación**: Retorna 0

---

## Notas Importantes

1. **Orden de ejecución**: Los tests se ejecutan en el orden definido en `main()`. Algunos tests pueden depender de la correcta ejecución de funciones anteriores.

2. **Memoria dinámica**: Los tests de listas (`test_bonus`) asignan memoria que debe liberarse correctamente. Usar `valgrind` para verificar.

3. **Stack alignment**: La función `cmp_str` en `main_bonus.c` utiliza `ft_strcmp` en lugar de `strcmp` de la librería estándar. Esto es necesario porque `strcmp` puede usar instrucciones SSE que requieren stack alineado a 16 bytes.

4. **Archivos temporales**: `ft_write` y `ft_read` crean archivos temporales `/tmp/libasm_test.txt` que se eliminan automáticamente.

---

## Extender los Tests

Para añadir nuevos casos de prueba:

1. **Crear función de test**:
```c
void test_nueva_funcion(void) {
    printf(BLUE "\n=== Testing nueva_funcion ===\n" RESET);
    
    // Tu código de test aquí
    
    if (resultado_esperado == resultado_obtenido)
        printf(GREEN "Test passed ✓\n" RESET);
    else
        printf(RED "Test failed ✗\n" RESET);
}
```

2. **Llamar desde main**:
```c
int main(void) {
    // ... tests existentes ...
    test_nueva_funcion();
    // ...
}
```

3. **Recompilar**:
```bash
make fclean
make test_bonus
```

---

## Cobertura de Tests

### Funciones Obligatorias: 100%
- ✅ ft_strlen (3 casos)
- ✅ ft_strcpy (3 casos)
- ✅ ft_strcmp (4 casos)
- ✅ ft_write (3 casos)
- ✅ ft_read (2 casos)
- ✅ ft_strdup (3 casos)

### Funciones Bonus: 100%
- ✅ ft_atoi_base (8 casos)
- ✅ ft_list_push_front (1 caso)
- ✅ ft_list_size (2 casos)
- ✅ ft_list_sort (1 caso)
- ✅ ft_list_remove_if (1 caso)

**Total**: 26 casos de prueba
