# 🌦️ Advanced Weather App - Módulo 03

Esta aplicación es el proyecto final de la **Piscine Mobile (Módulo 03)**. Es una herramienta de pronóstico meteorológico avanzada que combina geolocalización, búsqueda global y visualizaciones de datos profesionales mediante gráficos.

## 🚀 Funcionalidades Principales

-   **Geolocalización en Tiempo Real**: Detecta automáticamente tu ubicación actual para ofrecerte el clima local mediante el paquete `geolocator`.
-   **Búsqueda Global con Sugerencias**: Sistema de autocompletado en tiempo real que permite buscar cualquier ubicación del mundo.
-   **Visualización de Datos Avanzada (Gráficos)**:
    -   **Hoy (Today)**: Gráfico de evolución térmica horaria para las próximas 24 horas con sombreado degradado.
    -   **Semanal (Weekly)**: Gráfico de doble línea (Máximas en naranja, Mínimas en azul) para los próximos 7 días, con etiquetas de fecha en formato `dd/MM`.
-   **Diseño Adaptativo Profesional**:
    -   **Modo Vertical (Portrait)**: Navegación por pestañas superiores.
    -   **Modo Horizontal (Landscape)**: Interfaz con `NavigationRail` centrado para una ergonomía superior en pantallas anchas.
-   **Detalles Técnicos**: Integración de velocidad del viento en pronósticos horarios y mapeo completo de códigos meteorológicos WMO.

## 🛠️ Stack Tecnológico

-   **Framework**: [Flutter](https://flutter.dev) (Dart).
-   **Gráficos**: [fl_chart](https://pub.dev/packages/fl_chart) para visualizaciones vectoriales fluidas.
-   **Ubicación**: [geolocator](https://pub.dev/packages/geolocator).
-   **Red**: [http](https://pub.dev/packages/http) para consumo de APIs REST.
-   **APIs Utilizadas**:
    -   [Open-Meteo](https://open-meteo.com/): Datos climáticos (sin necesidad de API Key) y Geocoding.
    -   [BigDataCloud](https://www.bigdatacloud.com/): Reverse Geocoding para identificar la ciudad por coordenadas.

## 📱 Visualización (Screenshots)

Aquí puedes ver la interfaz de la aplicación en sus diferentes estados y orientaciones:

### Interfaz Principal (Modo Retrato)
| Actualmente | Hoy (Detalles) | Semanal (Pronóstico) |
| :---: | :---: | :---: |
| ![Actualmente](screenshots/advanced_weather_app_00.png) | ![Hoy](screenshots/advanced_weather_app_01.png) | ![Semanal](screenshots/advanced_weather_app_02.png) |

### Gráficos y Búsqueda
| Evolución Térmica (Hoy) | Gráfico de Máx/Mín | Búsqueda de Ubicación |
| :---: | :---: | :---: |
| ![Gráfico Hoy](screenshots/advanced_weather_app_03.png) | ![Gráfico Semanal](screenshots/advanced_weather_app_04.png) | ![Búsqueda](screenshots/advanced_weather_app_05.png) |

### Diseño Adaptativo (Modo Horizontal)
| Home Landscape | Gráficos en Landscape | Detalle Semanal |
| :---: | :---: | :---: |
| ![Landscape 1](screenshots/advanced_weather_app_06.png) | ![Landscape 2](screenshots/advanced_weather_app_07.png) | ![Landscape 3](screenshots/advanced_weather_app_08.png) |

## 📁 Estructura del Proyecto

-   `lib/models/`: Modelos de datos (`WeatherData`) y lógica de interpretación de códigos WMO (iconos y descripciones).
-   `lib/services/`: Lógica de red (`WeatherService`) y gestión de hardware/GPS (`LocationService`).
-   `lib/widgets/`: Componentes de UI especializados, destacando `weather_chart.dart` para toda la lógica de dibujo de gráficas.
-   `lib/screens/`: `weather_home.dart` actúa como el orquestador principal de estados, navegación y layouts adaptativos.

## ⚙️ Instalación

1.  Asegúrate de tener Flutter instalado (`flutter doctor`).
2.  Clona el repositorio.
3.  Ejecuta `flutter pub get`.
4.  Lanza la app con `flutter run`.

---
*Este proyecto ha sido desarrollado siguiendo estrictamente las especificaciones del subject de la Piscine Mobile, asegurando un código limpio, comentado y totalmente funcional.*
