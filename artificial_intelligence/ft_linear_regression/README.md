# 🚗 ft_linear_regression

> **Implementación de regresión lineal con gradiente descendente**  
> Predice el precio de un coche basándose en su kilometraje usando machine learning desde cero.

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

Este proyecto implementa un **algoritmo básico de machine learning** (regresión lineal) desde cero, sin usar librerías que hagan el trabajo automáticamente (como `numpy.polyfit`). 

🎯 **Objetivo:** Entrenar un modelo que pueda predecir el precio de un coche dado su kilometraje usando únicamente las matemáticas del gradiente descendente.

## 🎯 Características

<table>
<tr>
<td width="50%">

### ✅ Parte Obligatoria

| Componente | Descripción |
|------------|-------------|
| 🔮 **predict.py** | Predicción de precio por kilometraje |
| 🧠 **train.py** | Entrenamiento con gradiente descendente |
| 💾 **thetas.txt** | Almacenamiento de parámetros θ₀ y θ₁ |
| 📐 **Fórmulas** | Implementación exacta según subject |

</td>
<td width="50%">

### ⭐ Parte Bonus

| Componente | Descripción |
|------------|-------------|
| 📊 **visualize.py** | Gráficos de datos y regresión |
| 📈 **precision.py** | Métricas: R², MSE, RMSE, MAE, MAPE |
| 📉 **learning_curve.py** | Curva de convergencia del algoritmo |
| 🎨 **Interfaz** | Salidas coloridas y formateadas |
| 🎓 **Overfitting** | Explicación conceptual del sobreajuste |

</td>
</tr>
</table>

