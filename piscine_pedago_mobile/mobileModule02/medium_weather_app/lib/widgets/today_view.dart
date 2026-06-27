// =============================================================================
//  VISTA DE HOY: Pronóstico por horas
//  Aquí mostramos una lista con lo que pasará en las próximas 24 horas.
// =============================================================================

import 'package:flutter/material.dart';
// 'intl' es una librería para manejar fechas de forma fácil (como el formato 24h).
import 'package:intl/intl.dart';
import '../models/weather_data.dart';

class TodayView extends StatelessWidget {
  final String locationName;
  final List<HourlyWeather> hourlyData; // Una lista con datos de cada hora.

  const TodayView({
    super.key,
    required this.locationName,
    required this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now(); // Miramos qué hora es ahora mismo.
    
    // Filtramos los datos para mostrar solo el futuro (las próximas 24 horas).
    final filteredHourly = hourlyData
        .where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1))))
        .take(24)
        .toList();

    return Column(
      children: [
        const SizedBox(height: 20),
        // Cabecera con el nombre de la ciudad.
        Text(locationName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        
        // Si no hay datos, mostramos un mensaje de aviso.
        if (filteredHourly.isEmpty)
          const Expanded(child: Center(child: Text("No data available")))
        else
          // Si hay datos, usamos un 'ListView.builder'.
          // Es como una cinta transportadora que fabrica solo las tarjetas que caben en pantalla.
          Expanded(
            child: ListView.builder(
              itemCount: filteredHourly.length,
              itemBuilder: (context, index) {
                final hour = filteredHourly[index];
                
                // Cada hora es una "Card" (tarjeta) con estilo elegante.
                return Card(
                  color: Colors.white.withValues(alpha: 0.05), // Casi transparente.
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    // A la izquierda: La hora formateada (Ej: 14:00).
                    leading: Text(
                      DateFormat('HH:00').format(hour.time),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // En el centro: Temperatura.
                    title: Text("${hour.temperature.toStringAsFixed(1)}°C"),
                    // Debajo: Descripción del cielo.
                    subtitle: Text(WeatherData.getWeatherDescription(hour.weatherCode)),
                    // A la derecha: Icono del tiempo y velocidad del viento.
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Que ocupe el mínimo espacio posible.
                      children: [
                        Icon(WeatherData.getWeatherIcon(hour.weatherCode),
                            color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.air, size: 16, color: Colors.grey),
                            Text("${hour.windSpeed.toInt()} km/h",
                                style: const TextStyle(fontSize: 10)),
                          ],
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
