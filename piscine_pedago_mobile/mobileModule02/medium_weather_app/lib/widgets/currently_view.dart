// =============================================================================
//  VISTA ACTUAL: ¿Qué tiempo hace ahora mismo?
//  Este pequeño componente (widget) solo se encarga de mostrar los datos de hoy.
// =============================================================================

import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class CurrentlyView extends StatelessWidget {
  // Los datos que este widget necesita para funcionar.
  final String locationName;       // El nombre de la ciudad.
  final CurrentWeather? current;   // Los datos del tiempo (temperatura, etc).
  final String? description;      // "Soleado", "Nublado", etc.

  // Constructor: Le pasamos los datos al crear el widget.
  const CurrentlyView({
    super.key,
    required this.locationName,
    this.current,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Todo centrado en vertical.
      children: [
        // Nombre de la ubicación en letra mediana.
        Text(locationName, 
            style: const TextStyle(fontSize: 24), 
            textAlign: TextAlign.center),
            
        // Si tenemos datos del tiempo, los mostramos.
        if (current != null) ...[
          // Temperatura en tamaño gigante (72). 'toStringAsFixed(1)' quita decimales extra.
          Text("${current!.temperature.toStringAsFixed(1)}°C", 
              style: const TextStyle(fontSize: 72)),
          
          // Descripción del cielo (Ej: Lluvia moderada).
          if (description != null) 
            Text(description!, style: const TextStyle(fontSize: 22)),
            
          // Velocidad del viento.
          Text("Wind speed: ${current!.windSpeed.toStringAsFixed(1)} km/h"),
        ],
      ],
    );
  }
}
