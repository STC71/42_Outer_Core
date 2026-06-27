# 🌦️ Piscine Mobile - Module 01: Weather App (Estructura y Navegación)

**Segundo módulo de la Piscine Mobile de 42 Málaga.**  
En este módulo, dejamos atrás las bases para adentrarnos en la creación de una aplicación con una estructura más compleja. El objetivo principal es dominar la navegación y la captura de datos del usuario mediante componentes avanzados de Flutter.

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
- [✅ Guía de Evaluación](#-guía-de-evaluación)
- [🛠️ Preparación del Entorno](#️-preparación-del-entorno)
- [✍️ Autor](#️-autor)

---

## 🎯 Objetivos del Módulo

El **Module 01** se centra en la organización visual y la interacción. Al finalizar, habrás aprendido a:
1. Implementar la navegación mediante **BottomNavigationBar**.
2. Gestionar múltiples vistas o pestañas dentro de una misma pantalla.
3. Utilizar **TextField** para capturar entradas de texto complejas.
4. Diseñar barras de herramientas (**AppBar**) personalizadas con botones de acción.
5. Aplicar estilos y temas coherentes en toda la aplicación.

---

## 📋 Reglas Generales

*   **Sin Errores de Layout**: Es crítico que la aplicación sea responsiva. No debe haber desbordamientos de píxeles.
*   **Logs de Depuración**: Cada acción (cambio de pestaña, envío de búsqueda, clic en GPS) debe quedar registrada en la consola.
*   **Organización del Código**: Se valora la limpieza y la separación de componentes en widgets reutilizables.

---

## 🛣️ Hoja de Ruta Detallada

### 🔹 [weather_app: The Foundation](./weather_app/README.md)
*   **El Reto**: Crear la estructura visual de una aplicación de clima con tres secciones: "Currently", "Today" y "Weekly".
*   **Requisitos específicos**: 
    *   **Barra Superior**: Un buscador (`TextField`) y un botón de geolocalización.
    *   **Cuerpo**: Un área central que cambie según la pestaña seleccionada.
    *   **Barra Inferior**: Tres iconos con sus respectivos nombres para navegar.
*   **Propósito**: Entender cómo se estructuran las aplicaciones modernas con múltiples puntos de acceso.

---

## ✅ Guía de Evaluación (Peer-to-Peer)

### 1. Interfaz y Navegación
- [ ] **Navegación**: ¿Al pulsar en los iconos de abajo cambia el texto central?
- [ ] **Buscador**: ¿Al escribir una ciudad y pulsar "Enter", se actualiza la franja azul con el nombre de la ciudad?
- [ ] **GPS**: ¿Al pulsar el icono de ubicación, cambia el texto a "Geolocation"?

### 2. Comportamiento y Robustez
- [ ] **Teclado**: ¿El teclado se oculta correctamente o permite la interacción sin romper el diseño?
- [ ] **Logs**: Verifica que en la consola aparezca el rastro de cada interacción del usuario.
- [ ] **Responsividad**: Al girar el dispositivo, ¿la barra de búsqueda y los iconos se mantienen en su sitio correctamente?

---

## 🛠️ Preparación del Entorno

```bash
# Entra en la carpeta del proyecto
cd weather_app

# Obtén las dependencias
flutter pub get

# Ejecuta la aplicación
flutter run
```

---

## ✍️ Autor

**[sternero](https://github.com/STC71)** - junio 2026

---
<p align="center">
  <b>Piscine Mobile 42 Málaga</b><br>
  <i>"Mastering the art of Navigation"</i>
</p>
