// =============================================================================
//  PISCINE MOBILE - MÓDULO 04: PROYECTO FINAL - DIARY APP
//  Punto de entrada principal de la aplicación.
//  Aquí configuramos la inicialización de Firebase y el flujo de autenticación.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'profile_page.dart';

void main() async {
  // Aseguramos que los bindings de Flutter estén listos antes de inicializar Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase con la configuración nativa (google-services.json).
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diary App',
      theme: ThemeData(
        // Usamos Material 3 con un color semilla púrpura profundo.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // El "home" es el AuthWrapper, que decide qué pantalla mostrar.
      home: const AuthWrapper(),
    );
  }
}

/// [AuthWrapper] escucha los cambios en el estado de autenticación de Firebase.
/// Si hay un usuario logueado, muestra el [ProfilePage], de lo contrario, [LoginPage].
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // FirebaseAuth.instance.authStateChanges() emite un nuevo evento cada vez
      // que el usuario entra o sale de la aplicación.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras esperamos la primera respuesta de Firebase, mostramos un cargador.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Si el snapshot tiene datos (un objeto User), el usuario está autenticado.
        if (snapshot.hasData) {
          return const ProfilePage();
        }
        
        // Si no hay datos, redirigimos a la pantalla de inicio de sesión.
        return const LoginPage();
      },
    );
  }
}
