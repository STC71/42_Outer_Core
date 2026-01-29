# DSLR - Data Science × Regresión Logística
## Harry Potter y el Científico de Datos

Este proyecto implementa un clasificador de regresión logística multiclase para clasificar a los estudiantes de Hogwarts en sus casas usando la estrategia One-vs-All (OvA).

**Resultado alcanzado: ✅ 98.12% de precisión** (Requerido: ≥98%)

## Estructura del Proyecto

```
dslr/
├── README.md                      # Este archivo
├── describe.py                    # Análisis estadístico (OBLIGATORIO)
├── histogram.py                   # Visualización de distribución homogénea (OBLIGATORIO)
├── scatter_plot.py                # Análisis de características similares (OBLIGATORIO)
├── pair_plot.py                   # Matriz de correlación de características (OBLIGATORIO)
├── logreg_train.py                # Entrenamiento con descenso de gradiente (OBLIGATORIO)
├── logreg_predict.py              # Predicción y clasificación (OBLIGATORIO)
├── data_preprocessing.py          # Utilidades de limpieza y normalización de datos
├── logreg_train_stochastic.py     # BONUS: Descenso de Gradiente Estocástico
├── logreg_train_minibatch.py      # BONUS: Descenso de Gradiente Mini-Batch
├── evaluate.py                    # Evaluación de precisión
├── cross_validate.py              # Validación cruzada (BONUS)
├── test_pipeline.sh               # Script de testing del pipeline
├── evaluation.sh                  # Guía de evaluación interactiva (NUEVO)
├── test_auto.sh                   # Tests automatizados completos (NUEVO)
├── Makefile                       # Automatización de tareas
├── weights.pkl                    # Pesos del modelo entrenado (generado)
├── houses.csv                     # Salida de predicciones (generado)
├── dataset_train.csv              # Dataset de entrenamiento
└── dataset_test.csv               # Dataset de prueba
```

## Requisitos

- Python 3.x
- NumPy (solo para operaciones matriciales)
- Matplotlib (para visualizaciones)
- No se permiten métodos de pandas DataFrame
- No se permite sklearn para el algoritmo principal

## Detalles de Implementación

### Parte Obligatoria

1. **describe.py**: Descripción estadística sin usar funciones incorporadas
   - Count, Mean, Std, Min, 25%, 50%, 75%, Max
   - Implementación personalizada de todas las funciones estadísticas

2. **Visualización de Datos**:
   - **histogram.py**: Identifica el curso con la distribución de puntuaciones más homogénea
   - **scatter_plot.py**: Encuentra las dos características más similares
   - **pair_plot.py**: Muestra todas las correlaciones de características para la selección

3. **Regresión Logística**:
   - **logreg_train.py**: Clasificador multiclase One-vs-All
   - Implementación de Descenso de Gradiente por Lotes
   - Función de coste y sigmoide personalizadas
   - Guarda los pesos entrenados
   - **logreg_predict.py**: Predice las asignaciones de casas
   - Carga los pesos entrenados
   - Genera houses.csv

### Parte Bonus

1. **describe.py extendido**: Medidas estadísticas adicionales (moda, rango, IQR, etc.)
2. **Descenso de Gradiente Estocástico**: Entrenamiento más rápido con actualizaciones por muestra
3. **Descenso de Gradiente Mini-Batch**: Equilibrio entre lotes y estocástico
4. **Comparación de múltiples algoritmos de optimización**

## Fundamento Matemático

### Función de Coste de Regresión Logística
```
J(θ) = -1/m Σ[y⁽ⁱ⁾ log(hθ(x⁽ⁱ⁾)) + (1-y⁽ⁱ⁾) log(1-hθ(x⁽ⁱ⁾))]
```

### Función de Hipótesis
```
hθ(x) = g(θᵀx)
donde g(z) = 1/(1 + e⁻ᶻ)
```

### Gradiente
```
∂J(θ)/∂θⱼ = 1/m Σ(hθ(x⁽ⁱ⁾) - y⁽ⁱ⁾)xⱼ⁽ⁱ⁾
```

## Uso

