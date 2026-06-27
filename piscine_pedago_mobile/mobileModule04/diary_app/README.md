# 📓 Piscine Mobile — Module 04: Final Project - Diary App

> **Módulo final de la Piscine Mobile de 42 Málaga.**  
> En este proyecto culminante, llevamos nuestras aplicaciones Flutter a la nube. Implementamos un sistema completo de Diario Personal (Diary App) que utiliza la potencia de **Firebase** para gestionar la autenticación de usuarios, el almacenamiento de datos en tiempo real y la gestión de archivos multimedia (fotografías).

---
> 🔗 **[Ir al README General de la Piscine](../../README.md)** | **[📖 Guía de Aprendizaje](../../FLUTTER.md)** | **[⚙️ Configuración Firebase](../../CONFIG.md)**
---

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/NoSQL-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="Firestore" />
  <img src="https://img.shields.io/badge/42_Málaga-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 Málaga" />
</p>

---

## 📑 Índice

- [🗺️ Dónde estamos en el camino](#️-dónde-estamos-en-el-camino)
- [🎯 ¿Qué aprendemos en este módulo?](#-qué-aprendemos-en-este-módulo)
- [📋 Reglas Generales](#-reglas-generales)
- [🔥 El ecosistema Firebase](#-el-ecosistema-firebase)
- [🏗️ Estructura del Proyecto](#️-estructura-del-proyecto)
- [📦 Dependencias Cloud](#-dependencias-cloud)
- [🔑 Conceptos Finales Clave](#-conceptos-finales-clave)
- [✅ Guía de Evaluación (Peer-to-Peer)](#-guía-de-evaluación-peer-to-peer)
- [🛠️ Preparación del Entorno](#️-preparación-del-entorno)

---

## 🗺️ Dónde estamos en el camino

| Módulo | Nombre | Foco Principal |
|--------|--------|----------------|
| **00** | Fundamentals | Widgets básicos y estado simple |
| **01** | Navigation | AppBar, BottomBar y layouts |
| **02** | Medium App | HTTP, JSON y GPS |
| **03** | Advanced App | Visualización de Datos y Gráficos |
| **➡️ 04** | **Final Project** | **Integración Cloud con Firebase (Auth, Firestore, Storage)** |

---

## 🎯 ¿Qué aprendemos en este módulo?

El **Module 04** representa el salto a las aplicaciones conectadas y escalables. Al finalizarlo, habrás dominado:

1.  **Autenticación Social:** Implementación de *Google Sign-In* y gestión del estado de autenticación de Firebase.
2.  **Bases de Datos NoSQL (Firestore):** Persistencia de datos en la nube con `cloud_firestore`, permitiendo que el usuario acceda a sus notas desde cualquier dispositivo.
3.  **Almacenamiento en la Nube (Storage):** Gestión de carga y descarga de imágenes reales utilizando `firebase_storage`.
4.  **Programación Reactiva con Streams:** Uso de `StreamBuilder` para actualizar la interfaz de usuario automáticamente cuando los datos cambian en la base de datos (tiempo real).
5.  **Seguridad y Reglas Cloud:** Entender cómo proteger los datos de cada usuario para que solo ellos puedan acceder a sus propias entradas.

---

## 📋 Reglas Generales

Para aprobar el proyecto final, se aplican los criterios más estrictos:
- **Seguridad**: Solo los usuarios autenticados pueden usar la app.
- **Privacidad**: Un usuario NO debe poder ver ni editar las notas de otro usuario.
- **Estabilidad**: La app debe manejar correctamente la falta de internet y los errores de carga.
- **Limpieza de Recursos**: Si se borra una nota con foto, la foto también debe borrarse de Cloud Storage.

---

## 🔥 El ecosistema Firebase

En este proyecto utilizamos cuatro pilares de Firebase:
-   **Firebase Auth**: Maneja el login seguro con **Google** y **GitHub**.
-   **Cloud Firestore**: Guarda el título, contenido, fecha y estado de ánimo del diario.
-   **Firebase Storage**: Almacena las fotos que el usuario adjunta a sus vivencias.
-   **Google Services**: Configuración nativa necesaria para que Android se comunique con el servidor.

---

## 🏗️ Estructura del Proyecto

```
diary_app/
│
├── lib/
│   ├── main.dart                ← Punto de entrada e inicialización de Firebase
│   ├── login_page.dart          ← Interfaz de acceso con Google Sign-In
│   ├── profile_page.dart        ← Listado principal del diario (StreamBuilder)
│   ├── entry_editor_page.dart   ← Creación y edición de notas (Upload logic)
│   └── details_page.dart        ← Visualización detallada de una entrada
│
├── android/app/
│   └── google-services.json     ← Archivo de configuración crítico de Firebase
└── pubspec.yaml                 ← Declaración de dependencias de FlutterFire
```

---

## 📦 Dependencias Cloud

Este módulo se apoya fuertemente en el ecosistema **FlutterFire**:

```yaml
dependencies:
  firebase_core: ^3.10.1      # Inicialización de Firebase
  firebase_auth: ^5.4.1       # Autenticación con Google
  google_sign_in: ^6.2.2      # Google Sign-In para autenticar con Google
  cloud_firestore: ^5.6.2     # Persistencia de datos en la nube
  firebase_storage: ^12.4.10  # Almacenamiento en la nube de imágenes
  image_picker: ^1.1.2        # Para seleccionar fotos de la galería o cámara
  intl: ^0.19.0                # Formateo de fechas para el diario
```

---

## 🔑 Conceptos Finales Clave

### 1. El AuthWrapper
Un patrón de diseño que envuelve la aplicación y, basándose en un Stream de `authStateChanges`, decide instantáneamente si mostrar la pantalla de Login o la pantalla de Inicio del usuario.

### 2. Índices Compuestos en Firestore
Como aprendimos durante el desarrollo, consultas complejas que combinan `where` (filtrar por usuario) y `orderBy` (ordenar por fecha) requieren que generemos índices específicos en la consola de Firebase para que el rendimiento sea óptimo.

### 3. Gestión de Imágenes
El flujo de trabajo profesional consiste en: capturar la imagen con `image_picker` -> subirla a `firebase_storage` -> obtener el link público -> guardar ese link en el documento de `cloud_firestore`.

---

## ✅ Guía de Evaluación (Peer-to-Peer)

### 1. Autenticación
- [ ] ¿Se puede iniciar sesión correctamente con una cuenta de Google?
- [ ] ¿Se puede iniciar sesión correctamente con una cuenta de GitHub?
- [ ] ¿Aparece el nombre y foto del usuario en el Drawer (menú lateral)?
- [ ] ¿Funciona correctamente el botón de Logout?

### 2. CRUD (Create, Read, Update, Delete)
- [ ] ¿Se pueden crear nuevas entradas con título, contenido y sentimiento?
- [ ] ¿Se pueden editar entradas existentes y que los cambios se reflejen en la nube?
- [ ] ¿Al borrar una entrada, desaparece inmediatamente de la lista?

### 3. Multimedia e Imágenes
- [ ] ¿Se pueden subir fotos desde la cámara o la galería?
- [ ] ¿Las fotos se visualizan correctamente en la lista y en el detalle?
- [ ] ¿Se borran las imágenes de Storage cuando se elimina la nota (Clean Up)?

### 4. Tiempo Real
- [ ] ¿Si añades una nota, aparece en la lista automáticamente sin tener que reiniciar la app? (Uso de `StreamBuilder`).

---

## 🛠️ Preparación del Entorno

### Configuración de GitHub Authentication
Para que el botón de GitHub funcione, debes seguir estos pasos:
1.  **Firebase Console**: Ve a *Authentication -> Sign-in method* y habilita **GitHub**.
2.  **GitHub Settings**: Ve a *Developer settings -> OAuth Apps* y crea una nueva App.
3.  **Callback URL**: Copia la URL que te da Firebase (ej: `https://tu-proyecto.firebaseapp.com/__/auth/handler`) y pégala en GitHub.
4.  **Client ID/Secret**: Copia las credenciales de GitHub y pégalas en la configuración de Firebase.

### Ejecución
```bash
# 1. Asegúrate de tener el archivo google-services.json en android/app/
# 2. Instalar las dependencias de Firebase
flutter pub get

# 3. Iniciar la aplicación
flutter run
```

---

## ✍️ Autor

**[sternero](https://github.com/STC71)** — junio 2026

---

<p align="center">
  <b>Piscine Mobile 42 Málaga</b><br>
  <i>"El fin del camino: Dominando la nube con Flutter y Firebase"</i>
</p>