> 💡 **Nota sobre el 5º punto bonus:** Según el PDF oficial de evaluación, hay un punto bonus adicional si puedes **explicar qué es el overfitting** durante la defensa. Consulta la sección detallada en [MATHS.md](MATHS.md#-overfitting-sobreajuste---bonus-point).

## 📊 Dataset

El archivo `data.csv` contiene datos reales de precios de coches:

| Campo | Descripción | Rango |
|-------|-------------|-------|
| **km** | Kilometraje del coche | 22,899 - 240,000 km |
| **price** | Precio del coche | 3,650€ - 8,290€ |

📌 **Total:** 24 muestras de entrenamiento

## 🚀 Instalación

### 📦 Requisitos básicos
```bash
Python 3.x  # Ya instalado en sistemas 42 
```

### 🎨 Para la parte bonus (visualización)
```bash
pip install matplotlib
# o usar el Makefile
make install
```

## 💻 Uso

### 🧠 1. Entrenar el modelo

```bash
python3 train.py
# o usando Makefile (con ejecución optimizada)
make train
```

**¿Qué hace?**
- ✓ Lee los datos de `data.csv`
- ✓ Ejecuta el algoritmo de gradiente descendente
- ✓ Guarda los parámetros θ₀ y θ₁ en `thetas.txt`
- ✓ Muestra el progreso del entrenamiento

💡 **Tip:** El Makefile incluye verificaciones automáticas de archivos y ejecución optimizada.

<details>
<summary>📋 Ver ejemplo de salida</summary>

```plaintext
Cargando datos desde 'data.csv'...
Datos cargados: 24 muestras
Rango de kilometraje: 22899 - 240000 km
Rango de precios: 3650 - 8290€

Iniciando entrenamiento con 24 muestras...
Learning rate: 0.1, Iteraciones: 1000
Iteración 1/1000 - MSE: 0.500000
Iteración 100/1000 - MSE: 0.021234
...
Iteración 1000/1000 - MSE: 0.002145

Parámetros guardados en 'thetas.txt'
θ0 = 8499.72
θ1 = -0.021893

¡Entrenamiento completado exitosamente!
```
</details>

---

### 🔮 2. Predecir precios

```bash
python3 predict.py
# o usando Makefile
make predict
```

**Ejemplo interactivo:**
```plaintext
Introduce el kilometraje del coche: 50000
Precio estimado para 50000 km: 7405.07€
```

---

### 📊 3. Visualizar resultados (Bonus)

```bash
python3 visualize.py
# o usando Makefile
make visualize
```

**Muestra un gráfico con:**
- 🔵 Puntos azules → datos originales
- 🔴 Línea roja → regresión lineal calculada

---

### 📈 4. Evaluar precisión (Bonus)

```bash
python3 precision.py
# o usando Makefile
make precision
```

---

### 📉 5. Visualizar curva de aprendizaje (Bonus)

```bash
python3 learning_curve.py
# o usando Makefile
make learning_curve
```

**Muestra dos gráficos:**
- 📈 **Gráfico superior:** Evolución completa del MSE durante todas las iteraciones
- 🔍 **Gráfico inferior:** Zoom de las primeras 100 iteraciones con punto de convergencia

**Información mostrada:**
- MSE inicial y final
- Porcentaje de reducción del error
- Iteración aproximada de convergencia

---

### 🧪 6. Ejecutar suite de tests completa

```bash
./test_auto.sh
# o usando Makefile
make test
```

**Verifica:**
- ✓ Todos los requisitos del PDF de evaluación oficial
- ✓ 7 puntos críticos obligatorios
- ✓ Predicción antes/después del entrenamiento
- ✓ Ecuaciones correctas
- ✓ Asignación simultánea de θ₀ y θ₁
- ✓ No uso de librerías prohibidas
- ✓ Funcionalidades bonus
- ✓ Robustez y calidad del código

**Resultado:** Checklist completo de aprobación con 39 tests automatizados.

---

### � 7. Simulación de evaluación oficial de 42

```bash
./evaluation.sh
```

**Guía interactiva que simula la evaluación real de 42:**
- 📄 Traduce cada punto del PDF oficial al español
- 🔍 Verifica cada requisito paso a paso
- 📂 Muestra archivos y líneas exactas que implementan cada punto
- 💻 Ejecuta pruebas prácticas en tiempo real
- ✅ Sistema de puntuación (mandatory + bonus)
- 🎯 Pausas entre secciones para el evaluador

**Perfecto para:**
- Prepararte antes de la defensa
- Entender qué se evalúa exactamente
- Ver dónde está implementado cada requisito
- Simular la evaluación real de 42

---

### 📊 8. Evaluar métricas de precisión

```bash
python3 precision.py
# o usando Makefile
make precision
```

**Métricas calculadas:**

| Métrica | Descripción |
|---------|-------------|
| **R²** | Coeficiente de determinación (0-1, donde 1 es perfecto) |
| **MSE** | Error cuadrático medio |
| **RMSE** | Raíz del MSE (en la misma escala que los datos) |
| **MAE** | Error absoluto medio |
| **MAPE** | Error porcentual medio |

<details>
<summary>📋 Ver ejemplo de salida</summary>

```plaintext
============================================================
         EVALUACIÓN DE PRECISIÓN DEL MODELO
============================================================

Parámetros del modelo:
  θ₀ (intersección): 8,499.72
  θ₁ (pendiente):    -0.02189331

Número de muestras: 24

Métricas de precisión:
  R² (Coef. determinación): 0.8642
    → Buen ajuste

  MSE (Error cuadrático medio):  156,234.52
  RMSE (Raíz del MSE):           395.27€
  MAE (Error absoluto medio):    324.18€
  MAPE (Error porcentual medio): 4.82%

============================================================

Interpretación:
  • El modelo explica el 86.42% de la varianza en los precios
  • Error promedio de ±324€ en las predicciones
  • Error típico (RMSE) de ±395€
============================================================
```
</details>

---

## 🛠️ Comandos del Makefile

El proyecto incluye un Makefile optimizado con todas las operaciones comunes:

| Comando | Descripción |
|---------|-------------|
| `make` o `make all` | Ejecuta todo el flujo completo (limpieza → entrenamiento → demo → tests) |
| `make train` | Entrena el modelo y genera thetas.txt |
| `make predict` | Ejecuta predicción interactiva |
| `make visualize` | Muestra gráficos (requiere matplotlib) |
| `make precision` | Calcula y muestra métricas de precisión |
| `make learning_curve` | Visualiza curva de aprendizaje |
| `make test` | Ejecuta suite completa de tests (test_auto.sh) |
| `make eval` | Simulación de evaluación 42 (evaluation.sh) |
| `make bonus` | Ejecuta todas las funcionalidades bonus |
| `make demo` | Demostración interactiva con predicciones de ejemplo |
| `make install` | Instala dependencias (matplotlib) |
| `make clean` | Elimina thetas.txt y mse_history.txt |
| `make fclean` | Limpieza completa (clean + .pyc + __pycache__ + test_tmp/) |
| `make re` | Re-entrena desde cero (fclean + train) |
| `make help` | Muestra ayuda con todos los comandos disponibles |

💡 **Tip:** Usa `make help` para ver la lista completa de comandos con descripciones.

---

## 🧮 Algoritmo

Para una explicación matemática completa y rigurosa, consulta **[MATHS.md](MATHS.md)**.

### 📐 Función de hipótesis

```math
estimatePrice(mileage) = θ₀ + (θ₁ × mileage)
```

### 🎯 Gradiente Descendente

Las fórmulas implementadas según el subject:

```math
tmpθ₀ = learningRate × (1/m) × Σ(estimatePrice(mileage[i]) - price[i])
```

```math
tmpθ₁ = learningRate × (1/m) × Σ((estimatePrice(mileage[i]) - price[i]) × mileage[i])
```

**Donde:**

| Variable | Significado |
|----------|-------------|
| **m** | Número de muestras en el dataset |
| **learningRate** | Tasa de aprendizaje (0.1 por defecto) |
| **θ₀, θ₁** | Parámetros del modelo (se actualizan simultáneamente) |

📖 **Para más detalles:** Consulta la derivación completa en [MATHS.md](MATHS.md) que incluye:
- Derivación de las ecuaciones de gradiente descendente
- Función de coste (MSE) y su optimización
- Normalización y su impacto matemático
- Métricas de evaluación (R², RMSE, MAE, MAPE)

### 🔄 Normalización

Para mejorar la convergencia del algoritmo:
1. 📊 **Normaliza** los datos durante el entrenamiento
2. 🧠 **Entrena** el modelo con datos normalizados
3. 🔙 **Desnormaliza** los parámetros θ al finalizar
4. 💾 **Guarda** los parámetros listos para usar con datos originales

🔍 **Implementación detallada:** Ver [PYTHON.md](PYTHON.md) para el análisis completo del código.

## 📁 Estructura de archivos

```plaintext
ft_linear_regression/
│
├── 📄 data.csv              # Dataset de entrenamiento (24 muestras)
│
├── 🔮 predict.py            # Programa de predicción (OBLIGATORIO)
├── 🧠 train.py              # Programa de entrenamiento (OBLIGATORIO)
├── 💾 thetas.txt            # Parámetros guardados (generado por train.py)
├── 📉 mse_history.txt       # Historial MSE (generado por train.py)
│
├── 📊 visualize.py          # Visualización gráfica (BONUS)
├── 📈 precision.py          # Cálculo de precisión (BONUS)
├── 📉 learning_curve.py     # Curva de aprendizaje (BONUS)
│
├── 🛠️  Makefile             # Automatización de comandos (optimizado)
├── 🧪 test_auto.sh          # Suite de testing exhaustiva (850+ líneas)
├── 📋 evaluation.sh         # Guía de evaluación 42 punto por punto (850 líneas)
│
├── 📝 README.md             # Documentación principal (este archivo)
├── 📐 MATHS.md              # Fundamentos matemáticos detallados
├── 🐍 PYTHON.md             # Implementación y código Python
└── 🚫 .gitignore            # Archivos ignorados por git
```

## 📚 Documentación adicional

Este proyecto incluye documentación técnica detallada:

| Documento | Contenido |
|-----------|-----------|
| 📝 **[README.md](README.md)** | Documentación principal y guía de uso |
| 📐 **[MATHS.md](MATHS.md)** | Fundamentos matemáticos, derivaciones y teoría |
| 🐍 **[PYTHON.md](PYTHON.md)** | Análisis del código e implementación |

💡 **Recomendación:** Lee [MATHS.md](MATHS.md) para entender la teoría detrás del algoritmo, y [PYTHON.md](PYTHON.md) para los detalles de implementación.

## 🧪 Sistema de Testing

### 📋 Suite de Tests Automática (`test_auto.sh`)

El proyecto incluye un sistema de testing exhaustivo (850+ líneas) que verifica **todos los puntos del PDF oficial de evaluación** de 42:

```bash
./test_auto.sh
# o
make test
```

**Verifica 7 puntos críticos obligatorios:**

| # | Requisito | Descripción |
|---|-----------|-------------|
| 1️⃣ | **Archivos obligatorios** | data.csv, predict.py, train.py |
| 2️⃣ | **No librerías prohibidas** | Sin numpy.polyfit, sklearn.fit |
| 3️⃣ | **Ecuación correcta** | estimatePrice = θ₀ + (θ₁ * mileage) |
| 4️⃣ | **Asignación simultánea** | Variables temporales tmp_theta0/1 |
| 5️⃣ | **Guardado de parámetros** | thetas.txt generado correctamente |
| 6️⃣ | **Lectura de CSV** | data.csv procesado correctamente |
| 7️⃣ | **Gradient descent** | learning_rate implementado |

**39 tests automatizados que cubren:**
- ✅ Predicción antes de entrenar (debe dar 0)
- ✅ Validación de entradas inválidas
- ✅ Entrenamiento y convergencia
- ✅ Predicción después de entrenar
- ✅ Fórmulas matemáticas del subject
- ✅ Funcionalidades bonus (visualize, precision, learning_curve)
- ✅ Robustez del código
- ✅ Calidad y estilo de código
- ✅ Compliance con subject oficial
- ✅ Rendimiento y velocidad

**Salida final:** Checklist completo de aprobación indicando si el proyecto está listo para la evaluación de 42.

<details>
<summary>📋 Ver ejemplo de salida final</summary>

```plaintext
╔════════════════════════════════════════════════════════════════════╗
║        VERIFICACIÓN DE PUNTOS CRÍTICOS (evaluation.pdf)            ║
╚════════════════════════════════════════════════════════════════════╝

Checklist oficial de evaluación:

  ✓ Archivos obligatorios presentes
  ✓ No usa librerías prohibidas (numpy.polyfit, sklearn)
  ✓ Usa ecuación correcta: θ0 + (θ1 * mileage)
  ✓ Asignación SIMULTÁNEA de θ0 y θ1 (variables tmp)
  ✓ Guarda θ0 y θ1 en archivo (thetas.txt)
  ✓ Lee el archivo CSV
  ✓ Implementa gradient descent (learning_rate)

Puntos críticos aprobados: 7/7

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  ✓✓✓ PROYECTO LISTO PARA EVALUACIÓN ✓✓✓                     ║
║                                                              ║
║  Todos los requisitos del PDF de evaluación se cumplen      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

★★★ EXCELENTE - 100% READY ★★★
```
</details>

---

## ⚙️ Parámetros ajustables

Puedes modificar el comportamiento del entrenamiento editando `train.py`:

```python
# Configuración del entrenamiento
theta0, theta1 = train_model(
    mileages, 
    prices, 
    learning_rate=0.1,     # 📊 Tasa de aprendizaje
    iterations=1000        # 🔄 Número de iteraciones
)
```

| Parámetro | Valor por defecto | Descripción |
|-----------|-------------------|-------------|
| `learning_rate` | 0.1 | Velocidad de aprendizaje del algoritmo |
| `iterations` | 1000 | Número de veces que se actualizan los θ |

💡 **Tip:** Si el MSE no converge, prueba reduciendo el `learning_rate`.

## ✅ Cumplimiento del Subject

<table>
<tr>
<td width="50%">

### 📋 Parte Obligatoria

| Requisito | Estado |
|-----------|--------|
| Programa de predicción | ✅ |
| Programa de entrenamiento | ✅ |
| Fórmulas especificadas | ✅ |
| Actualización simultánea θ₀ y θ₁ | ✅ |
| Almacenamiento de parámetros | ✅ |
| Sin librerías prohibidas | ✅ |

</td>
<td width="50%">

### ⭐ Parte Bonus

| Requisito | Estado |
|-----------|--------|
| Gráfico de datos | ✅ |
| Gráfico de regresión | ✅ |
| Cálculo de precisión | ✅ |
| Curva de aprendizaje | ✅ |
| Makefile estructurado | ✅ |
| Explicar overfitting | ✅ |

> 🎯 **Bonus 1-4:** Implementados en código  
> 🎓 **Bonus 5:** Explicación conceptual (ver [MATHS.md](MATHS.md#-overfitting-sobreajuste---bonus-point))

</td>
</tr>
</table>

> 🎉 **Resultado:** Proyecto 100% completo y listo para evaluación

## 🔍 Notas técnicas

<details>
<summary><b>1. 🔄 Normalización de datos</b></summary>

Se normalizan los datos para evitar problemas de escala y mejorar la convergencia del gradiente descendente. Esto es especialmente importante cuando los valores de entrada (km) y salida (precio) tienen rangos muy diferentes.

</details>

<details>
<summary><b>2. 🔙 Desnormalización de parámetros</b></summary>

Los parámetros θ se desnormalizan antes de guardarlos para que funcionen directamente con datos en su escala original, sin necesidad de normalizar en el programa de predicción.

</details>

<details>
<summary><b>3. 🎯 Valores iniciales</b></summary>

Antes del primer entrenamiento, θ₀ y θ₁ son 0, por lo que todas las predicciones serán 0. Esto es correcto según el subject.

</details>

<details>
<summary><b>4. 📉 Convergencia</b></summary>

El MSE (Mean Squared Error) mostrado durante el entrenamiento debe disminuir progresivamente. Si aumenta o se mantiene constante, considera ajustar el learning rate.

</details>

## 🎓 Conceptos aprendidos

```mermaid
graph LR
    A[📊 Regresión Lineal] --> B[🎯 Gradiente Descendente]
    A --> C[📈 Función de Hipótesis]
    B --> D[🔄 Normalización]
    B --> E[📉 Función de Coste MSE]
    C --> F[✅ Métricas de Evaluación]
    F --> G[R² - RMSE - MAE]
```

### 📖 Conocimientos aplicados

- 📊 **Regresión lineal simple** con una variable
- 🎯 **Gradiente descendente** para optimización
- 🔄 **Normalización** de datos para mejor convergencia
- 📉 **Función de coste** (MSE - Mean Squared Error)
- 📈 **Métricas de evaluación** (R², RMSE, MAE, MAPE)
- 📊 **Visualización** de datos y modelos
- 🐍 **Python** orientado a machine learning
- 🛠️ **Makefile** con reglas optimizadas y phony targets

### 🎯 Recursos de aprendizaje

Para profundizar en los conceptos:
- **Teoría matemática:** Lee [MATHS.md](MATHS.md) para derivaciones y fundamentos
- **Implementación práctica:** Consulta [PYTHON.md](PYTHON.md) para análisis del código
- **Visualización:** Ejecuta `make visualize` para ver el modelo en acción
- **Evaluación:** Usa `make precision` para entender el rendimiento

---

<div align="center">

## 📝 Autor

**Proyecto ft_linear_regression**  
🏫 42 Málaga - Campus 42  
👤 sternero  
📅 Enero 2026

---

## 📄 Licencia

Este proyecto es parte del currículum de **42 School**.

[![42 School](https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white)](https://www.42malaga.com/)

</div>