### Inicio Rápido con Makefile

```bash
# Ver todos los comandos disponibles
make help

# Pipeline completo (obligatorio)
make test

# Pipeline con bonus
make bonus

# Pasos individuales
make describe      # Estadísticas
make visualize     # Gráficos
make train         # Entrenar modelo
make predict       # Generar predicciones
make evaluate      # Evaluar precisión

# Tests automatizados
make test_auto     # Ejecutar todos los tests automáticos
make evaluation    # Guía de evaluación interactiva
```

### Tests y Evaluación

#### Tests Automatizados (`test_auto.sh`)
Script que ejecuta automáticamente todos los tests del proyecto:
- ✅ Verificación de archivos requeridos
- ✅ Comprobación de librerías prohibidas
- ✅ Tests de ejecución de todos los scripts
- ✅ Validación de precisión (≥98%)
- ✅ Tests de integración del pipeline completo
- ✅ Tests de características bonus

```bash
# Ejecutar tests automatizados
./test_auto.sh
# o
make test_auto
```

#### Guía de Evaluación (`evaluation.sh`)
Script interactivo que simula la evaluación de 42:
- 📋 Checklist completo de requisitos del subject
- 🔍 Verificación paso a paso de cada componente
- 📄 Referencias a archivos y líneas específicas
- 💡 Explicaciones de la implementación
- ⏸️ Pausas interactivas para verificación manual

```bash
# Ejecutar guía de evaluación
./evaluation.sh
# o
make evaluation
```

### Uso Detallado

#### 1. Análisis de Datos
```bash
python describe.py dataset_train.csv
```

#### 2. Visualización de Datos
```bash
python histogram.py dataset_train.csv      # ¿Qué curso tiene distribución homogénea?
python scatter_plot.py dataset_train.csv   # ¿Qué características son más similares?
python pair_plot.py dataset_train.csv      # Matriz de correlación completa
```

#### 3. Entrenamiento
```bash
# Descenso de Gradiente por Lotes (obligatorio)
python logreg_train.py dataset_train.csv 0.1 1000
# Argumentos: <datos> <tasa_aprendizaje> <iteraciones>

# BONUS: Descenso de Gradiente Estocástico
python logreg_train_stochastic.py dataset_train.csv 0.01 100

# BONUS: Descenso de Gradiente Mini-Batch
python logreg_train_minibatch.py dataset_train.csv 0.1 100 32
# Argumentos: <datos> <lr> <épocas> <tamaño_lote>
```

#### 4. Predicción
```bash
python logreg_predict.py dataset_test.csv weights.pkl houses.csv
# Argumentos: <datos_prueba> <pesos_modelo> <archivo_salida>
```

#### 5. Validación
```bash
python cross_validate.py dataset_train.csv 0.8
# Argumentos: <datos_entrenamiento> <proporción_entrenamiento>
```

## Rendimiento y Resultados

### Modelo Principal (Batch Gradient Descent)
- **Precisión Alcanzada**: ✅ **98.12%** (Requerido: ≥98%)
- **Learning Rate**: 0.1
- **Iteraciones**: 1000
- **Tiempo de Entrenamiento**: ~5-10 segundos
- **Features**: 13 características (todos los cursos de Hogwarts)

### Factores de Éxito
- Las 13 características numéricas usadas para clasificación
- Normalización Z-score para escalado de características
- Tasa de aprendizaje óptima (0.1) e iteraciones (1000)
- Estrategia One-vs-All para clasificación multiclase
- Manejo adecuado de valores faltantes (imputación por media)

### Distribución de Predicciones
- Gryffindor: ~20%
- Hufflepuff: ~36%
- Ravenclaw: ~28%
- Slytherin: ~16%

### Métricas por Casa
Todas las casas tienen:
- Precision: >96%
- Recall: >96%
- F1-Score: >0.96

## Características Utilizadas

Se usan las 13 características de cursos de Hogwarts:
- Aritmancia
- Astronomía
- Herbología
- Defensa Contra las Artes Oscuras
- Adivinación
- Estudios Muggles
- Runas Antiguas
- Historia de la Magia
- Transformación
- Pociones
- Cuidado de Criaturas Mágicas
- Encantamientos
- Vuelo

