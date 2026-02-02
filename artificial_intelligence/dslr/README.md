# 🧙‍♂️ DSLR - Data Science × Logistic Regression

> **Clasificación multiclase con regresión logística**  
> Harry Potter y el Científico de Datos - Clasifica estudiantes en las casas de Hogwarts usando machine learning desde cero.

---

<div align="center">

*"A computer program is said to learn from experience **E** with respect to some class of tasks **T** and performance measure **P**, <br>
if its performance at tasks in **T**, as measured by **P**, improves with experience **E**."*

*"Se dice que un programa informático aprende de la experiencia **E** con respecto a cierta clase de tareas **T** y una medida de rendimiento **P**, 
si su rendimiento en las tareas de **T**, medido por **P**, mejora con la experiencia **E**."*

— **Tom M. Mitchell**

Profesor e investigador en aprendizaje automático en la Universidad Carnegie Mellon (CMU); autor del libro 'Machine Learning'.

</div>

---

## 📋 Descripción

Este proyecto implementa un **clasificador de regresión logística multiclase** desde cero, sin usar librerías de alto nivel como `sklearn`. Utiliza la estrategia **One-vs-All (OvA)** para clasificar estudiantes de Hogwarts en sus casas.

🎯 **Objetivo:** Entrenar un modelo que pueda predecir la casa de un estudiante basándose en sus calificaciones en diferentes asignaturas mágicas.

**Resultado alcanzado: ✅ 99.0% de precisión** (Requerido: ≥98%)


## 🎯 Características

<table>
<tr>
<td width="50%">

### ✅ Parte Obligatoria

| Componente | Descripción |
|------------|-------------|
| 📊 **describe.py** | Estadísticas sin funciones built-in |
| 📈 **histogram.py** | Distribución homogénea de cursos |
| 🔍 **scatter_plot.py** | Características similares |
| 🎨 **pair_plot.py** | Matriz de correlación completa |
| 🧠 **logreg_train.py** | Entrenamiento Batch Gradient Descent |
| 🔮 **logreg_predict.py** | Predicción de casas |

</td>
<td width="50%">

### ⭐ Parte Bonus

| Componente | Descripción |
|------------|-------------|
| 📐 **Estadísticas extra** | Moda, rango, IQR, skewness |
| ⚡ **SGD** | Gradient Descent Estocástico |
| 🎯 **Mini-Batch GD** | Equilibrio velocidad/estabilidad |
| ✓ **cross_validate.py** | Validación cruzada K-fold |
| 🛠️ **preprocessing** | Limpieza y normalización avanzada |

</td>
</tr>
</table>

## 📊 Dataset

Los archivos CSV contienen datos de estudiantes de Hogwarts:

| Archivo | Descripción | Dimensiones |
|---------|-------------|-------------|
| **dataset_train.csv** | Datos de entrenamiento | 400 estudiantes × 13 asignaturas |
| **dataset_test.csv** | Datos de prueba | 400 estudiantes × 13 asignaturas |
| **dataset_truth.csv** | Casas reales (para validación) | 400 etiquetas |

📌 **Características:** 13 asignaturas de Hogwarts (Aritmancia, Astronomía, Herbología, etc.)  
🏠 **Clases:** 4 casas (Gryffindor, Hufflepuff, Ravenclaw, Slytherin)

## 🚀 Instalación

### 📦 Requisitos básicos
```bash
Python 3.x  # Ya instalado en sistemas 42 
```

### 🎨 Para visualizaciones
```bash
pip install matplotlib
# o usar el Makefile
make install
```

## 💻 Uso

### 📊 1. Análisis exploratorio de datos

```bash
python3 describe.py dataset_train.csv
# o usando Makefile
make describe
```

**¿Qué hace?**
- ✓ Calcula estadísticas descriptivas sin pandas
- ✓ Count, Mean, Std, Min, 25%, 50%, 75%, Max
- ✓ Implementación manual de todas las funciones


### 📈 2. Visualización de datos

```bash
# Distribución homogénea
python3 histogram.py dataset_train.csv
make histogram

# Características similares
python3 scatter_plot.py dataset_train.csv
make scatter

# Matriz de correlación completa
python3 pair_plot.py dataset_train.csv
make pair
```

**¿Qué hace?**
- ✓ Identifica el curso con distribución más homogénea
- ✓ Encuentra las dos características más correlacionadas
- ✓ Visualiza todas las relaciones entre características

