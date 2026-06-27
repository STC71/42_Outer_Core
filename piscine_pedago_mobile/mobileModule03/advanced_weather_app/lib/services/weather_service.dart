// =============================================================================
//  SERVICIO METEOROLÓGICO: COMUNICACIÓN CON APIS EXTERNAS
//  Maneja las peticiones HTTP para obtener pronósticos y nombres de ciudades.
// =============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  // URLs de Open-Meteo para geocodificación y pronóstico.
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';

  // Busca sugerencias de ciudades basadas en una cadena de texto.
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
      debugPrint("Geocoding error: $e");
    }
    return [];
  }

  // Obtiene el pronóstico meteorológico completo para unas coordenadas dadas.
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
      debugPrint("Weather fetch error: $e");
    }
    return null;
  }

  // Traduce coordenadas GPS a un nombre de ubicación legible.
  Future<String?> getCityName(double lat, double lon) async {
    try {
      // Usamos BigDataCloud para geocodificación inversa gratuita.
      final url = Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = data['city'] ?? data['locality'] ?? '';
        final region = data['principalSubdivision'] ?? '';
        final country = data['countryName'] ?? '';
        
        if (city.isNotEmpty) {
          return "$city, $region, $country";
        }
        return "$region, $country";
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    }
    return null;
  }

  // Búsqueda directa de una ciudad (devuelve el primer resultado).
  Future<dynamic> searchCity(String query) async {
    try {
      final url = Uri.parse('$_geocodingUrl?name=$query&count=1&language=en');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0];
        }
      }
    } catch (e) {
      debugPrint("City search error: $e");
    }
    return null;
  }
}
