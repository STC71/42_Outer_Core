// =============================================================================
//  PISCINE MOBILE - MÓDULO 02: MEDIUM WEATHER APP
//  En este nivel, el código está mucho más organizado y "limpio".
//  Hemos dividido la aplicación en diferentes archivos para que sea más fácil de mantener.
// =============================================================================

import 'package:flutter/material.dart';
// Importamos la pantalla principal desde otro archivo.
// Es como si el mando a distancia (main.dart) llamara a la televisión (weather_home.dart).
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
      
      // Mantenemos el estilo oscuro que ya conocemos.
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      
      // Lanzamos la pantalla principal.
      home: const WeatherHomeScreen(),
    );
  }
}
