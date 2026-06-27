// =============================================================================
//  VISTA SEMANAL: El pronóstico de los próximos 7 días
//  Muestra una lista con las temperaturas máximas y mínimas de la semana.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';

class WeeklyView extends StatelessWidget {
  final String locationName;
  final List<DailyWeather> dailyData; // Datos de cada día de la semana.

  const WeeklyView({
    super.key,
    required this.locationName,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Cabecera con la ciudad.
        Text(locationName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        
        // Si no hay datos, avisamos.
        if (dailyData.isEmpty)
          const Expanded(child: Center(child: Text("No data available")))
        else
          // Lista de días de la semana.
          Expanded(
            child: ListView.builder(
              itemCount: dailyData.length,
              itemBuilder: (context, index) {
                final day = dailyData[index];
                // El primer elemento de la lista es siempre hoy.
                final isToday = index == 0;

                return Card(
                  color: Colors.white.withValues(alpha: 0.05),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        // Columna 1: El día (Ej: Monday o "Today").
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isToday ? "Today" : DateFormat('EEEE').format(day.date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? Colors.blue : Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM').format(day.date),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        
                        // Columna 2: Icono y descripción (Ej: Soleado).
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Icon(WeatherData.getWeatherIcon(day.weatherCode),
                                  color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  WeatherData.getWeatherDescription(day.weatherCode),
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis, // Si es muy largo, pone "..."
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Columna 3: Temperaturas máxima (naranja) y mínima (azul).
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${day.maxTemp.toInt()}°C",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orangeAccent),
                              ),
                              Text(
                                "${day.minTemp.toInt()}°C",
                                style: const TextStyle(color: Colors.lightBlueAccent),
                              ),
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
