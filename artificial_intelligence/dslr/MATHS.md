<div align="center">

# 📐 MATHS — Fundamentos Matemáticos de DSLR

**Guía completa de las matemáticas detrás de la regresión logística multiclase**  
*De la teoría a la implementación práctica*

---

[![42 School](https://img.shields.io/badge/42-School-000000?style=flat-square&logo=42&logoColor=white)](https://www.42malaga.com/)
[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![ML](https://img.shields.io/badge/Machine-Learning-FF6F00?style=flat-square&logo=tensorflow&logoColor=white)](https://github.com/sternero)

</div>

---

## 📖 Sobre este documento

Este documento explica las matemáticas utilizadas en el proyecto **DSLR** (Data Science × Logistic Regression). Está diseñado para ser claro, directo y accesible incluso si tu experiencia previa en ML es limitada.

✨ **Incluye:**
- 📊 Fórmulas matemáticas completas con notación LaTeX
- 🔍 Derivaciones paso a paso
- 💡 Ejemplos numéricos del proyecto Hogwarts
- 🎥 Videos educativos en español (enlaces al final de cada sección)
- 📈 Visualizaciones y gráficos explicativos

**Resultado del proyecto:** ✅ **99.0% de precisión** en clasificación de casas de Hogwarts

---

<a id="indice"></a>

## 📑 Índice

1. [**Esquemas visuales del proceso matemático**](#-esquemas-visuales-del-proceso-matemático)
2. [Objetivo: Clasificación Multiclase](#1️⃣-objetivo-clasificación-multiclase)
3. [Estadísticas Descriptivas](#2️⃣-estadísticas-descriptivas)
4. [Regresión Logística vs Regresión Lineal](#3️⃣-regresión-logística-vs-regresión-lineal)
5. [Función Sigmoide](#4️⃣-función-sigmoide)
6. [Función de Coste (Log Loss)](#5️⃣-función-de-coste-log-loss)
7. [Derivación del Gradiente](#6️⃣-derivación-del-gradiente)
8. [Descenso por Gradiente](#7️⃣-descenso-por-gradiente)
9. [Estrategia One-vs-All (OvA)](#8️⃣-estrategia-one-vs-all-ova)
10. [Normalización de Características](#9️⃣-normalización-de-características)
11. [Ejemplo numérico completo](#-ejemplo-numérico-completo)
12. [Variantes del Gradient Descent (BONUS)](#-variantes-del-gradient-descent-bonus)
13. [Métricas de evaluación](#-métricas-de-evaluación)
14. [Implementación en el proyecto](#-implementación-en-el-proyecto)
15. [Referencias y recursos adicionales](#-referencias-y-recursos-adicionales)

---

## 🎯 Resumen en lenguaje llano

Este proyecto clasifica estudiantes de Hogwarts en sus casas (Gryffindor, Hufflepuff, Ravenclaw, Slytherin) basándose en sus notas en diferentes asignaturas.

**Diferencia clave con regresión lineal:**
- Regresión Lineal: Predice valores continuos (ej: precio de un coche)
- Regresión Logística: Predice categorías/clases (ej: casa de Hogwarts)

**¿Cómo funciona?**
1. Entrena 4 clasificadores binarios (uno por casa vs el resto)
2. Cada clasificador calcula la probabilidad de que un estudiante pertenezca a esa casa
3. Asigna al estudiante a la casa con mayor probabilidad

**Matemática clave:** La función **sigmoide** convierte cualquier valor en una probabilidad entre 0 y 1.

### 🎥 Aprende más
- [**Regresión Logística Explicada** - DotCSV](https://www.youtube.com/watch?v=DH7qK9u41Fo) - Explicación visual en español
- [**Clasificación con Machine Learning** - Ringa Tech](https://www.youtube.com/watch?v=FGR6XxnxXX4) - Introducción práctica

---

## 📊 Esquemas visuales del proceso matemático

### 🔄 Esquema general del flujo del algoritmo

```
╔═══════════════════════════════════════════════════════════════════════════╗
║            PROCESO COMPLETO DE REGRESIÓN LOGÍSTICA MULTICLASE             ║
╚═══════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 1: ANÁLISIS EXPLORATORIO DE DATOS                                 │
└─────────────────────────────────────────────────────────────────────────┘

    📁 dataset_train.csv (400 estudiantes × 13 asignaturas)
       ↓
    ┌──────────────────┐
    │  describe.py     │  →  Count, Mean, Std, Min, 25%, 50%, 75%, Max
    │  Estadísticas    │      para cada asignatura
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  histogram.py    │  →  ¿Qué asignatura tiene distribución homogénea?
    │  Visualización   │      → Care of Magical Creatures
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  scatter_plot.py │  →  ¿Qué asignaturas son similares?
    │  Correlaciones   │      → Astronomy y Defense Against Dark Arts
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  pair_plot.py    │  →  Matriz de correlación completa
    │  Matriz          │      Visualizar todas las relaciones
    └────────┬─────────┘
             ↓
    ✅ Comprensión de los datos completa


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 2: PREPARACIÓN DE DATOS                                           │
└─────────────────────────────────────────────────────────────────────────┘

    ┌──────────────────┐
    │  Cargar datos    │  →  X = matriz (400 × 13) de características
    │  dataset_train   │  →  y = vector (400,) de etiquetas (casas)
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  Limpiar datos   │  →  Manejar valores NaN/faltantes
    │  handle_missing  │      (usar media de la columna)
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  Normalizar      │  →  x_norm = (x - μ) / σ
    │  Z-score         │      Para cada característica
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  Agregar bias    │  →  X = [1, x₁, x₂, ..., x₁₃]
    │  (columna de 1s) │      Ahora X es (400 × 14)
    └────────┬─────────┘
             ↓
    ✅ Datos preparados para entrenamiento


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 3: ENTRENAMIENTO ONE-VS-ALL                                       │
└─────────────────────────────────────────────────────────────────────────┘

    Para cada casa k ∈ {Gryffindor, Hufflepuff, Ravenclaw, Slytherin}:
    
    ╔════════════════════════════════════════════════════════╗
    ║  CLASIFICADOR k: Casa k vs Resto                       ║
    ╚════════════════════════════════════════════════════════╝
    
    Crear etiquetas binarias:
        yₖ[i] = 1  si estudiante i está en casa k
        yₖ[i] = 0  en caso contrario
    
    Inicialización: θₖ = [0, 0, ..., 0]  (14 parámetros)
    
    ┌──────────────────────────────────────────────────────┐
    │  ITERACIÓN t (repetir 1000 veces)                    │
    └──────────────────────────────────────────────────────┘
    
    Para cada iteración t:
    
    1️⃣  PREDICCIÓN (Forward Pass)
    
        Para cada estudiante i:
        
            z_i = θₖᵀ · xᵢ = θ₀ + θ₁x₁ + θ₂x₂ + ... + θ₁₃x₁₃
            
            h_i = σ(z_i) = 1 / (1 + e^(-z_i))   [Función Sigmoide]
            
        Resultado: h_i ∈ [0, 1]  (probabilidad de estar en casa k)
    
    2️⃣  CÁLCULO DEL ERROR
    
        Para cada estudiante i:
        
            error_i = h_i - y_i
            
        Si y_i = 1 (está en casa k):  error_i debe ser ≈ 0
        Si y_i = 0 (no está):         error_i debe ser ≈ 0
    
    3️⃣  FUNCIÓN DE COSTE (Binary Cross-Entropy)
    
        J(θₖ) = -1/m · Σᵢ₌₁ᵐ [yᵢ·log(hᵢ) + (1-yᵢ)·log(1-hᵢ)]
        
        Penaliza predicciones incorrectas:
        - Si y=1 pero h≈0: log(h) → -∞  (gran penalización)
        - Si y=0 pero h≈1: log(1-h) → -∞  (gran penalización)
    
    4️⃣  CÁLCULO DEL GRADIENTE
    
        Para cada parámetro j:
        
            ∂J/∂θⱼ = 1/m · Σᵢ₌₁ᵐ (hᵢ - yᵢ) · xᵢⱼ
        
        Nota: ¡Idéntico a regresión lineal gracias a la elegancia
              de la función sigmoide!
    
    5️⃣  ACTUALIZACIÓN DE PARÁMETROS (Gradient Descent)
    
        θⱼ := θⱼ - α · (∂J/∂θⱼ)
        
        donde α = 0.1 (learning rate)
        
        ⚠️  Actualización SIMULTÁNEA de todos los parámetros
    
    6️⃣  CONVERGENCIA
    
        Monitorear J(θₖ):
        - Debe disminuir en cada iteración
        - Si se estabiliza: el modelo ha convergido
    
    ╔════════════════════════════════════════════════════════╗
    ║  FIN: θₖ_optimal                                       ║
    ╚════════════════════════════════════════════════════════╝
    
    Resultado para casa k: Vector θₖ de 14 parámetros
    
    ↓
    
    Repetir para las 4 casas → 4 vectores θ


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 4: PREDICCIÓN (dataset_test.csv)                                  │
└─────────────────────────────────────────────────────────────────────────┘

    Para cada estudiante nuevo:
    
    1. Normalizar sus características con μ, σ del training
    
    2. Para cada casa k:
           
           z_k = θₖᵀ · x
           
           probabilidad_k = σ(z_k)
    
    3. Asignar a la casa con mayor probabilidad:
    
           casa_predicha = argmax_k (probabilidad_k)
    
    4. Guardar resultado en houses.csv
    
    ✅ Predicciones completas


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 5: EVALUACIÓN                                                     │
└─────────────────────────────────────────────────────────────────────────┘

    Comparar houses.csv con dataset_truth.csv:
    
    Accuracy = (Predicciones correctas) / (Total de predicciones)
    
    ✅ Resultado: 99.0% (Requerido: ≥98%)
```

[⬆️ Volver al índice](#indice)

---

## 1️⃣ Objetivo: Clasificación Multiclase

### Problema

**Entrada:** Características de un estudiante (notas en 13 asignaturas)
**Salida:** Casa de Hogwarts (Gryffindor, Hufflepuff, Ravenclaw, Slytherin)

### Datos del proyecto

- **Dataset de entrenamiento:** 400 estudiantes
- **Dataset de test:** 133 estudiantes  
- **Características:** 13 asignaturas (Astronomía, Herbología, DADA, etc.)
- **Clases:** 4 casas de Hogwarts

### Diferencia con problemas de regresión

| Aspecto | Regresión Lineal | Regresión Logística |
|---------|------------------|---------------------|
| **Tipo de salida** | Continua (números reales) | Discreta (categorías) |
| **Ejemplo** | Precio de un coche: 5,000€ | Casa: Gryffindor |
| **Función** | $y = \theta_0 + \theta_1 x$ | $h(x) = \sigma(\theta^T x)$ |
| **Rango de salida** | $(-\infty, +\infty)$ | $[0, 1]$ (probabilidad) |
| **Función de coste** | MSE (error cuadrático) | Log Loss (entropía cruzada) |

### 🎥 Aprende más
- [**Clasificación vs Regresión** - Dot CSV](https://www.youtube.com/watch?v=X0_IXDJoUFs) - Diferencias clave
- [**Aprendizaje Supervisado** - Ringa Tech](https://www.youtube.com/watch?v=oT3arRRB2Cw) - Tipos de problemas ML

[⬆️ Volver al índice](#indice)

---

## 2️⃣ Estadísticas Descriptivas

Antes de entrenar, es crucial entender los datos. El archivo `describe.py` implementa estas métricas SIN usar pandas.

### Métricas calculadas

#### Count (Conteo)
```
Count = Número de valores no-NaN en la columna
```
**Propósito:** Verificar datos faltantes

#### Mean (Media)
```
μ = (1/n) · Σᵢ₌₁ⁿ xᵢ
```
**Interpretación:** Valor promedio de la característica

#### Std (Desviación Estándar)
```
σ = √[(1/n) · Σᵢ₌₁ⁿ (xᵢ - μ)²]
```
**Interpretación:** Dispersión de los datos respecto a la media

#### Min / Max
```
Min = min(x₁, x₂, ..., xₙ)
Max = max(x₁, x₂, ..., xₙ)
```
**Propósito:** Detectar valores atípicos (outliers)

#### Cuartiles (25%, 50%, 75%)
```
Q1 (25%): 25% de los datos están por debajo
Q2 (50%): Mediana, divide los datos en dos mitades iguales
Q3 (75%): 75% de los datos están por debajo
```
**Propósito:** Entender la distribución de los datos

### Implementación en describe.py

```python
def calculate_mean(data):
    """Calcula media sin numpy"""
    return sum(data) / len(data)

def calculate_std(data, mean):
    """Calcula desviación estándar sin numpy"""
    variance = sum((x - mean) ** 2 for x in data) / len(data)
    return variance ** 0.5

def calculate_quartile(data, q):
    """Calcula cuartiles q = 0.25, 0.50, 0.75"""
    sorted_data = sorted(data)
    index = q * (len(sorted_data) - 1)
    # Interpolación lineal si el índice no es entero
    lower = int(index)
    upper = lower + 1
    weight = index - lower
    if upper >= len(sorted_data):
        return sorted_data[lower]
    return sorted_data[lower] * (1 - weight) + sorted_data[upper] * weight
```

### 🎥 Aprende más
- [**Estadística Descriptiva** - Matemáticas con Juan](https://www.youtube.com/watch?v=4VdQmoh4vY0) - Conceptos fundamentales
- [**Media, Mediana, Moda** - Math2me](https://www.youtube.com/watch?v=nUHQVQdL-g8) - Medidas de tendencia central

[⬆️ Volver al índice](#indice)

---

## 3️⃣ Regresión Logística vs Regresión Lineal

### ¿Por qué no usar regresión lineal para clasificación?

**Problema:** La regresión lineal puede dar valores fuera de [0, 1]

```
Ejemplo con regresión lineal:
    x = 100    → y = 1.5  ❌ ¿Probabilidad > 100%?
    x = -50    → y = -0.3 ❌ ¿Probabilidad negativa?
```

**Solución:** Aplicar función sigmoide

```
Regresión Logística = Regresión Lineal + Función Sigmoide

h(x) = σ(θ₀ + θ₁x₁ + ... + θₙxₙ)
     = σ(θᵀx)
```

### Comparación visual

```
REGRESIÓN LINEAL
   y
   │     /
   │    /
   │   /
   │  /
   │ /
   └────────── x
   
   Problema: Sin límites

REGRESIÓN LOGÍSTICA
   y
 1 │    ┌─────
   │   /
0.5│  /
   │ /
 0 │─────┘
   └────────── x
   
   ✅ Salida en [0, 1]
```

### 🎥 Aprende más
- [**¿Por qué Regresión Logística?** - StatQuest](https://www.youtube.com/watch?v=yIYKR4sgzI8) - Explicación visual (subtítulos en español)
- [**Función Sigmoide Explicada** - 3Blue1Brown](https://www.youtube.com/watch?v=aircAruvnKk) - Deep Learning desde cero

[⬆️ Volver al índice](#indice)

---

## 4️⃣ Función Sigmoide

### Definición

La función sigmoide (también llamada logística) convierte cualquier valor real en una probabilidad entre 0 y 1:

$$\sigma(z) = \frac{1}{1 + e^{-z}}$$

### Propiedades clave

1. **Rango:** $\sigma(z) \in (0, 1)$ para todo $z \in \mathbb{R}$
2. **Punto medio:** $\sigma(0) = 0.5$
3. **Límites:**
   - $\lim_{z \to +\infty} \sigma(z) = 1$
   - $\lim_{z \to -\infty} \sigma(z) = 0$
4. **Simetría:** $\sigma(-z) = 1 - \sigma(z)$

### Tabla de valores

| z | σ(z) | Interpretación |
|---|------|----------------|
| -∞ | 0.00 | Imposible que sea de esta clase |
| -5 | 0.01 | Muy improbable |
| -2 | 0.12 | Poco probable |
| 0 | 0.50 | Incierto (umbral de decisión) |
| 2 | 0.88 | Muy probable |
| 5 | 0.99 | Casi seguro |
| +∞ | 1.00 | Seguro que es de esta clase |

### Implementación sin numpy

```python
def sigmoid(z):
    """
    Función sigmoide: σ(z) = 1 / (1 + e^(-z))
    
    Maneja overflow:
    - Si z > 500: retorna 1.0 (evita e^(-500) que es ≈ 0)
    - Si z < -500: retorna 0.0 (evita e^(500) que es ∞)
    """
    # Clip para evitar overflow
    if z > 500:
        return 1.0
    elif z < -500:
        return 0.0
    
    # Aproximación de e ≈ 2.718281828459045
    e = 2.718281828459045
    return 1.0 / (1.0 + (e ** (-z)))
```

### Derivada de la sigmoide

**Propiedad elegante:**

$$\frac{d\sigma(z)}{dz} = \sigma(z) \cdot (1 - \sigma(z))$$

**Demostración:**

$$
\begin{align}
\sigma(z) &= \frac{1}{1 + e^{-z}} \\
\frac{d\sigma}{dz} &= \frac{d}{dz}\left[(1 + e^{-z})^{-1}\right] \\
&= -(1 + e^{-z})^{-2} \cdot (-e^{-z}) \\
&= \frac{e^{-z}}{(1 + e^{-z})^2} \\
&= \frac{1}{1 + e^{-z}} \cdot \frac{e^{-z}}{1 + e^{-z}} \\
&= \sigma(z) \cdot (1 - \sigma(z))
\end{align}
$$

**¿Por qué es importante?** Simplifica enormemente el cálculo del gradiente.

### 🎥 Aprende más
- [**La Función Sigmoide** - Khan Academy](https://www.youtube.com/watch?v=TPqr8t919YM) - Matemática detrás
- [**Activaciones en Neural Networks** - DotCSV](https://www.youtube.com/watch?v=uwbHOpp9xkc) - Sigmoide y otras

[⬆️ Volver al índice](#indice)

---

## 5️⃣ Función de Coste (Log Loss)

### ¿Por qué no usar MSE?

En regresión lineal usamos Mean Squared Error (MSE):
```
J(θ) = 1/(2m) · Σᵢ₌₁ᵐ (hθ(xⁱ) - yⁱ)²
```

**Problema con MSE en clasificación:**
- La función de coste no es convexa (tiene mínimos locales)
- Gradient descent puede quedarse atascado

### Binary Cross-Entropy (Log Loss)

Para regresión logística usamos:

$$J(\theta) = -\frac{1}{m} \sum_{i=1}^{m} \left[y^{(i)} \log(h_\theta(x^{(i)})) + (1 - y^{(i)}) \log(1 - h_\theta(x^{(i)}))\right]$$

Donde:
- $m$ = número de ejemplos de entrenamiento
- $y^{(i)}$ = etiqueta real (0 o 1)
- $h_\theta(x^{(i)})$ = predicción (probabilidad entre 0 y 1)

### Interpretación intuitiva

**Caso 1: Si $y = 1$ (el estudiante está en esta casa)**
```
Coste = -log(h)

Si h ≈ 1 (predijimos correctamente):  -log(1) = 0       ✅ Sin penalización
Si h ≈ 0.5 (inciertos):               -log(0.5) = 0.69  ⚠️ Penalización media
Si h ≈ 0 (nos equivocamos):           -log(0) = ∞       ❌ Gran penalización
```

**Caso 2: Si $y = 0$ (el estudiante NO está en esta casa)**
```
Coste = -log(1 - h)

Si h ≈ 0 (predijimos correctamente):  -log(1) = 0       ✅ Sin penalización
Si h ≈ 0.5 (inciertos):               -log(0.5) = 0.69  ⚠️ Penalización media
Si h ≈ 1 (nos equivocamos):           -log(0) = ∞       ❌ Gran penalización
```

### Implementación

```python
def compute_cost(X, y, theta):
    """
    Calcula función de coste Binary Cross-Entropy
    
    J(θ) = -1/m Σ[y*log(h) + (1-y)*log(1-h)]
    
    Args:
        X: matriz de características (m × n)
        y: vector de etiquetas (m,)  valores 0 o 1
        theta: vector de parámetros (n,)
    
    Returns:
        coste: valor escalar de J(θ)
    """
    m = len(y)
    epsilon = 1e-15  # Evitar log(0)
    
    total_cost = 0.0
    for i in range(m):
        # Calcular z = θᵀx
        z = sum(theta[j] * X[i][j] for j in range(len(theta)))
        
        # Calcular h = σ(z)
        h = sigmoid(z)
        
        # Clipear h para evitar log(0)
        h = max(epsilon, min(1 - epsilon, h))
        
        # Calcular coste para este ejemplo
        if y[i] == 1:
            cost = -log_custom(h)
        else:
            cost = -log_custom(1 - h)
        
        total_cost += cost
    
    return total_cost / m


def log_custom(x):
    """
    Logaritmo natural usando serie de Taylor
    ln(x) para x cercano a 1: ln(1+u) ≈ u - u²/2 + u³/3 - u⁴/4 + ...
    """
    if x <= 0:
        return -1000.0  # Gran número negativo
    if x == 1:
        return 0.0
    
    # Para x en (0.5, 2) usar serie de Taylor
    if 0.5 < x < 2.0:
        u = x - 1
        return u - (u**2)/2 + (u**3)/3 - (u**4)/4 + (u**5)/5
    
    # Para otros valores, usar recursión
    if x > 2.0:
        return log_custom(x / 2.718281828459045) + 1.0
    else:
        return -log_custom(1.0 / x)
```

### Propiedades de J(θ)

1. **Convexa:** Tiene un único mínimo global
2. **Diferenciable:** Podemos usar gradient descent
3. **Penaliza fuertemente:** Errores grandes tienen penalización exponencial

### 🎥 Aprende más
- [**Cross-Entropy Loss** - StatQuest](https://www.youtube.com/watch?v=6ArSys5qHAU) - Explicación intuitiva (inglés con subtítulos)
- [**Funciones de Pérdida en ML** - DotCSV](https://www.youtube.com/watch?v=sDv4f4s2SB8) - Comparación de loss functions

[⬆️ Volver al índice](#indice)

---

## 6️⃣ Derivación del Gradiente

### Objetivo

Necesitamos calcular $\frac{\partial J}{\partial \theta_j}$ para cada parámetro $\theta_j$.

### Derivación paso a paso

**Función de coste:**
$$J(\theta) = -\frac{1}{m} \sum_{i=1}^{m} \left[y^{(i)} \log(h_\theta(x^{(i)})) + (1 - y^{(i)}) \log(1 - h_\theta(x^{(i)}))\right]$$

**Hipótesis:**
$$h_\theta(x) = \sigma(\theta^T x) = \sigma(z)$$

donde $z = \theta_0 + \theta_1 x_1 + ... + \theta_n x_n$

**Paso 1: Derivada de un solo ejemplo**

Para un ejemplo $(x, y)$:
$$\text{coste} = -\left[y \log(h) + (1-y) \log(1-h)\right]$$

Aplicando la regla de la cadena:
$$\frac{\partial \text{coste}}{\partial \theta_j} = \frac{\partial \text{coste}}{\partial h} \cdot \frac{\partial h}{\partial z} \cdot \frac{\partial z}{\partial \theta_j}$$

**Paso 2: Calcular cada término**

1. $\frac{\partial \text{coste}}{\partial h}$:
$$\frac{\partial}{\partial h}\left[-y \log(h) - (1-y) \log(1-h)\right] = -\frac{y}{h} + \frac{1-y}{1-h}$$

2. $\frac{\partial h}{\partial z}$ (derivada de sigmoide):
$$\frac{\partial \sigma(z)}{\partial z} = \sigma(z)(1 - \sigma(z)) = h(1-h)$$

3. $\frac{\partial z}{\partial \theta_j}$ (derivada de combinación lineal):
$$\frac{\partial}{\partial \theta_j}(\theta_0 + \theta_1 x_1 + ... + \theta_j x_j + ...) = x_j$$

**Paso 3: Combinar (regla de la cadena)**

$$
\begin{align}
\frac{\partial \text{coste}}{\partial \theta_j} &= \left(-\frac{y}{h} + \frac{1-y}{1-h}\right) \cdot h(1-h) \cdot x_j \\
&= \left(-\frac{y}{h} + \frac{1-y}{1-h}\right) \cdot h(1-h) \cdot x_j \\
&= \left(-y(1-h) + (1-y)h\right) \cdot x_j \\
&= (-y + yh + h - yh) \cdot x_j \\
&= (h - y) \cdot x_j
\end{align}
$$

**Resultado elegante:** $(h - y) \cdot x_j$ ¡Idéntico a regresión lineal!

**Paso 4: Promedio sobre todos los ejemplos**

$$\frac{\partial J}{\partial \theta_j} = \frac{1}{m} \sum_{i=1}^{m} (h_\theta(x^{(i)}) - y^{(i)}) \cdot x_j^{(i)}$$

### Forma vectorial

Si escribimos en forma matricial:
$$\nabla J(\theta) = \frac{1}{m} X^T (h - y)$$

Donde:
- $X$ es la matriz de características $(m \times n)$
- $h$ es el vector de predicciones $(m \times 1)$
- $y$ es el vector de etiquetas $(m \times 1)$

### 🎥 Aprende más
- [**Cálculo del Gradiente** - Khan Academy](https://www.youtube.com/watch?v=TEB2z7ZlRAw) - Derivadas parciales
- [**Regla de la Cadena** - Unicoos](https://www.youtube.com/watch?v=gZPZvLdPZuE) - Fundamentos de cálculo

[⬆️ Volver al índice](#indice)

---

## 7️⃣ Descenso por Gradiente

### Concepto intuitivo

Imagina que estás en una montaña en la niebla y quieres bajar al valle (mínimo). El gradiente te dice la dirección de mayor pendiente hacia arriba, así que vas en la dirección opuesta.

```
        ⛰️
       /  \
      /    \
     /      \
    /   👤   \     ← Tú estás aquí
   /    ↓     \
  /     ↓      \
 /      ↓       \
/       🎯        \  ← Quieres llegar aquí (mínimo de J)
```

### Algoritmo de Gradient Descent

**Actualización simultánea:**
$$\theta_j := \theta_j - \alpha \frac{\partial J}{\partial \theta_j}$$

Para todos los parámetros $j = 0, 1, ..., n$

Donde:
- $\alpha$ = learning rate (tasa de aprendizaje)
- $\frac{\partial J}{\partial \theta_j}$ = gradiente (dirección de mayor aumento)
- El signo negativo hace que vayamos hacia abajo (minimizar)

### Paso a paso del algoritmo

```
INICIALIZACIÓN:
    θ = [0, 0, ..., 0]  (o valores aleatorios pequeños)
    α = 0.1  (learning rate)
    iteraciones = 1000

REPETIR iteraciones veces:
    
    1. Para cada ejemplo i de 1 hasta m:
           Calcular z_i = θᵀ · x_i
           Calcular h_i = σ(z_i)
    
    2. Para cada parámetro j de 0 hasta n:
           Calcular gradiente_j = (1/m) · Σᵢ (h_i - y_i) · x_i,j
    
    3. Actualizar SIMULTÁNEAMENTE todos los θ_j:
           θ_j := θ_j - α · gradiente_j
    
    4. Opcional: Calcular y guardar J(θ) para monitorear convergencia

FIN
```

### Implementación

```python
def gradient_descent_batch(X, y, theta, learning_rate, num_iterations, verbose=False):
    """
    BATCH Gradient Descent - actualiza pesos usando TODOS los ejemplos
    
    Args:
        X: matriz de características (m × n)
        y: vector de etiquetas (m,)
        theta: vector inicial de parámetros (n,)
        learning_rate: α (típicamente 0.01 - 0.3)
        num_iterations: número de iteraciones
        verbose: imprimir progreso
    
    Returns:
        theta: parámetros optimizados
        cost_history: lista de costes por iteración
    """
    m = len(y)
    n = len(theta)
    cost_history = []
    
    for iteration in range(num_iterations):
        # 1. Calcular predicciones para todos los ejemplos
        h = []
        for i in range(m):
            z = sum(theta[j] * X[i][j] for j in range(n))
            h.append(sigmoid(z))
        
        # 2. Calcular gradiente para cada parámetro
        gradient = [0.0] * n
        for i in range(m):
            error = h[i] - y[i]
            for j in range(n):
                gradient[j] += error * X[i][j]
        
        # Promediar gradiente
        for j in range(n):
            gradient[j] /= m
        
        # 3. Actualizar parámetros SIMULTÁNEAMENTE
        for j in range(n):
            theta[j] -= learning_rate * gradient[j]
        
        # 4. Monitorear coste
        if iteration % 100 == 0:
            cost = compute_cost(X, y, theta)
            cost_history.append(cost)
            if verbose:
                print(f"  Iteration {iteration:5d}: Cost = {cost:.6f}")
    
    return theta, cost_history
```

### Learning Rate (α)

El learning rate controla el tamaño del paso:

```
α muy pequeño (ej: 0.001):
    ✅ Convergencia suave
    ❌ MUY lento

α adecuado (ej: 0.1):
    ✅ Convergencia rápida y estable
    
α muy grande (ej: 10):
    ❌ Puede divergir (oscilar o explotar)
```

**Gráfico del coste:**
```
J(θ)
  │
  │ α muy grande:  ╱╲╱╲╱╲  (oscila o diverge)
  │
  │ α adecuado:   ╲╲╲_____ (converge suavemente)
  │
  │ α muy pequeño: ╲___________ (muy lento pero converge)
  │
  └──────────────────── iteración
```

### Criterio de parada

**Opción 1: Número fijo de iteraciones**
```python
for iteration in range(1000):  # Siempre 1000 iteraciones
    ...
```

**Opción 2: Convergencia del coste**
```python
while abs(cost_nuevo - cost_anterior) > tolerancia:
    ...
```

Típicamente usamos opción 1 en este proyecto: **1000 iteraciones**.

### 🎥 Aprende más
- [**Gradient Descent Explicado** - StatQuest](https://www.youtube.com/watch?v=sDv4f4s2SB8) - Visualización clara
- [**Descenso del Gradiente** - DotCSV](https://www.youtube.com/watch?v=A6FiCDoz8_4) - Explicación en español
- [**Learning Rate** - Andrew Ng](https://www.youtube.com/watch?v=F6GSRDoB-Cg) - Cómo elegir α

[⬆️ Volver al índice](#indice)

---

## 8️⃣ Estrategia One-vs-All (OvA)

### Problema

Regresión logística es un clasificador **binario** (2 clases: 0 o 1).

Nuestro problema tiene **4 clases** (casas de Hogwarts).

### Solución: One-vs-All (One-vs-Rest)

**Idea:** Entrenar K clasificadores binarios, uno por cada clase.

Para K = 4 casas:

```
╔══════════════════════════════════════════════════════════╗
║  CLASIFICADOR 1: Gryffindor vs Resto                     ║
╚══════════════════════════════════════════════════════════╝

    y_gryffindor[i] = { 1  si estudiante i está en Gryffindor
                      { 0  si está en Hufflepuff, Ravenclaw o Slytherin
    
    Entrenar: θ_gryffindor


╔══════════════════════════════════════════════════════════╗
║  CLASIFICADOR 2: Hufflepuff vs Resto                     ║
╚══════════════════════════════════════════════════════════╝

    y_hufflepuff[i] = { 1  si estudiante i está en Hufflepuff
                      { 0  si está en Gryffindor, Ravenclaw o Slytherin
    
    Entrenar: θ_hufflepuff


╔══════════════════════════════════════════════════════════╗
║  CLASIFICADOR 3: Ravenclaw vs Resto                      ║
╚══════════════════════════════════════════════════════════╝

    y_ravenclaw[i] = { 1  si estudiante i está en Ravenclaw
                     { 0  si está en Gryffindor, Hufflepuff o Slytherin
    
    Entrenar: θ_ravenclaw


╔══════════════════════════════════════════════════════════╗
║  CLASIFICADOR 4: Slytherin vs Resto                      ║
╚══════════════════════════════════════════════════════════╝

    y_slytherin[i] = { 1  si estudiante i está en Slytherin
                     { 0  si está en Gryffindor, Hufflepuff o Ravenclaw
    
    Entrenar: θ_slytherin
```

### Predicción con One-vs-All

Para clasificar un nuevo estudiante:

```
1. Calcular probabilidad para cada casa:
   
   P(Gryffindor)  = σ(θ_gryffindor^T · x)
   P(Hufflepuff)  = σ(θ_hufflepuff^T · x)
   P(Ravenclaw)   = σ(θ_ravenclaw^T · x)
   P(Slytherin)   = σ(θ_slytherin^T · x)

2. Elegir la casa con mayor probabilidad:
   
   casa_predicha = argmax_k P(casa_k)
```

### Ejemplo numérico

```
Estudiante nuevo: Harry Potter
Notas normalizadas: x = [1, 0.8, -0.2, 1.5, ..., 0.3]

Probabilidades calculadas:
    P(Gryffindor)  = σ(θ_g^T · x) = 0.92  ← MÁXIMO
    P(Hufflepuff)  = σ(θ_h^T · x) = 0.15
    P(Ravenclaw)   = σ(θ_r^T · x) = 0.28
    P(Slytherin)   = σ(θ_s^T · x) = 0.05

Predicción: Gryffindor ✅
```

### Implementación

```python
def train_one_vs_all(X, y_dict, houses, learning_rate=0.1, num_iterations=1000, verbose=False):
    """
    Entrena K clasificadores binarios usando estrategia One-vs-All
    
    Args:
        X: matriz de características (m × n)
        y_dict: diccionario {casa: [etiquetas binarias]}
        houses: lista de nombres de casas
        learning_rate: α
        num_iterations: iteraciones por clasificador
        verbose: imprimir progreso
    
    Returns:
        theta_dict: {casa: theta_k} - un vector θ por cada casa
    """
    n = len(X[0])  # Número de características
    theta_dict = {}
    
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
    
    return theta_dict


def predict_one_vs_all(x, theta_dict, houses):
    """
    Predice la casa para un estudiante usando One-vs-All
    
    Args:
        x: vector de características del estudiante (n,)
        theta_dict: {casa: theta_k}
        houses: lista de nombres de casas
    
    Returns:
        casa_predicha: nombre de la casa con mayor probabilidad
    """
    probabilities = {}
    
    for house in houses:
        theta = theta_dict[house]
        z = sum(theta[j] * x[j] for j in range(len(theta)))
        probabilities[house] = sigmoid(z)
    
    # Retornar casa con mayor probabilidad
    casa_predicha = max(probabilities, key=probabilities.get)
    return casa_predicha
```

### Alternativa: One-vs-One

Otra estrategia sería **One-vs-One** (entrenar un clasificador por cada par de casas):

```
Gryffindor vs Hufflepuff
Gryffindor vs Ravenclaw
Gryffindor vs Slytherin
Hufflepuff vs Ravenclaw
Hufflepuff vs Slytherin
Ravenclaw vs Slytherin

Total: K(K-1)/2 = 4×3/2 = 6 clasificadores
```

**No usamos One-vs-One en este proyecto** porque:
- One-vs-All: K clasificadores (4 en nuestro caso)
- One-vs-One: K(K-1)/2 clasificadores (6 en nuestro caso)
- One-vs-All es más simple y eficiente para K pequeño

### 🎥 Aprende más
- [**Multiclass Classification** - Andrew Ng](https://www.youtube.com/watch?v=-EIfb6vFJzc) - Explicación de One-vs-All
- [**Clasificación Multiclase** - DotCSV](https://www.youtube.com/watch?v=MlK1VMfJMNw) - Estrategias en español

[⬆️ Volver al índice](#indice)

---

## 9️⃣ Normalización de Características

### ¿Por qué normalizar?

**Problema:** Características en escalas muy diferentes pueden dificultar el aprendizaje.

Ejemplo de nuestros datos:
```
Astronomy:         [-33.5, 120.8]  rango ≈ 154
Herbology:         [-12.3, 85.2]   rango ≈ 97
Care of Magical:   [-9.8, 78.4]    rango ≈ 88
```

Sin normalización:
- Astronomy dominaría el cálculo de z = θᵀx
- Learning rate óptimo para Astronomy podría ser terrible para Herbology
- Convergencia muy lenta o inestable

### Z-score Normalization (Estandarización)

**Fórmula:**
$$x_{norm} = \frac{x - \mu}{\sigma}$$

Donde:
- $\mu$ = media de la característica
- $\sigma$ = desviación estándar

**Resultado:**
- Media = 0
- Desviación estándar = 1
- La mayoría de valores están en el rango [-3, 3]

### Ejemplo paso a paso

**Asignatura: Astronomy**

Datos originales (10 primeros estudiantes):
```
x = [35.2, 68.5, -12.3, 92.7, 15.8, 44.6, -8.2, 73.1, 28.4, 55.9, ...]
```

Paso 1: Calcular media
```
μ = (35.2 + 68.5 + ... + 55.9) / 400 = 42.3
```

Paso 2: Calcular desviación estándar
```
σ = sqrt(((35.2-42.3)² + (68.5-42.3)² + ... + (55.9-42.3)²) / 400) = 28.6
```

Paso 3: Normalizar cada valor
```
x_norm[0] = (35.2 - 42.3) / 28.6 = -0.25
x_norm[1] = (68.5 - 42.3) / 28.6 =  0.92
x_norm[2] = (-12.3 - 42.3) / 28.6 = -1.91
...
```

Datos normalizados:
```
x_norm = [-0.25, 0.92, -1.91, 1.76, -0.93, 0.08, -1.77, 1.08, -0.49, 0.48, ...]
```

✅ Ahora: μ = 0, σ = 1

### Implementación

```python
def normalize_features(X):
    """
    Normaliza características usando Z-score
    
    Args:
        X: matriz de características (m × n)
           Nota: X[i][0] = 1 (bias), no normalizar!
    
    Returns:
        X_norm: matriz normalizada
        means: lista de medias por columna
        stds: lista de desviaciones estándar
    """
    m = len(X)
    n = len(X[0])
    
    X_norm = [[0.0] * n for _ in range(m)]
    means = []
    stds = []
    
    for j in range(n):
        if j == 0:
            # Columna de bias: NO normalizar
            for i in range(m):
                X_norm[i][j] = 1.0
            means.append(0.0)
            stds.append(1.0)
        else:
            # Calcular media
            column = [X[i][j] for i in range(m) if X[i][j] is not None]
            mean = sum(column) / len(column)
            
            # Calcular desviación estándar
            variance = sum((x - mean) ** 2 for x in column) / len(column)
            std = variance ** 0.5
            
            # Evitar división por cero
            if std < 1e-10:
                std = 1.0
            
            # Normalizar
            for i in range(m):
                if X[i][j] is not None:
                    X_norm[i][j] = (X[i][j] - mean) / std
                else:
                    X_norm[i][j] = 0.0  # Valor faltante → 0 después de normalizar
            
            means.append(mean)
            stds.append(std)
    
    return X_norm, means, stds
```

### ⚠️ Importante: Normalizar datos de test

Cuando predecimos sobre datos nuevos, debemos usar **la misma μ y σ del training**:

```python
# ❌ INCORRECTO:
X_test_norm, means_test, stds_test = normalize_features(X_test)

# ✅ CORRECTO:
X_test_norm = []
for x in X_test:
    x_norm = [1.0]  # bias
    for j in range(1, len(x)):
        x_norm.append((x[j] - means_train[j]) / stds_train[j])
    X_test_norm.append(x_norm)
```

### Otras técnicas de normalización

**Min-Max Scaling** (no usada en este proyecto):
$$x_{norm} = \frac{x - x_{min}}{x_{max} - x_{min}}$$

Resultado: valores en [0, 1]

**¿Cuándo usar cada una?**
- **Z-score:** Cuando los datos tienen distribución normal (Gaussiana)
- **Min-Max:** Cuando necesitas valores acotados en [0, 1]

En este proyecto usamos **Z-score** porque:
1. Las notas tienen distribución aproximadamente normal
2. Es más robusta ante outliers
3. Es el estándar en machine learning

### 🎥 Aprende más
- [**Feature Scaling** - Andrew Ng](https://www.youtube.com/watch?v=r7Ay2pqSrSA) - Por qué y cómo normalizar
- [**Normalización de Datos** - DotCSV](https://www.youtube.com/watch?v=UYWfQc6PkPU) - Técnicas en español

[⬆️ Volver al índice](#indice)

---

## 📝 Ejemplo numérico completo

Vamos a seguir el entrenamiento de **un clasificador** (Gryffindor vs Resto) con **datos simplificados**.

### Datos de ejemplo

**3 estudiantes, 2 asignaturas:**

| Estudiante | Astronomy | Herbology | Casa | y_Gryffindor |
|------------|-----------|-----------|------|--------------|
| Harry      | 85        | 70        | Gryffindor | 1 |
| Draco      | 55        | 90        | Slytherin | 0 |
| Luna       | 95        | 65        | Ravenclaw | 0 |

### Paso 1: Normalizar características

**Astronomy:**
```
μ = (85 + 55 + 95) / 3 = 78.33
σ = sqrt(((85-78.33)² + (55-78.33)² + (95-78.33)²) / 3) = 16.77

x₁_norm[Harry] = (85 - 78.33) / 16.77 =  0.40
x₁_norm[Draco] = (55 - 78.33) / 16.77 = -1.39
x₁_norm[Luna]  = (95 - 78.33) / 16.77 =  0.99
```

**Herbology:**
```
μ = (70 + 90 + 65) / 3 = 75.00
σ = sqrt(((70-75)² + (90-75)² + (65-75)²) / 3) = 10.80

x₂_norm[Harry] = (70 - 75.00) / 10.80 = -0.46
x₂_norm[Draco] = (90 - 75.00) / 10.80 =  1.39
x₂_norm[Luna]  = (65 - 75.00) / 10.80 = -0.93
```

**Matriz X normalizada con bias:**

$$X = \begin{bmatrix}
1 & 0.40 & -0.46 \\
1 & -1.39 & 1.39 \\
1 & 0.99 & -0.93
\end{bmatrix}, \quad y = \begin{bmatrix} 1 \\ 0 \\ 0 \end{bmatrix}$$

### Paso 2: Inicialización

```
θ = [0, 0, 0]
α = 0.5  (learning rate mayor para converger rápido con pocos datos)
m = 3
```

### Iteración 1

**Predicciones:**

Harry (i=0):
```
z₀ = θᵀx₀ = 0·1 + 0·0.40 + 0·(-0.46) = 0
h₀ = σ(0) = 0.5
```

Draco (i=1):
```
z₁ = θᵀx₁ = 0·1 + 0·(-1.39) + 0·1.39 = 0
h₁ = σ(0) = 0.5
```

Luna (i=2):
```
z₂ = θᵀx₂ = 0·1 + 0·0.99 + 0·(-0.93) = 0
h₂ = σ(0) = 0.5
```

**Errores:**
```
error₀ = h₀ - y₀ = 0.5 - 1 = -0.5
error₁ = h₁ - y₁ = 0.5 - 0 =  0.5
error₂ = h₂ - y₂ = 0.5 - 0 =  0.5
```

**Coste:**
```
J(θ) = -1/3 · [1·log(0.5) + 0·log(0.5) + 0·log(0.5) + 0·log(0.5) + 1·log(0.5) + 1·log(0.5)]
     = -1/3 · [log(0.5) + log(0.5) + log(0.5)]
     = -1/3 · 3 · (-0.693)
     = 0.693
```

**Gradientes:**

θ₀ (bias):
```
∂J/∂θ₀ = 1/3 · (error₀·1 + error₁·1 + error₂·1)
        = 1/3 · (-0.5 + 0.5 + 0.5)
        = 0.167
```

θ₁ (Astronomy):
```
∂J/∂θ₁ = 1/3 · (error₀·0.40 + error₁·(-1.39) + error₂·0.99)
        = 1/3 · (-0.5·0.40 + 0.5·(-1.39) + 0.5·0.99)
        = 1/3 · (-0.20 - 0.70 + 0.50)
        = -0.133
```

θ₂ (Herbology):
```
∂J/∂θ₂ = 1/3 · (error₀·(-0.46) + error₁·1.39 + error₂·(-0.93))
        = 1/3 · (-0.5·(-0.46) + 0.5·1.39 + 0.5·(-0.93))
        = 1/3 · (0.23 + 0.70 - 0.47)
        = 0.153
```

**Actualización:**
```
θ₀ := 0 - 0.5 · 0.167 = -0.084
θ₁ := 0 - 0.5 · (-0.133) = 0.067
θ₂ := 0 - 0.5 · 0.153 = -0.077
```

### Iteración 2

**Predicciones con nuevo θ:**

Harry (i=0):
```
z₀ = -0.084 + 0.067·0.40 + (-0.077)·(-0.46) = -0.084 + 0.027 + 0.035 = -0.022
h₀ = σ(-0.022) = 0.494
```

Draco (i=1):
```
z₁ = -0.084 + 0.067·(-1.39) + (-0.077)·1.39 = -0.084 - 0.093 - 0.107 = -0.284
h₁ = σ(-0.284) = 0.429
```

Luna (i=2):
```
z₂ = -0.084 + 0.067·0.99 + (-0.077)·(-0.93) = -0.084 + 0.066 + 0.072 = 0.054
h₂ = σ(0.054) = 0.513
```

**Errores:**
```
error₀ = 0.494 - 1 = -0.506
error₁ = 0.429 - 0 =  0.429
error₂ = 0.513 - 0 =  0.513
```

**Nuevo coste:**
```
J(θ) ≈ 0.676  (ha disminuido desde 0.693 ✅)
```

... (continuar iterando hasta convergencia)

### Resultado final (después de ~100 iteraciones)

```
θ_final ≈ [-0.58, 0.92, -1.05]
```

**Verificación:**

Harry (Gryffindor):
```
z = -0.58 + 0.92·0.40 + (-1.05)·(-0.46) = -0.58 + 0.37 + 0.48 = 0.27
P(Gryffindor) = σ(0.27) = 0.57  ✅ > 0.5 → Gryffindor correcto
```

Draco (no Gryffindor):
```
z = -0.58 + 0.92·(-1.39) + (-1.05)·1.39 = -0.58 - 1.28 - 1.46 = -3.32
P(Gryffindor) = σ(-3.32) = 0.03  ✅ < 0.5 → No Gryffindor correcto
```

Luna (no Gryffindor):
```
z = -0.58 + 0.92·0.99 + (-1.05)·(-0.93) = -0.58 + 0.91 + 0.98 = 1.31
P(Gryffindor) = σ(1.31) = 0.79  ❌ > 0.5 → Clasificación incorrecta
```

En este ejemplo simplificado, el modelo clasifica correctamente 2 de 3 (66.7%). Con los datos reales (400 estudiantes, 13 asignaturas, 1000 iteraciones), alcanzamos **99.0%**.

[⬆️ Volver al índice](#indice)

---

## 🔄 Variantes del Gradient Descent (BONUS)

### A) Batch Gradient Descent (OBLIGATORIO)

**Ya explicado anteriormente.** Usa todos los ejemplos en cada iteración.

```python
for iteration in range(num_iterations):
    gradient = (1/m) * Σᵢ₌₁ᵐ [(h(xⁱ) - yⁱ) · xⁱ]  # Todos los ejemplos
    θ := θ - α · gradient
```

**Ventajas:**
- ✅ Convergencia suave y estable
- ✅ Actualización precisa del gradiente

**Desventajas:**
- ⚠️ Lento con datasets muy grandes (>100k ejemplos)

Con DSLR (400 ejemplos): **No hay problema de velocidad**.

### B) Stochastic Gradient Descent - SGD (BONUS)

**Idea:** Actualizar θ después de **cada ejemplo individual**.

```python
for epoch in range(num_epochs):
    shuffle(data)  # Importante: mezclar orden
    for i in range(m):
        gradient = (h(xⁱ) - yⁱ) · xⁱ  # Solo ejemplo i
        θ := θ - α · gradient
```

**Ventajas:**
- ✅ Muy rápido por iteración
- ✅ Puede escapar de mínimos locales (por el "ruido")
- ✅ Funciona bien con datasets enormes

**Desventajas:**
- ⚠️ Convergencia con más fluctuaciones
- ⚠️ Puede oscilar cerca del mínimo (nunca converge exactamente)

**Gráfico del coste:**
```
J(θ)
  │  Batch GD:        ╲╲╲_____
  │
  │  Stochastic GD:   ╲ ╲╲╲╲╲╲___～～～  (oscila pero llega)
  │
  └────────────────────── iteración
```

**Implementación simplificada:**

```python
def gradient_descent_stochastic(X, y, theta, learning_rate, num_epochs, verbose=False):
    """
    Stochastic Gradient Descent
    Actualiza parámetros después de CADA ejemplo
    """
    m = len(y)
    n = len(theta)
    
    for epoch in range(num_epochs):
        # Mezclar datos al inicio de cada epoch
        indices = list(range(m))
        random.shuffle(indices)
        
        for idx in indices:
            i = indices[idx]
            
            # Calcular predicción para ejemplo i
            z = sum(theta[j] * X[i][j] for j in range(n))
            h = sigmoid(z)
            
            # Calcular error
            error = h - y[i]
            
            # Actualizar INMEDIATAMENTE (sin promediar)
            for j in range(n):
                theta[j] -= learning_rate * error * X[i][j]
        
        if verbose and epoch % 10 == 0:
            cost = compute_cost(X, y, theta)
            print(f"  Epoch {epoch:5d}: Cost = {cost:.6f}")
    
    return theta
```

### C) Mini-Batch Gradient Descent (BONUS)

**Idea:** Compromiso entre Batch y Stochastic. Actualizar θ usando **pequeños lotes** (típicamente 16-256 ejemplos).

```python
for epoch in range(num_epochs):
    shuffle(data)
    for each batch of size b:
        gradient = (1/b) * Σⁱⁿᵇᵃᵗᶜʰ [(h(xⁱ) - yⁱ) · xⁱ]
        θ := θ - α · gradient
```

**Ventajas:**
- ✅ Convergencia más suave que SGD
- ✅ Más rápido que Batch GD
- ✅ Puede aprovechar paralelización (GPUs)

**Parámetro clave:** `batch_size`
- Típico: 32, 64, 128
- En DSLR: 32 (con 400 ejemplos → 13 batches por epoch)

**Implementación:**

```python
def gradient_descent_minibatch(X, y, theta, learning_rate, num_epochs, batch_size=32, verbose=False):
    """
    Mini-Batch Gradient Descent
    Actualiza parámetros después de cada mini-batch
    """
    m = len(y)
    n = len(theta)
    
    for epoch in range(num_epochs):
        # Mezclar datos
        indices = list(range(m))
        random.shuffle(indices)
        
        # Dividir en mini-batches
        for start in range(0, m, batch_size):
            end = min(start + batch_size, m)
            batch_indices = indices[start:end]
            batch_size_actual = len(batch_indices)
            
            # Calcular gradiente sobre el batch
            gradient = [0.0] * n
            for idx in batch_indices:
                i = indices[idx]
                
                # Predicción
                z = sum(theta[j] * X[i][j] for j in range(n))
                h = sigmoid(z)
                
                # Acumular gradiente
                error = h - y[i]
                for j in range(n):
                    gradient[j] += error * X[i][j]
            
            # Promediar y actualizar
            for j in range(n):
                gradient[j] /= batch_size_actual
                theta[j] -= learning_rate * gradient[j]
        
        if verbose and epoch % 10 == 0:
            cost = compute_cost(X, y, theta)
            print(f"  Epoch {epoch:5d}: Cost = {cost:.6f}")
    
    return theta
```

### Comparación de las tres variantes

| Aspecto | Batch GD | Stochastic GD | Mini-Batch GD |
|---------|----------|---------------|---------------|
| **Tamaño de actualización** | m ejemplos | 1 ejemplo | b ejemplos (16-256) |
| **Velocidad por iteración** | Lenta | Muy rápida | Media |
| **Convergencia** | Muy suave | Ruidosa | Suave |
| **Memoria requerida** | Alta | Baja | Media |
| **Mejor para** | Datasets pequeños | Datasets enormes | Uso general |

**En DSLR:**
- Batch GD: 1000 iteraciones × 400 ejemplos = 400,000 actualizaciones
- Stochastic GD: 100 epochs × 400 ejemplos = 40,000 actualizaciones (pero por ejemplo)
- Mini-Batch GD: 100 epochs × 13 batches = 1,300 actualizaciones (sobre batches)

**Resultado:** Las tres alcanzan **99.0% de precisión** en DSLR.

### 🎥 Aprende más
- [**Batch vs SGD vs Mini-Batch** - Andrew Ng](https://www.youtube.com/watch?v=4qJaSmvhxi8) - Comparación detallada
- [**Optimization Algorithms** - DeepLearning.AI](https://www.youtube.com/watch?v=k8fTYJPd3_I) - Variantes avanzadas

[⬆️ Volver al índice](#indice)

---

## 📊 Métricas de evaluación

### Accuracy (Precisión)

$$\text{Accuracy} = \frac{\text{Predicciones correctas}}{\text{Total de predicciones}}$$

**Ejemplo:**
- Dataset de test: 133 estudiantes
- Predicciones correctas: 132
- Accuracy = 132 / 133 = **99.0%** ✅

### Confusion Matrix (Matriz de confusión)

Para cada casa, podemos calcular:

```
                    Predicho
                Gryf  Huff  Rave  Slyt
     ┌───────┬─────┬─────┬─────┬─────┐
  G  │ Gryff │  32 │   0 │   0 │   1 │
  r  ├───────┼─────┼─────┼─────┼─────┤
  e  │ Huffl │   0 │  35 │   0 │   0 │
  a  ├───────┼─────┼─────┼─────┼─────┤
  l  │ Raven │   0 │   0 │  33 │   0 │
     ├───────┼─────┼─────┼─────┼─────┤
     │ Slyt  │   0 │   0 │   0 │  32 │
     └───────┴─────┴─────┴─────┴─────┘
```

Diagonal: clasificaciones correctas
Fuera de diagonal: errores

### Precision, Recall, F1-Score (por clase)

**Para una casa específica (ej: Gryffindor):**

**Precision (Precisión):**
$$\text{Precision} = \frac{TP}{TP + FP}$$

"De los que predijimos Gryffindor, ¿cuántos realmente lo eran?"

**Recall (Exhaustividad):**
$$\text{Recall} = \frac{TP}{TP + FN}$$

"De los Gryffindor reales, ¿cuántos identificamos?"

**F1-Score:**
$$F1 = 2 \cdot \frac{\text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$$

Media armónica de precision y recall.

**Nota:** Con 99% de accuracy en DSLR, todas estas métricas son excelentes para todas las casas.

### 🎥 Aprende más
- [**Confusion Matrix** - StatQuest](https://www.youtube.com/watch?v=Kdsp6soqA7o) - Explicación visual
- [**Precision vs Recall** - DotCSV](https://www.youtube.com/watch?v=58LfUvlZGtc) - Diferencias clave

[⬆️ Volver al índice](#indice)

---

## 💻 Implementación en el proyecto

### Archivos del proyecto

```
dslr/
├── describe.py             # Estadísticas sin pandas
├── histogram.py            # Distribución homogénea
├── scatter_plot.py         # Características similares
├── pair_plot.py            # Matriz de correlación
├── logreg_train.py         # OBLIGATORIO: Entrenamiento con Batch GD
├── logreg_predict.py       # OBLIGATORIO: Predicción
├── logreg_train_stochastic.py   # BONUS: SGD
├── logreg_train_minibatch.py    # BONUS: Mini-Batch GD
├── cross_validate.py       # BONUS: Validación cruzada
├── data_preprocessing.py   # BONUS: Utilidades de limpieza
├── evaluate.py             # Cálculo de accuracy
└── weights.pkl             # Parámetros entrenados (generado)
```

### Pipeline completo

```bash
# 1. Análisis estadístico
python3 describe.py dataset_train.csv

# 2. Visualizaciones
python3 histogram.py dataset_train.csv
python3 scatter_plot.py dataset_train.csv
python3 pair_plot.py dataset_train.csv

# 3. Entrenamiento (Batch GD)
python3 logreg_train.py dataset_train.csv 0.1 1000
#                                         α=0.1  1000 iter

# 4. Predicción
python3 logreg_predict.py dataset_test.csv weights.pkl houses.csv

# 5. Evaluación
python3 evaluate.py houses.csv dataset_truth.csv
# → Output: Your score on test set: 0.990 (99.0%)
```

### Estructura de weights.pkl

```python
{
    'theta': {
        'Gryffindor': [θ₀, θ₁, ..., θ₁₃],
        'Hufflepuff': [θ₀, θ₁, ..., θ₁₃],
        'Ravenclaw': [θ₀, θ₁, ..., θ₁₃],
        'Slytherin': [θ₀, θ₁, ..., θ₁₃]
    },
    'features': ['Index', 'Arithmancy', 'Astronomy', ...],
    'means': [0.0, μ₁, μ₂, ..., μ₁₃],
    'stds': [1.0, σ₁, σ₂, ..., σ₁₃],
    'algorithm': 'batch_gradient_descent'
}
```

[⬆️ Volver al índice](#indice)

---

## 📚 Referencias y recursos adicionales

### Videos educativos (español)

**Regresión Logística:**
- [Regresión Logística - DotCSV](https://www.youtube.com/watch?v=DH7qK9u41Fo)
- [Clasificación con ML - Ringa Tech](https://www.youtube.com/watch?v=FGR6XxnxXX4)

**Machine Learning General:**
- [Curso completo ML - AprendeIA](https://www.youtube.com/playlist?list=PLJ4Y3R-e6TqvqG3Bpbj8N3P0j3WBN-v1R)
- [Machine Learning desde Cero - Píldoras Informáticas](https://www.youtube.com/playlist?list=PLU8oAlHdN5BkWc7LnE48JJ0UdG1aECmqO)

**Matemáticas:**
- [Cálculo diferencial - Khan Academy](https://es.khanacademy.org/math/differential-calculus)
- [Estadística - Math2me](https://www.youtube.com/playlist?list=PLlP4T0ckZLY3bXgXNj1d3Zu2X3OqLqP2k)

### Cursos completos

**Andrew Ng - Machine Learning (Coursera):**
- [Curso en Coursera](https://www.coursera.org/learn/machine-learning)
- Semanas 1-3 cubren regresión logística
- **Nota:** Curso en inglés, pero con subtítulos en español

**DeepLearning.AI:**
- [Neural Networks and Deep Learning](https://www.deeplearning.ai/courses/neural-networks-deep-learning/)
- Cubre fundamentos de clasificación

### Libros recomendados

1. **"Hands-On Machine Learning"** - Aurélien Géron
   - Capítulo 4: Training Models (regresión logística)
   - Muy práctico con código Python

2. **"Pattern Recognition and Machine Learning"** - Christopher Bishop
   - Capítulo 4: Linear Models for Classification
   - Más teórico, matemática profunda

3. **"The Elements of Statistical Learning"** - Hastie, Tibshirani, Friedman
   - Capítulo 4: Linear Methods for Classification
   - Versión gratuita: https://web.stanford.edu/~hastie/ElemStatLearn/

### Documentación online

- [Scikit-learn: Logistic Regression](https://scikit-learn.org/stable/modules/linear_model.html#logistic-regression)
- [Wikipedia: Logistic Regression](https://es.wikipedia.org/wiki/Regresi%C3%B3n_log%C3%ADstica)
- [ML Cheatsheet](https://ml-cheatsheet.readthedocs.io/en/latest/logistic_regression.html)

### Herramientas de visualización

- [TensorFlow Playground](https://playground.tensorflow.org/)  - Experimenta con clasificadores
- [Desmos Calculator](https://www.desmos.com/calculator) - Graficar funciones matemáticas
- [Wolfram Alpha](https://www.wolframalpha.com/) - Cálculo simbólico

[⬆️ Volver al índice](#indice)

---

<div align="center">

## 🎓 ¡Felicidades!

Has completado la guía matemática de **DSLR - Logistic Regression**.

Ahora comprendes:
- ✅ Estadísticas descriptivas sin pandas
- ✅ Función sigmoide y su derivada
- ✅ Binary Cross-Entropy (Log Loss)
- ✅ Derivación del gradiente
- ✅ Gradient Descent (Batch, Stochastic, Mini-Batch)
- ✅ Estrategia One-vs-All para multiclase
- ✅ Normalización Z-score
- ✅ Pipeline completo de clasificación

**Resultado:** 99.0% de precisión en clasificación de casas de Hogwarts 🏰✨

---

[![42 School](https://img.shields.io/badge/42-School-000000?style=flat-square&logo=42&logoColor=white)](https://www.42malaga.com/)

*Documentación creada para el proyecto DSLR de 42 School*

</div>
