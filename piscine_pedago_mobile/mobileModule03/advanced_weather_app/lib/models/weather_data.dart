// =============================================================================
//  MODELOS DE DATOS: ESTRUCTURANDO EL PRONÓSTICO PROFESIONAL
//  Este archivo define cómo organizamos la información que recibimos de internet.
//  En el Módulo 03, estos modelos alimentarán tanto las listas como los gráficos.
// =============================================================================

import 'package:flutter/material.dart';

// 'WeatherData' es el contenedor principal de toda la información meteorológica.
class WeatherData {
  final CurrentWeather current;      // Datos del momento exacto.
  final List<HourlyWeather> hourly;  // Pronóstico para las próximas 24-48 horas.
  final List<DailyWeather> daily;    // Pronóstico para los próximos 7 días.

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  // Constructor 'factory' para convertir el JSON de la API en objetos de Dart.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'];
    final hourlyJson = json['hourly'];
    final dailyJson = json['daily'];

    // Procesamos la lista de horas (esencial para el gráfico de fl_chart).
    final List<HourlyWeather> hourlyList = [];
    for (int i = 0; i < (hourlyJson['time'] as List).length; i++) {
      hourlyList.add(HourlyWeather(
        time: DateTime.parse(hourlyJson['time'][i]),
        temperature: hourlyJson['temperature_2m'][i].toDouble(),
        weatherCode: hourlyJson['weather_code'][i],
        windSpeed: hourlyJson['wind_speed_10m'][i].toDouble(),
      ));
    }

    // Procesamos la lista de días (máximas y mínimas).
    final List<DailyWeather> dailyList = [];
    for (int i = 0; i < (dailyJson['time'] as List).length; i++) {
      dailyList.add(DailyWeather(
        date: DateTime.parse(dailyJson['time'][i]),
        maxTemp: dailyJson['temperature_2m_max'][i].toDouble(),
        minTemp: dailyJson['temperature_2m_min'][i].toDouble(),
        weatherCode: dailyJson['weather_code'][i],
      ));
    }

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

  // Traductor de códigos meteorológicos WMO a texto legible (más preciso).
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0: return "Clear sky";
      case 1: return "Mainly clear";
      case 2: return "Partly cloudy";
      case 3: return "Overcast";
      case 45: case 48: return "Fog";
      case 51: case 53: case 55: return "Drizzle";
      case 61: case 63: case 65: return "Rain";
      case 66: case 67: return "Freezing Rain";
      case 71: case 73: case 75: return "Snow fall";
      case 77: return "Snow grains";
      case 80: case 81: case 82: return "Rain showers";
      case 85: case 86: return "Snow showers";
      case 95: return "Thunderstorm";
      case 96: case 99: return "Thunderstorm with hail";
      default: return "Unknown";
    }
  }

  // Traductor de códigos meteorológicos WMO a iconos de Flutter.
  static IconData getWeatherIcon(int code) {
    switch (code) {
      case 0: return Icons.wb_sunny;
      case 1: case 2: return Icons.wb_cloudy_outlined;
      case 3: return Icons.wb_cloudy;
      case 45: case 48: return Icons.blur_on;
      case 51: case 53: case 55: return Icons.grain;
      case 61: case 63: case 65: return Icons.umbrella;
      case 66: case 67: return Icons.ac_unit;
      case 71: case 73: case 75: return Icons.ac_unit;
      case 77: return Icons.ac_unit;
      case 80: case 81: case 82: return Icons.beach_access;
      case 85: case 86: return Icons.ac_unit;
      case 95: return Icons.thunderstorm;
      case 96: case 99: return Icons.thunderstorm;
      default: return Icons.help_outline;
    }
  }
}

// Representa el tiempo en el instante actual.
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

// Representa el tiempo en una hora específica (se usa para el gráfico lineal).
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

// Representa el resumen meteorológico de un día completo.
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