### 🧠 3. Entrenar el modelo

```bash
# Batch Gradient Descent (obligatorio)
python3 logreg_train.py dataset_train.csv 0.1 1000
# Argumentos: <archivo_datos> <learning_rate> <iteraciones>

make train
```

**¿Qué hace?**
- ✓ Lee y normaliza los datos
- ✓ Entrena 4 clasificadores binarios (One-vs-All)
- ✓ Minimiza la función de coste con gradient descent
- ✓ Guarda los pesos en `weights.pkl`

**Variantes bonus:**
```bash
# Stochastic Gradient Descent (más rápido)
python3 logreg_train_stochastic.py dataset_train.csv 0.01 100

# Mini-Batch Gradient Descent (equilibrio)
python3 logreg_train_minibatch.py dataset_train.csv 0.1 100 32
```

### 🔮 4. Predecir casas

```bash
python3 logreg_predict.py dataset_test.csv weights.pkl houses.csv
# Argumentos: <archivo_test> <archivo_pesos> <archivo_salida>

make predict
```

**¿Qué hace?**
- ✓ Carga el modelo entrenado
- ✓ Predice la casa para cada estudiante
- ✓ Genera `houses.csv` con el formato requerido

### ✅ 5. Evaluar precisión

```bash
python3 evaluate.py dataset_truth.csv houses.csv
make evaluate
```

**Resultado esperado:** ≥98% de precisión

## 🎓 Fundamento Matemático

### Función de Hipótesis
```
h_θ(x) = sigmoid(θᵀx) = 1 / (1 + e^(-θᵀx))
```

### Función de Coste (Binary Cross-Entropy)
```
J(θ) = -1/m Σ[y^(i) log(h_θ(x^(i))) + (1-y^(i)) log(1-h_θ(x^(i)))]
```

### Gradiente
```
∂J(θ)/∂θ_j = 1/m Σ(h_θ(x^(i)) - y^(i))x_j^(i)
```

### Actualización de Parámetros
```
θ_j := θ_j - α · ∂J(θ)/∂θ_j
```

📖 **Explicación detallada:** Consulta [MATHS.md](MATHS.md) para derivaciones completas, ejemplos numéricos y visualizaciones.


## ⚡ Inicio Rápido con Makefile

```bash
# Ver todos los comandos disponibles
make help

# 🚀 Pipeline completo (obligatorio)
make test

# ⭐ Pipeline con bonus
make bonus

# 📊 Pasos individuales
make describe      # Estadísticas descriptivas
make visualize     # Todos los gráficos
make train         # Entrenar modelo
make predict       # Generar predicciones
make evaluate      # Evaluar precisión

# 🧪 Tests y evaluación
make test_auto     # Tests automatizados completos
make evaluation    # Guía de evaluación interactiva
```

## 🧪 Tests y Evaluación

### 🤖 Tests Automatizados (`test_auto.sh`)

Script que verifica automáticamente todo el proyecto:

- ✅ Verificación de archivos requeridos
- ✅ Comprobación de librerías prohibidas
- ✅ Tests de ejecución de todos los scripts
- ✅ Validación de precisión (≥98%)
- ✅ Tests de integración del pipeline completo
- ✅ Tests de características bonus

```bash
./test_auto.sh
# o
make test_auto
```

### 📋 Guía de Evaluación (`evaluation.sh`)

Script interactivo que simula la evaluación de 42:

- 📋 Checklist completo de requisitos del subject
- 🔍 Verificación paso a paso de cada componente
- 📄 Referencias a archivos y líneas específicas
- 💡 Explicaciones de la implementación
- ⏸️ Pausas interactivas para verificación manual

```bash
./evaluation.sh
# o
make evaluation
```

## 📊 Rendimiento y Resultados

### Modelo Principal (Batch Gradient Descent)

| Métrica | Valor |
|---------|-------|
| **Precisión Alcanzada** | ✅ **99.0%** |
| **Precisión Requerida** | ≥98% |
| **Learning Rate** | 0.1 |
| **Iteraciones** | 1000 |
| **Tiempo de Entrenamiento** | ~5-10 segundos |
| **Features** | 13 asignaturas |

### Distribución de Predicciones

| Casa | Porcentaje |
|------|------------|
| 🦁 Gryffindor | ~20% |
| 🦡 Hufflepuff | ~36% |
| 🦅 Ravenclaw | ~28% |
| 🐍 Slytherin | ~16% |

