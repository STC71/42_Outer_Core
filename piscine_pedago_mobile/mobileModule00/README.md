# 🚀 Piscine Mobile - Module 00: Flutter Fundamentals

**Bienvenido al primer módulo de la Piscine Mobile de 42 Málaga.**  
Este proyecto es el punto de partida para convertirte en desarrollador móvil. A través de una serie de ejercicios prácticos, exploraremos el ecosistema de **Flutter** y **Dart**, desde la creación de una interfaz básica hasta la lógica compleja de una aplicación funcional.

---
> 🔗 **[Ir al README General de la Piscine](../README.md)** | **[📖 Guía de Aprendizaje](../FLUTTER.md)**
---

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Material%20Design%203-757575?style=for-the-badge&logo=google&logoColor=white" alt="Material Design 3" />
  <img src="https://img.shields.io/badge/42_Málaga-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 Málaga" />
</p>

---

## 📑 Índice
- [🎯 Objetivos del Módulo](#-objetivos-del-módulo)
- [📋 Reglas Generales](#-reglas-generales)
- [🛣️ Hoja de Ruta Detallada](#️-hoja-de-ruta-detallada)
- [✅ Guía de Evaluación Exhaustiva](#-guía-de-evaluación-exhaustiva)
- [🛠️ Preparación del Entorno](#️-preparación-del-entorno)
- [✍️ Autor](#️-autor)

---

## 🎯 Objetivos del Módulo

El **Module 00** tiene como meta que se comprenda la naturaleza reactiva de Flutter. Al finalizar, serás capaz de:
1. Construir interfaces usando el **Árbol de Widgets**.
2. Gestionar el **Estado** de una aplicación para que reaccione al usuario.
3. Implementar **Layouts adaptativos** que funcionen en cualquier pantalla y orientación.
4. Integrar **lógica de negocio** y librerías externas en Dart.

---

## 📋 Reglas Generales (Subject Requirements)

Para que el proyecto sea válido, debe cumplir estrictamente con las normas del subject:

*   **Versión de Flutter**: Se debe utilizar una versión estable y reciente (preferiblemente ^3.19.0).
*   **Sin Warnings**: El código debe compilar sin advertencias. Revisa los `analysis_options.yaml`.
*   **Estructura**: Cada ejercicio debe estar en su propia carpeta (`ex00`, `ex01`, etc.).
*   **Librerías Externas**: Solo están permitidas en el ejercicio final (`calculator_app`). Para los demás, se debe usar el SDK estándar de Flutter.
*   **Logs obligatorios**: Todos los clics en botones deben imprimir información relevante en la consola mediante `debugPrint`.

---

## 🛣️ Hoja de Ruta Detallada

### 🔹 [ex00: A Basic Display](./ex00/README.md)
*   **El Reto**: Crear una pantalla con un texto central y un botón.
*   **Requisitos específicos**: 
    *   Texto "A simple text" y botón "Click me".
    *   Uso de `Center` y `Column`.
    *   Imprimir "Button pressed" en la consola al hacer clic.
*   **Propósito**: Entender cómo se posicionan los elementos en pantalla.

### 🔹 [ex01: State Management](./ex01/README.md)
*   **El Reto**: Hacer que el botón del ejercicio anterior cambie el texto.
*   **Requisitos específicos**:
    *   Alternar entre "A simple text" y "Hello World!".
    *   Uso obligatorio de `StatefulWidget` y `setState`.
*   **Propósito**: Comprender que la UI es un reflejo de los datos (Estado).

### 🔹 [ex02: Calculator UI](./ex02/README.md)
*   **El Reto**: Diseñar la interfaz de una calculadora completa.
*   **Requisitos específicos**:
    *   Dos áreas de visualización (expresión y resultado).
    *   Teclado completo (0-9, operadores, AC, C, =).
    *   Imprimir `button pressed: [valor]` en consola.
    *   **Cero Errores de Layout**: No debe haber "overflow" (rayas amarillas) al rotar el móvil.
*   **Propósito**: Dominar el diseño de cuadrículas complejas y la responsividad.

### 🔹 [calculator_app: The Final Logic](./calculator_app/README.md)
*   **El Reto**: Dar vida a la calculadora del ex02.
*   **Requisitos específicos**:
    *   Cálculos matemáticos reales (puedes usar `math_expressions`).
    *   Gestión de errores (división por cero, sintaxis incorrecta).
    *   Botones funcionales: `AC` limpia todo, `C` borra el último carácter.
*   **Propósito**: Unir diseño y lógica en una app lista para el usuario.

---

## ✅ Guía de Evaluación Exhaustiva (Peer-to-Peer)

Estos son los puntos que se revisarán durante la evaluación:

### 1. Funcionalidad Básica (ex00 & ex01)
- [ ] ¿La aplicación arranca sin errores?
- [ ] ¿El botón imprime en la consola del evaluador?
- [ ] ¿El texto cambia de "A simple text" a "Hello World!" y viceversa?

### 2. Calidad de la Interfaz (ex02)
- [ ] **Simetría**: ¿Los botones están bien alineados y distribuidos?
- [ ] **Detección de Logs**: ¿Cada botón imprime su valor correcto al ser pulsado?
- [ ] **Prueba de Fuego (Rotación)**: El evaluador girará el móvil varias veces. La interfaz debe adaptarse sin mostrar errores visuales.

### 3. Lógica y Robustez (calculator_app)
- [ ] **Jerarquía Matemática**: Prueba `2 + 2 * 2`. El resultado debe ser `6`, no `8`.
- [ ] **Borrado**: ¿El botón `C` borra solo el último número? ¿El `AC` resetea todo a `0`?
- [ ] **Control de Crash**: Escribe una expresión inválida (ej: `*+5`). La app debe mostrar "Error", **nunca cerrarse**.
- [ ] **Precisión**: Realiza operaciones con decimales y verifica que el resultado sea coherente.

### 4. Código y Estilo
- [ ] ¿El código está limpio y bien comentado?
- [ ] ¿Se han evitado las repeticiones innecesarias (ej: usando funciones para crear botones)?

---

## 🛠️ Preparación del Entorno

Si eres el evaluador o quieres probar los proyectos:

1.  **Instala Flutter**: Sigue la guía oficial.
2.  **Verifica**: Ejecuta `flutter doctor` para asegurar que todo está en orden.
3.  **Descarga dependencias**:
    ```bash
    # En la raíz de cada ejercicio:
    flutter pub get
    ```
4.  **Lanza la app**:
    ```bash
    flutter run
    ```

---

## ✍️ Autor

**[sternero](https://github.com/STC71)** - junio 2026

---
<p align="center">
  <b>Piscine Mobile 42 Málaga</b><br>
  <i>"Don't panic and enjoy the widgets"</i>
</p>
