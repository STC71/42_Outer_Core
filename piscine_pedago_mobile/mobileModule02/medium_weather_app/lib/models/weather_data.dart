// =============================================================================
//  MODELOS DE DATOS: EL TRADUCTOR DE LA APP
//  Cuando pedimos el tiempo a internet, nos llega un texto gigante y feo (JSON).
//  Este archivo es como un "traductor" que convierte ese texto en objetos 
//  limpios y fáciles de usar en nuestras pantallas.
// =============================================================================

import 'package:flutter/material.dart';

// 'WeatherData' es el paquete completo que contiene todo lo que necesitamos:
// El tiempo de ahora, el de las próximas horas y el de los próximos días.
class WeatherData {
  final CurrentWeather current;      // Información de "ahora".
  final List<HourlyWeather> hourly;  // Una lista con las próximas horas.
  final List<DailyWeather> daily;    // Una lista con los próximos días.

  // El constructor: nos dice que para crear un 'WeatherData' necesitamos esos 3 datos.
  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  // 'factory WeatherData.fromJson' es como un obrero especializado.
  // Su trabajo es coger un mapa de datos (JSON) y repartirlo en los sitios correctos.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // Sacamos las piezas individuales del gran paquete 'json'.
    final currentJson = json['current'];
    final hourlyJson = json['hourly'];
    final dailyJson = json['daily'];

    // --- PROCESANDO LAS HORAS ---
    // Como las horas vienen en listas separadas, tenemos que unirlas nosotros.
    final List<HourlyWeather> hourlyList = [];
    for (int i = 0; i < (hourlyJson['time'] as List).length; i++) {
      hourlyList.add(HourlyWeather(
        time: DateTime.parse(hourlyJson['time'][i]), // Convertimos texto en una "Fecha" real.
        temperature: hourlyJson['temperature_2m'][i].toDouble(),
        weatherCode: hourlyJson['weather_code'][i],
        windSpeed: hourlyJson['wind_speed_10m'][i].toDouble(),
      ));
    }

    // --- PROCESANDO LOS DÍAS ---
    final List<DailyWeather> dailyList = [];
    for (int i = 0; i < (dailyJson['time'] as List).length; i++) {
      dailyList.add(DailyWeather(
        date: DateTime.parse(dailyJson['time'][i]),
        maxTemp: dailyJson['temperature_2m_max'][i].toDouble(),
        minTemp: dailyJson['temperature_2m_min'][i].toDouble(),
        weatherCode: dailyJson['weather_code'][i],
      ));
    }

    // Finalmente, montamos el objeto 'WeatherData' con todo lo que hemos preparado.
    return WeatherData(
      current: CurrentWeather(
        temperature: currentJson['temperature_2m'].toDouble(),
        windSpeed: currentJson['wind_speed_10m'].toDouble(),
        weatherCode: currentJson['weather_code'],
      ),
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  // --- DICCIONARIO DE TRADUCCIÓN (CÓDIGO -> TEXTO) ---
  // Las estaciones meteorológicas mandan números (0, 1, 2...). 
  // Esta función traduce esos números a palabras que entendamos.
  static String getWeatherDescription(int code) {
    if (code == 0) return "Clear sky";
    if (code <= 3) return "Mainly clear";
    if (code <= 48) return "Fog";
    if (code <= 67) return "Rain";
    if (code <= 86) return "Snow";
    return "Thunderstorm";
  }

  // --- DICCIONARIO DE ICONOS (CÓDIGO -> DIBUJO) ---
  // Lo mismo, pero para elegir qué dibujito poner en pantalla.
  static IconData getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.wb_cloudy_outlined;
    if (code <= 48) return Icons.wb_cloudy;
    if (code <= 67) return Icons.umbrella;
    if (code <= 86) return Icons.ac_unit;
    return Icons.thunderstorm;
  }
}

// === MINI-PLANTILLAS DE DATOS ===
// Estas clases son como "fichas" con los huecos listos para rellenar.

// Ficha para el tiempo actual.
class CurrentWeather {
  final double temperature;
  final double windSpeed;
  final int weatherCode;

  CurrentWeather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
  });
}

// Ficha para una hora concreta.
class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final double windSpeed;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });
}

// Ficha para un día concreto.
class DailyWeather {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}