### Métricas por Casa

Todas las casas alcanzan:
- **Precision:** >96%
- **Recall:** >96%
- **F1-Score:** >0.96

## 🎯 Conceptos Clave Implementados

### 1. Regresión Logística
- Algoritmo de **clasificación** (NO regresión, a pesar del nombre)
- Predice **probabilidades** entre 0 y 1 usando función sigmoide
- Función de Hipótesis: `h(x) = sigmoid(θᵀx)` donde `sigmoid(z) = 1/(1 + e⁻ᶻ)`

### 2. One-vs-All (One-vs-Rest)

Para 4 casas, se entrenan **4 clasificadores binarios:**

1. 🦁 Gryffindor vs (Hufflepuff + Ravenclaw + Slytherin)
2. 🦡 Hufflepuff vs (Gryffindor + Ravenclaw + Slytherin)
3. 🦅 Ravenclaw vs (Gryffindor + Hufflepuff + Slytherin)
4. 🐍 Slytherin vs (Gryffindor + Hufflepuff + Ravenclaw)

**Predicción:** Elegir casa con mayor probabilidad

### 3. Tres Variantes de Gradient Descent

#### A) Batch Gradient Descent (OBLIGATORIO)
```python
for iteration in range(num_iterations):
    gradient = (1/m) * Σ[(h(xⁱ) - yⁱ) * xⁱ]  # Usa TODOS los ejemplos
    θ = θ - α * gradient
```
- ✅ Convergencia estable y suave
- ⚠️ Más lento con datasets muy grandes (no aplica aquí)

#### B) Stochastic Gradient Descent (BONUS)
```python
for epoch in range(num_epochs):
    shuffle(data)
    for each example (xⁱ, yⁱ):
        gradient = (h(xⁱ) - yⁱ) * xⁱ  # Un solo ejemplo
        θ = θ - α * gradient
```
- ✅ Muy rápido por iteración
- ⚠️ Convergencia con más fluctuaciones

#### C) Mini-Batch Gradient Descent (BONUS)
```python
for epoch in range(num_epochs):
    shuffle(data)
    for each batch of size b:
        gradient = (1/b) * Σ[(h(xⁱ) - yⁱ) * xⁱ]  # Sobre el batch
        θ = θ - α * gradient
```
- ✅ Mejor compromiso: estable y eficiente
- ✅ Convergencia suave con buen rendimiento

> 💡 **Nota:** Con el dataset DSLR (~400 muestras), las tres variantes alcanzan **99.0% de precisión**.


## 🔧 Implementación Sin Librerías Externas

Todas estas funciones están implementadas desde cero:

### 📊 Estadísticas (describe.py)
- Count, Mean, Standard Deviation
- Min, Max, Percentiles (25%, 50%, 75%)
- **BONUS:** Range, IQR, Skewness, Kurtosis

### 🧮 Matemáticas (logreg_train.py)
- Función Sigmoid
- Logaritmo Natural
- Función de Coste Logística
- Cálculo de Gradientes
- Normalización Z-score

### 📈 Análisis (scatter_plot.py)
- Correlación de Pearson
- Covarianza

## 📚 Características Utilizadas

Se utilizan las **13 asignaturas** de Hogwarts:

| Asignatura | Descripción |
|------------|-------------|
| ✨ **Aritmancia** | Predicción del futuro con números |
| 🌙 **Astronomía** | Estudio de cuerpos celestes |
| 🌿 **Herbología** | Estudio de plantas mágicas |
| ⚔️ **Defensa Contra las Artes Oscuras** | Protección contra magia negra |
| 🔮 **Adivinación** | Predicción del futuro |
| 👨‍💼 **Estudios Muggles** | Cultura no mágica |
| 📜 **Runas Antiguas** | Escritura y símbolos mágicos |
| 📚 **Historia de la Magia** | Historia del mundo mágico |
| 🦋 **Transformación** | Cambio de forma de objetos |
| 🧪 **Pociones** | Preparación de mezclas mágicas |
| 🐉 **Cuidado de Criaturas Mágicas** | Manejo de animales mágicos |
| ✨ **Encantamientos** | Hechizos y encantamientos |
| 🧹 **Vuelo** | Manejo de escobas voladoras |

## 🛠️ Preprocesamiento de Datos

