# 🚀 42 Outer Core

<div align="center">

![42 School](https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white)
![Status](https://img.shields.io/badge/Estado-En%20Progreso-yellow?style=for-the-badge)
![Projects](https://img.shields.io/badge/Proyectos-3-blue?style=for-the-badge)

**Colección de proyectos avanzados del currículo Outer Core de 42 School**

[Descripción](#descripción) • [Proyectos](#proyectos) • [Tecnologías](#tecnologías) • [Configuración](#configuración) • [Autor](#autor)

</div>

---

## Descripción

Bienvenido a **42 Outer Core**, una colección curada de proyectos avanzados desarrollados como parte del currículo de 42 School. Este repositorio presenta implementaciones en múltiples dominios incluyendo Inteligencia Artificial, Programación de Sistemas Unix y Desarrollo Web.

Cada proyecto está diseñado para empujar los límites del conocimiento técnico, enfatizando código limpio, pensamiento algorítmico y resolución de problemas del mundo real.

<div align="right">

[⬆️ Volver arriba](#)

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

<div align="right">

[⬆️ Volver arriba](#)

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

[⬆️ Volver arriba](#)

</div>

## Configuración

Cada proyecto contiene sus propias instrucciones de configuración y dependencias. Navega al directorio del proyecto específico y consulta su README individual para información detallada.

### Requisitos Generales

```bash
# Clonar el repositorio
git clone https://github.com/STC71/42_Outer_Core.git
cd 42_Outer_Core

# Navegar al proyecto específico
cd [categoría]/[nombre_proyecto]

# Seguir las instrucciones del README del proyecto
```

### Enlaces Rápidos a Guías de Configuración

- [Configuración ft_linear_regression](./artificial_intelligence/ft_linear_regression/README.md)
- [Configuración libasm](./unix_kernel/libasm/README.md)
- [Configuración Camagru (Docker + Manual)](./web_database/camagru/QUICKSTART.md)

<div align="right">

[⬆️ Volver arriba](#)

</div>

## Progreso

| Categoría | Proyecto | Lenguaje | Estado | Completado |
|-----------|----------|----------|--------|------------|
| IA | ft_linear_regression | Python | ✅ Completado | 100% |
| Unix | libasm | Assembly/C | ✅ Completado | 100% |
| Web | Camagru | PHP/JS/SQL | ✅ Completado | 100% |

<div align="right">

[⬆️ Volver arriba](#)

</div>

## Objetivos de Aprendizaje

Este repositorio demuestra competencia en:

- **Machine Learning**: Construcción de algoritmos de ML desde cero
- **Programación de Bajo Nivel**: Lenguaje ensamblador y llamadas al sistema
- **Desarrollo Web**: Arquitectura de aplicaciones full-stack
- **Ingeniería de Software**: Código limpio, testing, documentación
- **Resolución de Problemas**: Pensamiento algorítmico y optimización

<div align="right">

[⬆️ Volver arriba](#)

</div>

## Documentación

Cada proyecto incluye documentación exhaustiva:

### ft_linear_regression
- ✅ README principal con teoría matemática
- ✅ Documentación de uso y testing
- ✅ Guías de precisión y visualización

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

[⬆️ Volver arriba](#)

</div>

## Contribuciones

Este repositorio es parte de mi viaje personal de aprendizaje en 42 School. Aunque actualmente no se aceptan contribuciones, ¡el feedback y las sugerencias siempre son bienvenidos!

<div align="right">

[⬆️ Volver arriba](#)

</div>

## Licencia

Este proyecto es parte del currículo de 42 Málaga. Por favor, respeta las políticas de integridad académica de la escuela.

<div align="right">

[⬆️ Volver arriba](#)

</div>

## Autor

**sternero**

- 42 Intra: `sternero`
- GitHub: [@STC71](https://github.com/STC71)
Enero 2026
<div align="right">

[⬆️ Volver arriba](#)

</div>

---

<div align="center">

**Hecho con ❤️ en 42 Málaga**

*Última Actualización: Enero 2026*

</div>
