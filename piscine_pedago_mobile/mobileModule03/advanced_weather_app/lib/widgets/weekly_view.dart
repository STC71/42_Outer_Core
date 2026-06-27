// =============================================================================
//  VISTA SEMANAL: PRONÓSTICO A 7 DÍAS
//  Muestra la evolución diaria con un diseño de tarjetas moderno.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import 'weather_chart.dart';

class WeeklyView extends StatelessWidget {
  final String locationName;
  final List<DailyWeather> dailyData;

  const WeeklyView({
    super.key,
    required this.locationName,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
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
                if (dailyData.isNotEmpty)
                  Expanded(child: WeeklyWeatherChart(dailyData: dailyData)),
              ],
            ),
          ),
          const VerticalDivider(color: Colors.white24, width: 1),
          // Parte derecha: Lista detallada
          Expanded(
            flex: 2,
            child: _buildDailyList(dailyData),
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
        
        // --- SECCIÓN DEL GRÁFICO SEMANAL ---
        if (dailyData.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _LegendItem(color: Colors.orangeAccent, label: "Max"),
                SizedBox(width: 12),
                _LegendItem(color: Colors.lightBlueAccent, label: "Min"),
              ],
            ),
          ),
          WeeklyWeatherChart(dailyData: dailyData),
        ],

        const Divider(color: Colors.white24, indent: 20, endIndent: 20),
        
        if (dailyData.isEmpty)
          const Expanded(child: Center(child: Text("No data available")))
        else
          Expanded(child: _buildDailyList(dailyData)),
      ],
    );
  }

  Widget _buildDailyList(List<DailyWeather> dailyData) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dailyData.length,
      itemBuilder: (context, index) {
        final day = dailyData[index];
        final isToday = index == 0;

        return Card(
          color: Colors.white.withValues(alpha: 0.05),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Fecha y Día.
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? "Today" : DateFormat('EEEE').format(day.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.blueAccent : Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(day.date),
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                // Icono y Clima.
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Icon(WeatherData.getWeatherIcon(day.weatherCode), color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          WeatherData.getWeatherDescription(day.weatherCode),
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Máxima y Mínima.
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${day.maxTemp.toInt()}°C",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
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
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
      ],
    );
  }
}