| Técnica | Implementación |
|---------|----------------|
| **Valores Faltantes** | Imputación por media/mediana |
| **Normalización** | Z-score: `(x - μ) / σ` |
| **Selección de Features** | Análisis de correlación |

## ⚠️ Solución de Problemas

### "python: command not found"
```bash
# Usar python3 en su lugar
python3 logreg_train.py dataset_train.csv
```

### "matplotlib not found"
```bash
pip install matplotlib
# O usa Makefile
make install
```

### Baja precisión (<98%)
```bash
# Aumentar iteraciones
python3 logreg_train.py dataset_train.csv 0.1 2000

# Ajustar learning rate
python3 logreg_train.py dataset_train.csv 0.05 1000

# Validar con cross-validation
python3 cross_validate.py dataset_train.csv
```

## 📁 Archivos Generados

Al ejecutar el proyecto se crean:

| Archivo | Descripción |
|---------|-------------|
| `weights.pkl` | Modelo entrenado (Batch GD) |
| `weights_sgd.pkl` | BONUS: Modelo SGD |
| `weights_minibatch.pkl` | BONUS: Modelo Mini-Batch |
| `houses.csv` | Predicciones (formato requerido) |
| `histogram_analysis.png` | Visualización de distribución |
| `scatter_plot_analysis.png` | Visualización de correlación |
| `pair_plot.png` | Matriz de correlación completa |

## 📂 Estructura del Proyecto

```
dslr/
├── 📖 README.md                      # Este archivo
├── 📐 MATHS.md                       # Documentación matemática (1780+ líneas)
├── 🐍 PYTHON.md                      # Guía completa de Python (1860+ líneas)
│
├── 📊 describe.py                    # Análisis estadístico (OBLIGATORIO)
├── 📈 histogram.py                   # Distribución homogénea (OBLIGATORIO)
├── 🔍 scatter_plot.py                # Características similares (OBLIGATORIO)
├── 🎨 pair_plot.py                   # Matriz de correlación (OBLIGATORIO)
├── 🧠 logreg_train.py                # Entrenamiento Batch GD (OBLIGATORIO)
├── 🔮 logreg_predict.py              # Predicción (OBLIGATORIO)
│
├── 🛠️ data_preprocessing.py          # Utilidades de limpieza
├── ⚡ logreg_train_stochastic.py     # BONUS: SGD
├── 🎯 logreg_train_minibatch.py      # BONUS: Mini-Batch GD
├── ✅ evaluate.py                     # Evaluación de precisión
├── ✓ cross_validate.py               # BONUS: Validación cruzada
│
├── 🧪 evaluation.sh                  # Guía de evaluación interactiva
├── 🤖 test_auto.sh                   # Tests automatizados completos
├── ⚙️ Makefile                        # Automatización de tareas
│
├── 💾 weights.pkl                    # Pesos entrenados (generado)
├── 📄 houses.csv                     # Predicciones (generado)
│
├── 📊 dataset_train.csv              # Dataset de entrenamiento
├── 🧪 dataset_test.csv               # Dataset de prueba
└── ✓ dataset_truth.csv               # Casas reales (validación)
```


## 📚 Documentación Técnica Completa

Este proyecto incluye documentación exhaustiva de nivel profesional:

### 📐 [MATHS.md](MATHS.md) — **1,780+ líneas**

**Fundamentos matemáticos completos de Regresión Logística**

<details>
<summary><b>📖 Ver contenido detallado</b></summary>

- 📊 **Funciones estadísticas descriptivas** sin pandas
  - Media, desviación estándar, cuartiles
  - Implementación paso a paso de cada fórmula
  - Ejemplos numéricos con datos de estudiantes

- 🎯 **Regresión Logística vs Regresión Lineal**
  - ¿Por qué no usar regresión lineal para clasificación?
  - Diferencias conceptuales y matemáticas
  - Casos de uso apropiados

- 📈 **Función Sigmoide (Logística)**
  - Derivación matemática completa
  - Tabla de valores y gráfico
  - Implementación en Python sin numpy
  - Propiedades: `σ'(z) = σ(z)(1 - σ(z))`

- 💰 **Función de Coste: Binary Cross-Entropy**
  - Derivación desde Maximum Likelihood
  - ¿Por qué no MSE para clasificación?
  - Interpretación probabilística
  - Implementación con manejo de overflow

- 🔄 **Gradient Descent: Derivación Completa**
  - Cálculo del gradiente `∂J/∂θⱼ`
  - Batch, Stochastic y Mini-Batch GD
  - Comparación de ventajas/desventajas
  - Pseudocódigo y código Python

