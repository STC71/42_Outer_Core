// =============================================================================
//  PISCINE MOBILE - MÓDULO 03: ADVANCED WEATHER APP
//  Este nivel final integra visualización de datos (gráficos) y una 
//  interfaz de usuario pulida y profesional.
// =============================================================================

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
      title: 'Advanced Weather',
      debugShowCheckedModeBanner: false,
      
      // Definimos un tema oscuro elegante y moderno.
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
        ),
        // Personalización de las pestañas.
        tabBarTheme: const TabBarThemeData(
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Color(0xFF0A0E21),
          selectedIconTheme: IconThemeData(color: Colors.blueAccent),
          unselectedIconTheme: IconThemeData(color: Colors.white60),
          selectedLabelTextStyle: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle: TextStyle(color: Colors.white60),
          indicatorColor: Colors.transparent,
        ),
      ),
      
      home: const WeatherHomeScreen(),
    );
  }
}