## Preprocesamiento de Datos

- **Valores Faltantes**: Manejados mediante imputación por media/mediana
- **Normalización**: Escalado Min-Max o normalización Z-score
- **Selección de Características**: Basada en análisis de correlación

## Conceptos Clave Implementados

### 1. Regresión Logística
- Algoritmo de clasificación (NO regresión, a pesar del nombre)
- Predice probabilidades entre 0 y 1 usando función sigmoide
- Función de Hipótesis: `h(x) = sigmoid(θᵀx)` donde `sigmoid(z) = 1/(1 + e⁻ᶻ)`

### 2. One-vs-All (One-vs-Rest)
Para 4 casas, se entrenan 4 clasificadores binarios:
1. Gryffindor vs (Hufflepuff + Ravenclaw + Slytherin)
2. Hufflepuff vs (Gryffindor + Ravenclaw + Slytherin)
3. Ravenclaw vs (Gryffindor + Hufflepuff + Slytherin)
4. Slytherin vs (Gryffindor + Hufflepuff + Ravenclaw)

**Predicción**: Elegir casa con mayor probabilidad

### 3. Tres Variantes de Gradient Descent

#### A) Batch Gradient Descent (OBLIGATORIO)
```python
for iteration in range(num_iterations):
    gradient = (1/m) * Σ[(h(xⁱ) - yⁱ) * xⁱ]  # Usa TODOS los ejemplos
    θ = θ - α * gradient
```
- ✅ Convergencia estable
- ❌ Lento con datasets grandes

#### B) Stochastic Gradient Descent (BONUS)
```python
for epoch in range(num_epochs):
    shuffle(data)
    for each example (xⁱ, yⁱ):
        gradient = (h(xⁱ) - yⁱ) * xⁱ  # Un solo ejemplo
        θ = θ - α * gradient
```
- ✅ Muy rápido por iteración
- ❌ Convergencia ruidosa

#### C) Mini-Batch Gradient Descent (BONUS)
```python
for epoch in range(num_epochs):
    shuffle(data)
    for each batch of size b:
        gradient = (1/b) * Σ[(h(xⁱ) - yⁱ) * xⁱ]  # Sobre el batch
        θ = θ - α * gradient
```
- ✅ Compromiso entre Batch y Stochastic
- ✅ Más estable y eficiente

## Implementación Sin Librerías Externas

Todas estas funciones están implementadas desde cero:

### Estadísticas (describe.py)
- Count, Mean, Standard Deviation
- Min, Max, Percentiles (25%, 50%, 75%)
- BONUS: Range, IQR, Skewness, Kurtosis

### Matemáticas (logreg_train.py)
- Función Sigmoid
- Logaritmo Natural
- Función de Coste Logística
- Cálculo de Gradientes
- Normalización Z-score

### Análisis (scatter_plot.py)
- Correlación de Pearson
- Covarianza

## Solución de Problemas

### "python: command not found"
Usar `python3` en lugar de `python`

### "matplotlib not found"
```bash
pip install matplotlib
```
O las visualizaciones se omitirán (no obligatorias)

### Baja precisión (<98%)
- Aumentar iteraciones: `python3 logreg_train.py dataset_train.csv 0.1 2000`
- Ajustar tasa de aprendizaje: probar 0.05 o 0.2
- Ejecutar validación cruzada: `python3 cross_validate.py dataset_train.csv`

## Archivos Generados

Al ejecutar el proyecto se generan:
```
weights.pkl                # Modelo entrenado (Batch GD)
weights_sgd.pkl            # BONUS: Modelo SGD
weights_minibatch.pkl      # BONUS: Modelo Mini-Batch
houses.csv                 # Predicciones (formato requerido)
histogram_analysis.png     # Visualización
scatter_plot_analysis.png  # Visualización
pair_plot.png              # Visualización
```

## Autores

- sternero (42 Málaga)

## Referencias

- Subject: dslr_subject.pdf
- 42 School - Rama de Inteligencia Artificial
