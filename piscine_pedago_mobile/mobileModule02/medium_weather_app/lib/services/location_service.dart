// =============================================================================
//  SERVICIO DE LOCALIZACIÓN: EL EXPERTO EN GPS
//  Este archivo se encarga de hablar con los satélites y el móvil para 
//  saber exactamente en qué parte del mundo está el usuario.
// =============================================================================

// Importamos 'geolocator', que es como la antena de nuestra app.
import 'package:geolocator/geolocator.dart';

class LocationService {
  
  // 'Future<Position?>' significa que esta función es como un "encargo".
  // Lleva tiempo obtener la posición, así que el programa esperará a que el satélite responda.
  // 'Position' es un objeto que guarda Latitud y Longitud.
  Future<Position?> getCurrentLocation() async {
    
    // 1. Primero, preguntamos si el GPS del móvil está encendido.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si está apagado, lanzamos un aviso para que el usuario lo encienda.
      throw 'Los servicios de ubicación están desactivados en tu móvil.';
    }

    // 2. Preguntamos si el usuario nos ha dado permiso para usar el GPS.
    // Es por seguridad, las apps no pueden espiarte sin permiso.
    LocationPermission permission = await Geolocator.checkPermission();
    
    // Si el permiso ha sido denegado...
    if (permission == LocationPermission.denied) {
      // ...le pedimos permiso amablemente al usuario con una ventanita.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si sigue diciendo que no, no podemos hacer nada.
        throw 'Permiso de ubicación denegado por el usuario.';
      }
    }

    // Si el usuario bloqueó los permisos para siempre en los ajustes...
    if (permission == LocationPermission.deniedForever) {
      throw 'Permiso de ubicación bloqueado permanentemente en ajustes.';
    }

    // 3. Si los permisos son correctos, pedimos la posición.
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }
}