- 🎪 **Estrategia One-vs-All (Multiclase)**
  - 4 clasificadores binarios para 4 casas
  - Predicción por máxima probabilidad
  - Ejemplo completo con 3 estudiantes

- 📏 **Normalización Z-score**
  - Teoría: `x_norm = (x - μ) / σ`
  - ¿Por qué normalizar?
  - Implementación y aplicación

- 🎥 **Videos educativos en español** para cada tema
- ✍️ **Ejemplos numéricos paso a paso**
- 📐 **Diagramas de flujo** del algoritmo

</details>

---

### 🐍 [PYTHON.md](PYTHON.md) — **1,860+ líneas**

**Guía completa de Python específica para DSLR**

<details>
<summary><b>📖 Ver contenido detallado</b></summary>

- 🎓 **Conceptos básicos de Python**
  - Shebang, docstrings, imports
  - Variables y tipos de datos
  - Estructuras de control

- 📚 **Librerías utilizadas**
  - **csv**: Lectura/escritura de datasets
  - **sys**: Argumentos y manejo de errores
  - **pickle**: Serialización del modelo
  - **matplotlib**: Visualizaciones
  - **random**: Shuffle para SGD

- 🗂️ **Estructuras de datos**
  - Listas (arrays) y operaciones
  - Diccionarios para One-vs-All
  - Tuplas y desempaquetado
  - List comprehensions avanzadas

- 🧮 **Funciones matemáticas personalizadas**
  - Sigmoid sin numpy
  - Logaritmo natural (serie de Taylor)
  - Producto punto (dot product)
  - Estadísticas: mean, std, quartiles

- 📁 **Manejo de archivos CSV**
  - Lectura con csv.reader
  - Conversión de tipos segura
  - Extracción de características
  - Escritura de predicciones

- 💾 **Serialización con Pickle**
  - Guardar modelo completo
  - Cargar parámetros
  - Validación de integridad

- 📊 **Visualización con Matplotlib**
  - Histogramas por casa
  - Scatter plots
  - Pair plots (matriz completa)
  - Curvas de aprendizaje

- ⚠️ **Manejo de errores**
  - Try-except patterns
  - Validación de argumentos
  - Manejo de valores NaN
  - Assertions

- 🎯 **Programación funcional**
  - Lambda functions
  - map(), filter(), reduce()
  - Aplicaciones en clasificación

- 🏗️ **Arquitectura One-vs-All**
  - Pipeline completo de entrenamiento
  - Creación de etiquetas binarias
  - Predicción multiclase
  - Código completo comentado

- ✨ **Optimización y buenas prácticas**
  - Docstrings completos
  - Type hints
  - Constantes y configuración
  - Logging efectivo

- 🎥 **Videos educativos en español** para cada sección
- 💡 **Ejemplos prácticos** del proyecto Hogwarts
- 🔍 **Código comentado** línea por línea

</details>

---

### 🎯 ¿Para quién es esta documentación?

✅ **Estudiantes de 42** que necesitan entender el proyecto en profundidad  
✅ **Evaluadores** que quieren verificar comprensión conceptual  
✅ **Principiantes en ML** sin conocimientos previos de machine learning  
✅ **Desarrolladores Python** que quieren ver implementaciones sin librerías de alto nivel

### 💡 Características de la Documentación

- 📝 **Explicaciones claras** sin asumir conocimientos previos
- 🔢 **Ejemplos numéricos** completos (no solo teoría)
- 🎥 **80+ videos en español** de canales educativos reconocidos
- 💻 **Código funcional** sin dependencias de numpy/sklearn
- 🧪 **Reproducible** - puedes ejecutar todos los ejemplos

---

## 👥 Autores

- **sternero** ([42 Málaga](https://www.42malaga.com/)) - Enero 2026

## 📖 Referencias

- [42 School - Rama de Inteligencia Artificial](https://www.42.fr/)
- [Andrew Ng - Machine Learning Course](https://www.coursera.org/learn/machine-learning)
- [DotCSV - Canal de ML en español](https://www.youtube.com/@DotCSV)

---

<div align="center">

**¿Dudas o sugerencias?** Consulta [MATHS.md](MATHS.md) y [PYTHON.md](PYTHON.md) para más detalles

Made with 🧙‍♂️ at 42 Málaga

</div>
