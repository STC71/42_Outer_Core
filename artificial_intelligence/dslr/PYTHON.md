# PYTHON.md - Guía Completa de Python para DSLR

Este documento explica de forma clara y detallada todos los conceptos, librerías y funciones de Python utilizadas en el proyecto **DSLR** (Data Science × Logistic Regression), para que cualquier persona sin conocimientos previos pueda entenderlo completamente.

✨ **Incluye:**
- 🐍 Explicaciones detalladas de conceptos de Python
- 📚 Librerías utilizadas (csv, sys, pickle, matplotlib, random)
- 💡 Ejemplos prácticos del proyecto Hogwarts
- 🎥 Videos educativos en español (al final de cada sección)
- 🔍 Código comentado paso a paso

**Proyecto:** Clasificación multiclase de estudiantes de Hogwarts usando Regresión Logística One-vs-All

---

## 🎥 Recursos Generales

Antes de empezar, aquí tienes algunos cursos completos de Python en español:

- [**Python desde Cero - Curso Completo** - Píldoras Informáticas](https://www.youtube.com/playlist?list=PLU8oAlHdN5BlvPxziopYZRd55pdqFwkeS) - El curso más completo en español
- [**Curso Python para Principiantes** - MoureDev](https://www.youtube.com/watch?v=Kp4Mvapo5kc) - 7 horas de Python desde cero
- [**Python 3 Tutorial Completo** - Código Facilito](https://www.youtube.com/playlist?list=PLagErt3C7wnmNRv1tAv0qbj6m3hDhh1c4) - Curso estructurado
- [**Machine Learning con Python** - DotCSV](https://www.youtube.com/playlist?list=PL-Ogd76BhmcB9OjPucsnc2-piEE96jJDQ) - ML aplicado

---

## 📚 Tabla de Contenidos

1. [Conceptos Básicos de Python](#1-conceptos-básicos-de-python) 🎥
2. [Librerías Utilizadas](#2-librerías-utilizadas) 🎥
3. [Estructuras de Datos](#3-estructuras-de-datos) 🎥
4. [Funciones Matemáticas Personalizadas](#4-funciones-matemáticas-personalizadas) 🎥
5. [Manejo de Archivos CSV](#5-manejo-de-archivos-csv) 🎥
6. [Serialización con Pickle](#6-serialización-con-pickle) 🎥
7. [Visualización con Matplotlib](#7-visualización-con-matplotlib) 🎥
8. [Manejo de Errores](#8-manejo-de-errores) 🎥
9. [Programación Funcional](#9-programación-funcional) 🎥
10. [One-vs-All: Arquitectura del Código](#10-one-vs-all-arquitectura-del-código) 🎥
11. [Optimización y Buenas Prácticas](#11-optimización-y-buenas-prácticas) 🎥

*🎥 Cada sección incluye enlaces a videos educativos en español*

---

## 1. Conceptos Básicos de Python

### 1.1. Shebang y Ejecución

```python
#!/usr/bin/env python3
```

**¿Qué es?** Indica al sistema que ejecute este archivo con Python 3.

**Uso práctico:**
```bash
# Sin shebang:
python3 logreg_train.py dataset_train.csv

# Con shebang y permisos (chmod +x):
./logreg_train.py dataset_train.csv
```

### 1.2. Docstrings

```python
"""
DSLR - logreg_train.py
Entrenar un clasificador de regresión logística multiclase usando One-vs-All.

Este archivo implementa:
- Lectura y preprocesamiento de datos
- Normalización Z-score
- Gradient Descent por lotes
- Serialización de parámetros
"""
```

**¿Para qué sirve?**
- Documenta el propósito del archivo/función
- Accesible con `help(función)` o `función.__doc__`
- Útil para otros desarrolladores (y para ti en el futuro)

### 1.3. Importaciones

```python
import sys      # Argumentos de línea de comandos, salida del programa
import csv      # Leer/escribir archivos CSV
import pickle   # Serializar objetos Python (guardar modelos)
import random   # Números aleatorios (shuffle en SGD)
```

**Orden recomendado:**
1. Librerías estándar de Python (`sys`, `csv`, etc.)
2. Librerías de terceros permitidas (`matplotlib`)
3. Módulos propios del proyecto

### 1.4. Variables y Tipos de Datos

```python
# Tipos básicos
houses = ["Gryffindor", "Hufflepuff", "Ravenclaw", "Slytherin"]  # Lista
theta = [0.0, 0.0, 0.0]                                          # Lista de floats
student = {"name": "Harry", "house": "Gryffindor"}               # Diccionario

# Tipos numéricos
learning_rate = 0.1    # Float
num_iterations = 1000  # Integer
accuracy = 0.99        # Float

# Booleanos
verbose = True
converged = False
```

### 🎥 Aprende más
- [**Variables en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=Kp4Mvapo5kc&t=1200s)
- [**Tipos de Datos** - MoureDev](https://www.youtube.com/watch?v=Kp4Mvapo5kc&t=2400s)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 2. Librerías Utilizadas

### 2.1. `csv` - Manejo de archivos CSV

**¿Qué es CSV?** Comma-Separated Values - formato de archivo donde:
- Cada línea es una fila
- Columnas separadas por comas

**Ejemplo de dataset_train.csv:**
```csv
Index,Hogwarts House,Herbology,Defense Against the Dark Arts,Divination
0,Ravenclaw,3.0,7.5,8.0
1,Slytherin,5.5,9.0,6.5
2,Gryffindor,8.5,5.0,4.0
```

#### Leer archivos CSV

```python
import csv

def read_csv(filename):
    """Leer archivo CSV y devolver datos en diccionario"""
    try:
        with open(filename, 'r') as f:
            reader = csv.reader(f)
            headers = next(reader)  # Primera línea = encabezados
            
            # Inicializar diccionario con listas vacías
            data = {header: [] for header in headers}
            
            # Leer cada fila
            for row in reader:
                for i, value in enumerate(row):
                    if i < len(headers):
                        data[headers[i]].append(value)
        
        return headers, data
    
    except FileNotFoundError:
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)
```

**Explicación paso a paso:**

1. **`with open(filename, 'r') as f:`**
   - Abre el archivo en modo lectura ('r')
   - `with` asegura que se cierre automáticamente

2. **`reader = csv.reader(f)`**
   - Crea objeto lector de CSV
   - Maneja automáticamente las comas y comillas

3. **`headers = next(reader)`**
   - `next()` obtiene la primera línea
   - Contiene los nombres de las columnas

4. **`data = {header: [] for header in headers}`**
   - Comprensión de diccionario
   - Crea estructura: `{"Index": [], "House": [], ...}`

5. **`for row in reader:`**
   - Itera sobre cada fila restante
   - `row` es una lista: `['0', 'Ravenclaw', '3.0', ...]`

#### Escribir archivos CSV

```python
def write_csv(filename, headers, data):
    """Escribir datos a archivo CSV"""
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)  # Escribir encabezados
        
        # Escribir filas
        for i in range(len(data[headers[0]])):
            row = [data[header][i] for header in headers]
            writer.writerow(row)
```

**Ejemplo de uso (houses.csv):**
```python
# Crear archivo de predicciones
headers = ['Index', 'Hogwarts House']
data = {
    'Index': ['0', '1', '2'],
    'Hogwarts House': ['Gryffindor', 'Slytherin', 'Ravenclaw']
}
write_csv('houses.csv', headers, data)
```

### 2.2. `sys` - Sistema y Argumentos

**Propósito:** Interactuar con el intérprete de Python y el sistema operativo.

#### sys.argv - Argumentos de línea de comandos

```python
import sys

# Ejecución: python3 logreg_train.py dataset_train.csv 0.1 1000

print(sys.argv)
# → ['logreg_train.py', 'dataset_train.csv', '0.1', '1000']

filename = sys.argv[1]         # 'dataset_train.csv'
learning_rate = float(sys.argv[2])  # 0.1
num_iterations = int(sys.argv[3])   # 1000
```

**Nota:** `sys.argv[0]` siempre es el nombre del script.

#### sys.exit() - Salir del programa

```python
if len(sys.argv) < 2:
    print("Uso: python3 script.py <archivo.csv>", file=sys.stderr)
    sys.exit(1)  # Salir con código de error

# Si todo va bien:
sys.exit(0)  # Salir con éxito
```

#### sys.stderr - Mensajes de error

```python
# Mensaje normal (stdout):
print("Entrenamiento completado")

# Mensaje de error (stderr):
print("Error: Archivo no encontrado", file=sys.stderr)
```

**Diferencia:**
- `stdout` (salida estándar): Información normal
- `stderr` (error estándar): Mensajes de error

### 2.3. `pickle` - Serialización de Objetos

**¿Qué es serialización?** Convertir objetos Python en bytes para guardarlos en disco.

**¿Por qué usar pickle?**
- Guardar modelos entrenados (parámetros θ)
- Preservar estructuras complejas (diccionarios, listas)
- Cargar rápidamente sin re-entrenar

#### Guardar objeto (serialización)

```python
import pickle

# Objeto a guardar: diccionario con parámetros del modelo
model_data = {
    'theta': {
        'Gryffindor': [0.2, -0.5, 0.8, ...],
        'Hufflepuff': [-0.1, 0.3, -0.2, ...],
        'Ravenclaw': [0.5, 0.1, 0.4, ...],
        'Slytherin': [-0.3, 0.7, -0.1, ...]
    },
    'features': ['Index', 'Arithmancy', 'Astronomy', ...],
    'means': [0.0, 42.3, 78.5, ...],
    'stds': [1.0, 28.6, 35.2, ...],
    'algorithm': 'batch_gradient_descent'
}

# Guardar en archivo
with open('weights.pkl', 'wb') as f:  # 'wb' = write binary
    pickle.dump(model_data, f)

print("Modelo guardado en weights.pkl")
```

#### Cargar objeto (deserialización)

```python
# Cargar modelo guardado
with open('weights.pkl', 'rb') as f:  # 'rb' = read binary
    model_data = pickle.load(f)

# Extraer componentes
theta_dict = model_data['theta']
means = model_data['means']
stds = model_data['stds']

print(f"Modelo cargado: {len(theta_dict)} clasificadores")
```

**Ventajas de pickle:**
- ✅ Simple de usar
- ✅ Preserva estructura exacta
- ✅ Rápido

**Desventajas:**
- ⚠️ Solo funciona con Python
- ⚠️ No legible por humanos (binario)
- ⚠️ Problemas de seguridad si cargas archivos no confiables

### 2.4. `random` - Números Aleatorios

**Uso en DSLR:** Mezclar datos en SGD y Mini-Batch GD

```python
import random

# Crear lista de índices
indices = list(range(400))  # [0, 1, 2, ..., 399]

# Mezclar aleatoriamente
random.shuffle(indices)
# → [247, 12, 389, 5, ...]  (orden aleatorio)

# Ahora procesar en orden aleatorio:
for idx in indices:
    x_i = X[idx]
    y_i = y[idx]
    # ... entrenar con este ejemplo
```

**¿Por qué mezclar?**
- Evita que el modelo aprenda patrones del orden de los datos
- Mejora convergencia en SGD
- Reduce sesgo en mini-batches

### 🎥 Aprende más
- [**Módulos en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=1RYI-zLZyRw)
- [**Archivos CSV en Python** - Código Facilito](https://www.youtube.com/watch?v=4cIjQYXpYD0)
- [**Pickle Tutorial** - Ringa Tech](https://www.youtube.com/watch?v=Pl4Hp8qwwes)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 3. Estructuras de Datos

### 3.1. Listas (Arrays)

**Definición:** Colección ordenada y mutable de elementos.

```python
# Lista de casas
houses = ["Gryffindor", "Hufflepuff", "Ravenclaw", "Slytherin"]

# Lista de parámetros θ
theta = [0.0, 0.5, -0.3, 0.8]

# Acceso por índice (empieza en 0)
print(houses[0])  # → "Gryffindor"
print(theta[2])   # → -0.3

# Modificar elementos
theta[0] = 1.2    # Ahora theta = [1.2, 0.5, -0.3, 0.8]

# Longitud
print(len(houses))  # → 4

# Agregar elementos
houses.append("Durmstrang")  # Añade al final

# Iterar
for house in houses:
    print(house)
```

#### Listas anidadas (Matrices)

```python
# Matriz de características (3 estudiantes × 4 características)
X = [
    [1.0, 0.5, -0.3, 0.8],   # Estudiante 0
    [1.0, -0.2, 0.9, 0.1],   # Estudiante 1
    [1.0, 0.7, 0.4, -0.5]    # Estudiante 2
]

# Acceso: X[fila][columna]
print(X[0][1])  # → 0.5  (estudiante 0, característica 1)

# Iterar por filas
for i in range(len(X)):
    for j in range(len(X[0])):
        print(f"X[{i}][{j}] = {X[i][j]}")
```

### 3.2. Diccionarios

**Definición:** Colección de pares clave-valor.

```python
# Diccionario simple
student = {
    'name': 'Harry Potter',
    'house': 'Gryffindor',
    'year': 5
}

# Acceso por clave
print(student['name'])  # → 'Harry Potter'

# Modificar
student['year'] = 6

# Agregar nueva clave
student['position'] = 'Seeker'

# Verificar si existe clave
if 'house' in student:
    print(f"Casa: {student['house']}")

# Iterar sobre claves
for key in student:
    print(f"{key}: {student[key]}")

# Iterar sobre pares clave-valor
for key, value in student.items():
    print(f"{key} = {value}")
```

#### Diccionarios anidados (Modelo One-vs-All)

```python
# Estructura de nuestro modelo
theta_dict = {
    'Gryffindor': [0.2, -0.5, 0.8, 0.1, ...],
    'Hufflepuff': [-0.1, 0.3, -0.2, 0.6, ...],
    'Ravenclaw': [0.5, 0.1, 0.4, -0.3, ...],
    'Slytherin': [-0.3, 0.7, -0.1, 0.2, ...]
}

# Acceso a parámetros de una casa
theta_gryffindor = theta_dict['Gryffindor']
print(f"θ₀ de Gryffindor: {theta_gryffindor[0]}")

# Iterar sobre todas las casas
for house, theta in theta_dict.items():
    print(f"{house}: {len(theta)} parámetros")
```

#### Diccionario de listas (Datos CSV)

```python
# Estructura tras leer dataset_train.csv
data = {
    'Index': ['0', '1', '2', '3', ...],
    'Hogwarts House': ['Ravenclaw', 'Slytherin', 'Gryffindor', ...],
    'Herbology': ['3.0', '5.5', '8.5', ...],
    'Astronomy': ['7.5', '9.0', '5.0', ...]
}

# Acceso a columna completa
herbology_scores = data['Herbology']

# Acceso a valor específico (fila i, columna 'Herbology')
score = data['Herbology'][i]
```

### 3.3. Tuplas

**Definición:** Colección ordenada e **inmutable** de elementos.

```python
# Tupla (no se puede modificar)
dimensions = (400, 13)  # (filas, columnas)
m, n = dimensions       # Desempaquetado

# Retornar múltiples valores
def normalize_features(X):
    X_norm = ...
    means = ...
    stds = ...
    return X_norm, means, stds  # Retorna tupla

# Recibir múltiples valores
X_normalized, mu, sigma = normalize_features(X)
```

### 3.4. Comprensiones (List Comprehensions)

**Definición:** Forma concisa de crear listas.

#### Básica

```python
# Forma tradicional
squares = []
for i in range(10):
    squares.append(i ** 2)

# Comprensión de lista
squares = [i ** 2 for i in range(10)]
# → [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```

#### Con condición

```python
# Solo números pares al cuadrado
even_squares = [i ** 2 for i in range(10) if i % 2 == 0]
# → [0, 4, 16, 36, 64]
```

#### Aplicaciones en DSLR

```python
# Inicializar parámetros a cero
theta = [0.0 for _ in range(n)]  # n ceros

# Filtrar valores no-NaN
valid_scores = [x for x in data['Herbology'] if x is not None]

# Convertir strings a floats
scores_float = [float(x) for x in data['Herbology'] if x != '']

# Calcular errores
errors = [h[i] - y[i] for i in range(m)]
```

#### Comprensión de diccionarios

```python
# Crear diccionario de listas vacías
data = {header: [] for header in headers}

# Convertir listas a diccionario
houses = ['Gryffindor', 'Hufflepuff', 'Ravenclaw', 'Slytherin']
theta_dict = {house: [0.0] * n for house in houses}
```

### 🎥 Aprende más
- [**Listas en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=A1gn2vK8F0Q)
- [**Diccionarios** - MoureDev](https://www.youtube.com/watch?v=Kp4Mvapo5kc&t=5400s)
- [**List Comprehensions** - Código Facilito](https://www.youtube.com/watch?v=DlgG0QdrqAU)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 4. Funciones Matemáticas Personalizadas

**Restricción del proyecto:** No se permite usar numpy para operaciones matemáticas básicas.

### 4.1. Función Sigmoide

```python
def sigmoid(z):
    """
    Función sigmoide: σ(z) = 1 / (1 + e^(-z))
    
    Args:
        z (float): Valor de entrada
    
    Returns:
        float: Probabilidad entre 0 y 1
    
    Ejemplos:
        sigmoid(0) → 0.5
        sigmoid(5) → 0.99
        sigmoid(-5) → 0.01
    """
    # Manejar overflow
    if z > 500:
        return 1.0
    elif z < -500:
        return 0.0
    
    # Aproximación de e
    e = 2.718281828459045
    
    try:
        return 1.0 / (1.0 + (e ** (-z)))
    except:
        return 0.5  # Fallback en caso de error numérico
```

**Explicación:**
- `z > 500`: e^(-500) es prácticamente 0, resultado ≈ 1
- `z < -500`: e^(500) es infinito, resultado ≈ 0
- `e ** (-z)`: Exponencial sin numpy

### 4.2. Logaritmo Natural Personalizado

```python
def log_custom(x):
    """
    Logaritmo natural usando serie de Taylor.
    ln(1 + u) ≈ u - u²/2 + u³/3 - u⁴/4 + ...
    
    Args:
        x (float): Valor positivo
    
    Returns:
        float: ln(x)
    """
    if x <= 0:
        return -1000.0  # Valor muy negativo (penalización)
    if x == 1:
        return 0.0
    
    # Para x cercano a 1, usar serie de Taylor
    if 0.5 < x < 2.0:
        u = x - 1
        result = u - (u**2)/2 + (u**3)/3 - (u**4)/4 + (u**5)/5
        return result
    
    # Para otros valores, usar recursión con cambio de base
    e = 2.718281828459045
    if x > 2.0:
        return log_custom(x / e) + 1.0
    else:
        return -log_custom(1.0 / x)
```

**¿Por qué necesitamos ln()?**
- Función de coste usa log: `J = -Σ[y·log(h) + (1-y)·log(1-h)]`
- Python tiene `math.log()` pero implementamos la nuestra como ejercicio

### 4.3. Operaciones con Listas (Vectores)

#### Producto punto (dot product)

```python
def dot_product(a, b):
    """
    Producto punto de dos vectores: a · b = Σ(aᵢ · bᵢ)
    
    Args:
        a (list): Vector de n elementos
        b (list): Vector de n elementos
    
    Returns:
        float: Resultado del producto punto
    
    Ejemplo:
        dot_product([1, 2, 3], [4, 5, 6]) → 1*4 + 2*5 + 3*6 = 32
    """
    if len(a) != len(b):
        raise ValueError("Los vectores deben tener la misma longitud")
    
    return sum(a[i] * b[i] for i in range(len(a)))
```

**Uso en el proyecto:**
```python
# Calcular z = θᵀx
z = dot_product(theta, x)
# Equivalente a: z = θ₀x₀ + θ₁x₁ + θ₂x₂ + ...
```

#### Operaciones estadísticas

```python
def calculate_mean(data):
    """Calcular media sin numpy"""
    if not data:
        return 0.0
    return sum(data) / len(data)


def calculate_std(data, mean):
    """Calcular desviación estándar sin numpy"""
    if not data:
        return 1.0
    
    variance = sum((x - mean) ** 2 for x in data) / len(data)
    return variance ** 0.5


def calculate_quartile(data, q):
    """
    Calcular cuartiles (q = 0.25, 0.50, 0.75)
    
    Args:
        data (list): Datos
        q (float): Cuantil (0.25 para Q1, 0.50 para mediana, etc.)
    
    Returns:
        float: Valor del cuartil
    """
    sorted_data = sorted(data)
    n = len(sorted_data)
    
    # Interpolación lineal
    index = q * (n - 1)
    lower = int(index)
    upper = min(lower + 1, n - 1)
    weight = index - lower
    
    return sorted_data[lower] * (1 - weight) + sorted_data[upper] * weight
```

### 🎥 Aprende más
- [**Funciones en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=Pl4Hp8qwwes)
- [**Matemáticas sin NumPy** - DotCSV](https://www.youtube.com/watch?v=w2RJ1D6kz-o)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 5. Manejo de Archivos CSV

### 5.1. Lectura Completa de CSV

```python
def read_csv_complete(filename):
    """
    Leer CSV y devolver estructura completa
    
    Returns:
        headers (list): Lista de nombres de columnas
        data (dict): Diccionario {columna: [valores]}
    """
    try:
        with open(filename, 'r') as f:
            reader = csv.reader(f)
            
            # Leer encabezados
            headers = next(reader)
            
            # Inicializar estructura de datos
            data = {header: [] for header in headers}
            
            # Leer todas las filas
            for row in reader:
                for i, value in enumerate(row):
                    if i < len(headers):
                        data[headers[i]].append(value)
        
        return headers, data
    
    except FileNotFoundError:
        print(f"Error: '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error leyendo CSV: {e}", file=sys.stderr)
        sys.exit(1)
```

### 5.2. Conversión de Tipos

```python
def parse_float(value):
    """
    Convertir string a float de forma segura
    
    Args:
        value (str): Valor a convertir
    
    Returns:
        float or None: Número o None si no es válido
    """
    try:
        return float(value)
    except (ValueError, TypeError):
        return None
```

**Uso:**
```python
# Leer datos
headers, data = read_csv_complete('dataset_train.csv')

# Convertir columna numérica
herbology_scores = []
for value in data['Herbology']:
    score = parse_float(value)
    if score is not None:
        herbology_scores.append(score)
```

### 5.3. Extracción de Características

```python
def extract_features(data, headers):
    """
    Extraer solo columnas numéricas (asignaturas)
    
    Args:
        data (dict): Datos del CSV
        headers (list): Todos los encabezados
    
    Returns:
        X (list): Matriz de características (m × n)
        feature_names (list): Nombres de características usadas
    """
    # Identificar columnas numéricas (excluir Index, House, nombres)
    non_numeric = ['Index', 'Hogwarts House', 'First Name', 'Last Name', 
                   'Birthday', 'Best Hand']
    
    feature_names = [h for h in headers if h not in non_numeric]
    
    # Número de ejemplos
    m = len(data[headers[0]])
    
    # Inicializar matriz X
    X = []
    for i in range(m):
        row = []
        for feature in feature_names:
            value = parse_float(data[feature][i])
            row.append(value)  # None si es NaN
        X.append(row)
    
    return X, feature_names
```

### 5.4. Escribir Predicciones

```python
def write_predictions(filename, indices, predictions):
    """
    Escribir archivo houses.csv con predicciones
    
    Args:
        filename (str): Nombre del archivo de salida
        indices (list): Índices de estudiantes
        predictions (list): Casas predichas
    """
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        
        # Escribir encabezados
        writer.writerow(['Index', 'Hogwarts House'])
        
        # Escribir predicciones
        for i, pred in zip(indices, predictions):
            writer.writerow([i, pred])
    
    print(f"Predicciones guardadas en {filename}")
```

### 🎥 Aprende más
- [**Archivos CSV en Python** - Código Facilito](https://www.youtube.com/watch?v=4cIjQYXpYD0)
- [**Manejo de Archivos** - Píldoras Informáticas](https://www.youtube.com/watch?v=4VdQmoh4vY0)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 6. Serialización con Pickle

### 6.1. Guardar Modelo Completo

```python
def save_model(filename, theta_dict, features, means, stds, algorithm='batch_gradient_descent'):
    """
    Guardar modelo entrenado en archivo pickle
    
    Args:
        filename (str): Nombre del archivo (ej: 'weights.pkl')
        theta_dict (dict): {casa: [parámetros]}
        features (list): Nombres de características
        means (list): Medias para normalización
        stds (list): Desviaciones estándar
        algorithm (str): Algoritmo usado
    """
    model_data = {
        'theta': theta_dict,
        'features': features,
        'means': means,
        'stds': stds,
        'algorithm': algorithm,
        'timestamp': '2026-01-30',  # Opcional: fecha de entrenamiento
        'accuracy': 0.99            # Opcional: precisión alcanzada
    }
    
    try:
        with open(filename, 'wb') as f:
            pickle.dump(model_data, f)
        print(f"Modelo guardado en: {filename}")
    except Exception as e:
        print(f"Error guardando modelo: {e}", file=sys.stderr)
        sys.exit(1)
```

**Ejemplo de uso:**
```python
# Después de entrenar
theta_dict = {
    'Gryffindor': [0.2, -0.5, 0.8, ...],
    'Hufflepuff': [-0.1, 0.3, -0.2, ...],
    'Ravenclaw': [0.5, 0.1, 0.4, ...],
    'Slytherin': [-0.3, 0.7, -0.1, ...]
}

save_model('weights.pkl', theta_dict, feature_names, means, stds)
```

### 6.2. Cargar Modelo

```python
def load_model(filename):
    """
    Cargar modelo entrenado desde archivo pickle
    
    Args:
        filename (str): Nombre del archivo pickle
    
    Returns:
        dict: Datos del modelo
    """
    try:
        with open(filename, 'rb') as f:
            model_data = pickle.load(f)
        
        print(f"Modelo cargado desde: {filename}")
        print(f"Algoritmo: {model_data.get('algorithm', 'desconocido')}")
        print(f"Casas: {list(model_data['theta'].keys())}")
        
        return model_data
    
    except FileNotFoundError:
        print(f"Error: '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error cargando modelo: {e}", file=sys.stderr)
        sys.exit(1)
```

**Uso en logreg_predict.py:**
```python
# Cargar modelo
model_data = load_model('weights.pkl')

# Extraer componentes
theta_dict = model_data['theta']
means = model_data['means']
stds = model_data['stds']
features = model_data['features']

# Usar para predicción
for x in X_test:
    prediction = predict_one_vs_all(x, theta_dict, houses)
    predictions.append(prediction)
```

### 6.3. Verificar Integridad del Modelo

```python
def validate_model(model_data):
    """
    Verificar que el modelo tiene todos los componentes necesarios
    
    Args:
        model_data (dict): Datos del modelo
    
    Returns:
        bool: True si el modelo es válido
    """
    required_keys = ['theta', 'features', 'means', 'stds']
    
    for key in required_keys:
        if key not in model_data:
            print(f"Error: Modelo no contiene '{key}'", file=sys.stderr)
            return False
    
    # Verificar que hay 4 casas
    if len(model_data['theta']) != 4:
        print("Error: Se esperan 4 casas en el modelo", file=sys.stderr)
        return False
    
    # Verificar dimensiones consistentes
    n_features = len(model_data['features'])
    n_means = len(model_data['means'])
    n_stds = len(model_data['stds'])
    
    if not (n_features == n_means == n_stds):
        print("Error: Dimensiones inconsistentes", file=sys.stderr)
        return False
    
    return True
```

### 🎥 Aprende más
- [**Pickle en Python** - Ringa Tech](https://www.youtube.com/watch?v=Pl4Hp8qwwes)
- [**Serialización de Objetos** - Código Facilito](https://www.youtube.com/watch?v=2Tw39kZIbhs)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 7. Visualización con Matplotlib

### 7.1. Configuración Básica

```python
import matplotlib.pyplot as plt

# Configurar estilo
plt.style.use('default')
plt.rcParams['figure.figsize'] = (12, 8)
plt.rcParams['font.size'] = 10
```

### 7.2. Histogramas (histogram.py)

```python
def plot_histogram(data, houses, features):
    """
    Crear histograma de distribución de notas por casa
    
    Args:
        data (dict): Datos del CSV
        houses (list): Lista de casas
        features (list): Nombres de asignaturas
    """
    # Colores por casa
    colors = {
        'Gryffindor': '#740001',
        'Hufflepuff': '#FFD700',
        'Ravenclaw': '#0E1A40',
        'Slytherin': '#1A472A'
    }
    
    # Crear subplots (6 filas × 2 columnas = 12 asignaturas)
    fig, axes = plt.subplots(6, 2, figsize=(15, 20))
    axes = axes.flatten()
    
    for idx, feature in enumerate(features):
        ax = axes[idx]
        
        # Para cada casa, obtener notas de esa asignatura
        for house in houses:
            # Filtrar estudiantes de esta casa
            house_indices = [i for i, h in enumerate(data['Hogwarts House']) 
                           if h == house]
            
            # Obtener notas
            scores = [parse_float(data[feature][i]) for i in house_indices 
                     if parse_float(data[feature][i]) is not None]
            
            # Plotear histograma
            ax.hist(scores, bins=20, alpha=0.5, 
                   label=house, color=colors[house])
        
        ax.set_title(feature)
        ax.set_xlabel('Nota')
        ax.set_ylabel('Frecuencia')
        ax.legend()
    
    plt.tight_layout()
    plt.savefig('histogram_analysis.png', dpi=100, bbox_inches='tight')
    plt.show()
```

**Componentes clave:**
- `plt.subplots()`: Crear múltiples gráficos
- `ax.hist()`: Crear histograma
- `alpha=0.5`: Transparencia (para superponer)
- `plt.tight_layout()`: Ajustar espaciado automáticamente
- `plt.savefig()`: Guardar imagen

### 7.3. Scatter Plot (scatter_plot.py)

```python
def plot_scatter(data, houses, feature1, feature2):
    """
    Crear scatter plot de dos características
    
    Args:
        data (dict): Datos
        houses (list): Casas
        feature1 (str): Primera característica (eje X)
        feature2 (str): Segunda característica (eje Y)
    """
    plt.figure(figsize=(10, 8))
    
    colors = {
        'Gryffindor': '#740001',
        'Hufflepuff': '#FFD700',
        'Ravenclaw': '#0E1A40',
        'Slytherin': '#1A472A'
    }
    
    for house in houses:
        # Filtrar datos de esta casa
        x_values = []
        y_values = []
        
        for i, h in enumerate(data['Hogwarts House']):
            if h == house:
                x = parse_float(data[feature1][i])
                y = parse_float(data[feature2][i])
                
                if x is not None and y is not None:
                    x_values.append(x)
                    y_values.append(y)
        
        # Plotear puntos
        plt.scatter(x_values, y_values, 
                   label=house, color=colors[house], 
                   alpha=0.6, s=50)
    
    plt.xlabel(feature1)
    plt.ylabel(feature2)
    plt.title(f'{feature1} vs {feature2}')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    plt.savefig(f'scatter_{feature1}_{feature2}.png', dpi=100, bbox_inches='tight')
    plt.show()
```

### 7.4. Pair Plot (pair_plot.py)

```python
def create_pair_plot(data, houses, features):
    """
    Crear matriz de scatter plots (todas vs todas)
    
    Similar a seaborn.pairplot() pero con matplotlib
    """
    n_features = len(features)
    
    fig, axes = plt.subplots(n_features, n_features, 
                             figsize=(20, 20))
    
    colors = {...}  # Colores por casa
    
    for i in range(n_features):
        for j in range(n_features):
            ax = axes[i, j]
            
            if i == j:
                # Diagonal: Histogramas
                for house in houses:
                    house_data = [...]  # Filtrar por casa
                    ax.hist(house_data, bins=15, alpha=0.5, 
                           color=colors[house])
            else:
                # Fuera de diagonal: Scatter plots
                for house in houses:
                    x_data = [...]  # Feature j
                    y_data = [...]  # Feature i
                    ax.scatter(x_data, y_data, alpha=0.4, 
                              color=colors[house], s=10)
            
            # Etiquetas solo en bordes
            if i == n_features - 1:
                ax.set_xlabel(features[j], fontsize=8)
            if j == 0:
                ax.set_ylabel(features[i], fontsize=8)
    
    plt.tight_layout()
    plt.savefig('pair_plot.png', dpi=100, bbox_inches='tight')
    plt.show()
```

### 7.5. Curva de Aprendizaje

```python
def plot_learning_curve(cost_history):
    """
    Plotear cómo disminuye el coste durante entrenamiento
    
    Args:
        cost_history (list): Lista de costes por iteración
    """
    plt.figure(figsize=(10, 6))
    
    plt.plot(cost_history, linewidth=2)
    plt.xlabel('Iteración')
    plt.ylabel('Coste J(θ)')
    plt.title('Curva de Aprendizaje - Convergencia del Modelo')
    plt.grid(True, alpha=0.3)
    
    # Marcar coste inicial y final
    plt.scatter([0, len(cost_history)-1], 
               [cost_history[0], cost_history[-1]], 
               color='red', s=100, zorder=5)
    
    plt.text(0, cost_history[0], f'Inicio: {cost_history[0]:.4f}', 
            verticalalignment='bottom')
    plt.text(len(cost_history)-1, cost_history[-1], 
            f'Final: {cost_history[-1]:.4f}', 
            verticalalignment='top')
    
    plt.savefig('learning_curve.png', dpi=100, bbox_inches='tight')
    plt.show()
```

### 🎥 Aprende más
- [**Matplotlib Tutorial** - Código Facilito](https://www.youtube.com/watch?v=9xJF1Qb_M6U)
- [**Visualización de Datos** - DotCSV](https://www.youtube.com/watch?v=kHmC6UPEo0I)
- [**Gráficas en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=Y0jKOfwn5MM)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 8. Manejo de Errores

### 8.1. Try-Except Básico

```python
def safe_float_conversion(value):
    """Convertir a float con manejo de errores"""
    try:
        return float(value)
    except ValueError:
        print(f"Advertencia: '{value}' no es un número válido")
        return None
    except TypeError:
        print("Advertencia: Tipo de dato inválido")
        return None
```

### 8.2. Validación de Argumentos

```python
def validate_arguments():
    """Validar argumentos de línea de comandos"""
    if len(sys.argv) < 2:
        print("Uso: python3 logreg_train.py <dataset.csv> [learning_rate] [iterations]", 
              file=sys.stderr)
        print("\nEjemplo: python3 logreg_train.py dataset_train.csv 0.1 1000", 
              file=sys.stderr)
        sys.exit(1)
    
    # Validar que el archivo existe
    filename = sys.argv[1]
    if not os.path.exists(filename):
        print(f"Error: Archivo '{filename}' no encontrado", file=sys.stderr)
        sys.exit(1)
    
    # Validar parámetros numéricos
    try:
        learning_rate = float(sys.argv[2]) if len(sys.argv) > 2 else 0.1
        if not (0.0 < learning_rate <= 1.0):
            raise ValueError("Learning rate debe estar entre 0 y 1")
    except ValueError as e:
        print(f"Error en learning_rate: {e}", file=sys.stderr)
        sys.exit(1)
    
    try:
        num_iterations = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
        if num_iterations <= 0:
            raise ValueError("Número de iteraciones debe ser positivo")
    except ValueError as e:
        print(f"Error en num_iterations: {e}", file=sys.stderr)
        sys.exit(1)
    
    return filename, learning_rate, num_iterations
```

### 8.3. Manejo de Valores Faltantes (NaN)

```python
def handle_missing_values(X):
    """
    Manejar valores NaN en matriz de características
    
    Estrategia: Reemplazar NaN con la media de la columna
    
    Args:
        X (list): Matriz con posibles valores None
    
    Returns:
        X_clean (list): Matriz sin valores None
    """
    m = len(X)
    n = len(X[0])
    
    # Calcular media por columna
    column_means = []
    for j in range(n):
        if j == 0:
            # Columna de bias: siempre 1.0
            column_means.append(1.0)
        else:
            # Calcular media de valores válidos
            valid_values = [X[i][j] for i in range(m) if X[i][j] is not None]
            mean = sum(valid_values) / len(valid_values) if valid_values else 0.0
            column_means.append(mean)
    
    # Reemplazar valores None
    X_clean = []
    for i in range(m):
        row = []
        for j in range(n):
            if X[i][j] is None:
                row.append(column_means[j])
            else:
                row.append(X[i][j])
        X_clean.append(row)
    
    return X_clean
```

### 8.4. Assertions (Comprobaciones)

```python
def train_classifier(X, y, theta, learning_rate, num_iterations):
    """
    Entrenar clasificador con validaciones
    """
    # Validar dimensiones
    m = len(X)
    n = len(X[0])
    
    assert len(y) == m, "X y y deben tener el mismo número de filas"
    assert len(theta) == n, "theta debe tener el mismo tamaño que las columnas de X"
    assert all(label in [0, 1] for label in y), "y debe contener solo 0 o 1"
    
    # Validar parámetros
    assert 0 < learning_rate <= 1, "Learning rate debe estar entre 0 y 1"
    assert num_iterations > 0, "Número de iteraciones debe ser positivo"
    
    # Entrenar...
    ...
```

### 🎥 Aprende más
- [**Manejo de Excepciones** - Píldoras Informáticas](https://www.youtube.com/watch?v=hPKcsf6pILY)
- [**Try-Except en Python** - MoureDev](https://www.youtube.com/watch?v=Kp4Mvapo5kc&t=7200s)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 9. Programación Funcional

### 9.1. Funciones Lambda

```python
# Lambda: Función anónima de una línea
square = lambda x: x ** 2
print(square(5))  # → 25

# Uso común: Ordenar listas
students = [
    {'name': 'Harry', 'score': 85},
    {'name': 'Hermione', 'score': 98},
    {'name': 'Ron', 'score': 72}
]

# Ordenar por nota (descendente)
students_sorted = sorted(students, key=lambda s: s['score'], reverse=True)
```

### 9.2. map(), filter(), reduce()

#### map() - Aplicar función a cada elemento

```python
# Convertir lista de strings a floats
scores_str = ['85.5', '92.0', '78.3']
scores_float = list(map(float, scores_str))
# → [85.5, 92.0, 78.3]

# Con lambda
scores_normalized = list(map(lambda x: x / 100, scores_float))
# → [0.855, 0.92, 0.783]
```

#### filter() - Filtrar elementos que cumplan condición

```python
# Filtrar solo notas aprobadas (>= 50)
all_scores = [45, 78, 92, 33, 88, 56]
passing_scores = list(filter(lambda x: x >= 50, all_scores))
# → [78, 92, 88, 56]

# Filtrar valores no-None
data_with_nans = [1.5, None, 2.3, None, 4.8]
valid_data = list(filter(lambda x: x is not None, data_with_nans))
# → [1.5, 2.3, 4.8]
```

#### reduce() - Reducir lista a un solo valor

```python
from functools import reduce

# Suma de todos los elementos
numbers = [1, 2, 3, 4, 5]
total = reduce(lambda a, b: a + b, numbers)
# → 15

# Encontrar máximo
max_value = reduce(lambda a, b: a if a > b else b, numbers)
# → 5
```

### 9.3. Uso en DSLR

```python
# Encontrar casa con mayor probabilidad
probabilities = {
    'Gryffindor': 0.92,
    'Hufflepuff': 0.15,
    'Ravenclaw': 0.28,
    'Slytherin': 0.05
}

predicted_house = max(probabilities, key=probabilities.get)
# → 'Gryffindor'

# O con lambda:
predicted_house = max(probabilities.items(), key=lambda x: x[1])[0]
# → 'Gryffindor'
```

### 🎥 Aprende más
- [**Funciones Lambda** - Código Facilito](https://www.youtube.com/watch?v=9hLBw12h8zw)
- [**Map, Filter, Reduce** - Píldoras Informáticas](https://www.youtube.com/watch?v=cKlnR-CB3tk)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 10. One-vs-All: Arquitectura del Código

### 10.1. Estructura del Entrenamiento

```python
def train_one_vs_all(X, y_dict, houses, learning_rate=0.1, 
                     num_iterations=1000, verbose=False):
    """
    Entrenar K clasificadores binarios (uno por cada casa)
    
    Args:
        X (list): Matriz de características (m × n)
        y_dict (dict): {casa: [etiquetas binarias]} para cada casa
        houses (list): ['Gryffindor', 'Hufflepuff', 'Ravenclaw', 'Slytherin']
        learning_rate (float): α
        num_iterations (int): Número de iteraciones
        verbose (bool): Imprimir progreso
    
    Returns:
        theta_dict (dict): {casa: [parámetros optimizados]}
    """
    n = len(X[0])  # Número de características
    theta_dict = {}
    
    print("=" * 80)
    print("ENTRENAMIENTO ONE-VS-ALL")
    print("=" * 80)
    
    # Entrenar un clasificador por cada casa
    for house in houses:
        print(f"\nEntrenando clasificador para '{house}' vs Todos...")
        
        # Obtener etiquetas binarias para esta casa
        y_binary = y_dict[house]
        
        # Inicializar parámetros
        theta = [0.0] * n
        
        # Entrenar con gradient descent
        theta_optimized, cost_history = gradient_descent_batch(
            X, y_binary, theta, learning_rate, num_iterations, verbose=verbose
        )
        
        # Guardar parámetros optimizados
        theta_dict[house] = theta_optimized
        
        print(f"Coste final: {cost_history[-1]:.6f}")
    
    print("\n" + "=" * 80)
    print("ENTRENAMIENTO COMPLETADO")
    print("=" * 80)
    
    return theta_dict
```

### 10.2. Crear Etiquetas Binarias

```python
def create_binary_labels(houses_list, target_house):
    """
    Crear etiquetas binarias para estrategia One-vs-All
    
    Args:
        houses_list (list): Lista de casas de todos los estudiantes
        target_house (str): Casa objetivo (ej: 'Gryffindor')
    
    Returns:
        y_binary (list): Lista de 0s y 1s
    
    Ejemplo:
        houses = ['Gryffindor', 'Slytherin', 'Gryffindor', 'Ravenclaw']
        create_binary_labels(houses, 'Gryffindor')
        → [1, 0, 1, 0]
    """
    return [1 if house == target_house else 0 for house in houses_list]


def prepare_ova_labels(data, houses):
    """
    Preparar diccionario de etiquetas binarias para todas las casas
    
    Args:
        data (dict): Datos del CSV
        houses (list): Lista de casas únicas
    
    Returns:
        y_dict (dict): {casa: [etiquetas binarias]}
    """
    houses_list = data['Hogwarts House']
    y_dict = {}
    
    for house in houses:
        y_dict[house] = create_binary_labels(houses_list, house)
    
    return y_dict
```

### 10.3. Predicción One-vs-All

```python
def predict_one_vs_all(x, theta_dict, houses):
    """
    Predecir casa para un estudiante usando One-vs-All
    
    Args:
        x (list): Vector de características del estudiante (n,)
        theta_dict (dict): {casa: [parámetros]}
        houses (list): Lista de casas
    
    Returns:
        str: Casa con mayor probabilidad
    
    Proceso:
        1. Para cada casa, calcular P(casa | x) = σ(θᵀx)
        2. Elegir casa con mayor probabilidad
    """
    probabilities = {}
    
    for house in houses:
        theta = theta_dict[house]
        
        # Calcular z = θᵀx
        z = sum(theta[j] * x[j] for j in range(len(theta)))
        
        # Calcular probabilidad
        probabilities[house] = sigmoid(z)
    
    # Retornar casa con mayor probabilidad
    predicted_house = max(probabilities, key=probabilities.get)
    
    return predicted_house
```

### 10.4. Pipeline Completo

```python
def main():
    """Pipeline completo de entrenamiento"""
    
    # 1. Validar argumentos
    filename, learning_rate, num_iterations = validate_arguments()
    
    # 2. Leer datos
    print("Leyendo datos...")
    headers, data = read_csv(filename)
    
    # 3. Extraer características
    print("Extrayendo características...")
    X_raw, feature_names = extract_features(data, headers)
    
    # 4. Manejar valores faltantes
    X_clean = handle_missing_values(X_raw)
    
    # 5. Normalizar
    print("Normalizando características...")
    X_norm, means, stds = normalize_features(X_clean)
    
    # 6. Preparar etiquetas One-vs-All
    houses = ['Gryffindor', 'Hufflepuff', 'Ravenclaw', 'Slytherin']
    y_dict = prepare_ova_labels(data, houses)
    
    # 7. Entrenar
    print(f"\nParámetros:")
    print(f"  Learning rate: {learning_rate}")
    print(f"  Iteraciones: {num_iterations}")
    print(f"  Ejemplos: {len(X_norm)}")
    print(f"  Características: {len(feature_names)}")
    
    theta_dict = train_one_vs_all(
        X_norm, y_dict, houses, learning_rate, num_iterations, verbose=True
    )
    
    # 8. Guardar modelo
    save_model('weights.pkl', theta_dict, feature_names, means, stds)
    
    print("\n¡Entrenamiento completo!")


if __name__ == '__main__':
    main()
```

### 🎥 Aprende más
- [**Arquitectura de Código en ML** - DotCSV](https://www.youtube.com/watch?v=MlK1VMfJMNw)
- [**Organización de Proyectos Python** - Código Facilito](https://www.youtube.com/watch?v=GMfMIKQnl2w)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 11. Optimización y Buenas Prácticas

### 11.1. Docstrings Completos

```python
def gradient_descent_batch(X, y, theta, learning_rate, num_iterations, verbose=False):
    """
    Batch Gradient Descent para regresión logística.
    
    Actualiza los parámetros usando todos los ejemplos en cada iteración.
    
    Args:
        X (list of list): Matriz de características (m × n).
            Cada fila es un ejemplo, cada columna una característica.
            Primera columna debe ser 1.0 (bias).
        y (list): Vector de etiquetas (m,). Valores 0 o 1.
        theta (list): Vector inicial de parámetros (n,).
        learning_rate (float): Tasa de aprendizaje α. Rango típico: 0.01-0.3.
        num_iterations (int): Número de iteraciones a ejecutar.
        verbose (bool, optional): Si True, imprime progreso cada 500 iteraciones.
            Por defecto False.
    
    Returns:
        tuple: (theta_optimizado, historial_costes)
            - theta_optimizado (list): Parámetros finales después del entrenamiento.
            - historial_costes (list): Lista de costes cada 100 iteraciones.
    
    Raises:
        ValueError: Si las dimensiones de X, y, theta son incompatibles.
        ValueError: Si learning_rate no está en (0, 1].
    
    Examples:
        >>> X = [[1, 0.5], [1, -0.3], [1, 0.8]]
        >>> y = [1, 0, 1]
        >>> theta = [0.0, 0.0]
        >>> theta_opt, costs = gradient_descent_batch(X, y, theta, 0.1, 1000)
        >>> print(f"Coste final: {costs[-1]:.4f}")
        Coste final: 0.3521
    
    Notes:
        - Implementa la ecuación: θⱼ := θⱼ - α * (1/m) * Σ[(h(xⁱ) - yⁱ) * xⁱⱼ]
        - Todos los parámetros se actualizan simultáneamente.
        - El coste debería disminuir en cada iteración si α es apropiado.
    
    See Also:
        - sigmoid(): Función de activación usada.
        - compute_cost(): Cálculo del coste J(θ).
    """
    # Implementación...
```

### 11.2. Type Hints (Python 3.5+)

```python
from typing import List, Dict, Tuple

def normalize_features(X: List[List[float]]) -> Tuple[List[List[float]], List[float], List[float]]:
    """
    Normalizar características usando Z-score.
    
    Args:
        X: Matriz de características
    
    Returns:
        Tupla de (X_normalizado, medias, desviaciones_estándar)
    """
    ...

def train_one_vs_all(
    X: List[List[float]], 
    y_dict: Dict[str, List[int]], 
    houses: List[str],
    learning_rate: float = 0.1,
    num_iterations: int = 1000
) -> Dict[str, List[float]]:
    """
    Entrenar clasificadores One-vs-All.
    """
    ...
```

### 11.3. Constantes

```python
# Constantes al inicio del archivo
DEFAULT_LEARNING_RATE = 0.1
DEFAULT_ITERATIONS = 1000
MAX_LEARNING_RATE = 1.0
MIN_LEARNING_RATE = 0.001

EPSILON = 1e-15  # Para evitar log(0)
MAX_Z = 500      # Para evitar overflow en sigmoid

HOUSES = ['Gryffindor', 'Hufflepuff', 'Ravenclaw', 'Slytherin']

# Características a excluir
NON_NUMERIC_FEATURES = [
    'Index', 'Hogwarts House', 'First Name', 
    'Last Name', 'Birthday', 'Best Hand'
]
```

### 11.4. Logging vs Print

```python
# Mal: usar print para todo
print("Entrenando...")
print("Error!")

# Mejor: distinguir tipos de mensajes
def print_info(message):
    print(f"[INFO] {message}")

def print_error(message):
    print(f"[ERROR] {message}", file=sys.stderr)

def print_progress(iteration, total, cost):
    print(f"[PROGRESS] Iteración {iteration}/{total}, Coste: {cost:.6f}")

# Uso
print_info("Iniciando entrenamiento...")
print_progress(500, 1000, 0.3521)
print_error("Archivo no encontrado")
```

### 11.5. Verificaciones de Sanidad

```python
def sanity_checks(X, y, theta):
    """Verificar que los datos son válidos antes de entrenar"""
    
    # Verificar dimensiones
    m = len(X)
    n = len(X[0]) if X else 0
    
    assert m > 0, "X no puede estar vacío"
    assert len(y) == m, f"X tiene {m} filas pero y tiene {len(y)}"
    assert len(theta) == n, f"theta tiene {len(theta)} elementos pero X tiene {n} columnas"
    
    # Verificar que y solo tiene 0 y 1
    unique_y = set(y)
    assert unique_y.issubset({0, 1}), f"y debe contener solo 0 y 1, encontrado: {unique_y}"
    
    # Verificar que no hay NaN en X
    for i in range(m):
        for j in range(n):
            assert X[i][j] is not None, f"X[{i}][{j}] es None/NaN"
    
    # Verificar primera columna es bias (todo 1s)
    first_column = [X[i][0] for i in range(m)]
    assert all(x == 1.0 for x in first_column), "Primera columna debe ser bias (1.0)"
    
    print("[SANITY CHECK] ✓ Todos los checks pasaron")
```

### 🎥 Aprende más
- [**Buenas Prácticas en Python** - Píldoras Informáticas](https://www.youtube.com/watch?v=pl1b3i1S5BM)
- [**Clean Code en Python** - MoureDev](https://www.youtube.com/watch?v=gR9BE8r8x8k)
- [**Type Hints** - Código Facilito](https://www.youtube.com/watch?v=QmzBH6-jR0I)

[⬆️ Volver a la Tabla de Contenidos](#📚-tabla-de-contenidos)

---

## 📚 Referencias y Recursos Adicionales

### Documentación Oficial

- [**Python 3 Documentation**](https://docs.python.org/3/) - Documentación completa de Python
- [**CSV Module**](https://docs.python.org/3/library/csv.html) - Documentación del módulo csv
- [**Pickle Module**](https://docs.python.org/3/library/pickle.html) - Serialización de objetos
- [**Matplotlib Documentation**](https://matplotlib.org/stable/contents.html) - Guía completa de matplotlib

### Cursos Completos en Español

**Python Básico:**
- [Curso Python desde Cero - Píldoras Informáticas](https://www.youtube.com/playlist?list=PLU8oAlHdN5BlvPxziopYZRd55pdqFwkeS)
- [Python para Principiantes - MoureDev](https://www.youtube.com/watch?v=Kp4Mvapo5kc)
- [Curso Python Completo - Código Facilito](https://www.youtube.com/playlist?list=PLagErt3C7wnmNRv1tAv0qbj6m3hDhh1c4)

**Machine Learning:**
- [Machine Learning desde Cero - DotCSV](https://www.youtube.com/playlist?list=PL-Ogd76BhmcB9OjPucsnc2-piEE96jJDQ)
- [Curso ML con Python - AprendeIA](https://www.youtube.com/playlist?list=PLJ4Y3R-e6TqvqG3Bpbj8N3P0j3WBN-v1R)

### Libros Recomendados

1. **"Automate the Boring Stuff with Python"** - Al Sweigart
   - Perfecto para principiantes
   - Disponible gratis: https://automatetheboringstuff.com/

2. **"Python Crash Course"** - Eric Matthes
   - Introducción práctica a Python
   - Proyecto de Machine Learning incluido

3. **"Fluent Python"** - Luciano Ramalho
   - Para nivel intermedio/avanzado
   - Profundiza en características de Python

### Herramientas Útiles

- [**Python Tutor**](https://pythontutor.com/) - Visualizar ejecución de código paso a paso
- [**Repl.it**](https://replit.com/) - Entorno Python online
- [**Real Python**](https://realpython.com/) - Tutoriales y artículos de calidad

### Comunidades

- [**r/learnpython**](https://www.reddit.com/r/learnpython/) - Subreddit para aprender Python
- [**Stack Overflow en español**](https://es.stackoverflow.com/) - Preguntas y respuestas
- [**Python Discord**](https://discord.gg/python) - Comunidad activa

---

<div align="center">

## 🎓 ¡Felicidades!

Has completado la guía completa de Python para **DSLR - Logistic Regression**.

Ahora dominas:
- ✅ Lectura/escritura de archivos CSV
- ✅ Serialización con pickle
- ✅ Estructuras de datos (listas, diccionarios)
- ✅ Funciones matemáticas sin numpy
- ✅ Visualización con matplotlib
- ✅ Manejo de errores y validaciones
- ✅ Arquitectura One-vs-All completa
- ✅ Buenas prácticas de código Python

**Proyecto completado:** Clasificador de casas de Hogwarts con 99.0% de precisión 🏰✨

---

[![42 School](https://img.shields.io/badge/42-School-000000?style=flat-square&logo=42&logoColor=white)](https://www.42malaga.com/)

*Documentación creada para el proyecto DSLR de 42 School*

</div>
