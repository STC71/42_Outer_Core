# 🚀 42 Outer Core

<div align="center">

![42 School](https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white)
![Status](https://img.shields.io/badge/Estado-En%20Progreso-yellow?style=for-the-badge)
![Projects](https://img.shields.io/badge/Proyectos-6-blue?style=for-the-badge)

**Colección de proyectos avanzados del currículo Outer Core de 42 School**

[Descripción](#descripción) • [Proyectos](#proyectos) • [Tecnologías](#tecnologías) • [Configuración](#configuración) • [Autor](#autor)

</div>

---

## Descripción

Bienvenido a **42 Outer Core**, una colección curada de proyectos avanzados desarrollados como parte del currículo de 42 School. Este repositorio presenta implementaciones en múltiples dominios incluyendo Inteligencia Artificial, Programación de Sistemas Unix y Desarrollo Web.

Cada proyecto está diseñado para empujar los límites del conocimiento técnico, enfatizando código limpio, pensamiento algorítmico y resolución de problemas del mundo real.

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Proyectos

### 🤖 Inteligencia Artificial

<details open>
<summary><b>ft_linear_regression</b> - Fundamentos de Machine Learning</summary>

Una implementación completa de regresión lineal desde cero, demostrando los fundamentos del aprendizaje automático sin depender de librerías de alto nivel.

**Características:**
- 📊 Entrenamiento del modelo con descenso de gradiente
- 🔮 Sistema de predicción de precios
- 📈 Herramientas de visualización de datos
- 🎯 Métricas de análisis de precisión
- ✅ Suite completa de tests

**Stack Tecnológico:** Python, NumPy, Matplotlib

**Estado:** ✅ Completado

[📂 Ver Proyecto](./artificial_intelligence/ft_linear_regression/)

</details>

<details open>
<summary><b>DSLR</b> - Data Science × Logistic Regression</summary>

Clasificador multiclase de Regresión Logística usando estrategia One-vs-All para clasificar estudiantes de Hogwarts en sus casas. Proyecto completo de Data Science con análisis estadístico, visualización y machine learning.

**Características:**
- 📊 **describe.py** - Estadísticas descriptivas sin pandas (mean, std, quartiles)
- 📈 **Visualización de datos** - Histogramas, scatter plots y pair plots
- 🤖 **Regresión Logística One-vs-All** - 4 clasificadores binarios
- 🔄 **Tres algoritmos de Gradient Descent**:
  - Batch GD (obligatorio)
  - Stochastic GD (bonus)
  - Mini-Batch GD (bonus)
- ✅ **99.0% de precisión** (requerido: ≥98%)
- 🎯 **Validación cruzada K-fold** (bonus)
- 🧹 **Preprocesamiento** - Normalización Z-score y manejo de NaN
- 📚 **Documentación exhaustiva**:
  - **MATHS.md** (2700+ líneas) - Teoría matemática completa
  - **PYTHON.md** (1500+ líneas) - Guía de Python específica
  - 80+ videos educativos en español

**Stack Tecnológico:** Python, Matplotlib (csv, pickle, sys - sin numpy/sklearn para algoritmos)

**Documentación:** 📚 [MATHS.md](./artificial_intelligence/dslr/MATHS.md) + [PYTHON.md](./artificial_intelligence/dslr/PYTHON.md) con teoría completa y 80+ videos en español

**Estado:** ✅ Completado (125/100 puntos estimados)

[📂 Ver Proyecto](./artificial_intelligence/dslr/)

</details>

<details open>
<summary><b>multilayer-perceptron</b> - Deep Learning y Redes Neuronales</summary>

Red neuronal artificial (Multilayer Perceptron) implementada desde cero para clasificación binaria. Predice diagnósticos de cáncer de mama (maligno/benigno) usando el dataset de Wisconsin Breast Cancer.

**Características:**
- 🧠 **Red neuronal feedforward** - Mínimo 2 capas ocultas
- 🔙 **Backpropagation** - Implementación manual del algoritmo
- 📉 **Gradient Descent** - Optimización de pesos
- 🎲 **Funciones de activación** - Sigmoid, Tanh, ReLU, Softmax
- 📊 **Dataset** - 569 muestras con 30 características
- 📈 **Visualización** - Curvas de Loss y Accuracy (train/validation)
- 🎯 **Métricas** - Binary cross-entropy, precisión
- 🔧 **Configuración flexible** - Arquitectura modular de capas
- ⚙️ **Hiperparámetros** - Learning rate, batch size, epochs ajustables
- 🧹 **Preprocesamiento** - Normalización y división de datos

**Stack Tecnológico:** Python, NumPy, Matplotlib (sin TensorFlow/Keras/PyTorch)

**Conceptos clave:** Feedforward, Backpropagation, Gradient Descent, Activations, Overfitting

**Estado:** 🚧 En Desarrollo

[📂 Ver Proyecto](./artificial_intelligence/multilayer-perceptron/)

</details>

### 🐧 Kernel Unix

<details open>
<summary><b>libasm</b> - Implementación de Librería en Assembly</summary>

Una librería de bajo nivel que implementa funciones estándar de C en Assembly x86-64, proporcionando conocimientos profundos sobre arquitectura de sistemas y optimización.

**Características:**
- 🔧 Funciones básicas de manipulación de strings (`strlen`, `strcpy`, `strcmp`)
- 📝 Operaciones de I/O (`read`, `write`)
- 💾 Gestión de memoria (`strdup`)
- 🎁 Bonus: Operaciones avanzadas de listas y conversión de bases
- ⚡ Rutinas optimizadas en assembly
- 🧪 Framework completo de testing

**Stack Tecnológico:** Assembly x86-64 (sintaxis Intel), C, Makefile

**Estado:** ✅ Completado

[📂 Ver Proyecto](./unix_kernel/libasm/)

</details>

### 🌐 Web & Base de Datos

<details open>
<summary><b>Camagru</b> - Aplicación Web tipo Instagram</summary>

Una aplicación web full-stack inspirada en Instagram con captura de fotos desde webcam, edición con stickers y funcionalidades sociales.

**Características Principales:**
- 📸 **Captura desde webcam** con getUserMedia API
- 🎨 **Superposición de stickers** sobre fotos
- 👥 **Sistema completo de autenticación** (registro, login, verificación por email)
- 💬 **Interacción social** (likes y comentarios en tiempo real con AJAX)
- 📤 **Subida de archivos** con validación de seguridad
- 📱 **Diseño responsive** (móvil, tablet, desktop)

**Características BONUS:**
- ✨ Vista previa en vivo de stickers sobre webcam
- ♾️ Scroll infinito con Intersection Observer
- 🎬 Generación de GIFs animados
- 🔗 Compartir en redes sociales

**Stack Tecnológico:** PHP 8.2 (MVC personalizado), MySQL 8.0, JavaScript Vanilla, HTML5/CSS3, Docker

**Arquitectura:** Patrón MVC sin frameworks, PDO para base de datos, AJAX para interactividad

**Documentación:** 📚 [19 README detallados](./web_database/camagru/) explicando cada componente del proyecto + videos educativos en español

**Estado:** ✅ Completado (125/100 puntos estimados)

[📂 Ver Proyecto](./web_database/camagru/) | [🚀 Guía Rápida](./web_database/camagru/QUICKSTART.md) | [📋 Compliance](./web_database/camagru/COMPLIANCE.md)

</details>

### 🦠 Virus & Security

<details open>
<summary><b>Dr. Quine</b> - Recursión y Auto-replicación</summary>

Proyecto introductorio al teorema de recursión de Kleene mediante la implementación de quines - programas que se auto-replican imprimiendo su propio código fuente.

**Características:**
- 🔄 **Quines básicos** - Programas que imprimen su propio código
- 🧬 **Auto-replicación controlada** - Propagación con N generaciones
- 🔬 **Fundamentos de malware** - Conceptos de virus informáticos
- 🧠 **Teorema de Kleene** - Recursión y puntos fijos en computación
- 📝 **Implementación dual** - C y Assembly x86-64
- 🎯 **Tres programas**: Colleen (quine básico), Grace (auto-escritura), Sully (replicación N veces)

**Stack Tecnológico:** C, Assembly x86-64 (NASM)

**Conceptos clave:** Metaprogramación, auto-replicación, teorema de recursión, puntos fijos

**Estado:** 🚧 En Desarrollo

[📂 Ver Proyecto](./virus/dr-quine/)

</details>

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Tecnologías

<div align="center">

### Lenguajes
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Assembly](https://img.shields.io/badge/Assembly-654FF0?style=for-the-badge&logo=assemblyscript&logoColor=white)
![C](https://img.shields.io/badge/C-A8B9CC?style=for-the-badge&logo=c&logoColor=black)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

### Herramientas & Frameworks
![NumPy](https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-11557c?style=for-the-badge)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Make](https://img.shields.io/badge/Make-6D00CC?style=for-the-badge)

</div>

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Configuración

Cada proyecto contiene sus propias instrucciones de configuración y dependencias. Navega al directorio del proyecto específico y consulta su README individual para información detallada.

### 📦 Trabajando con Git Submodules

Este repositorio utiliza **Git Submodules** para organizar cada proyecto de forma independiente. Cada proyecto (dslr, ft_linear_regression, libasm, camagru) es un repositorio separado que puede clonarse y trabajarse individualmente o como parte de esta colección.

#### 🔽 Clonar el Repositorio Completo

Para obtener todos los proyectos con sus contenidos:

```bash
# Opción 1: Clonar con submódulos (recomendado)
git clone --recursive https://github.com/STC71/42_Outer_Core.git

# Opción 2: Si ya clonaste sin --recursive
git clone https://github.com/STC71/42_Outer_Core.git
cd 42_Outer_Core
git submodule update --init --recursive
```

#### 🔄 Actualizar Submódulos

Para obtener las últimas actualizaciones de todos los proyectos:

```bash
# Actualizar todos los submódulos a sus últimos commits
git submodule update --remote --merge

# Actualizar el repositorio principal y todos los submódulos
git pull --recurse-submodules
```

#### 📝 Trabajar en un Submódulo

Si quieres hacer cambios en un proyecto específico:

```bash
# 1. Navegar al submódulo
cd artificial_intelligence/dslr

# 2. El submódulo está en "detached HEAD", crear/cambiar a una rama
git checkout main  # o git checkout -b mi-feature

# 3. Hacer cambios y commit normalmente
echo "# Cambio" >> README.md
git add .
git commit -m "Actualización del README"

# 4. Push al repositorio del submódulo
git push origin main

# 5. Volver al repositorio principal y actualizar la referencia
cd ../..
git add artificial_intelligence/dslr
git commit -m "Actualizar submódulo dslr"
git push
```

#### 🎯 Clonar Solo un Proyecto Específico

Si solo necesitas trabajar con un proyecto individual:

```bash
# Clonar directamente el repositorio del proyecto
git clone https://github.com/STC71/42_ft_linear_regression.git
git clone https://github.com/STC71/42_dslr.git
git clone https://github.com/STC71/42_multilayer-perceptron.git
git clone https://github.com/STC71/42_libasm.git
git clone https://github.com/STC71/42_camagru.git
git clone https://github.com/STC71/42_dr-quine.git
```

#### ⚠️ Consideraciones Importantes

- Los submódulos **no se actualizan automáticamente** con `git pull` del repositorio principal
- Cada submódulo apunta a un **commit específico**, no a una rama
- Al hacer cambios en un submódulo, necesitas hacer commit **primero en el submódulo** y **luego en el repositorio principal**
- Usa `git status` en el repositorio principal para ver si hay actualizaciones pendientes en los submódulos

#### 📚 Comandos Útiles

```bash
# Ver el estado de todos los submódulos
git submodule status

# Ejecutar un comando en todos los submódulos
git submodule foreach 'git pull origin main'

# Ver diferencias en submódulos
git diff --submodule

# Eliminar un submódulo (si es necesario)
git submodule deinit -f ruta/al/submodulo
git rm -f ruta/al/submodulo
rm -rf .git/modules/ruta/al/submodulo
```

### Requisitos Generales

```bash
# Clonar el repositorio con submódulos
git clone --recursive https://github.com/STC71/42_Outer_Core.git
cd 42_Outer_Core

# Navegar al proyecto específico
cd [categoría]/[nombre_proyecto]

# Seguir las instrucciones del README del proyecto
```

### Enlaces Rápidos a Guías de Configuración

- [Configuración ft_linear_regression](./artificial_intelligence/ft_linear_regression/README.md)
- [Configuración DSLR](./artificial_intelligence/dslr/README.md)
- [Configuración multilayer-perceptron](./artificial_intelligence/multilayer-perceptron/README.md)
- [Configuración libasm](./unix_kernel/libasm/README.md)
- [Configuración Camagru (Docker + Manual)](./web_database/camagru/QUICKSTART.md)
- [Configuración Dr. Quine](./virus/dr-quine/README.md)

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Progreso

| Categoría | Proyecto | Lenguaje | Estado | Completado |
|-----------|----------|----------|--------|------------|
| IA | ft_linear_regression | Python | ✅ Completado | 100% |
| IA | DSLR | Python | ✅ Completado | 100% |
| IA | multilayer-perceptron | Python | 🚧 En Desarrollo | 40% |
| Unix | libasm | Assembly/C | ✅ Completado | 100% |
| Web | Camagru | PHP/JS/SQL | ✅ Completado | 100% |
| Virus | Dr. Quine | C/Assembly | 🚧 En Desarrollo | 10% |

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Objetivos de Aprendizaje

Este repositorio demuestra competencia en:

- **Machine Learning**: Construcción de algoritmos de ML desde cero
- **Programación de Bajo Nivel**: Lenguaje ensamblador y llamadas al sistema
- **Desarrollo Web**: Arquitectura de aplicaciones full-stack
- **Seguridad Informática**: Auto-replicación, malware y teoría de la computación
- **Ingeniería de Software**: Código limpio, testing, documentación
- **Resolución de Problemas**: Pensamiento algorítmico y optimización

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Documentación

Cada proyecto incluye documentación exhaustiva:

### ft_linear_regression
- ✅ README principal con teoría matemática
- ✅ Documentación de uso y testing
- ✅ Guías de precisión y visualización
- ✅ MATHS.md y PYTHON.md con teoría completa

### DSLR (Documentación Destacada)
- ✅ **MATHS.md (2700+ líneas)** - Fundamentos completos de Regresión Logística
- ✅ **PYTHON.md (1500+ líneas)** - Guía exhaustiva de Python para ML
- ✅ **80+ videos educativos en español** sobre cada concepto
- ✅ Ejemplos numéricos paso a paso (3 estudiantes, 2 features)
- ✅ Derivaciones matemáticas completas (sigmoid, cost, gradient)
- ✅ Código comentado línea por línea sin numpy/sklearn
- ✅ Diagramas de flujo y visualizaciones
- ✅ README técnico con arquitectura One-vs-All

### libasm
- ✅ README técnico con explicaciones de Assembly
- ✅ Documentación de cada función
- ✅ Tests unitarios y de integración

### Camagru (Documentación Destacada)
- ✅ **19 README detallados** (uno por carpeta/subcarpeta)
- ✅ Explicación clara del **QUÉ, POR QUÉ y PARA QUÉ** de cada componente
- ✅ **80+ videos educativos en español** sobre tecnologías del proyecto
- ✅ Guías de inicio rápido, compliance y resumen técnico
- ✅ Documentación de arquitectura MVC, seguridad y buenas prácticas
- ✅ Ejemplos prácticos sin sobrecarga de código

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Contribuciones

Este repositorio es parte de mi viaje personal de aprendizaje en 42 School. Aunque actualmente no se aceptan contribuciones, ¡el feedback y las sugerencias siempre son bienvenidos!

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Licencia

Este proyecto es parte del currículo de 42 Málaga. Por favor, respeta las políticas de integridad académica de la escuela.

<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

## Autor

**sternero**

- 42 Intra: `sternero`
- GitHub: [@STC71](https://github.com/STC71)
<div align="right">

[⬆️ Volver arriba](#-42-outer-core)

</div>

---

<div align="center">

**Hecho con ❤️ en 42 Málaga**

*Última Actualización: Marzo 2026*

</div>
