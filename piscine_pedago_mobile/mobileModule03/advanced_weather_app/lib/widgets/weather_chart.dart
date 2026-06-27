// =============================================================================
//  WIDGETS DE GRÁFICOS: VISUALIZACIÓN DE TENDENCIAS TÉRMICAS
//  Usa la librería 'fl_chart' para mostrar la evolución de la temperatura.
//  Incluye gráficos para la vista horaria y semanal.
// =============================================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';

/// Gráfico lineal para la temperatura horaria (próximas 24h).
/// Muestra una única línea con la evolución de la temperatura hora a hora.
class HourlyWeatherChart extends StatelessWidget {
  final List<HourlyWeather> hourlyData;

  const HourlyWeatherChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    // Tomamos solo las primeras 24 entradas para el gráfico de "Hoy".
    final next24Hours = hourlyData.take(24).toList();
    if (next24Hours.isEmpty) return const SizedBox.shrink();

    // Calculamos extremos para ajustar la escala del eje Y automáticamente.
    double minTemp = next24Hours.map((h) => h.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = next24Hours.map((h) => h.temperature).reduce((a, b) => a > b ? a : b);

    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      // En horizontal el gráfico expande para ocupar el espacio; en vertical tiene altura fija.
      height: isLandscape ? null : 180,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              // Generamos los puntos (Spots) a partir de los datos horarios.
              spots: next24Hours.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.temperature);
              }).toList(),
              isCurved: true, // Suavizado de la línea (curva de Bézier).
              color: Colors.blueAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false), // No mostramos puntos para un look más limpio.
              // Sombreado degradado bajo la línea.
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: 0.3),
                    Colors.blueAccent.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4, // Etiqueta de tiempo cada 4 horas.
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < next24Hours.length) {
                    return Text(
                      DateFormat('HH:00').format(next24Hours[index].time),
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          minY: minTemp - 2, // Margen de seguridad inferior.
          maxY: maxTemp + 2, // Margen de seguridad superior.
        ),
      ),
    );
  }
}

/// Gráfico lineal para temperaturas máximas y mínimas semanales.
/// Muestra dos líneas (naranja para máximas, azul para mínimas) con etiquetas dd/MM.
class WeeklyWeatherChart extends StatelessWidget {
  final List<DailyWeather> dailyData;

  const WeeklyWeatherChart({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) return const SizedBox.shrink();

    // Determinamos el rango térmico semanal para la escala vertical.
    double minTemp = dailyData.map((d) => d.minTemp).reduce((a, b) => a < b ? a : b);
    double maxTemp = dailyData.map((d) => d.maxTemp).reduce((a, b) => a > b ? a : b);

    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape ? null : 180,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            // LÍNEA DE MÁXIMAS (Orange)
            LineChartBarData(
              spots: dailyData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.maxTemp);
              }).toList(),
              isCurved: true,
              color: Colors.orangeAccent,
              barWidth: 3,
              dotData: const FlDotData(show: true), // Puntos visibles para resaltar cada día.
            ),
            // LÍNEA DE MÍNIMAS (Light Blue)
            LineChartBarData(
              spots: dailyData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.minTemp);
              }).toList(),
              isCurved: true,
              color: Colors.lightBlueAccent,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Garantiza una etiqueta por cada día (0, 1, 2...), sin repeticiones.
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  // Verificamos que el valor sea exacto para evitar etiquetas fantasma entre puntos.
                  if (value == index.toDouble() && index >= 0 && index < dailyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('dd/MM').format(dailyData[index].date),
                        style: const TextStyle(color: Colors.white60, fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (dailyData.length - 1).toDouble(),
          minY: minTemp - 5,
          maxY: maxTemp + 5,
        ),
      ),
    );
  }
}
