# ⚙️ Guía de Configuración: Del Entorno al Despliegue

Este documento detalla paso a paso cómo configurar tu entorno de desarrollo para poder ejecutar y entender los proyectos de la **Piscine Pedago Mobile**. Configurar correctamente las herramientas es el 50% del éxito en el desarrollo de software.

---

## 1. 🛠️ Instalación del SDK de Flutter

El SDK es el conjunto de herramientas que permite compilar y ejecutar código Flutter.

1.  **Descarga**: Visita [flutter.dev](https://docs.flutter.dev/get-started/install) y descarga la versión estable para tu SO.
2.  **Variables de Entorno (PATH)**: Es vital añadir la carpeta `bin` de flutter a tu `PATH`.
    *   *¿Por qué?* Para que puedas ejecutar el comando `flutter` desde cualquier terminal.
3.  **Flutter Doctor**: Ejecuta `flutter doctor` en tu terminal. Esta herramienta analizará tu sistema y te dirá qué te falta (Android SDK, licencias, etc.). **¡No avances hasta que todo esté en verde o azul!**

---

## 2. 💻 Configuración de los IDEs

Hemos trabajado con **Android Studio** y **Visual Studio Code**. Ambos son excelentes, pero requieren plugins:

### Visual Studio Code
*   Instala la extensión **"Flutter"** (que incluye automáticamente la de Dart).
*   *Tip*: Usa los atajos `Ctrl+Shift+P` para ejecutar comandos como `Flutter: New Project` o `Flutter: Run Flutter Doctor`.

### Android Studio
*   Instala los plugins de **Flutter** y **Dart** desde `Settings > Plugins`.
*   Configura el **Android SDK**: Asegúrate de tener instalada una versión reciente de las "Build-Tools".

---

## 3. 📚 Recursos Externos de Referencia

A lo largo de la piscina, hemos contado con recursos de gran valor. Uno de los más destacados es el repositorio público de **Pablo Vílchez**:

🔗 **[Flutter-42MLG en GitHub](https://github.com/pablovilchez/Flutter-42MLG)**

Este repositorio es una mina de oro para alumnos de los campus de 42, con explicaciones y soluciones muy útiles durante la configuración del entorno de trabajo.

---

## 4. 🔥 Configuración Maestra de Firebase (Paso a Paso)

Los módulos 04 y 05 requieren Firebase. Aquí es donde muchos desarrolladores se pierden, así que respira hondo y sigue estos pasos:

### Paso A: El Proyecto en la Consola
1.  Ve a [Firebase Console](https://console.firebase.google.com/).
2.  Crea un nuevo proyecto llamado `Diary App`.
3.  Habilita los servicios:
    *   **Authentication**: Activa el método de inicio de sesión "Google".
    *   **Firestore Database**: Crea la base de datos en modo "test" (para empezar).
    *   **Storage**: Activa el almacenamiento de archivos.

### Paso B: FlutterFire CLI (El camino fácil)
En lugar de configurar manualmente archivos JSON y Gradle, usamos la herramienta oficial:
1.  Instala Firebase CLI en tu ordenador.
2.  Ejecuta `dart pub global activate flutterfire_cli`.
3.  Dentro de la carpeta de tu proyecto (`diary_app`), ejecuta:
    ```bash
    flutterfire configure
    ```
4.  Esto generará automáticamente el archivo `firebase_options.dart` con todas las claves necesarias. **¡Es mágico!**

### Paso C: SHA-1 para Google Sign-In
Para que Google permita el inicio de sesión, debes registrar tu "huella digital":
1.  En la terminal, dentro de la carpeta `android`, ejecuta: `./gradlew signingReport`.
2.  Copia la clave **SHA-1** de la variante `debug`.
3.  Pégala en la configuración de tu app Android en la consola de Firebase.

---

## 5. 🧠 Optimización de RAM y Rendimiento

Durante el último módulo, descubrimos que los equipos pueden sufrir (lentitud o cuelgues) al compilar proyectos grandes de Flutter con Firebase.

**La Solución**: Ajustar la memoria asignada a la **JVM (Java Virtual Machine)** que usa Gradle.

En el archivo `android/gradle.properties` de cada proyecto, hemos aplicado estos ajustes:

```properties
# Aumentamos el montón de memoria (heap size) a 8GB y el Metaspace a 4GB
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
```

*   **¿Por qué?**: Flutter y Firebase requieren mucha potencia de procesamiento durante la compilación. Si limitamos la RAM, el sistema operativo empezará a usar el disco (swap), lo que ralentiza todo o provoca cierres inesperados. Recomendamos hacer esto desde el **Módulo 00** para una experiencia fluida.

---

## 6. 🏃 Cómo ejecutar estos proyectos

1.  Clona este repo.
2.  Navega a la carpeta del módulo (ej: `cd mobileModule02/medium_weather_app`).
3.  Ejecuta `flutter pub get` para descargar las librerías.
4.  Conecta tu móvil o abre un emulador.
5.  Ejecuta `flutter run`.

---
<p align="center">
  <a href="./README.md"><b>⬅️ Volver al README Principal</b></a> | <a href="./FLUTTER.md"><b>📘 Ver Guía Educativa</b></a><br>
  <b>¿Dudas? Consulta la documentación de</b> <a href="https://firebase.flutter.dev/"><b>FlutterFire</b></a>
</p>
