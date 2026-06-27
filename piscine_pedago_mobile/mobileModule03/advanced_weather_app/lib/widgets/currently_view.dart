// =============================================================================
//  VISTA ACTUAL: EL ESTADO DEL CIELO EN TIEMPO REAL
//  Muestra el clima actual con un diseño limpio y profesional.
// =============================================================================

import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class CurrentlyView extends StatelessWidget {
  final String locationName;
  final CurrentWeather? current;
  final String? description;

  const CurrentlyView({
    super.key,
    required this.locationName,
    this.current,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lado izquierdo: Ubicación e Icono
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locationName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (current != null) ...[
                      const SizedBox(height: 10),
                      Icon(
                        WeatherData.getWeatherIcon(current!.weatherCode),
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ],
                ),
              ),
              // Lado derecho: Temperatura y detalles
              if (current != null)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "${current!.temperature.toStringAsFixed(1)}°C",
                        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      if (description != null)
                        Text(
                          description!.toUpperCase(),
                          style: const TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 2),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.air, color: Colors.blueAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "${current!.windSpeed.toStringAsFixed(1)} km/h",
                            style: const TextStyle(fontSize: 16, color: Colors.white60),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ubicación con estilo tipográfico mejorado.
          Text(
            locationName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          if (current != null) ...[
            // Icono grande representativo del clima.
            Icon(
              WeatherData.getWeatherIcon(current!.weatherCode),
              size: 100,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            
            // Temperatura principal.
            Text(
              "${current!.temperature.toStringAsFixed(1)}°C",
              style: const TextStyle(
                fontSize: 86,
                fontWeight: FontWeight.bold,
                letterSpacing: -2,
              ),
            ),
            
            // Descripción textual.
            if (description != null)
              Text(
                description!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            
            const SizedBox(height: 40),
            
            // Fila de información adicional (Viento).
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.air, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Wind Speed: ${current!.windSpeed.toStringAsFixed(1)} km/h",
                  style: const TextStyle(fontSize: 18, color: Colors.white60),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
