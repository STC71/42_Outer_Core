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

<a id="indice"></a>

## 📑 Índice

1. [**Esquemas visuales del proceso matemático**](#-esquemas-visuales-del-proceso-matemático)
2. [Objetivo](#1️⃣-objetivo)
3. [Función de coste (MSE)](#3️⃣-función-de-coste-mse)
4. [¿Qué son las derivadas? - Fundamentos de cálculo](#-qué-son-las-derivadas---fundamentos-de-cálculo)
5. [Derivación del gradiente (parcial)](#4️⃣-derivación-del-gradiente-parcial)
6. [Descenso por gradiente](#5️⃣-descenso-por-gradiente)
7. [Normalización de características](#6️⃣-normalización-de-características)
8. [Covarianza y Correlación](#-covarianza-y-correlación)
9. [Métricas de evaluación](#7️⃣-métricas-de-evaluación)
10. [Análisis de Residuos](#-análisis-de-residuos)
11. [Ejemplo numérico (dos iteraciones completas)](#8️⃣-ejemplo-numérico-dos-iteraciones-completas)
12. [Consideraciones prácticas](#9️⃣-consideraciones-prácticas)
13. [Overfitting (Sobreajuste) - Bonus Point](#-overfitting-sobreajuste---bonus-point)
14. [Implementación en el proyecto](#-implementación-en-el-proyecto)
15. [Referencias y recursos adicionales](#-referencias-y-recursos-adicionales)

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

## 📊 Esquemas visuales del proceso matemático

Esta sección presenta de forma visual y ordenada todos los pasos matemáticos que se ejecutan en nuestro proyecto de regresión lineal, desde la carga de datos hasta la predicción final.

### 🔄 Esquema general del flujo del algoritmo

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    PROCESO COMPLETO DE REGRESIÓN LINEAL                   ║
╚═══════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 1: PREPARACIÓN DE DATOS                                           │
└─────────────────────────────────────────────────────────────────────────┘

    📁 data.csv
       ↓
    ┌──────────────────┐
    │  Cargar datos    │  →  x = [240000, 139800, ..., 61789]  (24 valores)
    │  load_data()     │  →  y = [3650, 3800, ..., 8500]       (24 valores)
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  Normalizar      │  →  x_norm = [(x - μ_x) / σ_x]
    │  normalize_data()│  →  y_norm = [(y - μ_y) / σ_y]
    └────────┬─────────┘      
             │                μ_x = 103,503 km    σ_x = 61,298 km
             │                μ_y = 5,899€        σ_y = 2,094€
             ↓
    ✅ Datos preparados para entrenamiento


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 2: ENTRENAMIENTO (Gradiente Descendente)                          │
└─────────────────────────────────────────────────────────────────────────┘

    Inicialización: θ₀ = 0, θ₁ = 0
    
    ╔════════════════════════════════════════════════════╗
    ║  ITERACIÓN t (se repite 1000 veces)                ║
    ╚════════════════════════════════════════════════════╝
    
    Para cada iteración t:
    
    ┌─────────────────────────────────────────────────────┐
    │ 1️⃣  PREDICCIÓN                                      │
    │                                                     │
    │  Para cada muestra i = 1 hasta m = 24:              │
    │                                                     │
    │      ŷᵢ = h_θ(xᵢ) = θ₀ + θ₁ · xᵢ                    │
    │                                                     │
    │  Ejemplo (iter=0):                                  │
    │      x₁_norm = 2.23  →  ŷ₁ = 0 + 0·2.23 = 0         │
    └─────────────────────────────────────────────────────┘
              ↓
    ┌─────────────────────────────────────────────────────┐
    │ 2️⃣  CÁLCULO DEL ERROR                               │
    │                                                     │
    │  Para cada muestra i:                               │
    │                                                     │
    │      errorᵢ = ŷᵢ - yᵢ                               │
    │                                                     │
    │  Ejemplo:                                           │
    │      error₁ = 0 - (-1.07) = 1.07                    │
    └─────────────────────────────────────────────────────┘
              ↓
    ┌─────────────────────────────────────────────────────┐
    │ 3️⃣  FUNCIÓN DE COSTE (MSE)                          │
    │                                                     │
    │      J(θ) = 1/(2m) · Σᵢ₌₁ᵐ (errorᵢ)²                │
    │                                                     │
    │           = 1/48 · Σᵢ₌₁²⁴ (ŷᵢ - yᵢ)²                │
    │                                                     │
    │  Mide qué tan mal están nuestras predicciones       │
    └─────────────────────────────────────────────────────┘
              ↓
    ┌─────────────────────────────────────────────────────┐
    │ 4️⃣  CÁLCULO DEL GRADIENTE                           │
    │                                                     │
    │  Derivadas parciales (dirección de mayor error):    │
    │                                                     │
    │      ∂J/∂θ₀ = 1/m · Σᵢ₌₁ᵐ errorᵢ                    │
    │                                                     │
    │      ∂J/∂θ₁ = 1/m · Σᵢ₌₁ᵐ (errorᵢ · xᵢ)             │
    │                                                     │
    │  Nos dice en qué dirección mover θ₀ y θ₁            │
    └─────────────────────────────────────────────────────┘
              ↓
    ┌─────────────────────────────────────────────────────┐
    │ 5️⃣  ACTUALIZACIÓN DE PARÁMETROS                     │
    │                                                     │
    │      θ₀_nuevo = θ₀_viejo - α · (∂J/∂θ₀)             │
    │                                                     │
    │      θ₁_nuevo = θ₁_viejo - α · (∂J/∂θ₁)             │
    │                                                     │
    │  donde α = 0.1 (learning rate)                      │
    │                                                     │
    │  ⚠️  Actualización SIMULTÁNEA de ambos parámetros   │
    └─────────────────────────────────────────────────────┘
              ↓
    ┌─────────────────────────────────────────────────────┐
    │ 6️⃣  CONVERGENCIA                                    │
    │                                                     │
    │  ¿Ha convergido el modelo?                          │
    │                                                     │
    │      Si |J(θ)ₜ - J(θ)ₜ₋₁| < ε  →  ✅ CONVERGE       │
    │      Si t < 1000                →  🔄 REPETIR       │
    │                                                     │
    │  (ε = tolerancia, típicamente 10⁻⁶)                 │
    └─────────────────────────────────────────────────────┘
    
    ╔════════════════════════════════════════════════════╗
    ║  FIN DE ITERACIONES                                ║
    ╚════════════════════════════════════════════════════╝
    
              ↓
    ✅ Parámetros óptimos en espacio normalizado: θ₀_norm, θ₁_norm


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 3: DESNORMALIZACIÓN                                               │
└─────────────────────────────────────────────────────────────────────────┘

    ┌──────────────────────────────────────┐
    │  Convertir parámetros normalizados   │
    │  a escala original                   │
    │                                      │
    │  θ₁ = θ₁_norm · (σ_y / σ_x)          │
    │                                      │
    │  θ₀ = μ_y - θ₁ · μ_x                 │
    │                                      │
    │  denormalize_theta()                 │
    └──────────────────┬───────────────────┘
                       ↓
    ✅ Resultado: θ₀ = 8,499€  θ₁ = -0.0214 €/km
    
    Guardado en: thetas.txt


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE 4: PREDICCIÓN (predict.py)                                        │
└─────────────────────────────────────────────────────────────────────────┘

    Usuario introduce: x_nuevo = 120,000 km
    
    ┌──────────────────────────────────┐
    │  Cargar parámetros entrenados    │
    │  load_thetas()                   │
    │                                  │
    │  θ₀ = 8,499                      │
    │  θ₁ = -0.0214                    │
    └──────────┬───────────────────────┘
               ↓
    ┌──────────────────────────────────┐
    │  Aplicar función lineal          │
    │                                  │
    │  ŷ = θ₀ + θ₁ · x                 │
    │                                  │
    │    = 8499 + (-0.0214) · 120000   │
    │                                  │
    │    = 8499 - 2568                 │
    │                                  │
    │    = 5,931€                      │
    └──────────┬───────────────────────┘
               ↓
    ✅ Predicción: 5,931€ para un coche con 120,000 km
```

### 📐 Esquema detallado de las fórmulas matemáticas

```
╔═══════════════════════════════════════════════════════════════════════════╗
║           FÓRMULAS MATEMÁTICAS DEL PROYECTO (ORDEN LÓGICO)                ║
╚═══════════════════════════════════════════════════════════════════════════╝

┌───────────────────────────────────────────────────────────────────────────┐
│ 1. MODELO LINEAL (Hipótesis)                                              │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   h_θ(x) = θ₀ + θ₁ · x                                                    │
│                                                                           │
│   Descripción: Ecuación de la recta que predice y a partir de x           │
│   Variables:                                                              │
│     • x      = variable de entrada (kilometraje)                          │
│     • θ₀     = intercepto (punto de corte con eje Y)                      │
│     • θ₁     = pendiente (inclinación de la recta)                        │
│     • h_θ(x) = predicción de salida (precio estimado)                     │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│ 2. NORMALIZACIÓN (Estandarización Z-score)                                │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   Media:           μ = (1/m) · Σᵢ₌₁ᵐ xᵢ                                   │
│                                                                           │
│   Varianza:        σ² = (1/m) · Σᵢ₌₁ᵐ (xᵢ - μ)²                           │
│                                                                           │
│   Desv. estándar:  σ = √σ²                                                │
│                                                                           │
│   Normalización:   x_norm = (x - μ) / σ                                   │
│                                                                           │
│   Propósito: Escalar los datos para que tengan μ=0 y σ=1                  │
│   Beneficio: Mejor convergencia del gradiente descendente                 │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│ 3. FUNCIÓN DE COSTE (Mean Squared Error)                                  │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   J(θ) = 1/(2m) · Σᵢ₌₁ᵐ [h_θ(xᵢ) - yᵢ]²                                   │
│                                                                           │
│        = 1/(2m) · Σᵢ₌₁ᵐ [θ₀ + θ₁·xᵢ - yᵢ]²                                │
│                                                                           │
│   Componentes:                                                            │
│     • [h_θ(xᵢ) - yᵢ]  = error de predicción para la muestra i             │
│     • [...]²           = error al cuadrado (penaliza grandes errores)     │
│     • Σᵢ₌₁ᵐ            = suma de errores de todas las muestras            │
│     • 1/(2m)           = promedio (el ½ simplifica derivadas)             │
│                                                                           │
│   Objetivo: MINIMIZAR J(θ) ajustando θ₀ y θ₁                              │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│ 4. DERIVADAS PARCIALES (Gradiente)                                        │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   Respecto a θ₀:                                                          │
│                                                                           │
│     ∂J/∂θ₀ = 1/m · Σᵢ₌₁ᵐ [h_θ(xᵢ) - yᵢ]                                   │
│                                                                           │
│            = 1/m · Σᵢ₌₁ᵐ [θ₀ + θ₁·xᵢ - yᵢ]                                │
│                                                                           │
│                                                                           │
│   Respecto a θ₁:                                                          │
│                                                                           │
│     ∂J/∂θ₁ = 1/m · Σᵢ₌₁ᵐ [h_θ(xᵢ) - yᵢ] · xᵢ                              │
│                                                                           │
│            = 1/m · Σᵢ₌₁ᵐ [(θ₀ + θ₁·xᵢ - yᵢ) · xᵢ]                         │
│                                                                           │
│                                                                           │
│   Gradiente completo (vector):                                            │
│                                                                           │
│     ∇J(θ) = [∂J/∂θ₀]                                                      │
│             [∂J/∂θ₁]                                                      │
│                                                                           │
│   Interpretación: Dirección de máximo crecimiento de J(θ)                 │
│                  (por eso restamos el gradiente para minimizar)           │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│ 5. ACTUALIZACIÓN DE PARÁMETROS (Gradiente Descendente)                    │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   Actualización simultánea:                                               │
│                                                                           │
│     θ₀ := θ₀ - α · ∂J/∂θ₀                                                 │
│                                                                           │
│     θ₁ := θ₁ - α · ∂J/∂θ₁                                                 │
│                                                                           │
│                                                                           │
│   Forma expandida:                                                        │
│                                                                           │
│     θ₀ := θ₀ - α · [1/m · Σᵢ₌₁ᵐ (h_θ(xᵢ) - yᵢ)]                           │
│                                                                           │
│     θ₁ := θ₁ - α · [1/m · Σᵢ₌₁ᵐ ((h_θ(xᵢ) - yᵢ) · xᵢ)]                    │
│                                                                           │
│                                                                           │
│   Parámetros:                                                             │
│     • α = learning rate (tasa de aprendizaje, ej: 0.1)                    │
│     • := significa "asignación simultánea"                                │
│                                                                           │
│   ⚠️  IMPORTANTE: Calcular ambas actualizaciones con los valores VIEJOS   │
│                  de θ₀ y θ₁, luego actualizar ambos a la vez              │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│ 6. DESNORMALIZACIÓN DE PARÁMETROS                                         │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   Convertir parámetros del espacio normalizado al original:               │
│                                                                           │
│     θ₁_original = θ₁_norm · (σ_y / σ_x)                                   │
│                                                                           │
│     θ₀_original = μ_y - θ₁_original · μ_x                                 │
│                                                                           │
│                                                                           │
│   Propósito: Usar el modelo entrenado con datos sin normalizar            │
│                                                                           │
│   Ejemplo:                                                                │
│     θ₁_norm = -0.9821                                                     │
│     σ_y = 2094€,  σ_x = 61298 km                                          │
│     μ_y = 5899€,  μ_x = 103503 km                                         │
│                                                                           │
│     θ₁ = -0.9821 · (2094/61298) = -0.0336 €/km                            │
│     θ₀ = 5899 - (-0.0336 · 103503) = 9,377€                               │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│ 7. MÉTRICAS DE EVALUACIÓN                                                 │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   Mean Squared Error (MSE):                                               │
│                                                                           │
│     MSE = 1/m · Σᵢ₌₁ᵐ (yᵢ - ŷᵢ)²                                          │
│                                                                           │
│     donde:                                                                │
│       m  = número de ejemplos                                             │
│       yᵢ = valor real (precio real del coche i)                           │
│       ŷᵢ = valor predicho por el modelo                                   │
│                                                                           │
│     ¿Qué mide?: El error cuadrático promedio entre predicciones y         │
│     valores reales. Penaliza más los errores grandes (por el cuadrado).   │
│                                                                           │
│     Interpretación: Cuanto más bajo, mejor. MSE = 0 → predicción          │
│     perfecta. En unidades al cuadrado (ej: euros²).                       │
│                                                                           │
│                                                                           │
│   Root Mean Squared Error (RMSE):                                         │
│                                                                           │
│     RMSE = √MSE = √[1/m · Σᵢ₌₁ᵐ (yᵢ - ŷᵢ)²]                               │
│                                                                           │
│     ¿Qué mide?: La raíz cuadrada del MSE. Devuelve el error promedio      │
│     en las mismas unidades que los datos originales (ej: euros).          │
│                                                                           │
│     Interpretación: "En promedio, nuestras predicciones se desvían        │
│     ±RMSE del valor real". Más intuitivo que MSE. Cuanto menor, mejor.    │
│                                                                           │
│     Ejemplo: RMSE = 500€ → nos equivocamos ~500€ en promedio.             │
│                                                                           │
│                                                                           │
│   Mean Absolute Error (MAE):                                              │
│                                                                           │
│     MAE = 1/m · Σᵢ₌₁ᵐ |yᵢ - ŷᵢ|                                           │
│                                                                           │
│     ¿Qué mide?: El error absoluto promedio (sin elevar al cuadrado).      │
│     Menos sensible a valores atípicos que RMSE.                           │
│                                                                           │
│     Interpretación: "En promedio, el error absoluto es de ±MAE".          │
│     Más robusto ante outliers. Cuanto menor, mejor.                       │
│                                                                           │
│     Ejemplo: MAE = 400€ → el error promedio absoluto es de 400€.          │
│                                                                           │
│                                                                           │
│   Coeficiente de Determinación (R²):                                      │
│                                                                           │
│     R² = 1 - [Σᵢ(yᵢ - ŷᵢ)² / Σᵢ(yᵢ - ȳ)²]                                 │
│                                                                           │
│        = 1 - (SS_res / SS_tot)                                            │
│                                                                           │
│     donde:                                                                │
│       ȳ      = media de y                                                 │
│       SS_res = Sum of Squares Residual (Σ de cuadrados de residuos)       │
│       SS_tot = Total Sum of Squares (Σ total de cuadrados)                │
│                                                                           │
│   El R² mide qué proporción de la variabilidad total es explicada por     │
│   tu modelo.                                                              │
│   Si SS_res es pequeño comparado con SS_tot, significa que tu modelo      │
│   predice bien y el R² se acerca a 1.                                     │
│                                                                           │
│   Interpretación de R²:                                                   │
│     • R² = 1.0   → Modelo perfecto (100% de varianza explicada)           │
│     • R² = 0.9   → Excelente (90% de varianza explicada)                  │
│     • R² = 0.5   → Regular (50% de varianza explicada)                    │
│     • R² = 0.0   → Modelo inútil (no mejor que la media)                  │
│     • R² < 0     → Peor que predecir siempre la media                     │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

### 🔢 Ejemplo numérico completo paso a paso

```
╔═══════════════════════════════════════════════════════════════════════════╗
║         EJEMPLO: 2 ITERACIONES COMPLETAS DEL ALGORITMO                    ║
╚═══════════════════════════════════════════════════════════════════════════╝

Dataset simplificado (3 muestras):
┌─────┬──────────┬────────┐
│  i  │ km (x)   │ € (y)  │
├─────┼──────────┼────────┤
│  1  │ 50,000   │ 7,500  │
│  2  │ 100,000  │ 6,000  │
│  3  │ 150,000  │ 4,500  │
└─────┴──────────┴────────┘

Datos normalizados:
  μ_x = 100,000    σ_x = 40,825
  μ_y = 6,000      σ_y = 1,225

┌─────┬─────────────┬─────────────┐
│  i  │ x_norm      │ y_norm      │
├─────┼─────────────┼─────────────┤
│  1  │ -1.225      │  1.225      │
│  2  │  0.000      │  0.000      │
│  3  │  1.225      │ -1.225      │
└─────┴─────────────┴─────────────┘

Parámetros: α = 0.1, m = 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ITERACIÓN 0:
────────────

Estado inicial: θ₀ = 0.000, θ₁ = 0.000

1️⃣  Predicciones:
   ŷ₁ = 0 + 0·(-1.225) = 0.000
   ŷ₂ = 0 + 0·(0.000)  = 0.000
   ŷ₃ = 0 + 0·(1.225)  = 0.000

2️⃣  Errores:
   e₁ = 0.000 - 1.225 = -1.225
   e₂ = 0.000 - 0.000 =  0.000
   e₃ = 0.000 - (-1.225) = 1.225

3️⃣  Función de coste:
   J(θ) = 1/6 · [(-1.225)² + 0² + (1.225)²]
        = 1/6 · [1.5006 + 0 + 1.5006]
        = 0.5004

4️⃣  Gradientes:
   ∂J/∂θ₀ = 1/3 · (-1.225 + 0 + 1.225) = 0.000
   ∂J/∂θ₁ = 1/3 · [(-1.225)·(-1.225) + 0·0 + 1.225·1.225]
          = 1/3 · [1.5006 + 0 + 1.5006]
          = 1.0004

5️⃣  Actualización:
   θ₀ := 0.000 - 0.1·(0.000) = 0.000
   θ₁ := 0.000 - 0.1·(1.0004) = -0.100

Resultado: θ₀ = 0.000, θ₁ = -0.100, J(θ) = 0.5004

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ITERACIÓN 1:
────────────

Estado: θ₀ = 0.000, θ₁ = -0.100

1️⃣  Predicciones:
   ŷ₁ = 0 + (-0.100)·(-1.225) = 0.123
   ŷ₂ = 0 + (-0.100)·(0.000)  = 0.000
   ŷ₃ = 0 + (-0.100)·(1.225)  = -0.123

2️⃣  Errores:
   e₁ = 0.123 - 1.225 = -1.102
   e₂ = 0.000 - 0.000 =  0.000
   e₃ = -0.123 - (-1.225) = 1.102

3️⃣  Función de coste:
   J(θ) = 1/6 · [(-1.102)² + 0² + (1.102)²]
        = 1/6 · [1.214 + 0 + 1.214]
        = 0.405

4️⃣  Gradientes:
   ∂J/∂θ₀ = 1/3 · (-1.102 + 0 + 1.102) = 0.000
   ∂J/∂θ₁ = 1/3 · [(-1.102)·(-1.225) + 0 + 1.102·1.225]
          = 1/3 · [1.350 + 0 + 1.350]
          = 0.900

5️⃣  Actualización:
   θ₀ := 0.000 - 0.1·(0.000) = 0.000
   θ₁ := -0.100 - 0.1·(0.900) = -0.190

Resultado: θ₀ = 0.000, θ₁ = -0.190, J(θ) = 0.405

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CONVERGENCIA:

Observa cómo J(θ) disminuye:
  Iter 0: J(θ) = 0.5004
  Iter 1: J(θ) = 0.405  ✓ Mejora del 19%

Tras 1000 iteraciones convergería a:
  θ₀_norm ≈ 0.000, θ₁_norm ≈ -1.000
  J(θ) ≈ 0.000 (error mínimo)

Desnormalizando:
  θ₁ = -1.000 · (1225/40825) = -0.030 €/km
  θ₀ = 6000 - (-0.030)·100000 = 9,000€

Ecuación final: Precio = 9,000 - 0.030 · km
```

### 🎯 Mapa conceptual de relaciones

```
                      OBJETIVO PRINCIPAL
                            │
              ┌─────────────┴─────────────┐
              │                           │
        MINIMIZAR J(θ)          PREDECIR y = h(x)
              │                           │
              │                   ┌───────┴───────┐
              │                   │               │
              │               θ₀ (base)      θ₁ (pendiente)
              │                   │               │
              │                   └───────┬───────┘
              │                           │
              │                   Ecuación: y = θ₀ + θ₁·x
              │                           │
              └───────────┬───────────────┘
                          │
                 GRADIENTE DESCENDENTE
                          │
              ┌───────────┴───────────┐
              │                       │
        ∂J/∂θ₀ = ?              ∂J/∂θ₁ = ?
              │                       │
              └───────────┬───────────┘
                          │
                  Actualizar θ₀ y θ₁
                          │
                  θ := θ - α·∇J(θ)
                          │
                   ┌──────┴──────┐
                   │             │
            α muy grande    α muy pequeño
            (diverge)       (lento)
                   │             │
                   └──────┬──────┘
                          │
                   α = 0.1 (óptimo)


    FLUJO DE DATOS:
    
    data.csv  →  Normalizar  →  Entrenar  →  Desnormalizar  →  thetas.txt
                      ↓             ↓              ↓
                   (μ, σ)     1000 iters     (θ₀, θ₁)
                                   ↓
                           MSE disminuye
                                   ↓
                            Convergencia


    RELACIÓN ENTRE CONCEPTOS:
    
    Dato raw (x, y)
         ↓
    Normalizado (x_norm, y_norm)  ←──┐
         ↓                           │
    Predicción: ŷ = θ₀ + θ₁·x        │
         ↓                           │
    Error: e = ŷ - y                 │
         ↓                           │
    Coste: J(θ) = Σe²/2m             │
         ↓                           │
    Gradiente: ∇J = [∂J/∂θ₀, ∂J/∂θ₁] │
         ↓                           │
    Actualizar: θ := θ - α·∇J        │
         │                           │
         └───────────────────────────┘
              (repetir hasta convergencia)
```

### 📊 Visualización de la convergencia

```
Evolución del coste J(θ) durante el entrenamiento:

J(θ)
  │
25M│ •                              Inicio (θ₀=0, θ₁=0)
  │  ╲
20M│   ╲
  │    ╲
15M│     •                          Mal modelo
  │      ╲
10M│       ╲
  │        ╲•
 5M│         ╲                      Mejorando...
  │          ╲•
 1M│           ╲___
  │               ╲___•            
100K│                   ╲____•      
  │                         ╲____• Convergiendo...
10K│                              ╲_____
  │                                    ╲___•
 1K│                                        ╲___•___• ← Óptimo
  │                                                ╲___________
  └────────────────────────────────────────────────────────────→ Iteraciones
  0    100   200   300   400   500   600   700   800   900   1000


Learning Rate α - Impacto en convergencia:

α muy grande (α=1.0):              α pequeño (α=0.001):
J(θ)                                J(θ)
  │  •                                │  •
  │   ╲•                              │   ╲
  │    •╲                             │    •
  │   •  •                            │     •
  │  •    •                           │      •
  │ •      •  ← Oscila, diverge       │       •  ← Muy lento
  │•────────→ t                       │        • • • → t
  

α óptimo (α=0.1):
J(θ)
  │  •
  │   ╲___
  │       ╲___
  │           ╲___  ← Converge bien
  │               ╲___
  │                   ╲___________
  └────────────────────────────────→ t
```

### 📊 Esquema: Relación entre nuevos conceptos

```
╔═══════════════════════════════════════════════════════════════════════════╗
║            CONCEPTOS MATEMÁTICOS ADICIONALES EN USO                       ║
╚═══════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────┐
│  FASE PRE-ENTRENAMIENTO: Análisis Exploratorio                          │
└─────────────────────────────────────────────────────────────────────────┘

    📊 Dataset: (x, y) → km y precios
             ↓
    ┌──────────────────┐
    │  Calcular Media  │  →  μ_x, μ_y
    └────────┬─────────┘
             ↓
    ┌──────────────────┐
    │  Calcular        │  →  σ_x, σ_y
    │  Desv. Estándar  │
    └────────┬─────────┘
             ↓
    ┌──────────────────┐       Fundamento teórico: ¿Por qué
    │  Covarianza      │  →    funciona la regresión lineal?
    │  Cov(X,Y)        │       
    └────────┬─────────┘       Cov(km, precio) < 0
             ↓                 → Relación inversa ✓
    ┌──────────────────┐
    │  Correlación     │  →    r ≈ -0.97
    │  r = Cov/(σ_x·σ_y)│      → Relación lineal MUY fuerte ✓
    └────────┬─────────┘       → Regresión lineal apropiada ✓
             ↓
    ✅ Confirmación: El modelo lineal es adecuado


┌─────────────────────────────────────────────────────────────────────────┐
│  FASE POST-ENTRENAMIENTO: Evaluación del Modelo                         │
└─────────────────────────────────────────────────────────────────────────┘

    Modelo entrenado: θ₀, θ₁
             ↓
    ┌──────────────────────────────────┐
    │  Hacer predicciones              │
    │                                  │
    │  Para cada muestra i:            │
    │    ŷᵢ = θ₀ + θ₁ · xᵢ             │
    └──────────────┬───────────────────┘
                   ↓
    ┌─────────────────────────────────────────┐
    │  Calcular RESIDUOS                      │
    │                                         │
    │  residuoᵢ = yᵢ - ŷᵢ                     │
    │                                         │
    │  • Si residuo > 0 → Subpredicción       │
    │  • Si residuo < 0 → Sobrepredicción     │
    │  • Si residuo ≈ 0 → Predicción correcta │
    └──────────────┬──────────────────────────┘
                   ↓
    ┌──────────────────────────────────┐
    │  Calcular SUMA DE CUADRADOS      │
    │                                  │
    │  SST = Σ(yᵢ - ȳ)²                │
    │  Variabilidad TOTAL en los datos │
    │                                  │
    │  SSR = Σ(yᵢ - ŷᵢ)²               │
    │  Variabilidad NO explicada       │
    └──────────────┬───────────────────┘
                   ↓
    ┌──────────────────────────────────┐
    │  Calcular MÉTRICAS               │
    │                                  │
    │  MSE  = SSR / m                  │
    │  RMSE = √MSE                     │
    │  MAE  = Σ|residuoᵢ| / m          │
    │  R²   = 1 - SSR/SST              │
    └──────────────┬───────────────────┘
                   ↓
    ✅ Evaluación completa del modelo


    CONEXIÓN ENTRE CONCEPTOS:
    
    Correlación (r)  →  Indica si regresión es apropiada
           ↓
    Entrenamiento    →  Encuentra θ₀, θ₁ óptimos
           ↓
    Predicciones     →  ŷ = θ₀ + θ₁·x
           ↓
    Residuos         →  e = y - ŷ
           ↓
    SST, SSR         →  Miden variabilidad
           ↓
    R² = 1 - SSR/SST →  Calidad del modelo
           ↓
    ¿R² ≈ r² ?       →  SÍ (en regresión simple)


    IMPLEMENTACIÓN EN EL PROYECTO:
    
    Covarianza/Correlación → No se calcula (fundamento teórico)
    Media (μ)             → normalize_data() en train.py
    Desv. Estándar (σ)    → normalize_data() en train.py
    Residuos              → Implícito en precision.py
    SST                   → ss_total en precision.py (línea 84)
    SSR                   → ss_residual en precision.py (línea 89)
    R²                    → r_squared en precision.py (línea 93)
```

[↑ Volver al índice](#indice)

---

## 📚 Glosario rápido

| Símbolo | Nombre | Descripción | Ejemplo de uso |
|---------|--------|-------------|----------------|
| **m** | Muestras | Número de observaciones (líneas en `data.csv`) | En `train.py`: `m = len(data)` → 24 muestras en nuestro dataset |
| **x<sup>(i)</sup>** | Entrada i-ésima | Valor del kilometraje de la muestra i | `x[0]` = 240,000 km (primer coche) |
| **y<sup>(i)</sup>** | Salida i-ésima | Precio real de la muestra i | `y[0]` = 3,650€ (precio del primer coche) |
| **θ₀** | Intercepto | Precio estimado cuando el kilometraje es 0 | Tras entrenamiento: `θ₀ ≈ 8,499` → precio base |
| **θ₁** | Pendiente | Cuánto cambia el precio por unidad de kilometraje | `θ₁ ≈ -0.0214` → pierde 0.02€ por km |
| **θ** | Vector de parámetros | θ = [θ₀, θ₁]<sup>T</sup> (notación vectorial) | Representa ambos parámetros juntos: intercepto y pendiente |
| **h<sub>θ</sub>(x)** | Hipótesis | Predicción: `θ₀ + θ₁ × x` | `predict(50000)` → `8499 + (-0.0214) × 50000` ≈ 7,429€ |
| **J(θ)** | Función de coste | MSE: error cuadrático medio | En `train.py`: calcula qué tan lejos están las predicciones |
| **α** | Learning rate | Tasa de aprendizaje; controla el tamaño del paso | En código: `alpha = 0.01` → avanza 1% del gradiente |
| **∇J** | Gradiente | Vector de derivadas parciales | `[∂J/∂θ₀, ∂J/∂θ₁]` → dirección de descenso |
| **μ** | Media | Promedio de los valores de x | `mean_x = 103,503` km (promedio del kilometraje) |
| **σ** | Desviación estándar | Dispersión de los datos de x | `std_x = 61,298` km (variabilidad del kilometraje) |
| **x<sub>norm</sub>** | X normalizada | Valor normalizado: (x - μ) / σ | `(150000 - 103503) / 61298 ≈ 0.76` |
| **MSE** | Mean Squared Error | Error cuadrático medio: promedio de (y - ŷ)² | En `precision.py`: `MSE = 619,113` |
| **RMSE** | Root MSE | Raíz del MSE, en unidades originales | `RMSE = √619113 ≈ 787€` |
| **MAE** | Mean Absolute Error | Error absoluto medio: promedio de \|y - ŷ\| | `MAE = 632€` → error promedio |
| **R²** | Coeficiente de determinación | Proporción de varianza explicada (0-1) | `R² = 0.943` → el modelo explica el 94.3% de la varianza |
| **Epoch** | Iteración completa | Una pasada completa por todo el dataset | `epochs = 1000` → 1000 actualizaciones de θ |
| **Cov(X,Y)** | Covarianza | Mide cómo varían X e Y juntas | Si Cov < 0 → relación inversa (km↑ precio↓) |
| **r** | Coef. de correlación | Covarianza normalizada entre -1 y +1 | `r = -0.97` → correlación negativa muy fuerte |
| **Residuo** | Error de predicción | Diferencia entre valor real y predicho | `residuo = y - ŷ` |
| **SST** | Suma Cuadrados Total | Variabilidad total de los datos | `SST = Σ(y - ȳ)²` en precision.py |
| **SSR** | Suma Cuadrados Residual | Variabilidad NO explicada por el modelo | `SSR = Σ(y - ŷ)²` usado para calcular R² |

---

## 1️⃣ Objetivo

### 🎯 ¿Qué es la regresión lineal simple?

La **regresión lineal simple** es un método estadístico que nos permite **predecir** el valor de una variable (llamada variable dependiente o salida) a partir de otra variable (llamada variable independiente o entrada) asumiendo que existe una **relación lineal** entre ambas.

En términos más simples: queremos encontrar la **mejor línea recta** que pase por un conjunto de puntos en un gráfico.

### 📊 Nuestro problema específico

En este proyecto, queremos modelar la relación entre:
- **Variable independiente (x)**: Kilometraje de un coche
- **Variable dependiente (y)**: Precio del coche

**Hipótesis**: Cuanto más kilómetros tenga un coche, menor será su precio (relación inversa).

### 🔍 La ecuación de la recta

Buscamos una función hipótesis lineal:

$$
h_\theta(x) = \theta_0 + \theta_1 x
$$

donde:
- **$x$** → **Variable de entrada (feature)**: el kilometraje del coche que queremos evaluar
- **$\theta_0$** (theta cero) → **Intercepto**: punto donde la recta cruza el eje Y (precio cuando km = 0)
- **$\theta_1$** (theta uno) → **Pendiente**: cuánto cambia el precio por cada kilómetro adicional
- **$h_\theta(x)$** → **Predicción de salida**: el precio estimado del coche con kilometraje $x$

### 💡 Ejemplo numérico intuitivo

Imagina que después del entrenamiento obtenemos:
- $\theta_0 = 8500$ (euros)
- $\theta_1 = -0.02$ (euros por kilómetro)

Entonces la ecuación queda:

$$
\text{Precio} = 8500 - 0.02 \times \text{Kilometraje}
$$

**Predicciones concretas:**

| Kilometraje | Cálculo | Precio estimado |
|-------------|---------|-----------------|
| 0 km | $8500 - 0.02 \times 0$ | **8,500€** |
| 50,000 km | $8500 - 0.02 \times 50000$ | **7,500€** |
| 100,000 km | $8500 - 0.02 \times 100000$ | **6,500€** |
| 200,000 km | $8500 - 0.02 \times 200000$ | **4,500€** |

### 🎨 Visualización

Imagina un gráfico con:
- **Eje X (horizontal)**: Kilometraje (0 a 250,000 km)
- **Eje Y (vertical)**: Precio (0 a 10,000€)
- **Puntos azules**: Los 24 coches de nuestro dataset
- **Línea roja**: Nuestra recta de predicción $h_\theta(x)$

```
Precio (€)
    |
9000|    •              Puntos = datos reales
8000|      •            Línea = predicción
7000|        •  •
6000|          •  \
5000|            •  \    ← La recta aprende
4000|              •  \     la tendencia
3000|                •  \
2000|                  •  •
    |_________________________ Kilometraje (km)
     0    50k   100k  150k  200k
```

### 🎯 ¿Qué hace el algoritmo?

El algoritmo de **descenso por gradiente** ajusta automáticamente los valores de $\theta_0$ y $\theta_1$ para que:

1. **La recta se acerque lo máximo posible** a todos los puntos reales
2. **El error total sea mínimo** (suma de distancias entre predicciones y valores reales)
3. **Generalice bien** para predecir precios de coches que no ha visto

### 🔑 Conceptos clave

| Concepto | Descripción | En nuestro proyecto |
|----------|-------------|---------------------|
| **"Simple"** | Solo usamos **una** variable de entrada (km) | No consideramos marca, año, etc. |
| **"Lineal"** | La relación es una **línea recta** | No curvas ni formas complejas |
| **"Regresión"** | Predecimos un **valor continuo** (precio) | No categorías (caro/barato) |
| **"Supervisado"** | Aprendemos de **ejemplos etiquetados** | Tenemos pares (km, precio) |

### ⚠️ Limitaciones

La regresión lineal simple asume:
- ✓ Relación lineal entre variables
- ✓ Errores distribuidos normalmente
- ✓ Varianza constante (homocedasticidad)

Si la relación es **no lineal** (por ejemplo, exponencial o cuadrática), este modelo no funcionará bien.

### 🎥 Aprende más
- [**Regresión Lineal Simple** - DotCSV](https://www.youtube.com/watch?v=k964_uNn3l0) - Explicación muy visual y clara del concepto
- [**Intuición detrás de la Regresión Lineal** - AprendeIA](https://www.youtube.com/watch?v=GhrxgbQnEEU) - Geometría y significado

[↑ Volver al índice](#indice)

---

## 3️⃣ Función de coste (MSE)

### 🎯 ¿Qué es la función de coste?

La **función de coste** (también llamada función de pérdida o loss function) es una medida matemática que nos dice **qué tan mal** está funcionando nuestro modelo. Es el "juez" que evalúa la calidad de nuestras predicciones.

**Objetivo principal**: Queremos **minimizar** esta función para que nuestro modelo sea lo más preciso posible.

### 📐 La fórmula del MSE

Para medir el ajuste del modelo usamos el **error cuadrático medio** (MSE - Mean Squared Error) en su forma de coste para optimización:

$$
J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)^2
$$

### 🔍 Desglosando la fórmula

Vamos a entender cada componente:

| Componente | Significado |
|------------|-------------|
| **$J(\theta)$** | Valor del coste (el número que queremos minimizar) |
| **$h_\theta(x^{(i)})$** | Precio **predicho** por el modelo para el coche $i$ |
| **$y^{(i)}$** | Precio **real** del coche $i$ en el **dataset** (conjunto de datos de entrenamiento: `data.csv`) |
| **$h_\theta(x^{(i)}) - y^{(i)}$** | **Error** de predicción (residuo: diferencia entre lo que predecimos y lo real) |
| **$(...)^2$** | **Cuadrado** del error (penaliza errores grandes) |
| **$\sum_{i=1}^{m}$** | **Suma** de errores de todos los coches (recorre las 24 muestras) |
| **$\frac{1}{2m}$** | Divide por $2m$ para calcular el promedio. El $\frac{1}{2}$ es una convención matemática que no afecta al resultado final (verás por qué más adelante) |

### 💡 ¿Por qué elevar al cuadrado?

1. **Errores siempre positivos**: $(-100)^2 = 10000$ igual que $(+100)^2 = 10000$
2. **Penaliza errores grandes**: Un error de 200€ no es el doble de malo que uno de 100€, es **4 veces peor**
3. **Matemáticamente conveniente**: Derivadas más simples

### 📊 Ejemplo numérico paso a paso

Supongamos que tenemos solo **3 coches** en nuestro dataset y nuestro modelo actual predice:

| i | Kilometraje<br>$x^{(i)}$ | Precio real<br>$y^{(i)}$ | Predicción<br>$h_\theta(x^{(i)})$ | Error<br>$(h - y)$ | Error²<br>$(h - y)^2$ |
|---|---|---|---|---|---|
| 1 | 50,000 | 7,500€ | 7,700€ | +200€ | 40,000 |
| 2 | 100,000 | 6,000€ | 5,900€ | -100€ | 10,000 |
| 3 | 150,000 | 4,500€ | 4,300€ | -200€ | 40,000 |

**Cálculo del MSE:**

$$
J(\theta) = \frac{1}{2 \times 3} (40000 + 10000 + 40000) = \frac{90000}{6} = 15000
$$

**Interpretación**: El coste es 15,000. Queremos entrenar el modelo para **reducir este número**.

### 🎯 Intuición visual

Imagina que trazas la recta de predicción sobre tus puntos reales:

```
Precio (€)
    |
8000|    •              • = Punto real
7500|   /|\             | = Distancia (error)
7000|  / | \            
6500| /  •  \
6000|/   |   \
5500|    •    \         La línea es h_θ(x)
5000|     \    \
4500|      •────\       ← Error vertical
    |_________________________ Kilometraje (km)
     50k   100k  150k
```

**MSE** es básicamente: "¿cuál es la distancia vertical promedio (al cuadrado) entre mis puntos y mi recta?"

### 🎲 Comparación de modelos

| Modelo | Coste $J(\theta)$ | Calidad |
|--------|-------------------|---------|
| Modelo A | 500,000 | ❌ Muy malo |
| Modelo B | 15,000 | ⚠️ Regular |
| Modelo C | 619 | ✅ Bueno |
| Modelo Perfecto | 0 | ⭐ Ideal (imposible) |

### ⚠️ Notas importantes

**💡 Explicación de cada parte:** 
- ✓ **Se suma** el cuadrado de la diferencia entre predicción y valor real
- ✓ **Se divide** por $2m$ para obtener una medida promedio
- ✓ **Los errores grandes** se penalizan más fuertemente (por el cuadrado)
- ✓ **La constante** $\tfrac{1}{2}$ simplifica las derivadas posteriores (al derivar $x^2$ → $2x$, el 2 se cancela)

**🎯 Objetivo del entrenamiento:**
El algoritmo de gradiente descendente ajusta $\theta_0$ y $\theta_1$ iterativamente para que $J(\theta)$ sea lo más pequeño posible.

### 🔄 Relación con el entrenamiento

```
Inicio:  θ₀=0, θ₁=0  →  J(θ) = 25,000,000  (muy alto)
Iter 100: θ₀=7000, θ₁=-0.01  →  J(θ) = 1,200,000  (bajando...)
Iter 500: θ₀=8200, θ₁=-0.019  →  J(θ) = 25,000  (mejorando)
Iter 1000: θ₀=8499, θ₁=-0.0214  →  J(θ) = 619  ✓ (convergió)
```

### 🎥 Aprende más
- [**Función de Coste en ML** - DotCSV](https://www.youtube.com/watch?v=TqnqMa7x3xc) - ¿Por qué usamos MSE?
- [**Loss Functions Explicadas** - StatQuest](https://www.youtube.com/watch?v=QZ0DtNFdDko) - Comparación entre diferentes funciones de coste

[↑ Volver al índice](#indice)

---

## 🧮 ¿Qué son las derivadas? - Fundamentos de cálculo

### 🎯 Introducción: ¿Por qué necesitamos derivadas?

En Machine Learning, nuestro objetivo es **minimizar la función de coste** $J(\theta)$. Pero, ¿cómo sabemos en qué dirección mover los parámetros $\theta_0$ y $\theta_1$ para reducir el error?

**La respuesta: las derivadas.** Son la herramienta matemática que nos dice:
- 📍 **Dónde estamos** en la función
- 📈 **Hacia dónde** debemos movernos
- 🏃 **Qué tan rápido** debemos movernos

### 🔍 ¿Qué es una derivada?

**Definición simple**: La derivada de una función es su **tasa de cambio instantánea**. Nos dice cómo cambia la salida ($y$) cuando cambiamos ligeramente la entrada ($x$).

**En otras palabras**: Es la **pendiente** de la función en un punto específico.

### 📊 Analogía cotidiana: Conduciendo un coche

Imagina que conduces por una carretera montañosa:

| Situación | Concepto matemático |
|-----------|--------------------|
| 🚗 **Tu posición en la carretera** | Valor actual de $\theta$ |
| ⛰️ **Altura de la montaña** | Valor de la función $J(\theta)$ |
| 📐 **Inclinación del terreno** | Derivada $\frac{dJ}{d\theta}$ |
| ⬇️ **Bajada (pendiente negativa)** | Derivada negativa → debemos avanzar |
| ⬆️ **Subida (pendiente positiva)** | Derivada positiva → debemos retroceder |
| 🏁 **Terreno plano (valle)** | Derivada = 0 → ¡mínimo encontrado! |

### 🧪 Ejemplo concreto: Nuestra función de predicción

**En nuestro proyecto**, la hipótesis es: $h_\theta(x) = \theta_0 + \theta_1 x$

Supongamos que fijamos $\theta_0 = 8000$ y queremos optimizar solo $\theta_1$:

```
Precio (€)
     |
9000 |      •  (θ₁=-0.01)        Probamos diferentes
8000 |_____•__ (θ₁=0)            valores de pendiente
7000 |         \ • (θ₁=-0.02)     
6000 |           \               El coste J(θ₁) forma
5000 |             • (θ₁=-0.03)   una curva
     |____________________________
           Pendiente θ₁
```

**Ejemplo práctico con 1 coche:**
- Kilometraje real: $x = 100,000$ km
- Precio real: $y = 6,000€$
- Mantenemos: $\theta_0 = 8000€$

**Probamos diferentes pendientes** $\theta_1$:

| $\theta_1$ | Predicción $h(x)$ | Error $(h-y)$ | Error² | Interpretación |
|------------|-------------------|---------------|--------|-----------------|
| $0.00$ | $8000 + 0(100k) = 8000€$ | $+2000€$ | $4,000,000$ | Error muy grande |
| $-0.01$ | $8000 - 0.01(100k) = 7000€$ | $+1000€$ | $1,000,000$ | Mejor, pero aún alto |
| $-0.02$ | $8000 - 0.02(100k) = 6000€$ | $0€$ | $0$ | **¡Perfecto!** ✓ |
| $-0.03$ | $8000 - 0.03(100k) = 5000€$ | $-1000€$ | $1,000,000$ | Nos pasamos |

**¿Qué nos dice la derivada?**

Si calculamos $\frac{dJ}{d\theta_1}$ en cada punto:

- En $\theta_1 = 0$: Derivada **positiva grande** → reducir $\theta_1$ mucho
- En $\theta_1 = -0.01$: Derivada **positiva** → seguir reduciendo $\theta_1$
- En $\theta_1 = -0.02$: Derivada **≈ 0** → **¡encontramos el mínimo!** ✓
- En $\theta_1 = -0.03$: Derivada **negativa** → aumentar $\theta_1$

**Regla de oro**: La derivada nos dice **hacia dónde mover** $\theta_1$ para reducir el error.

### 📐 Reglas básicas de derivación

Estas son las reglas fundamentales que usamos en **ft_linear_regression**:

| Función original | Derivada | Aplicación en nuestro proyecto | Explicación |
|------------------|----------|--------------------------------|-------------|
| $f(x) = c$ | $f'(x) = 0$ | $\theta_0 = 8500$ (constante) → derivada de constantes = 0 | Las constantes no cambian → derivada cero |
| $f(x) = x$ | $f'(x) = 1$ | Si derivamos $\theta_1 \cdot x$ respecto a $\theta_1$, el $x$ queda | Pendiente constante de 1 |
| $f(x) = x^2$ | $f'(x) = 2x$ | $(error)^2$ en MSE → derivada = $2 \times error$ | "Baja el exponente multiplicando" |
| $f(x) = ax$ | $f'(x) = a$ | Derivada de $\theta_1 x$ respecto a $x$ = $\theta_1$ | La constante se queda |

**En nuestra función de coste:**

$$
J(\theta) = \frac{1}{2m} \sum (\theta_0 + \theta_1 x - y)^2
$$

**Aplicamos estas reglas:**
1. Derivar $(error)^2$ → obtenemos $2 \times (error)$ (regla $x^2$)
2. El $\frac{1}{2}$ cancela el 2 → queda solo $(error)$
3. Derivar $\theta_0$ respecto a $\theta_0$ → queda 1 (regla $x$)
4. Derivar $\theta_1 x$ respecto a $\theta_1$ → queda $x$ (regla $ax$)

**Truco mental**: "Las constantes desaparecen, las potencias bajan su exponente multiplicando"

### 🎓 Derivadas parciales: El siguiente nivel

#### 🤔 ¿Cuál es la diferencia?

| Tipo | Situación | Notación | Acción |
|------|-----------|----------|--------|
| **Derivada normal** | Función de 1 variable: $f(x)$ | $\frac{df}{dx}$ o $f'(x)$ | Derivamos respecto a la única variable |
| **Derivada parcial** | Función de 2+ variables: $J(\theta_0, \theta_1)$ | $\frac{\partial J}{\partial \theta_0}$ | Derivamos respecto a UNA, las demás se tratan como números fijos |

#### 📖 Definición simple

**Derivada parcial** = Derivar respecto a **una variable específica**, **congelando** (tratando como constantes) todas las demás.

#### 🔤 Notación importante

- $\frac{\partial J}{\partial \theta_0}$ → "derivada parcial de J respecto a theta cero"
  - Significa: ¿cómo cambia $J$ si muevo solo $\theta_0$? (con $\theta_1$ fijo)
  
- $\frac{\partial J}{\partial \theta_1}$ → "derivada parcial de J respecto a theta uno"
  - Significa: ¿cómo cambia $J$ si muevo solo $\theta_1$? (con $\theta_0$ fijo)

**Nota del símbolo**: Usamos $\partial$ (curva) en vez de $d$ (recta) para indicar "parcial".

### 💡 Ejemplo paso a paso con NUESTRO PROYECTO

**Situación real**: Tenemos 2 coches en el dataset

| Coche | Kilometraje ($x$) | Precio real ($y$) |
|-------|-------------------|-------------------|
| 1 | 50,000 km | 7,500€ |
| 2 | 100,000 km | 6,000€ |

**Parámetros actuales**: $\theta_0 = 8000€$, $\theta_1 = -0.01€/km$

**Función de coste:**
$$
J(\theta_0, \theta_1) = \frac{1}{2 \times 2} \sum_{i=1}^{2} (\theta_0 + \theta_1 x^{(i)} - y^{(i)})^2
$$

#### Paso 1: Calcular predicciones y errores

| Coche | Predicción $h(x)$ | Precio real | Error |
|-------|-------------------|-------------|-------|
| 1 | $8000 - 0.01(50k) = 7500€$ | 7,500€ | $0€$ |
| 2 | $8000 - 0.01(100k) = 7000€$ | 6,000€ | $+1000€$ |

**Coste actual**: $J = \frac{1}{4}(0^2 + 1000^2) = 250,000$

#### Paso 2: Derivada parcial respecto a θ₀ (intercepto)

**Pregunta**: Si cambio solo el precio base ($\theta_0$), ¿cómo cambia el error?

**Cálculo:**
$$
\frac{\partial J}{\partial \theta_0} = \frac{1}{2} (0 + 1000) = 500
$$

**Interpretación**: 
- Derivada **positiva** (500) → si aumentamos $\theta_0$, el error sube
- Por tanto, debemos **reducir** $\theta_0$

#### Paso 3: Derivada parcial respecto a θ₁ (pendiente)

**Pregunta**: Si cambio solo la pendiente ($\theta_1$), ¿cómo cambia el error?

**Cálculo:**
$$
\frac{\partial J}{\partial \theta_1} = \frac{1}{2} (0 \times 50000 + 1000 \times 100000) = 50,000,000
$$

**Interpretación**:
- Derivada **muy positiva** (50M) → $\theta_1$ contribuye muchísimo al error
- Debemos **reducir** $\theta_1$ más agresivamente (hacerlo más negativo)

#### Paso 4: Actualizar parámetros (con α = 0.00001)

| Parámetro | Valor actual | Derivada | Actualización | Nuevo valor |
|-----------|--------------|----------|---------------|-------------|
| $\theta_0$ | 8000 | 500 | $8000 - 0.00001(500)$ | $≈ 7999.995$ |
| $\theta_1$ | -0.01 | 50,000,000 | $-0.01 - 0.00001(50M)$ | $≈ -0.51$ |

#### 🎯 Conclusión práctica

Después de esta iteración:
- **Nuevo coste** será mucho menor porque ajustamos la pendiente
- $\theta_1$ cambió mucho más que $\theta_0$ (su derivada era mayor)
- Las predicciones ahora serán más cercanas a los precios reales
- El algoritmo repite este proceso hasta que las derivadas ≈ 0 (convergencia)

**Esto es EXACTAMENTE lo que hace `train.py`**: calcula estas derivadas parciales en cada iteración y ajusta ambos parámetros proporcionalmente a su contribución al error.

### 🤖 ¿Por qué las derivadas en Machine Learning?

En ML usamos derivadas para el **gradiente descendente**:

```
1. Calcular el coste actual:     J(θ) = 10,000
2. Calcular las derivadas:       ∂J/∂θ₀ = 500
                                 ∂J/∂θ₁ = -300
3. Interpretar las derivadas:
   - ∂J/∂θ₀ positiva → aumentar θ₀ sube el coste → debemos BAJAR θ₀
   - ∂J/∂θ₁ negativa → aumentar θ₁ baja el coste → debemos SUBIR θ₁
4. Actualizar parámetros:        θ₀ := θ₀ - α × 500
                                 θ₁ := θ₁ - α × (-300)
5. Repetir hasta que J(θ) sea mínimo
```

### 🔗 Conexión con nuestro proyecto

En `ft_linear_regression`, calculamos derivadas de:

$$
J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \bigl(\theta_0 + \theta_1 x^{(i)} - y^{(i)}\bigr)^2
$$

**Proceso paso a paso:**

1. **Aplicar regla de la cadena**: Derivar $(error)^2$
2. **Obtener derivadas parciales**:
   - $\frac{\partial J}{\partial \theta_0} = \frac{1}{m} \sum (predicción - real)$
   - $\frac{\partial J}{\partial \theta_1} = \frac{1}{m} \sum (predicción - real) \times x$
3. **Usar en gradiente descendente** para actualizar $\theta_0$ y $\theta_1$

### 📈 Visualización: Descendiendo por la montaña

```
    J(θ)
     |
 Alto |     •
      |    / \         ← Empezamos aquí (coste alto)
      |   /   \       
      |  /     •       ← Derivada nos dice: "baja hacia la izquierda"
      | /       \     
 Bajo |/         •__   ← Convergemos al mínimo
      |_______________θ
           Mínimo
```

La derivada es nuestra **brújula** que nos guía hacia el mínimo.

### 🎯 Resumen de conceptos clave

| Concepto | Significado | En nuestro proyecto |
|----------|-------------|--------------------|
| **Derivada** | Tasa de cambio / pendiente | Nos dice cómo ajustar θ |
| **Derivada = 0** | Punto plano (posible mínimo) | Algoritmo converge aquí |
| **Derivada positiva** | Función creciente | Debemos reducir θ |
| **Derivada negativa** | Función decreciente | Debemos aumentar θ |
| **Derivada parcial** | Derivada en función multi-variable | Necesitamos una para θ₀ y otra para θ₁ |
| **Gradiente** | Vector de derivadas parciales | $[\frac{\partial J}{\partial \theta_0}, \frac{\partial J}{\partial \theta_1}]$ |

### ⚠️ Intuición importante

**Sin derivadas**: Sería como buscar el valle más bajo con los ojos vendados, probando al azar.

**Con derivadas**: Es como tener un GPS que te dice exactamente la pendiente del terreno en cada paso.

### 🎥 Aprende más
- [**¿Qué es una Derivada?** - 3Blue1Brown](https://www.youtube.com/watch?v=9vKqVkMQHKk) - Visualización geométrica perfecta (subtítulos en español)
- [**Concepto de derivada desde cero.** - Matemáticas con Juan](https://youtu.be/nxoWXfWRJH4?si=58Mvi5BErczEt9vs) - Concepto de derivada desde cero
- [**Gradient Descent visualmente** - StatQuest](https://www.youtube.com/watch?v=sDv4f4s2SB8) - Cómo las derivadas guían el algoritmo

[↑ Volver al índice](#indice)

---

## 4️⃣ Derivación del gradiente (parcial)

### 🎯 ¿Qué vamos a hacer?

Ahora que sabemos qué son las derivadas, vamos a calcular las **derivadas parciales** de nuestra función de coste $J(\theta_0, \theta_1)$ respecto a cada parámetro. Estas derivadas nos dirán exactamente cómo ajustar $\theta_0$ y $\theta_1$ para minimizar el error.

### 🔍 ¿Por qué usamos $\frac{1}{2m}$ en la función de coste?

Recuerda que definimos:
$$
J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)^2
$$

**Pregunta**: ¿Por qué $\frac{1}{2m}$ y no solo $\frac{1}{m}$?

**Respuesta**: Es un truco matemático elegante:

Al derivar $(error)^2$, la regla de la cadena nos da:
- **Antes de derivar**: $(error)^2$
- **Después de derivar**: $2 \times (error) \times \frac{d(error)}{d\theta}$
- **El factor 2 aparece** por la regla de potencias: $(x^2)' = 2x$

El $\frac{1}{2}$ inicial **cancela** ese 2:
$$
\frac{1}{2} \times 2 = 1
$$

**Resultado**: Fórmulas finales más limpias, sin factores molestos.

**Ejemplo rápido**: 
$$
\text{Si } J = \frac{1}{2}x^2, \text{ entonces } \frac{dJ}{dx} = \frac{1}{2} \times 2x = x \quad \text{(¡perfecto, sin el 2!)}
$$

**Importante**: Esto es solo por conveniencia matemática y **no afecta** al mínimo encontrado (solo simplifica cálculos).

### 📐 Derivación paso a paso para θ₀

**Función de coste**:
$$
J(\theta_0, \theta_1) = \frac{1}{2m} \sum_{i=1}^{m} \bigl(\theta_0 + \theta_1 x^{(i)} - y^{(i)}\bigr)^2
$$

**Paso 1**: Aplicar regla de la cadena a $(error)^2$
$$
\frac{\partial}{\partial \theta_0} (error)^2 = 2 \times (error) \times \frac{\partial (error)}{\partial \theta_0}
$$

**Paso 2**: Derivar el error respecto a $\theta_0$
$$
\frac{\partial}{\partial \theta_0} (\theta_0 + \theta_1 x^{(i)} - y^{(i)}) = 1
$$
(porque $\theta_0$ deriva a 1, y $\theta_1 x^{(i)} - y^{(i)}$ son constantes respecto a $\theta_0$)

**Paso 3**: Combinar y simplificar
$$
\frac{\partial J}{\partial \theta_0} = \frac{1}{2m} \sum_{i=1}^{m} 2 \times (h_\theta(x^{(i)}) - y^{(i)}) \times 1
$$

**Paso 4**: El $\frac{1}{2}$ cancela el 2
$$
\frac{\partial J}{\partial \theta_0} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)
$$

**🎯 Resultado final para θ₀**:
$$
\boxed{\frac{\partial J}{\partial \theta_0} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)}
$$

**💡 Interpretación práctica**: 
- Es el **promedio** de los errores
- Si es positivo → nuestras predicciones son muy altas → bajar $\theta_0$
- Si es negativo → nuestras predicciones son muy bajas → subir $\theta_0$

### 📐 Derivación paso a paso para θ₁

**Paso 1**: Aplicar regla de la cadena (igual que antes)
$$
\frac{\partial}{\partial \theta_1} (error)^2 = 2 \times (error) \times \frac{\partial (error)}{\partial \theta_1}
$$

**Paso 2**: Derivar el error respecto a $\theta_1$
$$
\frac{\partial}{\partial \theta_1} (\theta_0 + \theta_1 x^{(i)} - y^{(i)}) = x^{(i)}
$$
(porque $\theta_1 x^{(i)}$ deriva a $x^{(i)}$, y $\theta_0 - y^{(i)}$ son constantes respecto a $\theta_1$)

**Paso 3**: Combinar y simplificar
$$
\frac{\partial J}{\partial \theta_1} = \frac{1}{2m} \sum_{i=1}^{m} 2 \times (h_\theta(x^{(i)}) - y^{(i)}) \times x^{(i)}
$$

**Paso 4**: El $\frac{1}{2}$ cancela el 2
$$
\frac{\partial J}{\partial \theta_1} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr) x^{(i)}
$$

**🎯 Resultado final para θ₁**:
$$
\boxed{\frac{\partial J}{\partial \theta_1} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr) x^{(i)}}
$$

**💡 Interpretación práctica**: 
- Es el **promedio** de los errores **ponderados por el kilometraje**
- El factor $x^{(i)}$ significa que coches con más kilómetros tienen más "peso" en el cálculo
- Nos dice cuánto debemos ajustar la pendiente

### 🔍 Comparación de ambas fórmulas

| Gradiente | Fórmula | Diferencia clave |
|-----------|---------|------------------|
| $\frac{\partial J}{\partial \theta_0}$ | $\frac{1}{m} \sum (error)$ | Solo el error promedio |
| $\frac{\partial J}{\partial \theta_1}$ | $\frac{1}{m} \sum (error \times x)$ | Error multiplicado por $x$ |

**¿Por qué esta diferencia?**
- $\theta_0$ es el intercepto (precio base) → afecta igual a todos los coches
- $\theta_1$ es la pendiente (precio por km) → afecta **más** a coches con más kilómetros

### 💡 Ejemplo numérico con 2 coches

**Datos**:
| Coche | km ($x$) | Precio real ($y$) |
|-------|----------|-------------------|
| 1 | 50,000 | 7,500€ |
| 2 | 150,000 | 5,000€ |

**Parámetros actuales**: $\theta_0 = 8000$, $\theta_1 = -0.01$

**Predicciones**:
- Coche 1: $h(50k) = 8000 - 0.01(50k) = 7500€$ → Error = $0€$
- Coche 2: $h(150k) = 8000 - 0.01(150k) = 6500€$ → Error = $+1500€$

**Gradiente para θ₀**:
$$
\frac{\partial J}{\partial \theta_0} = \frac{1}{2}(0 + 1500) = 750
$$

**Gradiente para θ₁**:
$$
\frac{\partial J}{\partial \theta_1} = \frac{1}{2}(0 \times 50000 + 1500 \times 150000) = 112,500,000
$$

**Conclusión**: $\theta_1$ necesita mucho más ajuste porque el coche con más kilómetros tiene un error grande.

### 🎥 Aprende más
- [**Cálculo de Gradientes** - AprendeIA](https://www.youtube.com/watch?v=zPDp_ewoyhM) - Derivadas en ML
- [**Chain Rule Explained** - 3Blue1Brown](https://www.youtube.com/watch?v=YG15m2VwSjA) - Regla de la cadena visualizada

[↑ Volver al índice](#indice)

---

## 5️⃣ Descenso por gradiente

### 🎯 ¿Qué es el descenso por gradiente?

El **descenso por gradiente** (gradient descent) es el algoritmo que usamos para **encontrar los valores óptimos** de $\theta_0$ y $\theta_1$ que minimizan la función de coste $J(\theta)$.

**Analogía**: Imagina que estás en una montaña con niebla y quieres bajar al valle. No ves el camino completo, pero puedes sentir la inclinación del terreno bajo tus pies. El descenso por gradiente es caminar siempre en la dirección más empinada hacia abajo, paso a paso, hasta llegar al fondo.

### 📐 La regla de actualización

**Fórmula general**:
$$
\theta_j := \theta_j - \alpha \frac{\partial J(\theta)}{\partial \theta_j}, \quad j=0,1
$$

**Desglosando la fórmula**:

| Símbolo | Significado | En nuestro proyecto |
|---------|-------------|---------------------|
| $\theta_j$ | Parámetro a actualizar | $\theta_0$ (intercepto) o $\theta_1$ (pendiente) |
| $:=$ | Operador de asignación | "Actualiza el valor de" (no es una igualdad matemática) |
| $\alpha$ | Learning rate (tasa de aprendizaje) | Controla el tamaño del paso (ej: 0.01) |
| $\frac{\partial J}{\partial \theta_j}$ | Gradiente | Nos dice la dirección y magnitud del cambio |
| $-$ (signo negativo) | Dirección opuesta | Vamos **contra** el gradiente para **minimizar** |

### 🔢 Fórmulas explícitas para nuestro proyecto

**Para el intercepto θ₀**:
$$
\theta_0 := \theta_0 - \alpha \cdot \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)
$$

**Para la pendiente θ₁**:
$$
\theta_1 := \theta_1 - \alpha \cdot \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr) x^{(i)}
$$

### 💡 Ejemplo paso a paso con 2 coches

**Situación inicial**:
- Dataset: 2 coches
  - Coche 1: 50,000 km → 7,500€
  - Coche 2: 100,000 km → 6,000€
- Parámetros: $\theta_0 = 8000$, $\theta_1 = -0.01$
- Learning rate: $\alpha = 0.01$

#### Paso 1: Calcular predicciones y errores

| Coche | Predicción | Real | Error |
|-------|------------|------|-------|
| 1 | $8000 - 0.01(50k) = 7500€$ | 7,500€ | $0€$ |
| 2 | $8000 - 0.01(100k) = 7000€$ | 6,000€ | $+1000€$ |

#### Paso 2: Calcular gradientes

**Gradiente de θ₀**:
$$
\frac{\partial J}{\partial \theta_0} = \frac{1}{2}(0 + 1000) = 500
$$

**Gradiente de θ₁**:
$$
\frac{\partial J}{\partial \theta_1} = \frac{1}{2}(0 \times 50000 + 1000 \times 100000) = 50,000,000
$$

#### Paso 3: Actualizar parámetros

**Nuevo θ₀**:
$$
\theta_0 := 8000 - 0.01 \times 500 = 8000 - 5 = 7995€
$$

**Nuevo θ₁**:
$$
\theta_1 := -0.01 - 0.01 \times 50,000,000 = -0.01 - 500,000 = -500,010
$$

**¡Ups! 🚨**: Este valor de $\theta_1$ es absurdo. ¿Qué pasó?

**Problema**: $\alpha = 0.01$ es **demasiado grande** para datos sin normalizar. Los gradientes son enormes (50 millones) y los pasos son gigantescos.

**Solución**: Usar $\alpha$ mucho más pequeño (ej: $0.0000001$) o **normalizar** los datos primero.

### 🎚️ El papel del learning rate (α)

El learning rate controla qué tan grandes son los "pasos" que damos:

```
    J(θ)
     |
Alto |  •                      α muy grande:
     | / \___•___             Saltamos de un lado
     |/        \___•____      a otro, nunca convergemos
     |              \___•___
Bajo |________________•_______θ
     
     
    J(θ)
     |
Alto |  •                      α muy pequeño:
     | /•                      Pasos diminutos,
     |/  •                     tardamos eternidades
     |    •  •
Bajo |______•__•__•___________θ
     
     
    J(θ)
     |
Alto |  •                      α óptimo:
     | / \                     Converge rápido
     |/   • •                  y de forma estable
     |      • •
Bajo |________•_______________θ
```

### ⚠️ Consideraciones importantes

| Aspecto | Descripción | En la práctica |
|---------|-------------|----------------|
| ⏱️ **Actualización simultánea** | Calcular TODOS los gradientes primero, DESPUÉS actualizar | No mezclar valores viejos y nuevos |
| 🔺 **α muy grande** | Oscilación o explosión (diverge) | Reducir α o normalizar datos |
| 🐌 **α muy pequeño** | Convergencia muy lenta | Aumentar α (con cuidado) |
| 🎯 **α adecuado** | Convergencia suave y rápida | Probar valores: 0.001, 0.01, 0.1, 1.0 |

### 🔄 El bucle de entrenamiento completo

```python
# Pseudocódigo del algoritmo

# Inicializar
theta_0 = 0
theta_1 = 0
alpha = 0.01
epochs = 1000

for epoch in range(epochs):
    # 1. Calcular predicciones para todos los coches
    predictions = [theta_0 + theta_1 * km for km in kilometrajes]
    
    # 2. Calcular errores
    errors = [pred - real for pred, real in zip(predictions, precios)]
    
    # 3. Calcular gradientes (ANTES de actualizar)
    grad_theta_0 = sum(errors) / m
    grad_theta_1 = sum([e * km for e, km in zip(errors, kilometrajes)]) / m
    
    # 4. Actualizar parámetros (DESPUÉS de calcular ambos gradientes)
    theta_0 = theta_0 - alpha * grad_theta_0
    theta_1 = theta_1 - alpha * grad_theta_1
    
    # 5. (Opcional) Calcular y mostrar el coste
    cost = sum([e**2 for e in errors]) / (2*m)
    if epoch % 100 == 0:
        print(f"Epoch {epoch}: Cost = {cost}")
```

### 📉 Visualización de la convergencia

```
Coste J(θ)
     |
25M  |•                        Iteración 0: coste muy alto
     |                         
10M  | •                       Iteración 100: bajando rápido
     |                         
 1M  |  •                      Iteración 500: desacelerando
     |                         
100K |   •••                   Iteración 800: casi convergió
     |      •••___             
 10K |___________•••••••       Iteración 1000: convergencia ✓
     |_________________________ Iteraciones
     0   100  500  800  1000
```

### 🎯 ¿Cuándo parar?

**Criterios de convergencia**:

1. **Número fijo de iteraciones**: Simple pero puede ser ineficiente
   ```python
   for i in range(1000):  # Siempre 1000 iteraciones
   ```

2. **Cambio en el coste**: Para cuando el coste casi no cambia
   ```python
   if abs(cost_actual - cost_anterior) < 0.000001:
       break  # ¡Convergió!
   ```

3. **Magnitud del gradiente**: Para cuando los gradientes son muy pequeños
   ```python
   if sqrt(grad_0**2 + grad_1**2) < 0.000001:
       break  # Los gradientes ≈ 0
   ```

### 💡 Intuición final

**Sin gradiente descendente**: Probar millones de combinaciones de ($\theta_0$, $\theta_1$) al azar.

**Con gradiente descendente**: Seguir la "brújula matemática" (el gradiente) que siempre apunta hacia el mínimo.

### 🎥 Aprende más
- [**Gradiente Descendente** - Codificando bits](https://youtu.be/mAq2wjTYnGg?si=SjmDL2P2jZcpnMJ8) - Algoritmo explicado paso a paso
- [**Gradient Descent** - StatQuest](https://www.youtube.com/watch?v=sDv4f4s2SB8) - Visualización muy intuitiva
- [**Learning Rate en práctica** - DotCSV](https://www.youtube.com/watch?v=vMh0zPT0tLI) - Cómo elegir α

[↑ Volver al índice](#indice)

---

## 6️⃣ Normalización de características

### 🎯 ¿Por qué necesitamos normalizar?

En nuestro proyecto, el kilometraje varía entre **10,000 y 250,000 km**. Esta escala tan grande causa problemas:

**Problema 1 - Gradientes desbalanceados**:
- $\frac{\partial J}{\partial \theta_1}$ incluye el factor $x$ (kilometraje)
- Con $x$ = 250,000, los gradientes son **enormes**
- Con $x$ = 10,000, los gradientes son más pequeños
- Resultado: $\theta_1$ cambia descontroladamente

**Problema 2 - Learning rate difícil de ajustar**:
- Si $\alpha$ es grande → $\theta_1$ explota
- Si $\alpha$ es pequeño → $\theta_0$ converge muy lento
- No hay un $\alpha$ que funcione bien para ambos

**Solución**: **Normalizar** los datos para que estén en una escala similar (ej: entre -3 y +3).

### 📐 Normalización estándar (z-score)

La fórmula más común es:

$$
x_{norm} = \frac{x - \mu}{\sigma}
$$

donde:
- $\mu$ = media aritmética de todos los valores de $x$
- $\sigma$ = desviación estándar de todos los valores de $x$

### 💡 Ejemplo paso a paso con nuestros datos

**Dataset completo** (24 coches):
- Kilometraje mínimo: 22,500 km
- Kilometraje máximo: 240,000 km
- **Media ($\mu$)**: 103,503 km
- **Desviación estándar ($\sigma$)**: 61,298 km

**Normalicemos algunos coches**:

| Coche | km original | Cálculo | km normalizado |
|-------|-------------|---------|----------------|
| 1 | 50,000 | $(50000 - 103503) / 61298$ | $≈ -0.87$ |
| 2 | 100,000 | $(100000 - 103503) / 61298$ | $≈ -0.06$ |
| 3 | 150,000 | $(150000 - 103503) / 61298$ | $≈ +0.76$ |
| 4 | 240,000 | $(240000 - 103503) / 61298$ | $≈ +2.23$ |

**Observa**: Ahora los valores están entre **-2 y +3** aproximadamente. ¡Mucho mejor!

### 🔄 Proceso completo en train.py

#### Paso 1: Entrenar con datos normalizados

```python
# 1. Calcular estadísticas
mean_km = sum(kilometrajes) / len(kilometrajes)  # μ = 103,503
std_km = calcular_desviacion_estandar(kilometrajes)  # σ = 61,298

# 2. Normalizar TODOS los datos de entrenamiento
km_normalized = [(km - mean_km) / std_km for km in kilometrajes]

# 3. Entrenar con datos normalizados
theta_0, theta_1 = gradient_descent(km_normalized, precios, alpha=0.01)

# 4. GUARDAR μ y σ (¡importantísimo!)
save_parameters(theta_0, theta_1, mean_km, std_km)
```

#### Paso 2: Predecir con datos normalizados

```python
# 1. CARGAR μ y σ guardados
theta_0, theta_1, mean_km, std_km = load_parameters()

# 2. Usuario ingresa km
km_usuario = 120000  # Por ejemplo

# 3. Normalizar con las MISMAS estadísticas
km_norm = (km_usuario - mean_km) / std_km  # (120000 - 103503) / 61298 ≈ 0.27

# 4. Predecir
precio = theta_0 + theta_1 * km_norm
```

### ⚠️ Errores comunes

| Error | Consecuencia | Solución |
|-------|--------------|----------|
| **No guardar μ y σ** | No puedes hacer predicciones | Guárdalos junto con θ₀ y θ₁ |
| **Normalizar con nueva μ/σ** | Predicciones incorrectas | Usa las mismas μ/σ del entrenamiento |
| **No normalizar al predecir** | Predicción totalmente errónea | Normaliza siempre con los mismos parámetros |
| **Normalizar solo algunas muestras** | Inconsistencia en el modelo | Normaliza TODO el dataset |

### 📊 Comparación: Sin vs Con normalización

**Sin normalización**:
```
Coste J(θ)
     |     
25M  |•••••               Oscila sin control
     |     •••••          
10M  |          •••••     α = 0.01 es muy grande
     |               •••  
 1M  |                    No converge
     |________________________ Iteraciones
     0   100   500   1000
```

**Con normalización**:
```
Coste J(θ)
     |
25M  |•                   
     | \                  Convergencia suave
10M  |  •                 α = 0.01 funciona bien
     |   \                
 1M  |    •               
100K |     \___           
 10K |_________•••••••    Convergió ✓
     |________________________ Iteraciones
     0   100   500   1000
```

### ✅ Ventajas de la normalización

| Beneficio | Explicación | Impacto en nuestro proyecto |
|-----------|-------------|----------------------------|
| ⚡ **Convergencia rápida** | Menos iteraciones necesarias | De 10,000 a 1,000 iteraciones |
| 🔢 **Estabilidad numérica** | Evita overflow/underflow | No más valores infinitos |
| ⚖️ **Escalas comparables** | θ₀ y θ₁ en rangos similares | Más fácil de interpretar |
| 🎯 **Learning rate único** | Un α funciona para todos los parámetros | No necesitas α diferentes |

### 🧮 Fórmulas alternativas de normalización

Aunque usamos z-score, existen otras:

| Método | Fórmula | Rango resultado | Cuándo usar |
|--------|---------|-----------------|-------------|
| **Z-score** | $\frac{x - \mu}{\sigma}$ | Aprox. [-3, +3] | **General (recomendado)** |
| **Min-Max** | $\frac{x - min}{max - min}$ | [0, 1] | Si necesitas valores positivos |
| **Max Abs** | $\frac{x}{max(\|x\|)}$ | [-1, +1] | Si datos ya centrados en 0 |

### 🎥 Aprende más
- [**Normalización de Datos** - DotCSV](https://www.youtube.com/watch?v=Sj1PR_OkT8w) - Por qué y cómo normalizar
- [**Feature Scaling** - Andrew Ng](https://www.youtube.com/watch?v=sDv4f4s2SB8) - Escalado de características en ML

[↑ Volver al índice](#indice)

---

## 📐 Covarianza y Correlación

### 🎯 ¿Por qué son importantes?

Antes de entrenar un modelo de regresión lineal, es fundamental entender si existe una **relación lineal** entre las variables. La covarianza y la correlación son las herramientas matemáticas que nos permiten medir esta relación.

**Conexión con el proyecto**: Aunque no calculamos explícitamente estos valores en el código, la regresión lineal funciona **precisamente porque existe una correlación negativa** entre kilometraje y precio.

### 📊 Covarianza

**Definición**: La covarianza mide cómo dos variables cambian juntas.

$$
\text{Cov}(X, Y) = \frac{1}{m} \sum_{i=1}^{m} (x^{(i)} - \bar{x})(y^{(i)} - \bar{y})
$$

donde:
- $\bar{x}$ = media de los valores de $x$
- $\bar{y}$ = media de los valores de $y$
- $m$ = número de muestras

**Interpretación**:

| Valor | Significado | En nuestro proyecto |
|-------|-------------|---------------------|
| **Cov > 0** | Las variables crecen juntas | Si km ↑ entonces precio ↑ (NO es nuestro caso) |
| **Cov < 0** | Una crece cuando la otra decrece | Si km ↑ entonces precio ↓ ✅ **(nuestro caso)** |
| **Cov ≈ 0** | No hay relación lineal | Regresión lineal no funcionaría bien |

### 💡 Ejemplo con nuestros datos

Supongamos 3 coches simplificados:

| i | km (x) | € (y) | $x - \bar{x}$ | $y - \bar{y}$ | $(x - \bar{x})(y - \bar{y})$ |
|---|--------|-------|---------------|---------------|-------------------------------|
| 1 | 50,000 | 7,500 | -50,000 | +1,500 | -75,000,000 |
| 2 | 100,000| 6,000 | 0 | 0 | 0 |
| 3 | 150,000| 4,500 | +50,000 | -1,500 | -75,000,000 |

Media: $\bar{x} = 100,000$ km, $\bar{y} = 6,000$€

$$
\text{Cov}(X, Y) = \frac{1}{3}(-75M + 0 - 75M) = \frac{-150M}{3} = -50,000,000
$$

**Conclusión**: Covarianza negativa grande → **relación inversa fuerte** entre kilometraje y precio.

### 📏 Correlación de Pearson (r)

**Problema con la covarianza**: Su valor depende de las unidades (km, metros, €, etc.). Difícil de interpretar.

**Solución**: Normalizar la covarianza → **Coeficiente de correlación de Pearson**

$$
r = \frac{\text{Cov}(X, Y)}{\sigma_x \cdot \sigma_y}
$$

donde:
- $\sigma_x$ = desviación estándar de $x$
- $\sigma_y$ = desviación estándar de $y$

**Propiedades**:
- **Rango**: $-1 \leq r \leq +1$ (siempre está entre -1 y +1)
- **Independiente de unidades**: sin importar si medimos en km o millas, en € o $

### 📊 Interpretación del coeficiente de correlación

```
r = +1.0  ═══════>  Correlación positiva perfecta
                    Puntos en línea recta ascendente
                    
r = +0.8  ═══╱╱══>  Correlación positiva fuerte
                    Puntos cerca de línea ascendente
                    
r = +0.5  ══╱ ╱══>  Correlación positiva moderada
                    Puntos dispersos, tendencia ascendente
                    
r =  0.0  • • • •    Sin correlación lineal
           • • • •   Puntos aleatorios
           
r = -0.5  ══╲ ╲══>  Correlación negativa moderada
                    Puntos dispersos, tendencia descendente
                    
r = -0.8  ═══╲╲══>  Correlación negativa fuerte  ← Nuestro proyecto
                    Puntos cerca de línea descendente
                    
r = -1.0  ═══════>  Correlación negativa perfecta
                    Puntos en línea recta descendente
```

### 🎯 En nuestro proyecto

Con los datos reales de `data.csv`, si calculáramos la correlación entre kilometraje y precio:

$$
r \approx -0.97
$$

**Interpretación**:
- ✅ Correlación **negativa** (cuando km sube, precio baja)
- ✅ Correlación **muy fuerte** (cerca de -1.0)
- ✅ **Ideal para regresión lineal** (relación casi perfectamente lineal)

### 🔗 Relación con R²

¿Recuerdas el coeficiente de determinación $R^2$ de las métricas?

$$
R^2 = r^2
$$

Para regresión lineal simple, $R^2$ es **el cuadrado del coeficiente de correlación**.

**Ejemplo**:
- Si $r = -0.97$ (correlación fuerte)
- Entonces $R^2 = (-0.97)^2 = 0.94 = 94\%$
- **Significado**: El modelo explica el 94% de la varianza en los precios

### 📊 Visualización de la correlación

```
Correlación fuerte (r ≈ -0.97):          Correlación débil (r ≈ -0.3):

Precio                                    Precio
  │                                         │
  │  •                                      │    •   •
  │    •                                    │  •       •
  │      •                                  │      •     •
  │        •  •                             │  •     •
  │          •                              │    •       •
  │            •  •  Línea clara           │        •   •  Nube dispersa
  │              •                          │  •   •
  │                •                        │      •   •
  └──────────────────> km                  └──────────────────> km
  
  ✅ Perfecto para regresión               ⚠️  Regresión menos útil
```

### 🧮 Fórmula alternativa de correlación

Forma computacionalmente eficiente (sin calcular medias primero):

$$
r = \frac{m \sum xy - (\sum x)(\sum y)}{\sqrt{[m \sum x^2 - (\sum x)^2][m \sum y^2 - (\sum y)^2]}}
$$

Esta es la forma que usarías si implementaras un cálculo de correlación en el código.

### ✅ Conceptos clave

| Concepto | Fórmula | Rango | Uso |
|----------|---------|-------|-----|
| **Covarianza** | $\text{Cov}(X,Y) = \frac{1}{m}\sum(x_i-\bar{x})(y_i-\bar{y})$ | $-\infty$ a $+\infty$ | Detectar relación |
| **Correlación** | $r = \frac{\text{Cov}(X,Y)}{\sigma_x \sigma_y}$ | -1 a +1 | Cuantificar fuerza |
| **R²** | $R^2 = r^2$ | 0 a 1 | Evaluar modelo |

### 🎥 Aprende más
- [**Covarianza y Correlación** - Matemáticas profe Alex](https://www.youtube.com/watch?v=Cq-7xt5fTKw) - Explicación clara en español
- [**Correlation Explained** - StatQuest](https://www.youtube.com/watch?v=xZ_z8KWkhXE) - Correlación explicada visualmente
- [**¿Qué es la Correlación?** - DotCSV](https://www.youtube.com/watch?v=HJ_AlR-Llkw) - Correlación en Machine Learning

[↑ Volver al índice](#indice)

---

## 7️⃣ Métricas de evaluación

### 🎯 ¿Por qué necesitamos métricas?

Una vez entrenado el modelo, necesitamos **medir qué tan bueno es**. Las métricas de evaluación nos permiten:
- 📊 Cuantificar la calidad del modelo
- 📈 Comparar diferentes modelos
- 🎯 Comunicar resultados de forma clara
- ✅ Validar que el modelo funciona bien

### 📊 MSE (Mean Squared Error)

**Fórmula**:
$$
\mathrm{MSE} = \frac{1}{m} \sum_{i=1}^{m} \bigl(h_\theta(x^{(i)}) - y^{(i)}\bigr)^2
$$

**¿Qué es?**: El **promedio de los errores al cuadrado**.

**Características**:
- ✅ Penaliza **fuertemente** errores grandes (por el cuadrado)
- ❌ Difícil de interpretar (unidades al cuadrado: €²)
- ✅ Siempre positivo
- ✅ MSE = 0 → modelo perfecto

**💡 Ejemplo con 3 coches**:

| Coche | km | Precio real | Predicción | Error | Error² |
|-------|-----|-------------|------------|-------|--------|
| 1 | 50k | 7,500€ | 7,450€ | -50€ | 2,500 |
| 2 | 100k | 6,000€ | 6,100€ | +100€ | 10,000 |
| 3 | 150k | 4,500€ | 4,700€ | +200€ | 40,000 |

$$
\mathrm{MSE} = \frac{2500 + 10000 + 40000}{3} = \frac{52500}{3} = 17,500 \text{ €}^2
$$

**Interpretación**: Un error de 200€ pesa mucho más que uno de 50€ (40,000 vs 2,500).

### 📏 RMSE (Root Mean Squared Error)

**Fórmula**:
$$
\mathrm{RMSE} = \sqrt{\mathrm{MSE}}
$$

**¿Qué es?**: La **raíz cuadrada del MSE**.

**Características**:
- ✅ **Mismas unidades** que los datos originales (€)
- ✅ Fácil de interpretar: "error promedio aproximado"
- ✅ Penaliza errores grandes (pero menos que MSE)

**💡 Continuando el ejemplo anterior**:
$$
\mathrm{RMSE} = \sqrt{17,500} ≈ 132€
$$

**Interpretación**: "En promedio, nuestras predicciones se equivocan por unos 132€".

### 📉 MAE (Mean Absolute Error)

**Fórmula**:
$$
\mathrm{MAE} = \frac{1}{m} \sum_{i=1}^{m} |h_\theta(x^{(i)}) - y^{(i)}|
$$

**¿Qué es?**: El **promedio de los valores absolutos de los errores**.

**Características**:
- ✅ Mismas unidades que los datos (€)
- ✅ Más **robusto** a outliers (no eleva al cuadrado)
- ✅ Interpretación directa
- ❌ No penaliza tanto errores grandes

**💡 Mismo ejemplo**:

| Coche | Error | |Error| |
|-------|-------|---------|
| 1 | -50€ | 50€ |
| 2 | +100€ | 100€ |
| 3 | +200€ | 200€ |

$$
\mathrm{MAE} = \frac{50 + 100 + 200}{3} = \frac{350}{3} ≈ 117€
$$

**Interpretación**: "El error promedio absoluto es de 117€".

### 📊 MAPE (Mean Absolute Percentage Error)

**Fórmula**:
$$
\mathrm{MAPE} = \frac{100}{m} \sum_{i=1}^{m} \left|\frac{h_\theta(x^{(i)}) - y^{(i)}}{y^{(i)}}\right|
$$

**¿Qué es?**: El **promedio de los errores porcentuales**.

**Características**:
- ✅ Independiente de la escala (%  en vez de €)
- ✅ Útil para comparar modelos en diferentes datasets
- ❌ Problemático si $y^{(i)} ≈ 0$ (división por cero)
- ✅ Fácil de comunicar a no técnicos

**💡 Mismo ejemplo**:

| Coche | Precio real | Error | % Error |
|-------|-------------|-------|---------|
| 1 | 7,500€ | 50€ | $\frac{50}{7500} = 0.67\%$ |
| 2 | 6,000€ | 100€ | $\frac{100}{6000} = 1.67\%$ |
| 3 | 4,500€ | 200€ | $\frac{200}{4500} = 4.44\%$ |

$$
\mathrm{MAPE} = \frac{0.67 + 1.67 + 4.44}{3} = \frac{6.78}{3} ≈ 2.26\%
$$

**Interpretación**: "En promedio, nos equivocamos en un 2.26% del precio real".

### ⭐ R² (Coeficiente de determinación)

**Fórmula**:
$$
R^2 = 1 - \frac{\sum_{i=1}^{m} (y^{(i)} - h_\theta(x^{(i)}))^2}{\sum_{i=1}^{m} (y^{(i)} - \bar{y})^2}
$$

donde $\bar{y}$ es el **precio promedio** de todos los coches.

**¿Qué es?**: Mide **qué proporción de la varianza** es explicada por el modelo.

**Interpretación del valor**:

| Valor R² | Significado | Calidad |
|----------|-------------|---------|
| **1.0** | Predicciones perfectas | ⭐⭐⭐⭐⭐ Excelente (sospechoso de overfitting) |
| **0.9 - 0.99** | Muy buen ajuste | ⭐⭐⭐⭐ Muy bueno |
| **0.7 - 0.89** | Buen ajuste | ⭐⭐⭐ Bueno |
| **0.5 - 0.69** | Ajuste moderado | ⭐⭐ Regular |
| **0.0 - 0.49** | Ajuste pobre | ⭐ Malo |
| **< 0** | Peor que predecir la media | ❌ Muy malo |

**💡 Ejemplo detallado**:

Supongamos:
- Precio promedio $\bar{y} = 6000€$
- 3 coches con predicciones del ejemplo anterior

**Paso 1: Error del modelo (numerador)**
$$
\sum (y - h_\theta(x))^2 = 2500 + 10000 + 40000 = 52,500
$$

**Paso 2: Varianza total (denominador)**

| Coche | Precio real | Precio medio | Diferencia² |
|-------|-------------|--------------|-------------|
| 1 | 7,500€ | 6,000€ | $(7500-6000)^2 = 2,250,000$ |
| 2 | 6,000€ | 6,000€ | $(6000-6000)^2 = 0$ |
| 3 | 4,500€ | 6,000€ | $(4500-6000)^2 = 2,250,000$ |

$$
\sum (y - \bar{y})^2 = 2,250,000 + 0 + 2,250,000 = 4,500,000
$$

**Paso 3: Calcular R²**
$$
R^2 = 1 - \frac{52,500}{4,500,000} = 1 - 0.0117 = 0.9883 ≈ 0.99
$$

**Interpretación**: "El modelo explica el 98.8% de la varianza en los precios. ¡Excelente!"

### 🔍 Comparación de métricas

**Dataset de ejemplo**: 3 coches con errores: -50€, +100€, +200€

| Métrica | Valor | Unidad | Interpretación |
|---------|-------|--------|----------------|
| **MSE** | 17,500 | €² | Difícil de interpretar |
| **RMSE** | 132 | € | "Error promedio de ~132€" |
| **MAE** | 117 | € | "Error absoluto promedio de 117€" |
| **MAPE** | 2.26 | % | "Nos equivocamos ~2.3%" |
| **R²** | 0.99 | - | "Explicamos 99% de la varianza" |

### 🎯 ¿Qué métrica usar?

| Situación | Métrica recomendada | Por qué |
|-----------|---------------------|---------|
| **Presentar a clientes** | MAPE o R² | Fáciles de entender |
| **Comparar modelos** | RMSE o R² | Interpretables y estándar |
| **Optimizar durante entrenamiento** | MSE | Derivadas más simples |
| **Dataset con outliers** | MAE | Más robusto |
| **Evaluar poder explicativo** | R² | Mide ajuste global |

### 💡 En precision.py

En nuestro proyecto, `precision.py` calcula todas estas métricas:

```python
# Después del entrenamiento
predictions = [theta_0 + theta_1 * km for km in kilometrajes]
errors = [pred - real for pred, real in zip(predictions, precios)]

# MSE
mse = sum([e**2 for e in errors]) / len(errors)

# RMSE
rmse = sqrt(mse)

# MAE
mae = sum([abs(e) for e in errors]) / len(errors)

# MAPE
mape = sum([abs(e / real) for e, real in zip(errors, precios)]) / len(errors) * 100

# R²
mean_price = sum(precios) / len(precios)
ss_res = sum([e**2 for e in errors])
ss_tot = sum([(price - mean_price)**2 for price in precios])
r2 = 1 - (ss_res / ss_tot)

print(f"MSE:  {mse:.2f} €²")
print(f"RMSE: {rmse:.2f} €")
print(f"MAE:  {mae:.2f} €")
print(f"MAPE: {mape:.2f} %")
print(f"R²:   {r2:.4f}")
```

### 🎥 Aprende más
- [**¿Cómo medir el desempeño de un modelo de Regresión? | Métricas de Regresión** - Codificando Bits](https://youtu.be/0GnZ7krN2ss?si=PL1B9Qkvu6kT9hBt)
- [**R² explicado visualmente** - StatQuest](https://www.youtube.com/watch?v=2AQKmw14mHM) - Coeficiente de determinación

[↑ Volver al índice](#indice)

---

## 📊 Análisis de Residuos

### 🎯 ¿Qué son los residuos?

Los **residuos** (también llamados errores) son las diferencias entre los valores reales y los valores predichos por el modelo.

$$
\text{Residuo}_i = y^{(i)} - \hat{y}^{(i)} = y^{(i)} - h_\theta(x^{(i)})
$$

donde:
- $y^{(i)}$ = valor real (precio real del coche $i$)
- $\hat{y}^{(i)}$ = predicción del modelo para el coche $i$
- $\text{Residuo}_i$ = error en la predicción

**Conexión con el proyecto**: En [precision.py](precision.py#L89) calculamos los residuos para cada muestra y los usamos para calcular las métricas de evaluación.

### 📐 Suma de Cuadrados (Sum of Squares)

Los residuos se utilizan para calcular tres medidas fundamentales:

#### 1️⃣ Suma de Cuadrados Total (SST - Total Sum of Squares)

Mide la **variabilidad total** en los datos (sin considerar el modelo):

$$
\text{SST} = \sum_{i=1}^{m} (y^{(i)} - \bar{y})^2
$$

**Significado**: "¿Cuánto varían los precios respecto a su media?"

#### 2️⃣ Suma de Cuadrados Residual (SSR - Residual Sum of Squares)

Mide la **variabilidad NO explicada** por el modelo:

$$
\text{SSR} = \sum_{i=1}^{m} (y^{(i)} - \hat{y}^{(i)})^2 = \sum_{i=1}^{m} (\text{Residuo}_i)^2
$$

**Significado**: "¿Cuánto error comete nuestro modelo?"

#### 3️⃣ Suma de Cuadrados Explicada (SSE - Explained Sum of Squares)

Mide la **variabilidad explicada** por el modelo:

$$
\text{SSE} = \sum_{i=1}^{m} (\hat{y}^{(i)} - \bar{y})^2
$$

**Relación fundamental**:

$$
\text{SST} = \text{SSE} + \text{SSR}
$$

```
Variabilidad Total = Variabilidad Explicada + Variabilidad No Explicada
```

### 🔗 Conexión con R²

El coeficiente de determinación se calcula usando estas sumas:

$$
R^2 = 1 - \frac{\text{SSR}}{\text{SST}} = \frac{\text{SSE}}{\text{SST}}
$$

**Implementación en precision.py**:

```python
# Línea 84-87 en precision.py
ss_total = sum((price - mean_price) ** 2 for price in actual_prices)

# Línea 89-90
ss_residual = sum((actual_prices[i] - predictions[i]) ** 2 for i in range(n))

# Línea 92-94
r_squared = 1 - (ss_residual / ss_total) if ss_total != 0 else 0
```

### 💡 Ejemplo numérico completo

Supongamos 4 coches con precio medio $\bar{y} = 6000$€:

| i | km | Precio real<br>$y^{(i)}$ | Predicción<br>$\hat{y}^{(i)}$ | Residuo<br>$y - \hat{y}$ | $(y - \bar{y})^2$ | $(y - \hat{y})^2$ |
|---|---|---|---|---|---|---|
| 1 | 50k | 7,500 | 7,400 | +100 | 2,250,000 | 10,000 |
| 2 | 100k | 6,200 | 6,100 | +100 | 40,000 | 10,000 |
| 3 | 150k | 5,800 | 5,800 | 0 | 40,000 | 0 |
| 4 | 200k | 4,500 | 4,700 | -200 | 2,250,000 | 40,000 |
| **Σ** | | | | | **4,580,000** | **60,000** |

**Cálculos**:

$$
\text{SST} = 4,580,000 \quad \text{(varianza total en los precios)}
$$

$$
\text{SSR} = 60,000 \quad \text{(error del modelo)}
$$

$$
R^2 = 1 - \frac{60,000}{4,580,000} = 1 - 0.013 = 0.987 = 98.7\%
$$

**Interpretación**: El modelo explica el 98.7% de la varianza → excelente ajuste.

### 📊 Visualización de residuos

```
Precio
  │
8k│    •                         • = punto real
  │   /|                         / = línea de regresión
7k│  / •←residuo positivo       | = residuo
  │ /  |
6k│/   • ← residuo ≈ 0
  /    |
5k|    •
  │   /|← residuo negativo
4k│  / •
  └──────────> km
```

### 🔍 Propiedades de los residuos en un buen modelo

Un modelo de regresión lineal bien ajustado debe tener residuos que cumplan:

#### 1️⃣ Media cero

$$
\frac{1}{m}\sum_{i=1}^{m} \text{Residuo}_i \approx 0
$$

**Significado**: El modelo no tiene sesgo sistemático (no sobre-predice ni sub-predice consistentemente).

#### 2️⃣ Distribución normal

Los residuos deben seguir aproximadamente una distribución normal (gaussiana).

```
Frecuencia
    │      ╱╲
    │     ╱  ╲
    │    ╱    ╲
    │   ╱      ╲
    │__╱________╲____ Residuo
     -σ    0    +σ
```

#### 3️⃣ Varianza constante (Homocedasticidad)

Los residuos deben tener varianza similar en todo el rango de predicciones.

**Bueno** (homocedasticidad):
```
Residuo
  +│  •  •   •  •  •
   │   •  •   •  •      Dispersión constante
  0├─•───•──•───•──>
   │  •  •  •   •
  -│ •   •   •
           Predicción
```

**Malo** (heterocedasticidad):
```
Residuo
  +│            • •
   │          •   •    Dispersión creciente
  0├─•──•─•──────>
   │ •  •  • 
  -│•  •  •
           Predicción
```

#### 4️⃣ Independencia

Los residuos no deben mostrar patrones o correlación entre sí.

**Bueno** (aleatorios):
```
Residuo
   │ •  •   •  • •    Sin patrón claro
   ├──•──•───•────>
   │•   •  •
         i (índice)
```

**Malo** (patrón):
```
Residuo
   │   •••   •••       Patrón cíclico
   ├•••   •••   ••>   (problema con el modelo)
   │
         i (índice)
```

### 📈 Análisis de residuos en precision.py

Nuestro archivo [precision.py](precision.py#L1) calcula los residuos implícitamente:

```python
# Predicciones
predictions = [estimate_price(m, theta0, theta1) for m in mileages]

# Residuos (error)
residuals = [actual_prices[i] - predictions[i] for i in range(n)]

# MSE (promedio de residuos al cuadrado)
mse = sum(residual**2 for residual in residuals) / n

# MAE (promedio de residuos en valor absoluto)
mae = sum(abs(residual) for residual in residuals) / n
```

### 🎯 ¿Por qué importa el análisis de residuos?

| Si los residuos... | Entonces... | Acción |
|-------------------|-------------|--------|
| Tienen media ≠ 0 | El modelo tiene sesgo | Revisar datos o modelo |
| No son normales | Violación de supuestos | Considerar transformaciones |
| Tienen heterocedasticidad | Varianza no constante | Considerar ponderación |
| Muestran patrones | Modelo inadecuado | Probar modelo no lineal |
| Son aleatorios y pequeños | ✅ **Modelo correcto** | Continuar |

### 💡 Ejemplo práctico con nuestro dataset

Si ejecutas [precision.py](precision.py#L1) con el modelo entrenado:

```bash
$ python3 precision.py
```

Obtienes métricas calculadas a partir de los residuos:

```
RMSE: 787.23€    ← Desviación típica de los residuos
MAE:  632.45€    ← Promedio del valor absoluto de residuos
R²:   0.943      ← 94.3% de varianza explicada (SSR/SST)
```

**Interpretación**:
- Los residuos típicos son de ±787€ (RMSE)
- En promedio, nos equivocamos por 632€ (MAE)
- Solo el 5.7% de la varianza queda sin explicar (1 - R²)

### 🧮 Fórmulas resumen

| Concepto | Fórmula | En el código |
|----------|---------|--------------|
| **Residuo** | $e_i = y_i - \hat{y}_i$ | `actual - predicted` |
| **SST** | $\sum(y_i - \bar{y})^2$ | `ss_total` en precision.py |
| **SSR** | $\sum(y_i - \hat{y}_i)^2$ | `ss_residual` en precision.py |
| **MSE** | $\frac{\text{SSR}}{m}$ | `mse = ss_residual / n` |
| **RMSE** | $\sqrt{\text{MSE}}$ | `rmse = mse ** 0.5` |
| **R²** | $1 - \frac{\text{SSR}}{\text{SST}}$ | `r_squared = 1 - (ss_res/ss_tot)` |

### 🎥 Aprende más
- [**Residuos en Regresión Lineal** - Khan Academy](https://es.khanacademy.org/math/statistics-probability/describing-relationships-quantitative-data/residuals-intro/v/introduction-to-residuals-and-least-squares-regression) - Introducción a residuos
- [**Sum of Squares** - StatQuest](https://www.youtube.com/watch?v=2AQKmw14mHM) - Explicación visual de SST, SSR, SSE

[↑ Volver al índice](#indice)

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

[↑ Volver al índice](#indice)

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

[↑ Volver al índice](#indice)

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
- [**Cómo EVITAR el OVERFITTING!** - AprendeInnovando](https://youtu.be/_opXSMa_nX4?si=iMwM5FoZv3RniyyJ)
- [**Bias vs Variance** - StatQuest](https://www.youtube.com/watch?v=EuBBz3bI-aA) - Trade-off fundamental en ML (inglés con subtítulos)

[↑ Volver al índice](#indice)

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

[↑ Volver al índice](#indice)

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

[↑ Volver al índice](#indice)

---

<div align="center">

**Proyecto ft_linear_regression - Documentación Matemática**  
🏫 42 Málaga - Campus 42 | 👤 **sternero** | 📅 Enero 2026

</div>
