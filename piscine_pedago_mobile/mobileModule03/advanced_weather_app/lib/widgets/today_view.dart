// =============================================================================
//  VISTA DE HOY: DETALLE HORARIO Y GRÁFICO
//  Combina una lista de horas con una representación gráfica de la temperatura.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import 'weather_chart.dart'; // Importamos el nuevo gráfico.

class TodayView extends StatelessWidget {
  final String locationName;
  final List<HourlyWeather> hourlyData;

  const TodayView({
    super.key,
    required this.locationName,
    required this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredHourly = hourlyData
        .where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1))))
        .take(24)
        .toList();

    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parte izquierda: Título y Gráfico
          Expanded(
            flex: 3,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  locationName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (filteredHourly.isNotEmpty)
                  Expanded(child: HourlyWeatherChart(hourlyData: filteredHourly)),
              ],
            ),
          ),
          const VerticalDivider(color: Colors.white24, width: 1),
          // Parte derecha: Lista detallada
          Expanded(
            flex: 2,
            child: _buildHourlyList(filteredHourly),
          ),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          locationName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        
        // --- SECCIÓN DEL GRÁFICO ---
        if (filteredHourly.isNotEmpty)
          HourlyWeatherChart(hourlyData: filteredHourly),
        
        const Divider(color: Colors.white24, indent: 20, endIndent: 20),
        
        // --- LISTA DE HORAS ---
        Expanded(child: _buildHourlyList(filteredHourly)),
      ],
    );
  }

  Widget _buildHourlyList(List<HourlyWeather> filteredHourly) {
    if (filteredHourly.isEmpty) {
      return const Center(child: Text("No data available"));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredHourly.length,
      itemBuilder: (context, index) {
        final hour = filteredHourly[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white.withValues(alpha: 0.05),
              child: ListTile(
                dense: true,
                leading: Text(
                  DateFormat('HH:00').format(hour.time),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text("${hour.temperature.toStringAsFixed(1)}°C"),
                subtitle: Row(
                  children: [
                    const Icon(Icons.air, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      "${hour.windSpeed.toInt()} km/h",
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        WeatherData.getWeatherDescription(hour.weatherCode),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(WeatherData.getWeatherIcon(hour.weatherCode), color: Colors.blueAccent),
              ),
            ),
          ),
        );
      },
    );
  }
}
