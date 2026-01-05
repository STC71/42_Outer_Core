# PYTHON.md - Guía Completa de Python para ft_linear_regression

Este documento explica de forma clara y detallada todos los conceptos, librerías y funciones de Python utilizadas en el proyecto **ft_linear_regression**, para que cualquier persona sin conocimientos previos pueda entenderlo completamente.

✨ **Incluye:**
- 🐍 Explicaciones detalladas de conceptos básicos
- 📚 Librerías y módulos utilizados (csv, sys, os, matplotlib)
- 💡 Ejemplos prácticos del proyecto
- 🎥 Videos educativos en español (al final de cada sección)
- 🔍 Código comentado paso a paso

---

## 🎥 Recursos Generales

Antes de empezar, aquí tienes algunos cursos completos de Python en español que te serán muy útiles:

- [**Python desde Cero - Curso Completo** - Píldoras Informáticas](https://www.youtube.com/playlist?list=PLU8oAlHdN5BlvPxziopYZRd55pdqFwkeS) - El curso más completo en español
- [**Curso Python para Principiantes** - MoureDev](https://www.youtube.com/watch?v=Kp4Mvapo5kc) - 7 horas de Python desde cero
- [**Python 3 Tutorial Completo** - Código Facilito](https://www.youtube.com/playlist?list=PLagErt3C7wnmNRv1tAv0qbj6m3hDhh1c4) - Curso estructurado y práctico
- [**Aprende Python Ahora** - Ringa Tech](https://www.youtube.com/watch?v=tQZy0U8s9LY) - Tutorial moderno y actualizado

---

## 📚 Tabla de Contenidos

1. [Conceptos Básicos de Python](#conceptos-básicos-de-python) 🎥
2. [Librerías Utilizadas](#librerías-utilizadas) 🎥
3. [Estructuras de Datos](#estructuras-de-datos) 🎥
4. [Funciones y Definiciones](#funciones-y-definiciones) 🎥
5. [Manejo de Archivos](#manejo-de-archivos) 🎥
6. [Manejo de Errores](#manejo-de-errores) 🎥
7. [Entrada/Salida](#entradasalida) 🎥
8. [Operaciones Matemáticas](#operaciones-matemáticas) 🎥
9. [Comprensiones de Listas](#comprensiones-de-listas) 🎥
10. [Condicionales e Iteraciones](#condicionales-e-iteraciones) 🎥
11. [Módulos y Ejecución](#módulos-y-ejecución) 🎥

*🎥 Cada sección incluye enlaces a videos educativos en español*

---

## Conceptos Básicos de Python

### 1.1. Shebang (`#!/usr/bin/env python3`)

```python
#!/usr/bin/env python3
```

**¿Qué es?** Es la primera línea de un script ejecutable en sistemas Unix/Linux.

**¿Para qué sirve?** Indica al sistema operativo que debe ejecutar este archivo con Python 3.

**Ejemplo práctico:**
- Sin shebang: `python3 train.py`
- Con shebang y permisos: `./train.py`

### 1.2. Docstrings (Documentación)

```python
"""
Esto es un docstring.
Documenta qué hace el programa, función o clase.
"""
```

**¿Qué es?** Texto entre triple comillas que documenta el código.

**Ubicaciones:**
- Inicio del archivo: describe el programa completo
- Después de `def función():`: describe qué hace la función

**Acceso:** Se puede acceder con `help(función)` o `función.__doc__`

### 1.3. Comentarios

```python
# Esto es un comentario de una línea
x = 5  # Los comentarios explican el código
```

**Diferencia con docstrings:**
- Comentarios (#): Notas para programadores
- Docstrings ("""): Documentación oficial accesible

### 🎥 Aprende más
- [**Python desde Cero** - Píldoras Informáticas](https://www.youtube.com/watch?v=G2FCfQj-9ig&list=PLU8oAlHdN5BlvPxziopYZRd55pdqFwkeS) - Curso completo desde conceptos básicos
- [**Introducción a Python** - Víctor Robles](https://www.youtube.com/watch?v=chPhlsHoEPo) - Fundamentos explicados paso a paso
- [**Python para Principiantes** - MoureDev](https://www.youtube.com/watch?v=Kp4Mvapo5kc) - Tutorial moderno y actualizado

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Librerías Utilizadas

### 2.1. `csv` - Manejo de archivos CSV

**¿Qué es CSV?** Formato de archivo para tablas de datos, donde cada línea es una fila y las columnas están separadas por comas.

**Ejemplo de CSV:**
```csv
km,price
240000,3650
139800,3800
150500,4400
```

#### Funciones principales:

##### `csv.DictReader(archivo)`

```python
import csv

with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row['km'])      # Acceso por nombre de columna
        print(row['price'])
```

**¿Qué hace?**
- Lee archivos CSV
- Convierte cada fila en un diccionario
- Usa la primera fila como nombres de las columnas (claves)

**Ejemplo completo:**
```python
# Archivo: data.csv
# km,price
# 100000,5000
# 200000,3000

reader = csv.DictReader(f)
for row in reader:
    # row = {'km': '100000', 'price': '5000'}
    print(row['km'])  # '100000'
```

### 2.2. `sys` - Interacción con el sistema

**¿Qué hace?** Permite interactuar con el intérprete de Python y el sistema operativo.

#### Funciones principales:

##### `sys.exit(código)`

```python
import sys

sys.exit(0)  # Salir con éxito
sys.exit(1)  # Salir con error
```

**¿Para qué sirve?**
- Termina la ejecución del programa inmediatamente
- Código 0: éxito
- Código diferente de 0: error

**Ejemplo práctico:**
```python
if not archivo_existe:
    print("Error: Archivo no encontrado")
    sys.exit(1)  # Terminar con error
```

### 2.3. `os` - Operaciones del sistema operativo

**¿Qué hace?** Permite interactuar con el sistema de archivos.

#### Funciones principales:

##### `os.path.exists(ruta)`

```python
import os

if os.path.exists('thetas.txt'):
    print("El archivo existe")
else:
    print("El archivo no existe")
```

**¿Qué devuelve?**
- `True` si el archivo o carpeta existe
- `False` si no existe

##### `os.system(comando)`

```python
os.system("python3 train.py")  # Ejecuta un comando del sistema
```

**¿Qué hace?** Ejecuta comandos del sistema operativo desde Python.

##### `os.path.dirname()` y `os.path.abspath()`

```python
script_dir = os.path.dirname(os.path.abspath(__file__))
# Obtiene el directorio donde está el script
```

##### `os.chdir(ruta)`

```python
os.chdir('/home/usuario/proyecto')  # Cambia el directorio actual
```

### 2.4. `matplotlib` - Visualización de datos

**¿Qué es?** Librería para crear gráficos y visualizaciones.

**Instalación:**
```bash
pip install matplotlib
```

#### Importación:

```python
import matplotlib.pyplot as plt
```

**`plt` es un alias** (nombre corto) para facilitar el uso.

#### Funciones principales:

##### `plt.figure(figsize=(ancho, alto))`

```python
plt.figure(figsize=(12, 7))  # Crea figura de 12x7 pulgadas
```

**¿Qué hace?** Crea una nueva figura (lienzo) para el gráfico.

##### `plt.scatter(x, y, opciones...)`

```python
plt.scatter(
    mileages,           # Valores eje X
    prices,             # Valores eje Y
    color='blue',       # Color de los puntos
    alpha=0.6,          # Transparencia (0-1)
    s=50,               # Tamaño de los puntos
    label='Datos',      # Etiqueta para la leyenda
    edgecolors='black', # Color del borde
    linewidth=0.5       # Grosor del borde
)
```

**¿Qué hace?** Crea un gráfico de dispersión (puntos).

##### `plt.plot(x, y, opciones...)`

```python
plt.plot(
    [0, 100000],        # Valores X
    [8000, 3000],       # Valores Y
    color='red',        # Color de la línea
    linewidth=2,        # Grosor de la línea
    label='Regresión'   # Etiqueta
)
```

**¿Qué hace?** Dibuja una línea conectando puntos.

##### `plt.xlabel()`, `plt.ylabel()`, `plt.title()`

```python
plt.xlabel('Kilometraje (km)', fontsize=12, fontweight='bold')
plt.ylabel('Precio (€)', fontsize=12, fontweight='bold')
plt.title('Regresión Lineal', fontsize=14, fontweight='bold', pad=20)
```

**¿Qué hace?** Añade etiquetas a los ejes y título al gráfico.

##### `plt.legend()`

```python
plt.legend(loc='upper right', fontsize=10, framealpha=0.9)
```

**¿Qué hace?** Muestra la leyenda con las etiquetas de cada elemento.

##### `plt.grid()`

```python
plt.grid(True, alpha=0.3, linestyle='--')
```

**¿Qué hace?** Añade una cuadrícula al gráfico.

##### `plt.tight_layout()`

```python
plt.tight_layout()
```

**¿Qué hace?** Ajusta automáticamente el espaciado para que nada se solape.

##### `plt.show()`

```python
plt.show()
```

**¿Qué hace?** Muestra el gráfico en una ventana.

### 🎥 Aprende más
- [**Módulos y Librerías en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=QboldeuCOL8) - Cómo funcionan las importaciones
- [**Lectura de CSV en Python** - Código Facilito](https://www.youtube.com/watch?v=VYSzN5oD53w) - Manejo de archivos CSV
- [**Matplotlib Tutorial** - Ringa Tech](https://www.youtube.com/watch?v=MPiz50TsyF0) - Visualización de datos desde cero
- [**Módulos sys y os** - DotCSV](https://www.youtube.com/watch?v=3lmtXBo2kR8) - Interacción con el sistema

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Estructuras de Datos

### 3.1. Listas

**¿Qué es?** Colección ordenada de elementos que puede cambiar.

```python
# Crear listas vacías
mileages = []
prices = []

# Crear lista con elementos
numeros = [1, 2, 3, 4, 5]
nombres = ["Ana", "Juan", "María"]

# Añadir elementos
mileages.append(240000)  # Añade al final
mileages.append(150000)  # mileages = [240000, 150000]

# Acceder elementos
primer_elemento = numeros[0]   # 1 (índice 0 = primero)
ultimo_elemento = numeros[-1]  # 5 (índice -1 = último)

# Longitud de la lista
cantidad = len(mileages)  # Número de elementos

# Iterar sobre listas
for km in mileages:
    print(km)

# Iterar con índice
for i in range(len(mileages)):
    print(f"Elemento {i}: {mileages[i]}")
```

#### Operaciones con listas:

```python
# Mínimo y máximo
min_km = min(mileages)  # Valor más pequeño
max_km = max(mileages)  # Valor más grande

# Suma
total = sum(prices)  # Suma de todos los elementos

# Ordenar
numeros.sort()  # Ordena la lista en su lugar
```

### 3.2. Diccionarios

**¿Qué es?** Colección de pares clave-valor.

```python
# Crear diccionario
row = {'km': '240000', 'price': '3650'}

# Acceder valores
kilometraje = row['km']     # '240000'
precio = row['price']       # '3650'

# Diccionario de métricas (ejemplo completo)
metrics = {
    'r_squared': 0.876,
    'mse': 1234.56,
    'rmse': 35.13,
    'mae': 420.50,
    'mape': 8.3,
    'n_samples': 24
}

# Acceso
r2 = metrics['r_squared']  # 0.876
```

### 3.3. Tuplas

**¿Qué es?** Colección ordenada e inmutable (no se puede cambiar).

```python
# Retornar múltiples valores
def normalize_data(data):
    normalized = [...]
    mean = 100
    std = 15
    return normalized, mean, std  # Devuelve una tupla

# Recibir múltiples valores
norm_data, mean, std = normalize_data(mileages)

# Otra forma
files_to_check = [
    ('data.csv', True),
    ('train.py', True)
]
# Lista de tuplas (nombre, obligatorio)
```

### 🎥 Aprende más
- [**Listas en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=Q1b0d_r6UgA) - Todo sobre listas y métodos
- [**Diccionarios en Python** - Código Facilito](https://www.youtube.com/watch?v=K7BP38RGnBs) - Diccionarios explicados en detalle
- [**Estructuras de Datos** - MoureDev](https://www.youtube.com/watch?v=SDa2wDga3kM) - Listas, tuplas, diccionarios y sets
- [**Tuplas en Python** - Programación ATS](https://www.youtube.com/watch?v=F9RQmWP5c-Q) - Diferencias entre tuplas y listas

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Funciones y Definiciones

### 4.1. Definir funciones

```python
def nombre_funcion(parametro1, parametro2):
    """Docstring explicando qué hace"""
    resultado = parametro1 + parametro2
    return resultado
```

**Componentes:**
- `def`: palabra clave para definir función
- `nombre_funcion`: identificador
- `(parametros)`: valores de entrada
- `"""docstring"""`: documentación
- `return`: devolver resultado

### 4.2. Parámetros opcionales con valores por defecto

```python
def train_model(mileages, prices, learning_rate=0.1, iterations=1000):
    # learning_rate e iterations son opcionales
    # Si no se pasan, usan valores por defecto
    pass

# Uso:
train_model(mileages, prices)                    # Usa valores por defecto
train_model(mileages, prices, 0.05)              # learning_rate=0.05
train_model(mileages, prices, 0.1, 2000)         # Ambos especificados
train_model(mileages, prices, iterations=500)    # Por nombre
```

### 4.3. Funciones sin retorno

```python
def print_metrics(metrics, theta0, theta1):
    print("Métricas:")
    print(f"R²: {metrics['r_squared']}")
    # No tiene return, devuelve None implícitamente
```

### 4.4. Alcance de variables (scope)

```python
# Variable global
theta0 = 0.0

def calcular():
    # Variable local
    resultado = 10 * 2
    # resultado solo existe dentro de la función
    return resultado

def otra_funcion():
    # No puedo acceder a 'resultado' aquí
    pass
```

### 🎥 Aprende más
- [**Funciones en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=VY8NbxEr3VE) - Definición y uso de funciones
- [**Parámetros y Argumentos** - Código Facilito](https://www.youtube.com/watch?v=7EfWlUx3BUc) - Diferencias y usos
- [**Ámbito de Variables** - MoureDev](https://www.youtube.com/watch?v=L0cIzYLQtVg) - Scope local y global
- [**Return en Python** - Programación ATS](https://www.youtube.com/watch?v=c8gg0j0bT5g) - Cómo devolver valores

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Manejo de Archivos

### 5.1. Abrir y cerrar archivos con `with`

**Forma correcta (recomendada):**
```python
with open('archivo.txt', 'r') as f:
    contenido = f.read()
    # El archivo se cierra automáticamente al salir del bloque
```

**¿Por qué usar `with`?**
- Cierra el archivo automáticamente
- Incluso si hay un error
- Libera recursos del sistema

### 5.2. Modos de apertura

```python
# Lectura
with open('archivo.txt', 'r') as f:     # 'r' = read (leer)
    contenido = f.read()

# Escritura (sobrescribe)
with open('archivo.txt', 'w') as f:     # 'w' = write (escribir)
    f.write("Nuevo contenido")

# Añadir al final
with open('archivo.txt', 'a') as f:     # 'a' = append (añadir)
    f.write("Línea adicional")
```

### 5.3. Operaciones con archivos

#### Leer todo el archivo:
```python
with open('thetas.txt', 'r') as f:
    contenido = f.read()  # Devuelve todo como string
```

#### Leer líneas:
```python
with open('thetas.txt', 'r') as f:
    lines = f.readlines()  # Lista de líneas
    # ['8000.0\n', '-0.02\n']
```

#### Escribir en archivo:
```python
with open('thetas.txt', 'w') as f:
    f.write(f"{theta0}\n")  # Escribe y añade nueva línea
    f.write(f"{theta1}\n")
```

### 5.4. Procesamiento de líneas

```python
with open('thetas.txt', 'r') as f:
    lines = f.readlines()
    # lines = ['8000.0\n', '-0.02\n']
    
    theta0 = float(lines[0].strip())  # Elimina '\n' y convierte
    theta1 = float(lines[1].strip())
```

**`.strip()`:** Elimina espacios y saltos de línea de los extremos.

### 🎥 Aprende más
- [**Archivos en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=hQR-NvpR-yM) - Lectura y escritura de archivos
- [**Context Manager (with)** - Código Facilito](https://www.youtube.com/watch?v=Oj3uzPEu6lE) - Por qué usar 'with'
- [**Manejo de Archivos CSV** - Programación ATS](https://www.youtube.com/watch?v=1HcYl3n7YU4) - Trabajar con CSV en Python
- [**Open, Read, Write** - MoureDev](https://www.youtube.com/watch?v=k1fY_Ag7BAs) - Operaciones básicas con archivos

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Manejo de Errores

### 6.1. Bloques try-except

**¿Para qué sirve?** Manejar errores sin que el programa se detenga abruptamente.

```python
try:
    # Código que puede fallar
    archivo = open('noexiste.txt', 'r')
except FileNotFoundError:
    # Se ejecuta si el archivo no existe
    print("Error: Archivo no encontrado")
except IOError:
    # Se ejecuta si hay error de entrada/salida
    print("Error al leer archivo")
```

### 6.2. Tipos de excepciones comunes

#### `FileNotFoundError`
```python
try:
    with open('noexiste.txt', 'r') as f:
        pass
except FileNotFoundError:
    print("El archivo no existe")
```

#### `ValueError`
```python
try:
    numero = float("abc")  # No se puede convertir
except ValueError:
    print("Error: Valor inválido")
```

#### `KeyError`
```python
try:
    row = {'km': '100'}
    precio = row['price']  # La clave no existe
except KeyError:
    print("Error: Clave no encontrada")
```

#### `IndexError`
```python
try:
    lista = [1, 2, 3]
    elemento = lista[10]  # Índice fuera de rango
except IndexError:
    print("Error: Índice inválido")
```

#### `IOError`
```python
try:
    with open('/ruta/protegida/archivo.txt', 'w') as f:
        f.write("dato")
except IOError:
    print("Error de entrada/salida")
```

#### `KeyboardInterrupt`
```python
try:
    mileage = input("Kilometraje: ")
except KeyboardInterrupt:
    print("\nOperación cancelada")
    sys.exit(0)
```

**¿Cuándo ocurre?** Cuando el usuario presiona Ctrl+C.

### 6.3. Múltiples excepciones

```python
try:
    with open('data.csv', 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            km = float(row['km'])
except FileNotFoundError:
    print("Archivo no encontrado")
except (ValueError, KeyError) as e:
    print(f"Error al procesar datos: {e}")
```

**Paréntesis** permiten capturar múltiples tipos de error.

### 🎥 Aprende más
- [**Excepciones en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=jvgMmW1aFmQ) - Try, except y manejo de errores
- [**Try Except en Python** - Código Facilito](https://www.youtube.com/watch?v=aBRgVHSYJAw) - Control de excepciones
- [**Errores y Excepciones** - MoureDev](https://www.youtube.com/watch?v=3DYEDvgQV6U) - Tipos de errores comunes
- [**Manejo de Excepciones** - Programación ATS](https://www.youtube.com/watch?v=4E5KN60VkGI) - Buenas prácticas

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Entrada/Salida

### 7.1. `print()` - Mostrar en pantalla

```python
# Print simple
print("Hola mundo")

# Print con variables
nombre = "Ana"
print(f"Hola {nombre}")  # f-string

# Print formateado
precio = 1234.5678
print(f"Precio: {precio:.2f}€")  # Precio: 1234.57€
```

#### Formato de números:

```python
numero = 1234.5678

# Decimales
f"{numero:.2f}"      # '1234.57' (2 decimales)
f"{numero:.4f}"      # '1234.5678' (4 decimales)

# Separador de miles
f"{numero:,.2f}"     # '1,234.57'

# Anchura mínima
f"{numero:>12,.2f}"  # '    1,234.57' (alineado derecha)

# Signo siempre
f"{numero:+.2f}"     # '+1234.57'
```

### 7.2. `input()` - Leer del usuario

```python
# Leer texto
nombre = input("Tu nombre: ")
# El usuario escribe y presiona Enter

# Leer número
edad_str = input("Tu edad: ")
edad = int(edad_str)  # Convertir a entero

# Conversión directa
mileage = float(input("Kilometraje: "))
```

**Importante:** `input()` siempre devuelve un string, hay que convertirlo.

### 7.3. F-strings (formateo de strings)

**¿Qué son?** Forma moderna de formatear strings en Python 3.6+.

```python
nombre = "Juan"
edad = 25

# F-string
mensaje = f"Hola {nombre}, tienes {edad} años"

# Expresiones dentro
precio = 100
mensaje = f"Total con IVA: {precio * 1.21}€"

# Formato
valor = 1234.5678
texto = f"Valor: {valor:.2f}"  # 'Valor: 1234.57'
```

**Ventajas sobre otros métodos:**
```python
# Antiguo (formato %)
"Hola %s, tienes %d años" % (nombre, edad)

# Medio antiguo (format)
"Hola {}, tienes {} años".format(nombre, edad)

# Moderno (f-string) - MÁS LEGIBLE
f"Hola {nombre}, tienes {edad} años"
```

### 🎥 Aprende más
- [**Print e Input en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=Yw_nHixR9rU) - Entrada y salida básica
- [**F-strings en Python** - Código Facilito](https://www.youtube.com/watch?v=BxUxX1Ku1EQ) - Formato moderno de strings
- [**Format en Python** - MoureDev](https://www.youtube.com/watch?v=O55X54COqxU) - Todas las formas de formatear
- [**Input y Output** - Programación ATS](https://www.youtube.com/watch?v=Uw6_GvzJ87g) - Interacción con el usuario

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Operaciones Matemáticas

### 8.1. Operadores básicos

```python
# Suma
resultado = 5 + 3        # 8

# Resta
resultado = 5 - 3        # 2

# Multiplicación
resultado = 5 * 3        # 15

# División (devuelve float)
resultado = 5 / 2        # 2.5

# División entera (descarta decimales)
resultado = 5 // 2       # 2

# Módulo (resto)
resultado = 5 % 2        # 1

# Potencia
resultado = 5 ** 2       # 25 (5 al cuadrado)
raiz = 25 ** 0.5        # 5.0 (raíz cuadrada)
```

### 8.2. Operadores de asignación compuesta

```python
x = 10

x += 5   # x = x + 5    → x = 15
x -= 3   # x = x - 3    → x = 12
x *= 2   # x = x * 2    → x = 24
x /= 4   # x = x / 4    → x = 6.0
```

### 8.3. Cálculos estadísticos

#### Media (promedio):
```python
data = [1, 2, 3, 4, 5]
mean = sum(data) / len(data)  # 3.0
```

#### Varianza:
```python
mean = sum(data) / len(data)
variance = sum((x - mean) ** 2 for x in data) / len(data)
```

#### Desviación estándar:
```python
std = variance ** 0.5  # Raíz cuadrada de la varianza
```

#### Suma de cuadrados:
```python
ss = sum(x ** 2 for x in data)
```

### 🎥 Aprende más
- [**Operadores en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=cG4ZMBPm_cE) - Operadores aritméticos y lógicos
- [**Matemáticas en Python** - Código Facilito](https://www.youtube.com/watch?v=4pFu50JrXKg) - Operaciones matemáticas básicas
- [**Operadores Matemáticos** - MoureDev](https://www.youtube.com/watch?v=3fqPZiYGhV8) - Todos los operadores disponibles
- [**Estadística con Python** - Ringa Tech](https://www.youtube.com/watch?v=MHh7F2aHUCE) - Media, varianza, desviación

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Comprensiones de Listas

**¿Qué son?** Forma concisa de crear listas aplicando operaciones.

### 9.1. Sintaxis básica

```python
# Forma tradicional
result = []
for x in range(5):
    result.append(x * 2)
# result = [0, 2, 4, 6, 8]

# Comprensión de lista (equivalente)
result = [x * 2 for x in range(5)]
```

**Estructura:** `[expresión for elemento in iterable]`

### 9.2. Ejemplos del proyecto

#### Convertir todos a float:
```python
mileages = [float(row['km']) for row in reader]
# Equivale a:
# mileages = []
# for row in reader:
#     mileages.append(float(row['km']))
```

#### Normalizar datos:
```python
normalized = [(x - mean) / std for x in data]
# Para cada x, resta la media y divide por desv. estándar
```

#### Calcular predicciones:
```python
predictions = [estimate_price(m, theta0, theta1) for m in mileages]
# Predice el precio para cada kilometraje
```

#### Suma con condición:
```python
ss_total = sum((price - mean_price) ** 2 for price in actual_prices)
# Suma de los cuadrados de las diferencias
```

### 9.3. Con condicionales

```python
# Filtrar valores positivos
positivos = [x for x in numeros if x > 0]

# Con condición if-else
valores = [x if x > 0 else 0 for x in numeros]
```

### 🎥 Aprende más
- [**Comprensión de Listas** - Píldoras Informáticas](https://www.youtube.com/watch?v=wzbUuFXAfWQ) - List comprehensions explicadas
- [**List Comprehensions** - Código Facilito](https://www.youtube.com/watch?v=5UlO16Y9L8Y) - Crear listas de forma eficiente
- [**Listas por Comprensión** - MoureDev](https://www.youtube.com/watch?v=GlCXZCPVXmo) - Ejemplos prácticos avanzados
- [**Comprensiones en Python** - Programación ATS](https://www.youtube.com/watch?v=_CNhjQwBMGY) - Listas, dict y set comprehensions

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Condicionales e Iteraciones

### 10.1. Condicional `if`

```python
if condicion:
    # Se ejecuta si condicion es True
    print("Verdadero")
elif otra_condicion:
    # Se ejecuta si la primera es False y esta es True
    print("Otra condición")
else:
    # Se ejecuta si todas las anteriores son False
    print("Falso")
```

#### Operadores de comparación:

```python
x == y   # Igual a
x != y   # Diferente de
x > y    # Mayor que
x < y    # Menor que
x >= y   # Mayor o igual que
x <= y   # Menor o igual que
```

#### Operadores lógicos:

```python
# AND (y)
if x > 0 and x < 10:
    print("x está entre 0 y 10")

# OR (o)
if x == 0 or x == 1:
    print("x es 0 o 1")

# NOT (negación)
if not archivo_existe:
    print("El archivo no existe")
```

### 10.2. Bucle `for`

```python
# Iterar sobre lista
for elemento in lista:
    print(elemento)

# Iterar sobre rango de números
for i in range(5):      # 0, 1, 2, 3, 4
    print(i)

for i in range(1, 6):   # 1, 2, 3, 4, 5
    print(i)

for i in range(0, 10, 2):  # 0, 2, 4, 6, 8 (paso de 2)
    print(i)
```

#### `range()` explicado:

```python
range(5)        # 0, 1, 2, 3, 4
range(1, 5)     # 1, 2, 3, 4 (inicio, fin-exclusivo)
range(0, 10, 2) # 0, 2, 4, 6, 8 (inicio, fin, paso)
```

#### Enumerar con índice:

```python
for i in range(len(mileages)):
    print(f"Posición {i}: {mileages[i]}")

# O usando enumerate
for i, km in enumerate(mileages):
    print(f"Posición {i}: {km}")
```

### 10.3. Bucle `while`

```python
# Mientras la condición sea verdadera
iteration = 0
while iteration < 10:
    print(f"Iteración {iteration}")
    iteration += 1
```

**Diferencia con `for`:**
- `for`: número de iteraciones conocido
- `while`: hasta que se cumpla una condición

### 🎥 Aprende más
- [**Condicionales en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=gDVIZvVtZVo) - If, elif, else explicados
- [**Bucles For y While** - Código Facilito](https://www.youtube.com/watch?v=TqPzwenhMj0) - Iteraciones en Python
- [**Control de Flujo** - MoureDev](https://www.youtube.com/watch?v=hEb5bwo1wGk) - If, for, while completo
- [**Range en Python** - Programación ATS](https://www.youtube.com/watch?v=bVXaXVWU5UY) - Cómo usar range correctamente

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## Módulos y Ejecución

### 11.1. Importar módulos

```python
# Importar módulo completo
import csv
import sys

# Usar funciones del módulo
sys.exit(1)
```

```python
# Importar submódulo con alias
import matplotlib.pyplot as plt

# Usar el alias
plt.show()
```

```python
# Importar función específica
from csv import DictReader

# Usar directamente
reader = DictReader(f)
```

### 11.2. El bloque `if __name__ == "__main__"`

```python
def funcion1():
    pass

def funcion2():
    pass

if __name__ == "__main__":
    # Este código solo se ejecuta si el archivo
    # se ejecuta directamente, no si se importa
    funcion1()
    funcion2()
```

**¿Para qué sirve?**

**Escenario 1:** Ejecutar directamente
```bash
$ python3 train.py
# Se ejecuta el código dentro de if __name__ == "__main__"
```

**Escenario 2:** Importar desde otro archivo
```python
# En otro archivo
import train  # Solo se importan las funciones, no se ejecuta main()
```

**Resumen:**
- `__name__` es una variable especial
- Si ejecutas el archivo directamente: `__name__ == "__main__"`
- Si lo importas: `__name__ == "train"` (nombre del módulo)

### 🎥 Aprende más
- [**Módulos en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=WnT1JwYB9vI) - Crear e importar módulos
- [**Import en Python** - Código Facilito](https://www.youtube.com/watch?v=XvvT00r0DtA) - Diferentes formas de importar
- [**if __name__ == '__main__'** - MoureDev](https://www.youtube.com/watch?v=sVmRlT4kWsM) - Para qué sirve y cuándo usarlo
- [**Paquetes y Módulos** - Programación ATS](https://www.youtube.com/watch?v=fBpZmJqLJVk) - Organización de código

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 📖 Ejemplos Integrados del Proyecto

### Ejemplo 1: Cargar datos CSV

```python
import csv
import sys

def load_data(filename):
    """Carga datos del CSV"""
    mileages = []
    prices = []
    
    try:
        # Abrir archivo en modo lectura
        with open(filename, 'r') as f:
            # Crear lector CSV con diccionarios
            reader = csv.DictReader(f)
            
            # Iterar sobre cada fila
            for row in reader:
                # row es un diccionario: {'km': '240000', 'price': '3650'}
                # Convertir string a float y añadir a lista
                mileages.append(float(row['km']))
                prices.append(float(row['price']))
        
        # Validar que hay datos
        if len(mileages) == 0:
            raise ValueError("El archivo está vacío")
        
        return mileages, prices
    
    except FileNotFoundError:
        print(f"Error: No se encuentra el archivo '{filename}'")
        sys.exit(1)
    except (ValueError, KeyError) as e:
        print(f"Error al leer datos: {e}")
        sys.exit(1)

# Uso
mileages, prices = load_data('data.csv')
print(f"Cargados {len(mileages)} datos")
```

### Ejemplo 2: Normalización de datos

```python
def normalize_data(data):
    """
    Normaliza datos usando z-score:
    normalized = (x - media) / desviación_estándar
    """
    # Calcular media
    mean = sum(data) / len(data)
    
    # Calcular varianza
    variance = sum((x - mean) ** 2 for x in data) / len(data)
    
    # Calcular desviación estándar (raíz de varianza)
    std = variance ** 0.5
    
    # Evitar división por cero
    if std == 0:
        std = 1
    
    # Normalizar cada valor
    normalized = [(x - mean) / std for x in data]
    
    return normalized, mean, std

# Ejemplo de uso
data = [1, 2, 3, 4, 5]
norm_data, mean, std = normalize_data(data)
print(f"Media: {mean}")           # 3.0
print(f"Desv. std: {std}")        # 1.41...
print(f"Normalizados: {norm_data}")  # Valores cercanos a 0
```

### Ejemplo 3: Gradiente descendente

```python
def train_model(mileages, prices, learning_rate=0.1, iterations=1000):
    """Entrena usando gradiente descendente"""
    
    # Inicializar parámetros
    m = len(mileages)  # Número de muestras
    theta0 = 0.0
    theta1 = 0.0
    
    # Iterar número especificado de veces
    for iteration in range(iterations):
        # Inicializar sumas
        sum_errors_theta0 = 0.0
        sum_errors_theta1 = 0.0
        
        # Para cada muestra
        for i in range(m):
            # Calcular predicción
            estimated = theta0 + (theta1 * mileages[i])
            
            # Calcular error
            error = estimated - prices[i]
            
            # Acumular para gradientes
            sum_errors_theta0 += error
            sum_errors_theta1 += error * mileages[i]
        
        # Calcular gradientes
        gradient_theta0 = sum_errors_theta0 / m
        gradient_theta1 = sum_errors_theta1 / m
        
        # Actualizar parámetros (descenso)
        theta0 -= learning_rate * gradient_theta0
        theta1 -= learning_rate * gradient_theta1
        
        # Mostrar progreso cada 100 iteraciones
        if (iteration + 1) % 100 == 0:
            # Calcular error medio cuadrático
            mse = sum((theta0 + theta1 * mileages[i] - prices[i]) ** 2 
                     for i in range(m)) / m
            print(f"Iteración {iteration + 1}: MSE = {mse:.6f}")
    
    return theta0, theta1
```

### Ejemplo 4: Guardar y cargar parámetros

```python
def save_thetas(theta0, theta1, filename='thetas.txt'):
    """Guarda parámetros en archivo"""
    try:
        with open(filename, 'w') as f:
            # Escribir cada theta en una línea
            f.write(f"{theta0}\n")
            f.write(f"{theta1}\n")
        print(f"Parámetros guardados en '{filename}'")
    except IOError as e:
        print(f"Error al guardar: {e}")
        sys.exit(1)

def load_thetas(filename='thetas.txt'):
    """Carga parámetros desde archivo"""
    if not os.path.exists(filename):
        return 0.0, 0.0  # Valores por defecto
    
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
            # Leer primera línea, quitar espacios/saltos, convertir a float
            theta0 = float(lines[0].strip())
            theta1 = float(lines[1].strip())
            return theta0, theta1
    except (IOError, ValueError, IndexError) as e:
        print(f"Error al leer: {e}")
        return 0.0, 0.0
```

### Ejemplo 5: Visualización con matplotlib

```python
import matplotlib.pyplot as plt

def plot_regression(mileages, prices, theta0, theta1):
    """Crea gráfico de regresión"""
    
    # Crear figura de tamaño 12x7 pulgadas
    plt.figure(figsize=(12, 7))
    
    # Puntos de datos originales (azul)
    plt.scatter(
        mileages,           # Eje X
        prices,             # Eje Y
        color='blue',       # Color azul
        alpha=0.6,          # 60% opaco
        s=50,               # Tamaño 50
        label='Datos reales'  # Para leyenda
    )
    
    # Línea de regresión (roja)
    min_km = min(mileages)
    max_km = max(mileages)
    
    # Calcular puntos de la línea
    x_line = [min_km, max_km]
    y_line = [theta0 + theta1 * min_km, theta0 + theta1 * max_km]
    
    # Dibujar línea
    plt.plot(
        x_line,
        y_line,
        color='red',
        linewidth=2,
        label=f'Regresión (θ₀={theta0:.2f}, θ₁={theta1:.6f})'
    )
    
    # Configurar gráfico
    plt.xlabel('Kilometraje (km)', fontsize=12, fontweight='bold')
    plt.ylabel('Precio (€)', fontsize=12, fontweight='bold')
    plt.title('Regresión Lineal', fontsize=14, fontweight='bold')
    plt.legend(loc='upper right')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    
    # Mostrar
    plt.show()
```

---

## 🎯 Conceptos Clave del Proyecto

### 1. Tipos de datos y conversiones

```python
# String a Float
texto = "123.45"
numero = float(texto)  # 123.45

# String a Int
texto = "123"
entero = int(texto)  # 123

# Float a String con formato
numero = 1234.5678
texto = f"{numero:.2f}"  # "1234.57"
```

### 2. Valores booleanos

```python
True   # Verdadero
False  # Falso

# Comparaciones devuelven booleanos
resultado = (5 > 3)  # True
existe = os.path.exists('archivo.txt')  # True o False
```

### 3. None (valor nulo)

```python
# Representa ausencia de valor
valor = None

if valor is None:
    print("No hay valor")
```

### 4. Indentación (espacios)

Python usa **indentación** (espacios) para definir bloques de código:

```python
# Correcto
if x > 0:
    print("Positivo")
    print("Mayor que cero")

# Incorrecto (error de indentación)
if x > 0:
print("Positivo")  # ERROR: falta indentación
```

**Regla:** Usa 4 espacios por nivel de indentación.

### 5. Nomenclatura

```python
# Variables y funciones: snake_case (minúsculas con guiones bajos)
learning_rate = 0.1
def calculate_error():
    pass

# Constantes: MAYÚSCULAS
MAX_ITERATIONS = 1000

# Clases: PascalCase (cada palabra mayúscula)
class LinearRegression:
    pass
```

---

## 🔍 Debugging y Testing

### Print para debug

```python
# Ver valor de variables
print(f"theta0 = {theta0}")
print(f"theta1 = {theta1}")
print(f"mileages = {mileages}")

# Ver tipo de dato
print(f"Tipo: {type(variable)}")

# Ver longitud
print(f"Longitud: {len(lista)}")
```

### Verificar condiciones

```python
# Usar assert para verificaciones
assert len(mileages) > 0, "La lista no puede estar vacía"
assert theta0 != 0 or theta1 != 0, "Los parámetros deben ser diferentes de 0"
```

---

## 📚 Resumen de Conceptos por Archivo

### `train.py`
- **csv.DictReader**: Leer CSV como diccionarios
- **Listas y append**: Almacenar datos
- **Funciones matemáticas**: Media, varianza, desviación estándar
- **Comprensiones de lista**: Normalización eficiente
- **Bucles for anidados**: Gradiente descendente
- **Manejo de archivos**: Guardar thetas

### `predict.py`
- **os.path.exists**: Verificar si existe archivo
- **input()**: Leer del usuario
- **Manejo de errores**: try-except para validación
- **Conversión de tipos**: str → float
- **Formato de salida**: f-strings con decimales

### `precision.py`
- **Cálculo de métricas**: R², MSE, RMSE, MAE
- **Comprensiones complejas**: Suma de cuadrados
- **Formato de números**: Separadores de miles, decimales
- **Condicionales**: Interpretación de resultados
- **Listas con índices**: Comparar predicciones vs reales

### `visualize.py`
- **matplotlib**: Toda la librería de gráficos
- **plt.figure**: Crear figura
- **plt.scatter**: Gráfico de dispersión
- **plt.plot**: Líneas
- **plt.xlabel/ylabel/title**: Etiquetas
- **plt.legend**: Leyenda
- **plt.show**: Mostrar gráfico

### `test_project.py`
- **os.system**: Ejecutar comandos del sistema
- **Funciones de organización**: print_header
- **Validaciones**: Verificar archivos existen
- **Tests automatizados**: Verificar comportamiento

---

## 💡 Consejos Finales

### 1. Leer mensajes de error

```python
Traceback (most recent call last):
  File "train.py", line 45, in <module>
    mileages.append(float(row['km']))
ValueError: could not convert string to float: 'abc'
```

**Cómo leer:**
- Última línea: Tipo de error (ValueError)
- Línea anterior: Qué línea de código falló
- Mensaje: Descripción del problema

### 2. Usar help() y dir()

```python
# Ver documentación
help(csv.DictReader)

# Ver qué métodos tiene un objeto
dir(lista)
```

### 3. REPL para experimentar

```bash
$ python3
>>> x = [1, 2, 3]
>>> sum(x)
6
>>> x.append(4)
>>> x
[1, 2, 3, 4]
```

### 4. Comentar código mientras aprendes

```python
# Añade comentarios explicando cada paso
mileages = []  # Lista vacía para almacenar kilometrajes
for row in reader:  # Para cada fila del CSV
    km = float(row['km'])  # Convertir a número decimal
    mileages.append(km)  # Añadir a la lista
```

---

## 🎓 Conclusión

Este documento cubre todos los conceptos de Python utilizados en el proyecto **ft_linear_regression**. Con esta guía, deberías poder:

✅ Entender cada línea de código del proyecto  
✅ Modificar y experimentar con el código  
✅ Crear tus propios scripts similares  
✅ Comprender mensajes de error y solucionarlos  

**Recuerda:** La mejor forma de aprender es **practicando**. Ejecuta el código, modifícalo, rómpelo y arréglalo. ¡Así se aprende de verdad!

---

## 🎥 Recursos Adicionales Recomendados

### Canales de YouTube en español especializados:

#### Python General
- [**Píldoras Informáticas**](https://www.youtube.com/@pildorasinformaticas) - Cursos estructurados y completos
- [**MoureDev by Brais Moure**](https://www.youtube.com/@mouredev) - Tutoriales modernos y actualizados
- [**Código Facilito**](https://www.youtube.com/@codigofacilito) - Explicaciones claras y prácticas
- [**Programación ATS**](https://www.youtube.com/@ProgramacionATS) - Conceptos específicos bien explicados

#### Machine Learning y Datos
- [**DotCSV**](https://www.youtube.com/@DotCSV) - Explicaciones visuales de ML y IA
- [**Ringa Tech**](https://www.youtube.com/@RingaTech) - Data Science y Machine Learning en español
- [**QuantumFracture**](https://www.youtube.com/@QuantumFracture) - Matemáticas y ciencia aplicada

#### Recursos Complementarios
- [**Documentación oficial de Python**](https://docs.python.org/es/3/) - Referencia completa en español
- [**Real Python en español**](https://realpython.com/) - Tutoriales avanzados (algunos traducidos)
- [**Python.org Tutorial**](https://docs.python.org/es/3/tutorial/) - Tutorial oficial

### Ejercicios prácticos para reforzar:

1. **Modificar los parámetros de entrenamiento** - Cambia learning_rate e iterations en train.py
2. **Añadir validación de datos** - Verifica rangos válidos de kilometraje
3. **Mejorar la visualización** - Añade más gráficos en visualize.py
4. **Crear nuevas métricas** - Implementa MAPE o R² ajustado
5. **Hacer el código más robusto** - Añade más manejo de errores

---

**Autor:** sternero 42 Málaga  
**Fecha:** Enero 2026  
**Python Version:** 3.x
