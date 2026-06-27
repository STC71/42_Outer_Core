# ⛈️ Piscine Mobile — Module 02: Medium Weather App

> **Tercer módulo de la Piscine Mobile de 42 Málaga.**  
> En este módulo damos el salto más importante hasta ahora: conectar nuestra aplicación con el mundo real. Dejamos atrás las interfaces estáticas para construir una app que habla con servidores de internet, procesa datos en tiempo real y usa el hardware del dispositivo (el GPS). Esto es lo que separa una "maqueta" de una aplicación de verdad.

---
> 🔗 **[Ir al README General de la Piscine](../README.md)** | **[📖 Guía de Aprendizaje](../FLUTTER.md)**
---

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Open--Meteo_API-FFA000?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Open-Meteo" />
  <img src="https://img.shields.io/badge/Geolocator_(GPS)-4CAF50?style=for-the-badge&logo=googlemaps&logoColor=white" alt="GPS" />
  <img src="https://img.shields.io/badge/HTTP_Client-FF6B6B?style=for-the-badge&logo=curl&logoColor=white" alt="HTTP" />
  <img src="https://img.shields.io/badge/42_Málaga-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 Málaga" />
</p>

---

## 📑 Índice

- [🗺️ Dónde estamos en el camino](#️-dónde-estamos-en-el-camino)
- [🎯 ¿Qué aprendemos en este módulo?](#-qué-aprendemos-en-este-módulo)
- [📋 Reglas Generales](#-reglas-generales)
- [🏗️ Arquitectura del Proyecto — La Gran Novedad](#️-arquitectura-del-proyecto--la-gran-novedad)
- [📦 Dependencias Externas — Las Herramientas Nuevas](#-dependencias-externas--las-herramientas-nuevas)
- [🛣️ Hoja de Ruta Detallada — Cada Pieza del Puzzle](#️-hoja-de-ruta-detallada--cada-pieza-del-puzzle)
  - [🌐 Conceptos previos: ¿Qué es una API?](#-conceptos-previos-qué-es-una-api)
  - [🌐 Conceptos previos: ¿Qué es JSON?](#-conceptos-previos-qué-es-json)
  - [📁 `main.dart` — El punto de arranque](#-maindart--el-punto-de-arranque)
  - [🗂️ `models/weather_data.dart` — Los Traductores de Datos](#️-modelsweather_datadart--los-traductores-de-datos)
  - [📡 `services/weather_service.dart` — El Cartero de Internet](#-servicesweather_servicedart--el-cartero-de-internet)
  - [📍 `services/location_service.dart` — El Experto en GPS](#-serviceslocation_servicedart--el-experto-en-gps)
  - [🖥️ `screens/weather_home.dart` — El Director de Orquesta](#️-screensweather_homedart--el-director-de-orquesta)
  - [🔵 `widgets/currently_view.dart` — Vista "Ahora Mismo"](#-widgetscurrently_viewdart--vista-ahora-mismo)
  - [📅 `widgets/today_view.dart` — Vista "Pronóstico de Hoy"](#-widgetstoday_viewdart--vista-pronóstico-de-hoy)
  - [🗓️ `widgets/weekly_view.dart` — Vista "Semana Completa"](#️-widgetsweekly_viewdart--vista-semana-completa)
- [🔑 Conceptos Clave Aprendidos en Profundidad](#-conceptos-clave-aprendidos-en-profundidad)
  - [1. Programación Asíncrona: `async`, `await` y `Future`](#1-programación-asíncrona-async-await-y-future)
  - [2. Peticiones HTTP con el paquete `http`](#2-peticiones-http-con-el-paquete-http)
  - [3. Parseo de JSON: De texto a objetos Dart](#3-parseo-de-json-de-texto-a-objetos-dart)
  - [4. El patrón `factory constructor` y los Modelos de Datos](#4-el-patrón-factory-constructor-y-los-modelos-de-datos)
  - [5. Geolocalización con `geolocator`](#5-geolocalización-con-geolocator)
  - [6. Gestión de Permisos del Sistema Operativo](#6-gestión-de-permisos-del-sistema-operativo)
  - [7. Estado de Carga y Manejo de Errores](#7-estado-de-carga-y-manejo-de-errores)
  - [8. El widget `Stack`: Capas superpuestas](#8-el-widget-stack-capas-superpuestas)
  - [9. `TextEditingController` y Búsqueda en Tiempo Real](#9-textEditingController-y-búsqueda-en-tiempo-real)
  - [10. `ListView.builder`: Listas Eficientes](#10-listviewbuilder-listas-eficientes)
  - [11. Formateo de Fechas con el paquete `intl`](#11-formateo-de-fechas-con-el-paquete-intl)
  - [12. Arquitectura por Capas (Separación de Responsabilidades)](#12-arquitectura-por-capas-separación-de-responsabilidades)
- [✅ Guía de Evaluación Exhaustiva (Peer-to-Peer)](#-guía-de-evaluación-exhaustiva-peer-to-peer)
- [🛠️ Preparación del Entorno — Paso a Paso](#️-preparación-del-entorno--paso-a-paso)
- [✍️ Autor](#️-autor)

---

## 🗺️ Dónde estamos en el camino

Para entender el valor de este módulo, es útil ver el recorrido completo de la Piscine:

| Módulo | Nombre | Qué se aprendió |
|--------|--------|-----------------|
| **00** | Flutter Fundamentals | Widgets, Estado básico (`setState`), Layouts, Calculadora |
| **01** | Navigation & UI | `BottomNavigationBar`, `AppBar`, `TextField`, estructura multi-pantalla |
| **➡️ 02** | **Medium Weather App** | **HTTP, APIs REST, JSON, GPS, Arquitectura por capas** |
| 03 | Advanced Topics | *(Próximos módulos...)* |

**Este módulo es el punto de inflexión.** Es donde una app de Flutter deja de ser un juguete y se convierte en una herramienta útil que interactúa con el mundo exterior.

---

## 🎯 ¿Qué aprendemos en este módulo?

El **Module 02** se enfoca en dos grandes pilares: **la comunicación con internet** y **el uso del hardware del dispositivo**. Al completarlo, habrás dominado:

1. **Peticiones HTTP**: Cómo hacer que tu app "salga" a internet para pedir datos a servidores externos usando la librería `http`.
2. **Procesamiento de JSON**: Cómo convertir la respuesta cruda de internet (un texto gigante y confuso) en objetos de Dart que podamos usar cómodamente en nuestra interfaz.
3. **Modelos de Datos**: Cómo diseñar clases de Dart que sirvan como "plantillas" o "fichas" para organizar los datos que recibimos.
4. **Geolocalización**: Cómo usar el paquete `geolocator` para acceder al GPS del dispositivo y obtener las coordenadas (latitud y longitud) del usuario.
5. **Gestión de Permisos**: Cómo pedir permiso al sistema operativo (Android/iOS) para acceder al GPS, y cómo manejar el caso en que el usuario diga que no.
6. **Programación Asíncrona**: Cómo usar `async` y `await` para que la app no se "congele" mientras espera respuestas de internet o del GPS.
7. **Gestión de Estados de Carga y Error**: Cómo mostrar un indicador de carga mientras esperamos datos, y un mensaje de error si algo falla, en lugar de que la app simplemente se rompa.
8. **Arquitectura por Capas**: Cómo organizar el código en carpetas con responsabilidades claras (Modelos, Servicios, Widgets, Pantallas) para que el proyecto sea fácil de mantener y ampliar.
9. **Búsqueda con Autocompletado**: Cómo hacer un buscador que sugiere ciudades en tiempo real mientras el usuario escribe.

---

## 📋 Reglas Generales

Para que el proyecto sea válido y supere la evaluación peer-to-peer, debe cumplir:

- **Sin Errores de Compilación**: La app debe arrancar limpiamente con `flutter run`. Cero errores.
- **Sin Desbordamientos de Layout** (las rayas amarillas y negras de Flutter): La interfaz debe ser completamente responsiva.
- **Manejo de Errores Obligatorio**: Si no hay conexión a internet o el GPS está apagado, la app **debe** mostrar un mensaje de error amigable. Nunca debe cerrarse de golpe (lo que se llama un "crash").
- **Indicador de Carga**: Siempre que se esté esperando datos de internet o del GPS, debe aparecer un `CircularProgressIndicator` (la ruedita giratoria) para que el usuario sepa que la app está trabajando.
- **Estructura de Código Limpia**: El código debe estar organizado en las capas descritas (modelos, servicios, widgets, screens). No todo en un único archivo `main.dart`.
- **Versión de Flutter**: Se usa una versión estable y reciente (SDK `^3.12.1`).

---

## 🏗️ Arquitectura del Proyecto — La Gran Novedad

### La Estructura de Carpetas

```
medium_weather_app/
│
├── lib/
│   ├── main.dart                    ← El punto de arranque de la app
│   │
│   ├── models/
│   │   └── weather_data.dart        ← Las "fichas" de datos (WeatherData, CurrentWeather, etc.)
│   │
│   ├── services/
│   │   ├── weather_service.dart     ← El módulo que habla con internet (API del clima)
│   │   └── location_service.dart    ← El módulo que habla con el GPS
│   │
│   ├── screens/
│   │   └── weather_home.dart        ← La pantalla principal que lo orquesta todo
│   │
│   └── widgets/
│       ├── currently_view.dart      ← Vista "Tiempo actual"
│       ├── today_view.dart          ← Vista "Pronóstico por horas de hoy"
│       └── weekly_view.dart         ← Vista "Pronóstico semanal"
│
└── pubspec.yaml                     ← La lista de "ingredientes" (dependencias) del proyecto
```

### ¿Por qué esta estructura y no todo en un archivo?

En los módulos anteriores, teníamos todo el código en pocos archivos. Eso funciona para proyectos pequeños, pero se vuelve un caos a medida que crece. La arquitectura por capas de este módulo sigue el principio de **Separación de Responsabilidades** (SoC, *Separation of Concerns*):

- **`models/`**: Solo describe los datos. No sabe nada de interfaces ni de internet.
- **`services/`**: Solo sabe comunicarse con el exterior (APIs, GPS). No sabe nada de cómo se pinta la pantalla.
- **`screens/`**: Solo coordina y orquesta. Usa los servicios y pasa los datos a los widgets.
- **`widgets/`**: Solo sabe pintar. Recibe datos ya procesados y los muestra bonitos.

Imagina construir una pizzería: el **cocinero** (servicios) hace las pizzas, el **mozo** (screen) las lleva a la mesa, y el **cliente** (widget) las consume. Ninguno hace el trabajo de los otros. Si hay un problema con la entrega, no tienes que revisar la cocina.

---

## 📦 Dependencias Externas — Las Herramientas Nuevas

En el archivo `pubspec.yaml` se declaran las librerías que este proyecto necesita. Es como la lista de la compra del proyecto:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  geolocator: ^13.0.1   # Para GPS y permisos de ubicación
  http: ^1.2.2          # Para hacer llamadas HTTP a la API del clima
  intl: ^0.19.0         # Para formatear fechas y horas según la localización
```

### ¿Para qué sirve cada una?

| Paquete | Versión | Para qué se usa |
|---------|---------|-----------------|
| `http` | ^1.2.2 | Enviar peticiones a servidores de internet (como un mensajero que lleva y trae cartas). Es la herramienta fundamental para comunicarse con APIs. |
| `geolocator` | ^13.0.1 | Acceder al GPS del dispositivo para obtener las coordenadas (latitud y longitud) actuales del usuario, y gestionar los permisos necesarios. |
| `intl` | ^0.19.0 | Formatear fechas y horas de forma legible y adaptada a distintos idiomas. Por ejemplo, convertir un objeto `DateTime` en el texto `"Lunes, 14:00"`. |

> **¿Cómo se instalan?** Simplemente ejecutando `flutter pub get` en la terminal dentro de la carpeta del proyecto. Flutter descarga e instala todo automáticamente.

---

## 🛣️ Hoja de Ruta Detallada — Cada Pieza del Puzzle

Antes de analizar el código, es crucial entender dos conceptos fundamentales de internet que la app usa constantemente.

---

### 🌐 Conceptos previos: ¿Qué es una API?

Una **API** (*Application Programming Interface*, o Interfaz de Programación de Aplicaciones) es como un **camarero en un restaurante**.

- Tú (la app) eres el cliente sentado en la mesa.
- La cocina (el servidor de datos del clima) tiene toda la información.
- Tú **no puedes entrar a la cocina** directamente. Necesitas al camarero.
- Le dices al camarero: "Quiero el tiempo de Málaga".
- El camarero va a la cocina, pide lo que necesitas, y te lo trae.

En este proyecto usamos la **API de Open-Meteo** (`api.open-meteo.com`). Es gratuita y no requiere registrarse ni obtener ninguna llave secreta (API key), lo que la hace perfecta para aprender. Le enviamos una "carta" (una URL con parámetros) y ella nos responde con los datos del clima en formato JSON.

**Ejemplo de URL que enviamos:**
```
https://api.open-meteo.com/v1/forecast?latitude=36.7&longitude=-4.42&current=temperature_2m,weather_code
```
→ Le estamos preguntando: "¿Qué temperatura y código de tiempo hay ahora mismo en las coordenadas 36.7°N, 4.42°W (Málaga)?"

---

### 🌐 Conceptos previos: ¿Qué es JSON?

**JSON** (*JavaScript Object Notation*) es el formato estándar en que los servidores nos devuelven los datos. Es texto plano estructurado de una manera que tanto humanos como ordenadores pueden leer.

La respuesta que nos daría la API del clima para Málaga se parecería a esto:

```json
{
  "current": {
    "temperature_2m": 28.5,
    "weather_code": 0,
    "wind_speed_10m": 12.3
  },
  "hourly": {
    "time": ["2024-06-10T00:00", "2024-06-10T01:00", ...],
    "temperature_2m": [22.1, 21.8, ...],
    "weather_code": [0, 0, ...],
    "wind_speed_10m": [8.1, 7.5, ...]
  },
  "daily": {
    "time": ["2024-06-10", "2024-06-11", ...],
    "temperature_2m_max": [31.0, 29.5, ...],
    "temperature_2m_min": [18.2, 17.0, ...],
    "weather_code": [0, 2, ...]
  }
}
```

Es como un árbol con ramas y hojas. Nuestro trabajo en el código es "navegar" por ese árbol para extraer solo la información que necesitamos y transformarla en objetos de Dart que nuestra UI pueda mostrar fácilmente.

---

### 📁 `main.dart` — El punto de arranque

```dart
import 'package:flutter/material.dart';
import 'screens/weather_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medium Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      home: const WeatherHomeScreen(),
    );
  }
}
```

**¿Qué hace este archivo?**

Poquísimo, y eso es justo lo que debe hacer. Su única responsabilidad es:
1. Configurar el tema visual oscuro de la app (el color de fondo `0xFF0A0E21` es un azul marino muy oscuro).
2. Designar `WeatherHomeScreen` como la pantalla inicial.
3. Importar esa pantalla desde `screens/weather_home.dart`.

El hecho de que `main.dart` sea tan pequeño es una señal de buena arquitectura: el punto de entrada no debería contener lógica de negocio.

**`debugShowCheckedModeBanner: false`**: Oculta la pequeña etiqueta roja de "DEBUG" que Flutter muestra en la esquina durante el desarrollo. Un detalle estético que da un aspecto más profesional.

---

### 🗂️ `models/weather_data.dart` — Los Traductores de Datos

Este es uno de los archivos más importantes conceptualmente. Define las **clases de modelo**, que son las "fichas" o "plantillas" que usamos para organizar los datos del clima.

#### Las clases de modelo

```dart
// La "ficha" para el tiempo ACTUAL
class CurrentWeather {
  final double temperature;   // Temperatura en grados Celsius
  final double windSpeed;     // Velocidad del viento en km/h
  final int weatherCode;      // Código numérico que describe el estado del cielo

  CurrentWeather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
  });
}

// La "ficha" para UNA HORA concreta
class HourlyWeather {
  final DateTime time;         // La hora exacta (ej: las 14:00)
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  // ...constructor igual
}

// La "ficha" para UN DÍA concreto
class DailyWeather {
  final DateTime date;         // La fecha (ej: lunes 10 de junio)
  final double maxTemp;        // Temperatura máxima del día
  final double minTemp;        // Temperatura mínima del día
  final int weatherCode;
  // ...constructor igual
}
```

**¿Por qué `final`?** Porque los datos del clima que recibimos no deben modificarse una vez creados. Los declaramos como "inmutables" para evitar bugs accidentales.

#### La clase contenedora `WeatherData`

```dart
class WeatherData {
  final CurrentWeather current;      // El tiempo ahora
  final List<HourlyWeather> hourly;  // Lista de las próximas horas
  final List<DailyWeather> daily;    // Lista de los próximos días
  // ...
}
```

`WeatherData` es el "paquete completo" que agrupa toda la información recibida de la API en un solo objeto fácil de pasar entre pantallas y widgets.

#### El `factory constructor` — El Gran Traductor

```dart
factory WeatherData.fromJson(Map<String, dynamic> json) {
  final currentJson = json['current'];
  final hourlyJson  = json['hourly'];
  final dailyJson   = json['daily'];

  final List<HourlyWeather> hourlyList = [];
  for (int i = 0; i < (hourlyJson['time'] as List).length; i++) {
    hourlyList.add(HourlyWeather(
      time:        DateTime.parse(hourlyJson['time'][i]),
      temperature: hourlyJson['temperature_2m'][i].toDouble(),
      weatherCode: hourlyJson['weather_code'][i],
      windSpeed:   hourlyJson['wind_speed_10m'][i].toDouble(),
    ));
  }
  // ... lo mismo para los días
  
  return WeatherData(
    current: CurrentWeather(
      temperature: currentJson['temperature_2m'].toDouble(),
      windSpeed:   currentJson['wind_speed_10m'].toDouble(),
      weatherCode: currentJson['weather_code'],
    ),
    hourly: hourlyList,
    daily:  dailyList,
  );
}
```

**¿Qué es un `factory constructor`?** Es un constructor especial en Dart que puede contener lógica antes de crear el objeto. En lugar de simplemente asignar valores, puede procesar datos, tomar decisiones, o —como aquí— recorrer arrays para construir listas.

La notación `WeatherData.fromJson(json)` es un patrón estándar en Flutter: "Crea un `WeatherData` a partir de un mapa JSON". Es como un obrero especializado cuya única tarea es desempaquetar una caja de datos confusa y distribuir cada pieza en el lugar correcto.

**`DateTime.parse('2024-06-10T14:00')`**: Convierte el texto de la API (un `String`) en un objeto `DateTime` real de Dart, con el que luego podemos hacer operaciones como "¿esta hora ya ha pasado?" o formatearla con `intl`.

#### Los diccionarios de traducción

```dart
static String getWeatherDescription(int code) {
  if (code == 0) return "Cielo despejado";
  if (code <= 3) return "Algunas nubes";
  if (code <= 48) return "Niebla o neblina";
  if (code <= 67) return "Lluvia";
  if (code <= 86) return "Nieve";
  return "Tormenta eléctrica";
}

static IconData getWeatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code <= 3) return Icons.wb_cloudy_outlined;
  if (code <= 48) return Icons.wb_cloudy;
  if (code <= 67) return Icons.umbrella;
  if (code <= 86) return Icons.ac_unit;
  return Icons.thunderstorm;
}
```

Las APIs meteorológicas no dicen "está lloviendo". Dicen `67`. Estas funciones `static` (sin necesidad de crear un objeto `WeatherData` para usarlas) son diccionarios que traducen esos números a texto legible e iconos visuales. El estándar WMO (Organización Meteorológica Mundial) define cada código: 0 = despejado, 1-3 = nubes, 45-48 = niebla, etc.

---

### 📡 `services/weather_service.dart` — El Cartero de Internet

Este servicio es el responsable de **toda la comunicación con la API externa**. Ningún otro archivo de la app hace peticiones HTTP directamente; todo pasa por aquí.

#### Las "direcciones" de la API

```dart
static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';
static const String _weatherUrl   = 'https://api.open-meteo.com/v1/forecast';
```

Open-Meteo nos ofrece dos servicios diferenciados:
- **Geocoding**: Convierte nombres de ciudades en coordenadas (y viceversa). "Málaga" → `{lat: 36.7, lon: -4.42}`.
- **Forecast (pronóstico)**: Dadas unas coordenadas, devuelve el tiempo meteorológico.
- **BigDataCloud**: Se utiliza para la geocodificación inversa (obtener el nombre del lugar a partir de coordenadas GPS) ya que es gratuita y no requiere API Key.

#### Búsqueda de ciudades con autocompletado

```dart
Future<List<dynamic>> getSuggestions(String query) async {
  if (query.length < 3) return [];
  
  try {
    final url = Uri.parse('$_geocodingUrl?name=$query&count=5&language=en');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'] ?? [];
    }
  } catch (e) {
    print("Error en sugerencias: $e");
  }
  return [];
}
```

**Análisis línea por línea:**

- `if (query.length < 3) return []` → Optimización inteligente: no molestamos al servidor si el usuario solo ha escrito una o dos letras.
- `Uri.parse(...)` → Construye la URL completa de la petición. `?name=$query&count=5&language=en` son los parámetros: busca por nombre, devuelve máximo 5 resultados, en inglés (para consistencia con el sujeto).
- `await http.get(url)` → **La magia asíncrona**: envía la petición HTTP y *espera* la respuesta sin congelar la app. `await` solo puede usarse dentro de funciones marcadas con `async`.
- `response.statusCode == 200` → El código HTTP 200 significa "éxito". Si fuera 404 sería "no encontrado", 500 sería "error del servidor", etc.
- `json.decode(response.body)` → La respuesta llega como texto plano (`response.body` es un `String`). `json.decode` lo convierte en un `Map<String, dynamic>` de Dart, que podemos manipular con código.
- `data['results'] ?? []` → El operador `??` es "si es null, usa esto en su lugar". Si la API no devuelve resultados, usamos una lista vacía en lugar de crashear.

#### Petición del clima real

```dart
Future<WeatherData?> fetchWeather(double lat, double lon) async {
  try {
    final url = Uri.parse(
      '$_weatherUrl?'
      'latitude=$lat&longitude=$lon'
      '&current=temperature_2m,weather_code,wind_speed_10m'
      '&hourly=temperature_2m,weather_code,wind_speed_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto'
    );
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    }
  } catch (e) {
    print("Error al pedir el clima: $e");
  }
  return null;
}
```

Aquí pedimos tres tipos de datos a la vez en una única petición:
- `current=...` → Datos instantáneos del momento actual.
- `hourly=...` → Datos para cada hora (devuelve 168 horas = 7 días completos por defecto).
- `daily=...` → Resumen por día (máximas y mínimas).
- `&timezone=auto` → Ajusta automáticamente los tiempos a la zona horaria del lugar pedido.

El tipo de retorno `WeatherData?` (con interrogante) significa que puede devolver `null`. Si algo falla (sin internet, servidor caído), devolvemos `null` y la pantalla se encarga de mostrar un error.

#### Geocodificación inversa (coordenadas → nombre de ciudad)

```dart
Future<String?> getCityName(double lat, double lon) async {
  final url = Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en');
  // ...
  return "$city, $region, $country";
}
```

Cuando el usuario usa el GPS, obtenemos coordenadas pero no un nombre. Esta función las convierte en algo legible como "Málaga, Andalusia, Spain" usando la API de BigDataCloud, ya que Open-Meteo no ofrece geocodificación inversa gratuita.

---

### 📍 `services/location_service.dart` — El Experto en GPS

Este servicio encapsula toda la lógica de geolocalización, que requiere varios pasos y puede fallar en distintos puntos.

```dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  
  Future<Position?> getCurrentLocation() async {
    
    // PASO 1: ¿Está el GPS del móvil encendido?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Los servicios de ubicación están desactivados en tu móvil.';
    }

    // PASO 2: ¿Ha dado el usuario permiso a esta app?
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Si no tiene permiso, lo pedimos en tiempo real (aparece un diálogo del sistema)
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permiso de ubicación denegado por el usuario.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Permiso de ubicación bloqueado permanentemente en ajustes.';
    }

    // PASO 3: Todo ok, pedimos la posición
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }
}
```

**La cadena de seguridad del GPS** tiene tres eslabones:

1. **¿Está el GPS encendido?** El dispositivo puede tener el GPS desactivado en los ajustes globales. Verificamos esto primero.
2. **¿Tenemos permiso de esta app?** Incluso con el GPS encendido, cada app necesita permiso explícito del usuario. Si no lo tiene, lo solicita con `requestPermission()`, que muestra automáticamente el diálogo del sistema operativo ("¿Permitir que Medium Weather acceda a tu ubicación?").
3. **¿Está bloqueado para siempre?** Si el usuario anteriormente dijo "Bloquear siempre", no podemos ni pedirlo. Solo podemos lanzar un error y decirle al usuario que vaya a los ajustes manualmente.

**`throw 'mensaje'`**: Lanza una excepción (un error intencionado) que será capturada por el `try/catch` en la pantalla principal. Esto permite que el servicio informe del problema sin tener que saber cómo mostrarlo en pantalla.

**`LocationAccuracy.medium`**: Precisión media. Es suficiente para saber en qué ciudad estamos (unos pocos cientos de metros de precisión) sin consumir tanta batería como la precisión máxima.

---

### 🖥️ `screens/weather_home.dart` — El Director de Orquesta

Esta es la pantalla principal y el cerebro de la aplicación. Coordina todos los servicios y decide qué mostrar y cuándo.

#### El estado de la pantalla

```dart
class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  int _currentIndex = 0;           // ¿Qué pestaña está activa? (0=Ahora, 1=Hoy, 2=Semana)
  bool _isLoading = false;         // ¿Estamos esperando datos? (para mostrar la ruedita)
  String _errorMessage = "";       // Mensaje de error, si lo hay
  String _locationName = "Unknown Location"; // Nombre visible de la ubicación
  WeatherData? _weatherData;       // Todos los datos del clima (null si no han llegado aún)

  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  
  List<dynamic> _suggestions = []; // Ciudades sugeridas mientras se escribe en el buscador
  final TextEditingController _searchController = TextEditingController();
}
```

Estas variables son **el estado completo de la aplicación**. Cada vez que alguna cambia (con `setState()`), Flutter vuelve a dibujar la pantalla para reflejar el nuevo estado.

#### `initState()` — Lo que ocurre al arrancar

```dart
@override
void initState() {
  super.initState();
  _searchController.addListener(() => setState(() {}));
  _getCurrentLocation();
}
```

`initState` es un método especial que se ejecuta exactamente una vez: cuando el widget se crea por primera vez. Aquí hacemos dos cosas:
1. Añadimos un "oyente" al controlador del buscador. Cada vez que el texto cambie, llamamos a `setState()` para redibujar la AppBar (por ejemplo, para mostrar/ocultar el botón de borrar `×`).
2. Intentamos obtener la ubicación GPS del usuario inmediatamente al abrir la app.

#### La función de GPS

```dart
Future<void> _getCurrentLocation() async {
  setState(() {
    _isLoading = true;   // Activamos la ruedita giratoria
    _errorMessage = "";  // Limpiamos errores anteriores
  });
  try {
    Position? position = await _locationService.getCurrentLocation();
    if (position != null) {
      await _updateWeather(position.latitude, position.longitude);
      String? name = await _weatherService.getCityName(position.latitude, position.longitude);
      if (name != null) setState(() => _locationName = name);
    }
  } catch (e) {
    // Si el LocationService lanzó una excepción (ej: permiso denegado), la capturamos aquí
    setState(() => _errorMessage = "Geolocation is not available");
  } finally {
    // El bloque 'finally' SIEMPRE se ejecuta, haya error o no
    setState(() => _isLoading = false); // Paramos la ruedita
  }
}
```

El patrón `try / catch / finally` es fundamental en operaciones asíncronas:
- **`try`**: Intenta ejecutar el código. Si algo falla, salta al `catch`.
- **`catch(e)`**: Maneja el error. `e` contiene la descripción del error.
- **`finally`**: Se ejecuta siempre, tanto si hubo éxito como si hubo error. Perfecto para "limpiar" estados (aquí, apagar el indicador de carga).

#### La lógica del buscador con autocompletado

```dart
void _onSearchChanged(String query) async {
  if (query.isEmpty) {
    setState(() => _suggestions = []);
    return;
  }
  final suggestions = await _weatherService.getSuggestions(query);
  setState(() {
    _suggestions = suggestions;
    if (query.length >= 3 && suggestions.isEmpty) {
      _errorMessage = "No results found";
    } else {
      _errorMessage = "";
    }
  });
}
```

Esta función se llama cada vez que el usuario escribe o borra una letra en el buscador. Pide sugerencias al servicio meteorológico y actualiza la lista desplegable en tiempo real. Es el mismo mecanismo que usan apps como Google Maps cuando te sugieren destinos mientras escribes.

#### La selección de ciudad

```dart
void _selectCity(dynamic city) {
  setState(() {
    _locationName = "${city['name']}, ${city['admin1'] ?? ''}, ${city['country']}";
    _suggestions = [];                    // Cerramos la lista desplegable
    _searchController.text = city['name']; // Mostramos el nombre en el campo de búsqueda
  });
  _updateWeather(city['latitude'], city['longitude']); // Pedimos el tiempo para esa ciudad
  FocusScope.of(context).unfocus();       // Escondemos el teclado virtual
}
```

`FocusScope.of(context).unfocus()` es una de esas líneas que solo se aprenden con experiencia: es la forma correcta de ocultar el teclado en Flutter. Sin ella, el teclado se quedaría visible de forma molesta.

#### El widget `Stack` — Capas superpuestas

```dart
body: SafeArea(
  child: Stack(
    children: [
      _buildMainContent(),                              // Capa inferior: el contenido principal
      if (_suggestions.isNotEmpty) _buildSuggestionsList(), // Capa superior: la lista de búsqueda
    ],
  ),
),
```

`Stack` es como Photoshop: apila widgets en capas, uno encima del otro. Aquí lo usamos para que la lista de sugerencias "flote" sobre el contenido del clima, tapándolo parcialmente mientras el usuario busca. Sin `Stack`, la lista empujaría hacia abajo el contenido (con `Column`) o sería imposible superponerla (con la mayoría de otros layouts).

#### El selector de vistas (tabs)

```dart
Widget _buildTabContent() {
  switch (_currentIndex) {
    case 0:
      return LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CurrentlyView(
                  locationName: _locationName,
                  current: _weatherData?.current,
                  description: _weatherData != null
                      ? WeatherData.getWeatherDescription(_weatherData!.current.weatherCode)
                      : null,
                ),
              ),
            ),
          ),
        );
      });
    case 1:
      return TodayView(locationName: _locationName, hourlyData: _weatherData?.hourly ?? []);
    case 2:
      return WeeklyView(locationName: _locationName, dailyData: _weatherData?.daily ?? []);
    default:
      return Container();
  }
}
```

**`_weatherData?.current`**: El operador `?.` es "accede a esta propiedad solo si el objeto no es null". Si `_weatherData` es null (aún no han llegado datos), esto devuelve `null` en lugar de crashear con un `NullPointerException`.

**`_weatherData?.hourly ?? []`**: "Dame la lista de horas, o si no hay datos, dame una lista vacía". Así los widgets de hoy y semana siempre reciben una lista válida, nunca `null`.

**`LayoutBuilder` + `ConstrainedBox`**: Técnica avanzada de Flutter para hacer que el contenido de "Currently" (que es poco y ocupa poco espacio) se centre verticalmente en pantalla sin importar el tamaño del dispositivo, y además sea desplazable si fuera necesario.

---

### 🔵 `widgets/currently_view.dart` — Vista "Ahora Mismo"

```dart
class CurrentlyView extends StatelessWidget {
  final String locationName;
  final CurrentWeather? current;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(locationName, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
        
        if (current != null) ...[
          Text("${current!.temperature.toStringAsFixed(1)}°C",
              style: const TextStyle(fontSize: 72)),
          
          if (description != null)
            Text(description!, style: const TextStyle(fontSize: 22)),
            
          Text("Wind speed: ${current!.windSpeed.toStringAsFixed(1)} km/h"),
        ],
      ],
    );
  }
}
```

Es un `StatelessWidget` porque no tiene estado propio: simplemente recibe datos y los muestra. Toda la lógica está en los niveles superiores.

**`if (current != null) ...[...]`**: La sintaxis `...[]` (spread operator dentro de un `if`) permite insertar condicionalmente múltiples widgets en una lista. Es la forma idiomática de Flutter de decir "muestra este bloque de widgets SOLO si tenemos datos del clima".

**`toStringAsFixed(1)`**: Muestra el número con exactamente 1 decimal. `28.5` en lugar de `28.500000000001` (los problemas habituales de los números en coma flotante).

**`current!`** (con exclamación): Le dice al compilador de Dart "confía en mí, sé que este valor no es null en este punto". Lo hacemos porque justo antes hemos comprobado `if (current != null)`.

---

### 📅 `widgets/today_view.dart` — Vista "Pronóstico de Hoy"

```dart
class TodayView extends StatelessWidget {
  final String locationName;
  final List<HourlyWeather> hourlyData;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // Filtramos: solo horas desde hace 1 hora hasta las próximas 24
    final filteredHourly = hourlyData
        .where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1))))
        .take(24)
        .toList();

    return Column(
      children: [
        Text(locationName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        
        if (filteredHourly.isEmpty)
          const Expanded(child: Center(child: Text("No data available")))
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredHourly.length,
              itemBuilder: (context, index) {
                final hour = filteredHourly[index];
                return Card(
                  color: Colors.white.withOpacity(0.05),
                  child: ListTile(
                    leading: Text(DateFormat('HH:00').format(hour.time)),
                    title: Text("${hour.temperature.toStringAsFixed(1)}°C"),
                    subtitle: Text(WeatherData.getWeatherDescription(hour.weatherCode)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(WeatherData.getWeatherIcon(hour.weatherCode)),
                        Text("${hour.windSpeed.toInt()} km/h"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
```

**Filtrado con `.where().take().toList()`**: Una cadena de operaciones funcionales sobre la lista:
- `.where((h) => h.time.isAfter(...))` → Filtra, manteniendo solo los elementos donde la condición es verdadera.
- `.take(24)` → Toma como máximo los primeros 24 elementos.
- `.toList()` → Convierte el resultado (un iterable) en una lista concreta.

El resultado: mostramos exactamente las próximas 24 horas desde el momento actual, sin horas pasadas.

**`DateFormat('HH:00').format(hour.time)`**: Del paquete `intl`. Formatea un `DateTime` en formato de 24 horas. `HH` es la hora con dos dígitos (00-23), y `:00` es literal. Resultado: "14:00", "15:00", etc.

**`ListView.builder`**: No crea todas las tarjetas a la vez (lo que sería costoso si hubiera muchas). Solo crea las que caben en pantalla en ese momento, y va creando/destruyendo más a medida que el usuario hace scroll. Es mucho más eficiente para listas largas.

**`Card`** con `Colors.white.withOpacity(0.05)`: Una tarjeta casi transparente que da un efecto de "cristal" sobre el fondo oscuro. `withOpacity(0.05)` significa 5% de opacidad (95% transparente).

---

### 🗓️ `widgets/weekly_view.dart` — Vista "Semana Completa"

```dart
class WeeklyView extends StatelessWidget {
  final String locationName;
  final List<DailyWeather> dailyData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(locationName, ...),
        Expanded(
          child: ListView.builder(
            itemCount: dailyData.length,
            itemBuilder: (context, index) {
              final day = dailyData[index];
              final isToday = index == 0;  // El primer elemento siempre es hoy

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      // Columna 1: Día de la semana (o "Today") + fecha
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              isToday ? "Today" : DateFormat('EEEE').format(day.date),
                              style: TextStyle(color: isToday ? Colors.blue : Colors.white),
                            ),
                            Text(DateFormat('dd/MM').format(day.date)),
                          ],
                        ),
                      ),
                      
                      // Columna 2: Icono + descripción del tiempo
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(WeatherData.getWeatherIcon(day.weatherCode)),
                            Text(WeatherData.getWeatherDescription(day.weatherCode)),
                          ],
                        ),
                      ),
                      
                      // Columna 3: Temperatura máxima (naranja) y mínima (azul)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${day.maxTemp.toInt()}°C",
                                style: const TextStyle(color: Colors.orangeAccent)),
                            Text("${day.minTemp.toInt()}°C",
                                style: const TextStyle(color: Colors.lightBlueAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

**`Expanded` con `flex`**: Divide el espacio horizontal disponible en proporciones. Con `flex: 2`, `flex: 3`, `flex: 2` el espacio total se divide en 7 partes: el día ocupa 2/7, la descripción 3/7, y las temperaturas 2/7. Es como dividir una pizza en porciones de tamaños distintos.

**`DateFormat('EEEE').format(day.date)`**: `EEEE` es el formato del nombre completo del día de la semana en el idioma del sistema. Devuelve "Monday", "Tuesday", etc. (o "Lunes", "Martes" si el idioma del dispositivo es español).

**`isToday ? "Today" : DateFormat('EEEE').format(day.date)`**: El operador ternario de Dart. "Si es hoy, muestra 'Today'; si no, muestra el nombre del día". El primer elemento de la lista siempre corresponde a la fecha actual, de ahí que `index == 0` equivalga a "hoy".

**`TextOverflow.ellipsis`**: Si el texto de la descripción es demasiado largo para caber, lo corta con "..." en lugar de desbordarse y romper el layout.

---

## 🔑 Conceptos Clave Aprendidos en Profundidad

### 1. Programación Asíncrona: `async`, `await` y `Future`

Este es el concepto más importante y más nuevo de este módulo.

**El problema**: Las operaciones de red (internet) y GPS tardan tiempo. Si Flutter esperara bloqueado a que terminaran, la app se congelaría y el usuario pensaría que está rota.

**La solución**: La programación asíncrona permite que Flutter diga "voy a pedir este dato, pero mientras espero, sigo dibujando la UI y respondiendo al usuario".

```dart
// SIN asincronía (MALO - congela la app):
void obtenerDatos() {
  WeatherData datos = pedirDatosAInternet(); // La app se CONGELA aquí
  mostrar(datos);
}

// CON asincronía (CORRECTO - la app sigue respondiendo):
Future<void> obtenerDatos() async {
  WeatherData datos = await pedirDatosAInternet(); // La app ESPERA sin congelarse
  mostrar(datos);
}
```

- **`Future<T>`**: Representa un valor que "llegará en el futuro". Es una promesa: "te prometo que en algún momento te daré un valor de tipo `T`".
- **`async`**: Marca una función como asíncrona. Dentro de ella puedes usar `await`.
- **`await`**: "Espera a que este `Future` se complete antes de continuar". Pero lo hace de forma no bloqueante: Flutter puede hacer otras cosas mientras espera.

### 2. Peticiones HTTP con el paquete `http`

```dart
import 'package:http/http.dart' as http;

final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=36.7&longitude=-4.42');
final response = await http.get(url);

print(response.statusCode); // 200 = éxito
print(response.body);       // El JSON como texto
```

El paquete `http` abstrae toda la complejidad de las conexiones de red. `http.get(url)` envía una petición GET (la más común, la que usa tu navegador para cargar una página web) y devuelve un `Future<Response>` con el resultado.

### 3. Parseo de JSON: De texto a objetos Dart

```dart
import 'dart:convert';

String jsonTexto = '{"temperatura": 28.5, "ciudad": "Málaga"}';

// Convertir texto JSON a Mapa de Dart
Map<String, dynamic> mapa = json.decode(jsonTexto);

print(mapa['temperatura']); // 28.5
print(mapa['ciudad']);      // "Málaga"

// Convertir Mapa de Dart a texto JSON
String textoOtraVez = json.encode(mapa);
```

`json.decode()` es la función de la librería estándar de Dart que transforma un `String` en JSON a un `Map` o `List` de Dart. A partir de ahí, podemos acceder a los valores con la notación `['clave']`.

### 4. El patrón `factory constructor` y los Modelos de Datos

El patrón **Model** (o Data Transfer Object) consiste en crear clases simples cuyo único propósito es contener datos estructurados. El `factory constructor` `fromJson` es la fábrica que transforma el "caos" del JSON en un objeto limpio y tipado.

```dart
// JSON crudo de la API (confuso, sin tipos seguros)
Map<String, dynamic> json = {
  'temperature_2m': 28.5,
  'weather_code': 0,
};

// Objeto de Dart (limpio, tipado, autocompletable en el IDE)
CurrentWeather weather = CurrentWeather.fromJson(json);
print(weather.temperature); // 28.5 — el IDE sabe que es un double
```

Los modelos proporcionan **seguridad de tipos** (el compilador de Dart avisa si intentas usar un `String` como `double`) y **autocompletado en el IDE** (el editor sabe qué propiedades tiene cada objeto).

### 5. Geolocalización con `geolocator`

```dart
import 'package:geolocator/geolocator.dart';

// Obtener la posición actual
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.medium,
);

print(position.latitude);  // Ej: 36.7213
print(position.longitude); // Ej: -4.4214
```

`Position` es el objeto de `geolocator` que contiene las coordenadas GPS. Con latitud y longitud podemos hacer absolutamente cualquier cosa: pedir el clima, mostrar un mapa, calcular distancias, etc.

### 6. Gestión de Permisos del Sistema Operativo

Los permisos en Android e iOS requieren dos cosas:

**1. Declarar el permiso en la configuración del SO:**

En Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

En iOS (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta app necesita tu ubicación para mostrar el tiempo de tu zona.</string>
```

**2. Pedirlo en tiempo de ejecución** (con `Geolocator.requestPermission()`), que es lo que hace `location_service.dart`.

Sin ambas cosas, la app falla. El paquete `geolocator` simplifica enormemente este proceso, que sin él sería código nativo Android/iOS bastante complejo.

### 7. Estado de Carga y Manejo de Errores

El patrón de "estado de carga + error" es una convención estándar en apps móviles:

```dart
bool _isLoading = false;
String _errorMessage = "";

// Al iniciar una operación asíncrona:
setState(() { _isLoading = true; _errorMessage = ""; });

try {
  final data = await fetchData();
  setState(() { _data = data; });
} catch (e) {
  setState(() { _errorMessage = "Error: $e"; });
} finally {
  setState(() { _isLoading = false; });
}

// En la UI:
if (_isLoading) CircularProgressIndicator()
else if (_errorMessage.isNotEmpty) Text(_errorMessage, style: TextStyle(color: Colors.red))
else MostrarDatos(_data)
```

Este patrón garantiza que el usuario siempre sabe qué está pasando: la app está cargando, hubo un error, o los datos están listos.

### 8. El widget `Stack`: Capas superpuestas

```
+----------------------------------+
|  Fondo (MainContent)             |  ← Capa 0 (inferior)
|  +----------------------------+  |
|  | Lista de sugerencias        |  |  ← Capa 1 (encima)
|  | - Madrid                   |  |
|  | - Málaga                   |  |
|  +----------------------------+  |
+----------------------------------+
```

`Stack` coloca sus hijos unos encima de otros en el mismo espacio. El último en la lista es el que queda más arriba (visible). Es fundamental para crear overlays, menús desplegables sobre contenido, o cualquier elemento que "flote" sobre la interfaz.

### 9. `TextEditingController` y Búsqueda en Tiempo Real

```dart
final TextEditingController _controller = TextEditingController();

// En initState:
_controller.addListener(() {
  setState(() {}); // Redibuja cuando el texto cambia
});

// En el widget:
TextField(
  controller: _controller,
  onChanged: (text) => buscarCiudades(text), // Se llama con cada pulsación
)

// Para leer el texto:
String textoActual = _controller.text;

// Para borrarlo:
_controller.clear();
```

`TextEditingController` es el mecanismo de Flutter para tener control programático sobre un campo de texto: leer su contenido, modificarlo desde código, añadir oyentes que reaccionen a cambios, etc.

### 10. `ListView.builder`: Listas Eficientes

```dart
// ❌ ListView estático - crea TODOS los widgets de golpe
ListView(
  children: miLista.map((item) => ItemWidget(item)).toList(),
)

// ✅ ListView.builder - crea solo los que caben en pantalla
ListView.builder(
  itemCount: miLista.length,
  itemBuilder: (context, index) {
    return ItemWidget(miLista[index]); // Solo se llama para los índices visibles
  },
)
```

Para listas de más de ~20 elementos, `ListView.builder` es siempre la elección correcta por rendimiento. Solo construye los widgets que el usuario puede ver en ese momento.

### 11. Formateo de Fechas con el paquete `intl`

```dart
import 'package:intl/intl.dart';

DateTime ahora = DateTime.now();

DateFormat('HH:mm').format(ahora);    // "14:30"
DateFormat('HH:00').format(ahora);    // "14:00" (siempre muestra :00)
DateFormat('EEEE').format(ahora);     // "Monday" / "Lunes" (según idioma del dispositivo)
DateFormat('dd/MM').format(ahora);    // "10/06"
DateFormat('dd MMM yyyy').format(ahora); // "10 Jun 2024"
```

Los objetos `DateTime` de Dart son potentes pero su `toString()` por defecto no es amigable. El paquete `intl` da control total sobre cómo se muestran fechas y horas.

### 12. Arquitectura por Capas (Separación de Responsabilidades)

La gran enseñanza estructural de este módulo:

```
┌─────────────────────────────────────────────┐
│  UI / WIDGETS (¿Cómo se ve?)                │  currently_view, today_view, weekly_view
│  Solo reciben datos y los pintan            │
└──────────────────────┬──────────────────────┘
                       │ datos ya procesados
┌──────────────────────▼──────────────────────┐
│  SCREENS (¿Qué debe ocurrir?)               │  weather_home.dart
│  Coordinan servicios y pasan datos a la UI  │
└────────────┬─────────────────┬──────────────┘
             │ pide datos      │ pide ubicación
┌────────────▼──────┐  ┌───────▼──────────────┐
│  SERVICES         │  │  SERVICES             │
│  weather_service  │  │  location_service     │
│  (habla con APIs) │  │  (habla con el GPS)   │
└────────────┬──────┘  └───────┬──────────────┘
             │                 │
┌────────────▼──────┐          │
│  MODELS           │          │
│  weather_data     │◄─────────┘ (servicios usan modelos)
│  (define los datos│
└───────────────────┘
```

Cada capa solo se comunica con la capa inmediatamente adyacente. Los widgets no saben que existe internet. Los servicios no saben que existe una pantalla. Esta separación hace el código mantenible, testeable y extensible.

---

## ✅ Guía de Evaluación Exhaustiva (Peer-to-Peer)

Esta sección está pensada tanto para el evaluador como para el autor, para asegurar que ningún punto quede sin revisar.

### 1. Arranque y Permisos

- [ ] La app arranca sin errores ni warnings en la consola.
- [ ] Al abrir la app por primera vez, aparece el diálogo del sistema pidiendo permiso de ubicación.
- [ ] Si se **acepta** el permiso, la app automáticamente detecta la ciudad actual y muestra el tiempo.
- [ ] Si se **deniega** el permiso, la app muestra el mensaje "Geolocation is not available" y no se cierra.
- [ ] El campo de búsqueda muestra el texto placeholder "Search Location..." cuando está vacío.

### 2. Funcionalidad de Búsqueda con Autocompletado

- [ ] Al escribir **menos de 3 letras**, no aparece ningún desplegable (es correcto, es la optimización).
- [ ] Al escribir **3 o más letras**, aparece una lista desplegable con ciudades sugeridas (máximo 5).
- [ ] Las sugerencias incluyen el nombre de la ciudad, la región y el país (Ej: "Madrid, Community of Madrid, Spain").
- [ ] Al **tocar una ciudad** de la lista, el desplegable desaparece, el teclado se oculta, y todos los datos del tiempo se actualizan para esa ciudad.
- [ ] Al pulsar **Enter/Return** en el teclado, la app selecciona la primera sugerencia de la lista (si hay alguna).
- [ ] Aparece la **icono de ×** (limpiar) en el campo de búsqueda cuando hay texto escrito. Al tocarlo, borra el texto y el desplegable desaparece.
- [ ] Si se escribe una ciudad que no existe, aparece el mensaje "No results found".

### 3. Geolocalización (Botón GPS)

- [ ] Al pulsar el **icono de localización** (📍) en la AppBar, se vuelve a intentar obtener el GPS.
- [ ] Mientras espera la respuesta del GPS o de internet, aparece el **indicador de carga** (ruedita giratoria).
- [ ] El nombre de la ciudad detectada se muestra en formato "Ciudad, Región, País" en la barra superior y en el contenido principal.

### 4. Vista "Currently" (Pestaña 0)

- [ ] Muestra el nombre de la ciudad/ubicación en tamaño grande.
- [ ] Muestra la **temperatura actual** en grados Celsius con 1 decimal (Ej: "28.5°C") en tamaño muy grande (~72px).
- [ ] Muestra una **descripción textual** del estado del cielo (Ej: "Cielo despejado", "Lluvia").
- [ ] Muestra la **velocidad del viento** actual en km/h.

### 5. Vista "Today" (Pestaña 1)

- [ ] Muestra una lista desplazable con el pronóstico hora a hora.
- [ ] Solo muestra **horas futuras** (desde la hora actual en adelante), no horas pasadas.
- [ ] Cada fila de la lista muestra: **hora** (formato HH:00), **temperatura**, **descripción** del tiempo, **icono** visual, y **velocidad del viento**.
- [ ] La lista tiene como máximo 24 entradas (las próximas 24 horas).
- [ ] Si no hay datos disponibles, muestra "No data available" de forma elegante.

### 6. Vista "Weekly" (Pestaña 2)

- [ ] Muestra una lista con los próximos 7 días.
- [ ] El primer elemento muestra "Today" en lugar del nombre del día, y está resaltado en color diferente (azul).
- [ ] Cada fila muestra: **nombre del día** (lunes, martes...) + **fecha** (dd/MM), **icono** del tiempo, **descripción**, **temperatura máxima** (en naranja) y **temperatura mínima** (en azul).
- [ ] Si no hay datos disponibles, muestra "No data available".

### 7. Robustez y Manejo de Errores

- [ ] **Prueba sin red**: Activa el "Modo Avión". Pulsa el botón de GPS o busca una ciudad. La app muestra un mensaje de error claro y **no se cierra**.
- [ ] **Prueba de GPS desactivado**: Desactiva el GPS del dispositivo en ajustes. Pulsa el botón de localización. La app muestra el mensaje de error correspondiente.
- [ ] El indicador de carga (`CircularProgressIndicator`) aparece **siempre** que se está esperando una respuesta, y desaparece cuando los datos llegan (con éxito o con error).

### 8. Calidad del Código

- [ ] Verificar que existe la carpeta `models/` con los modelos de datos.
- [ ] Verificar que existe la carpeta `services/` con los servicios separados.
- [ ] Verificar que `weather_home.dart` usa los servicios pero no contiene código HTTP directamente.
- [ ] El `pubspec.yaml` lista correctamente las dependencias `http`, `geolocator` e `intl`.
- [ ] La app no tiene warnings de análisis estático (`flutter analyze`).

---

## 🛠️ Preparación del Entorno — Paso a Paso

### Prerrequisitos

1. **Flutter instalado**: Sigue la [guía oficial](https://docs.flutter.dev/get-started/install) para tu sistema operativo.
2. **Verificación**: Ejecuta `flutter doctor` y asegúrate de que no hay errores críticos (marcados con ✗).
3. **Dispositivo o emulador**: Un móvil físico (Android o iOS) conectado por USB, o un emulador/simulador iniciado.

> ⚠️ **Nota sobre el GPS**: En emuladores, el GPS no funciona con hardware real. Para probar la geolocalización, usa un dispositivo físico o configura una ubicación ficticia en el emulador (Extended Controls → Location en Android Studio).

### Instalación y ejecución

```bash
# 1. Clona el repositorio (si aún no lo has hecho)
git clone https://github.com/STC71/piscine_pedago_mobile.git

# 2. Entra en la carpeta del proyecto de este módulo
cd piscine_pedago_mobile/mobileModule02/medium_weather_app

# 3. Descarga todas las dependencias declaradas en pubspec.yaml
#    (http, geolocator, intl, etc.)
flutter pub get

# 4. Verifica que no hay errores de código
flutter analyze

# 5. Ejecuta la aplicación en el dispositivo conectado
flutter run
```

### Comandos útiles durante el desarrollo

```bash
# Ver los logs en tiempo real (útil para debuggear)
flutter logs

# Reconstruir desde cero (útil si hay problemas raros)
flutter clean && flutter pub get && flutter run

# Compilar una APK para instalar directamente en Android
flutter build apk --release

# Ver todos los dispositivos disponibles
flutter devices
```

### Permisos requeridos

**Android** — en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** — en `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Medium Weather necesita tu ubicación para mostrarte el tiempo de tu zona.</string>
```

---

## ✍️ Autor

**[sternero](https://github.com/STC71)** — junio 2026

---

<p align="center">
  <b>Piscine Mobile 42 Málaga</b><br>
  <i>"Connecting Apps to the World — one HTTP request at a time"</i>
</p>
