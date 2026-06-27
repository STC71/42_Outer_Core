// =============================================================================
//  SERVICIO DE LOCALIZACIÓN: GESTIÓN DE GPS Y PERMISOS
//  Este archivo centraliza el acceso al hardware de ubicación del dispositivo.
// =============================================================================

import 'package:geolocator/geolocator.dart';

class LocationService {
  
  // Obtiene la posición actual del usuario manejando todos los estados de permisos.
  Future<Position?> getCurrentLocation() async {
    
    // Verificamos si el hardware del GPS está activo.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable GPS.';
    }

    // Comprobamos los permisos de la aplicación.
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Solicitamos permiso si aún no ha sido concedido.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // El usuario bloqueó los permisos permanentemente en ajustes.
      throw 'Location permissions are permanently denied.';
    }

    // Obtenemos la posición con precisión media para optimizar batería.
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
    );
    
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }
}
