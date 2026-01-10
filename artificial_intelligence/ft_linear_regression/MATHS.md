<div align="center">

# 📐 MATHS — Fundamentos Matemáticos de ft_linear_regression

**Guía completa de las matemáticas detrás de la regresión lineal**  
*De la teoría a la implementación práctica*

---

[![42 School](https://img.shields.io/badge/42-School-000000?style=flat-square&logo=42&logoColor=white)](https://www.42malaga.com/)
[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![ML](https://img.shields.io/badge/Machine-Learning-FF6F00?style=flat-square&logo=tensorflow&logoColor=white)](https://github.com/sternero)

</div>

---

## 📖 Sobre este documento

Este documento explica, las matemáticas utilizadas en el proyecto `ft_linear_regression`. Está diseñado para ser claro, directo y accesible incluso si tu experiencia previa en ML es limitada. 

✨ **Incluye:**
- 📊 Fórmulas matemáticas completas con notación LaTeX
- 🔍 Derivaciones paso a paso
- 💡 Ejemplos numéricos trabajados
- 🎥 Videos educativos en español (enlaces al final de cada sección)
- 📈 Visualizaciones y gráficos explicativos

---

## 🎯 Resumen en lenguaje llano

Este proyecto aprende una **recta** que relaciona el kilometraje de un coche con su precio. A partir de ejemplos (pares kilometraje-precio) el algoritmo ajusta dos números:

- 📍 **θ₀ (intersección)**: precio base cuando el kilometraje es 0
- 📈 **θ₁ (pendiente)**: cómo cambia el precio por cada kilómetro

Tras el entrenamiento, con esos dos números puedes predecir el precio estimado de cualquier coche según su kilometraje.

**¿Por qué funciona?** Porque buscamos minimizar la diferencia media entre las predicciones y los precios reales; el procedimiento para hacerlo es el llamado **gradiente descendente**.

### 🎥 Aprende más
- [**¿Qué es la Regresión Lineal?** - DotCSV](https://www.youtube.com/watch?v=k964_uNn3l0) - Explicación visual y sencilla en español
- [**Machine Learning desde Cero** - Ringa Tech](https://www.youtube.com/watch?v=w2RJ1D6kz-o) - Introducción completa al ML

---

## 📚 Glosario rápido

| Símbolo | Nombre | Descripción |
|---------|--------|-------------|
| **m** | Muestras | Número de observaciones (líneas en `data.csv`) |
| **θ₀** | Intercepto | Precio estimado cuando el kilometraje es 0 |
| **θ₁** | Pendiente | Cuánto cambia el precio por unidad de kilometraje |
| **h<sub>θ</sub>(x)** | Hipótesis | Predicción: `θ₀ + θ₁ × x` |
| **J(θ)** | Función de coste | MSE: error cuadrático medio |
| **α** | Learning rate | Tasa de aprendizaje; controla el tamaño del paso |
| **∇J** | Gradiente | Vector de derivadas parciales |

---

## 1️⃣ Objetivo

Modelar la relación entre el **kilometraje** de un coche ($x$) y su **precio** ($y$) usando regresión lineal simple. Se busca una función hipótesis lineal:

$$
h_\theta(x) = \theta_0 + \theta_1 x
$$

donde $\theta_0$ (intercepto) y $\theta_1$ (pendiente) son los parámetros a estimar.

### 🎥 Aprende más
- [**Regresión Lineal Explicada** - Matemáticas profe Alex](https://www.youtube.com/watch?v=KZKjNA9LqLI) - Fundamentos matemáticos claros

---

## 2️⃣ Notación matemática

| Notación | Significado |
|----------|-------------|
| $m$ | Número de muestras (observaciones) |
| $x^{(i)}$, $y^{(i)}$ | Entrada y salida de la $i$-ésima muestra |
| $\theta = [\theta_0,\ \theta_1]^T$ | Vector de parámetros |
| $h_\theta(x)$ | Hipótesis (predicción) para la entrada $x$ |

---

## 3️⃣ Función de coste (MSE)

Para medir el ajuste del modelo usamos el **error cuadrático medio** (MSE) en su forma de coste para optimización:

$$
J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)^2
$$

**💡 Explicación:** 
- Se suma el cuadrado de la diferencia entre predicción y valor real
- Se divide por $2m$ para obtener una medida promedio
- Los errores grandes se penalizan más fuertemente (por el cuadrado)
- La constante $\tfrac{1}{2}$ simplifica las derivadas posteriores

### 🎥 Aprende más
- [**Función de Coste en ML** - DotCSV](https://www.youtube.com/watch?v=TqnqMa7x3xc) - ¿Por qué usamos MSE?

---

## 4️⃣ Derivación del gradiente (parcial)

Para minimizar $J(\theta)$ aplicamos **descenso por gradiente**. Calculamos las derivadas parciales respecto a cada parámetro:

### Gradiente para θ₀ (intercepto)
$$
\frac{\partial J(\theta)}{\partial \theta_0} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)
$$

**💡 Explicación:** El gradiente respecto a $\theta_0$ es el promedio de los errores; indica en qué dirección ajustar la intersección para reducir el error.

### Gradiente para θ₁ (pendiente)
$$
\frac{\partial J(\theta)}{\partial \theta_1} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr) x^{(i)}
$$

**💡 Explicación:** El gradiente respecto a $\theta_1$ es el promedio de los errores ponderados por la característica $x$; mide cómo debe cambiar la pendiente para mejorar el ajuste.

---

## 5️⃣ Descenso por gradiente

La regla de actualización (para un learning rate $\alpha$) es:

$$
\theta_j := \theta_j - \alpha \frac{\partial J(\theta)}{\partial \theta_j}, \quad j=0,1
$$

De forma explícita:

$$
\begin{aligned}
\theta_0 &:= \theta_0 - \alpha \cdot \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr) \\
\theta_1 &:= \theta_1 - \alpha \cdot \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr) x^{(i)}
\end{aligned}
$$

### ⚠️ Notas prácticas

| Aspecto | Descripción |
|---------|-------------|
| ⏱️ **Simultaneidad** | Actualizar todos los $\theta_j$ con gradientes de la misma iteración |
| 🔺 **α muy grande** | El algoritmo puede divergir (oscila o explota) |
| 🐌 **α muy pequeño** | La convergencia será muy lenta |

### 🎥 Aprende más
- [**Gradiente Descendente** - DotCSV](https://www.youtube.com/watch?v=A6FiCDoz8_4) - Visualización animada del algoritmo
- [**Optimización en ML** - Ringa Tech](https://www.youtube.com/watch?v=d5SAGm_9KIA) - Cómo funciona la optimización

---

## 6️⃣ Normalización de características

Cuando la escala de $x$ varía mucho (por ejemplo, kilometraje entre 10,000 y 250,000 km), conviene normalizar para acelerar la convergencia del gradiente descendente:

### Normalización estándar (z-score)
$$
x_{norm} = \frac{x - \mu}{\sigma}
$$
donde $\mu$ es la media y $\sigma$ la desviación estándar de la característica.

### 📊 Ejemplo práctico
Si el kilometraje medio es 100,000 km con desviación estándar de 50,000 km, un coche con 150,000 km se normaliza como:
$$
x_{norm} = \frac{150000 - 100000}{50000} = 1.0
$$

### ✅ Ventajas

| Beneficio | Descripción |
|-----------|-------------|
| ⚡ **Convergencia rápida** | Menos iteraciones necesarias |
| 🔢 **Estabilidad numérica** | Evita problemas con valores extremos |
| ⚖️ **Escalas comparables** | θ₀ y θ₁ en rangos similares |

### ⚠️ Importante
Si normalizas durante el entrenamiento, **debes aplicar la misma transformación** (con los mismos $\mu$ y $\sigma$) al hacer predicciones.

### 🎥 Aprende más
- [**Normalización de Datos** - La Escuela de Inteligencia](https://www.youtube.com/watch?v=3QhxK1p6Jzs) - Por qué y cómo normalizar

---

## 7️⃣ Métricas de evaluación

### 📊 MSE (Mean Squared Error)
$$
\mathrm{MSE} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)^2
$$
Error cuadrático medio - penaliza errores grandes.

### 📏 RMSE (Root Mean Squared Error)
$$
\mathrm{RMSE} = \sqrt{\mathrm{MSE}}
$$
Misma unidad que los datos originales.

### 📉 MAE (Mean Absolute Error)
$$
\mathrm{MAE} = \frac{1}{m} \sum_{i=1}^{m} |h_\theta(x^{(i)}) - y^{(i)}|
$$
Error absoluto medio - más robusto a outliers.

### 📊 MAPE (Mean Absolute Percentage Error)
$$
\mathrm{MAPE} = \frac{100}{m} \sum_{i=1}^{m} \left|\frac{h_\theta(x^{(i)}) - y^{(i)}}{y^{(i)}}\right|
$$
Error porcentual - útil para comparar diferentes escalas.

### ⭐ R² (Coeficiente de determinación)
$$
R^2 = 1 - \frac{\sum_{i=1}^{m} (y^{(i)} - h_\theta(x^{(i)}))^2}{\sum_{i=1}^{m} (y^{(i)} - \bar{y})^2}
$$
Con $\bar{y}$ la media de las etiquetas. **R²** indica la fracción de varianza explicada por el modelo.

| Valor R² | Interpretación |
|----------|----------------|
| R² = 1.0 | Ajuste perfecto |
| R² = 0.8 | Buen ajuste (80% de varianza explicada) |
| R² = 0.0 | Modelo tan bueno como predecir la media |
| R² < 0.0 | Modelo peor que predecir la media |

### 🎥 Aprende más
- [**Métricas de Regresión** - AprendeIA](https://www.youtube.com/watch?v=rS_Pj4d3x10) - MSE, RMSE, MAE explicados
- [**Coeficiente R²** - Khan Academy Español](https://es.khanacademy.org/math/statistics-probability/describing-relationships-quantitative-data) - Entendiendo R²

---

## 8️⃣ Ejemplo numérico (dos iteraciones completas)

### Dataset pequeño (m = 3)

| i | $x^{(i)}$ | $y^{(i)}$ |
|---:|---:|---:|
| 1 | 1 | 2.0 |
| 2 | 2 | 2.5 |
| 3 | 3 | 3.5 |

Supongamos $\theta_0 = 0$, $\theta_1 = 0$, y $\alpha = 0.1$.

### Primera iteración

1) Predicciones iniciales:
$$
h_\theta(x^{(i)}) = 0 \quad \text{para } i=1,2,3
$$

2) Errores $e^{(i)} = h_\theta(x^{(i)}) - y^{(i)}$:

$$
e = [ -2.0, -2.5, -3.5 ]
$$

3) Gradientes:

$$
\frac{\partial J}{\partial \theta_0} = \frac{1}{3}(-2.0 -2.5 -3.5) = \frac{-8.0}{3} \approx -2.6667
$$

$$
\frac{\partial J}{\partial \theta_1} = \frac{1}{3}(-2.0\cdot1 -2.5\cdot2 -3.5\cdot3) = \frac{-2.0 -5.0 -10.5}{3} = \frac{-17.5}{3} \approx -5.8333
$$

4) Actualización de parámetros:

$$
\theta_0 := 0 - 0.1\times(-2.6667) \approx 0.26667
$$

$$
\theta_1 := 0 - 0.1\times(-5.8333) \approx 0.58333
$$

### Segunda iteración

Con los parámetros actualizados $\theta_0 \approx 0.26667$ y $\theta_1 \approx 0.58333$ calculamos nuevas predicciones:

$$
h_\theta(1) \approx 0.85,\quad h_\theta(2) \approx 1.43333,\quad h_\theta(3) \approx 2.01667
$$

Errores: $e \approx [ -1.15, -1.06667, -1.48333 ]$.

Gradientes:

$$
\frac{\partial J}{\partial \theta_0} \approx \frac{-1.15 -1.06667 -1.48333}{3} \approx -1.23334
$$

$$
\frac{\partial J}{\partial \theta_1} \approx \frac{-1.15\cdot1 -1.06667\cdot2 -1.48333\cdot3}{3} \approx -2.57779
$$

Actualización (con $\alpha=0.1$):

$$
\theta_0 := 0.26667 - 0.1\times(-1.23334) \approx 0.39000
$$

$$
\theta_1 := 0.58333 - 0.1\times(-2.57779) \approx 0.84111
$$

Después de dos iteraciones las predicciones se acercan más a los valores reales ($J$ disminuye); repetir este proceso reduce gradualmente el error hasta convergencia.

### 🎥 Aprende más
- [**Ejemplo Paso a Paso** - Matemóvil](https://www.youtube.com/watch?v=w2RJ1D6kz-o) - Cálculo manual de regresión lineal

---

## 📈 Gráficos de ayuda

Para facilitar la comprensión, se incluyen dos gráficos generados por `visualize.py`:

### 📊 Gráfico 1: Datos y recta de regresión

![Datos y recta de regresión](plots/regression.png)

**Descripción:** Puntos (kilometraje vs precio) y la recta de regresión ajustada. La caja muestra los valores de `θ₀` y `θ₁`; la línea punteada muestra la diferencia entre un punto observado y su predicción.

### 📉 Gráfico 2: Evolución de la función de coste

![Evolución de la función de coste](plots/loss.png)

**Descripción:** Evolución del MSE normalizado durante el entrenamiento. Los puntos resaltados marcan el MSE inicial y final, mostrando la mejora del modelo.

> 💡 **Tip:** Ejecuta `python3 visualize.py` o `make viz` para generar estos gráficos con tus propios datos.

---

## 9️⃣ Consideraciones prácticas

### 🎯 Inicialización
En regresión lineal simple, inicializar $\theta_0 = 0$ y $\theta_1 = 0$ funciona correctamente en la mayoría de los casos, ya que el problema es convexo.

### 🎚️ Elección de la tasa de aprendizaje ($\alpha$)
- **Valores típicos**: probar en escala logarítmica (0.001, 0.01, 0.1, 1.0).
- **Diagnóstico**: si $J(\theta)$ aumenta, $\alpha$ es demasiado grande; si la convergencia es muy lenta, es demasiado pequeño.
- **Técnicas avanzadas**: considerar decaimiento de $\alpha$ (ej. $\alpha_t = \alpha_0 / (1 + kt)$) o métodos adaptativos (Adam, RMSprop).

### 🛑 Criterio de parada
1. **Número fijo de iteraciones**: simple pero puede ser ineficiente.
2. **Convergencia del coste**: detener cuando $|J^{(t)} - J^{(t-1)}| < \epsilon$ (ej. $\epsilon = 10^{-6}$).
3. **Norma del gradiente**: detener cuando $||\nabla J(\theta)|| < \epsilon$.

### 🚀 Extensiones y mejoras
- **Regresión polinómica**: para relaciones no lineales, usar características $x, x^2, x^3, \ldots$ con regularización L2 (Ridge).
- **Validación cruzada**: dividir datos en entrenamiento y validación para evaluar generalización.
- **Detección de outliers**: valores atípicos pueden afectar significativamente el ajuste; considerar técnicas robustas.

---

## 🎓 Overfitting (Sobreajuste) - Bonus Point

### ¿Qué es el overfitting?

El **overfitting** (sobreajuste en español) ocurre cuando un modelo se ajusta **demasiado bien** a los datos de entrenamiento, hasta el punto de que memoriza el ruido y las peculiaridades específicas de esos datos, en lugar de aprender el patrón general subyacente.

#### 📊 Características del overfitting

| Aspecto | Descripción |
|---------|-------------|
| 🎯 **En entrenamiento** | Predicciones perfectas o casi perfectas (MSE muy bajo) |
| 📉 **En validación** | Predicciones pobres en datos nuevos (MSE alto) |
| 🔍 **Síntoma principal** | Poca capacidad de generalización |

#### 💡 Ejemplo práctico

Imagina que quieres predecir el precio de coches basándote en el kilometraje:

**Sin overfitting (buen modelo):**
```
Datos: (10k km, 7500€), (50k km, 6800€), (100k km, 5200€)
Modelo: θ₀ = 8000, θ₁ = -0.025
Predicción para 60k km → 6500€ ✓ (razonable)
```

**Con overfitting (modelo memoriza):**
```
Datos: (10k km, 7500€), (50k km, 6800€), (100k km, 5200€)
Modelo polinómico grado 10: pasa exactamente por todos los puntos
Predicción para 60k km → 12000€ ✗ (sin sentido, no generaliza)
```

#### 🚨 Cómo detectarlo en ft_linear_regression

En nuestro proyecto de **regresión lineal simple** (con solo 2 parámetros θ₀ y θ₁), el overfitting es **muy poco probable** porque:

1. **Modelo simple**: Solo 2 parámetros vs 24 muestras → no hay suficiente complejidad para memorizar
2. **Función lineal**: La recta no puede pasar exactamente por todos los puntos

**Sin embargo**, si observas que:
- ✓ El **MSE en entrenamiento es 0** (predicciones exactas)
- ✓ Las predicciones son **idénticas a los valores reales** en todos los casos
- ✓ El modelo **falla completamente** con datos nuevos

...entonces podrías estar ante un caso de overfitting (aunque en regresión lineal simple es extremadamente raro).

#### 🛡️ Cómo prevenir el overfitting

| Técnica | Descripción | ¿En ft_linear_regression? |
|---------|-------------|---------------------------|
| **Regularización** | Penalizar parámetros grandes (L1/L2) | ❌ No necesario (modelo simple) |
| **Validación cruzada** | Dividir datos train/test | ⚠️ Opcional (pocos datos) |
| **Early stopping** | Parar cuando el error de validación aumenta | ❌ No aplica (no tenemos validación) |
| **Simplificar modelo** | Usar menos features o menor grado polinomial | ✅ Ya usamos el más simple (lineal) |
| **Más datos** | Aumentar el dataset | ⚠️ Limitado por data.csv |

#### 📈 Overfitting vs Underfitting

```
Underfitting          Buen ajuste          Overfitting
(infraajuste)        (generaliza)         (sobreajuste)
─────────────────────────────────────────────────────────
MSE alto              MSE moderado         MSE muy bajo (train)
No captura patrón     Captura patrón       MSE alto (test)
Modelo muy simple     Modelo adecuado      Memoriza ruido
R² bajo (~0)          R² alto (>0.7)       R² = 1 (sospechoso)
```

#### 🎯 En la evaluación de 42

Si el evaluador nota que tus predicciones son **exactamente iguales** a los precios reales en todos los casos (precio idéntico todo el tiempo), podría sospechar overfitting y preguntarte:

> *"¿Qué es el overfitting y cómo lo detectarías aquí?"*

**Respuesta correcta** (+1 punto bonus):
> "El overfitting es cuando el modelo memoriza los datos de entrenamiento en lugar de aprender el patrón general. Se detecta porque las predicciones son perfectas en entrenamiento pero fallan en datos nuevos. En regresión lineal simple es muy raro porque solo tenemos 2 parámetros, pero si todas las predicciones fueran exactamente iguales a los valores reales (MSE = 0), sería sospechoso de overfitting."

### 🎥 Aprende más
- [**Overfitting explicado** - DotCSV](https://www.youtube.com/watch?v=LJJg-bY-K7c) - Explicación visual del concepto
- [**Bias vs Variance** - StatQuest](https://www.youtube.com/watch?v=EuBBz3bI-aA) - Trade-off fundamental en ML (inglés con subtítulos)

---

## 🔟 Implementación en el proyecto

Este proyecto implementa el algoritmo descrito en cuatro módulos principales:

1. **`train.py`**: Lee `data.csv`, normaliza características, ejecuta descenso por gradiente y guarda $\theta_0, \theta_1$ (y parámetros de normalización) en un archivo.

2. **`predict.py`**: Carga los parámetros entrenados, solicita un kilometraje al usuario, aplica normalización y calcula la predicción.

3. **`precision.py`** (opcional): Calcula métricas de evaluación (MSE, RMSE, MAE, MAPE, $R^2$) sobre el conjunto de entrenamiento o un conjunto de test.

4. **`visualize.py`** (opcional): Genera gráficos que muestran la recta de regresión ajustada y la evolución del coste durante el entrenamiento.

### Flujo de trabajo

```
1. Entrenar modelo:    make train    (o python3 train.py)
2. Hacer predicción:   make predict  (o python3 predict.py)
3. Evaluar precisión:  make test     (o python3 precision.py)
4. Visualizar:         make viz      (o python3 visualize.py)
```

Los parámetros $\theta_0$ y $\theta_1$ se guardan junto con $\mu$ y $\sigma$ para poder desnormalizar predicciones correctamente.

### 🎥 Aprende más
- [**Implementando ML desde Cero** - Código Máquina](https://www.youtube.com/watch?v=vP59dCE3KkQ) - Implementación práctica en Python
- [**Curso ML Completo** - AprendeIA](https://www.youtube.com/playlist?list=PLAnA8FVrBl8AWkZmbswwWiF8a_52dQ3JQ) - Serie completa de Machine Learning

---

## 📚 Referencias y recursos adicionales

### 📖 Libros recomendados
- **"Machine Learning"** - Tom M. Mitchell
- **"The Elements of Statistical Learning"** - Hastie, Tibshirani, Friedman
- **"Pattern Recognition and Machine Learning"** - Christopher Bishop

### 🌐 Recursos online
- [Curso de Machine Learning - Andrew Ng](https://www.coursera.org/learn/machine-learning) - El curso más famoso de ML
- [Khan Academy - Estadística](https://es.khanacademy.org/math/statistics-probability) - Fundamentos matemáticos
- [3Blue1Brown - Cálculo](https://www.youtube.com/playlist?list=PLZHQObOWTQDMsr9K-rj53DwVRMYO3t5Yr) - Visualización de conceptos matemáticos

### 🎓 Canales de YouTube en español
- [DotCSV](https://www.youtube.com/@DotCSV) - Machine Learning y AI
- [Ringa Tech](https://www.youtube.com/@RingaTech) - Programación y ML
- [AprendeIA](https://www.youtube.com/@AprendeIA) - Inteligencia Artificial
- [Matemáticas profe Alex](https://www.youtube.com/@matematicasprofealex) - Matemáticas aplicadas

---

<div align="center">

**Proyecto ft_linear_regression - Documentación Matemática**  
🏫 42 Málaga - Campus 42 | 👤 **sternero** | 📅 Enero 2026

</div>
