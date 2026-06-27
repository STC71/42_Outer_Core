// =============================================================================
//  SERVICIO METEOROLÓGICO: EL CARTERO DE INTERNET
//  Este archivo es el encargado de viajar a las bases de datos mundiales
//  en internet para preguntar: "¿Qué tiempo hace en esta ciudad?" o 
//  "¿Dónde está esta ciudad que ha escrito el usuario?".
// =============================================================================

import 'dart:convert'; // Para traducir el texto de internet a mapas de datos.
import 'package:http/http.dart' as http; // El "barco" que viaja por internet.

import '../models/weather_data.dart'; // Nuestra plantilla de datos.

class WeatherService {
  // Direcciones de las oficinas de datos (APIs) de Open-Meteo.
  // Una oficina sirve para buscar nombres de ciudades (Geocoding).
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  // La otra oficina sirve para saber el tiempo (Forecast).
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';

  // --- FUNCIÓN PARA SUGERIR CIUDADES MIENTRAS ESCRIBES ---
  Future<List<dynamic>> getSuggestions(String query) async {
    // Si solo hay una o dos letras, no buscamos nada para no trabajar de más.
    if (query.length < 3) return [];
    
    try {
      // Preparamos la carta con la dirección y el nombre de la ciudad a buscar.
      final url = Uri.parse('$_geocodingUrl?name=$query&count=5&language=en');
      // Enviamos el mensaje por internet y esperamos la respuesta (await).
      final response = await http.get(url);
      
      // Si la oficina de internet responde con un "200" (OK / Correcto)...
      if (response.statusCode == 200) {
        // Traducimos el texto (JSON) que nos envían a un formato que Flutter entienda.
        final data = json.decode(response.body);
        return data['results'] ?? []; // Devolvemos la lista de ciudades encontradas.
      }
    } catch (e) {
      // Manejo de errores silencioso.
    }
    return []; // Si algo falla, devolvemos una lista vacía.
  }

  // --- FUNCIÓN PARA PEDIR EL TIEMPO REAL ---
  Future<WeatherData?> fetchWeather(double lat, double lon) async {
    try {
      // Pedimos datos de temperatura, lluvia y viento para las coordenadas (Lat, Lon).
      // Pedimos datos actuales, por horas y por días.
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
        // Usamos nuestro "traductor especializado" para convertir el JSON en un objeto WeatherData.
        return WeatherData.fromJson(data);
      }
    } catch (e) {
      // Error silencioso.
    }
    return null;
  }

  // --- FUNCIÓN PARA TRADUCIR COORDENADAS A NOMBRE DE CIUDAD ---
  // Útil cuando usamos el GPS y no sabemos cómo se llama el sitio donde estamos.
  Future<String?> getCityName(double lat, double lon) async {
    try {
      // Usamos la API de BigDataCloud para geocodificación inversa (gratuita y sin registro).
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
      // Error silencioso.
    }
    return null;
  }

  // --- FUNCIÓN PARA BUSCAR UNA CIUDAD CONCRETA ---
  Future<dynamic> searchCity(String query) async {
    try {
      final url = Uri.parse('$_geocodingUrl?name=$query&count=10&language=en');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Devolvemos el primer resultado de la búsqueda.
          return data['results'][0];
        }
      }
    } catch (e) {
      // Error silencioso.
    }
    return null;
  }
}
