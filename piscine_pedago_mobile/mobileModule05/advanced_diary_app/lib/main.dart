// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: PUNTO DE ENTRADA
//  En este módulo avanzado, integramos Firebase para crear un diario personal
//  completo con autenticación, persistencia en la nube y vistas detalladas.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized() es obligatorio cuando realizamos
  // operaciones asíncronas (como inicializar Firebase) antes de llamar a runApp.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos la conexión con el servidor de Firebase usando los archivos
  // de configuración nativos (google-services.json en Android).
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

/// [MyApp] es la raíz de nuestra aplicación.
/// Aquí definimos el tema visual global y la navegación inicial.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diary App',
      // Definimos un tema moderno basado en Material 3.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // AuthWrapper se encarga de decidir si mostramos el Login o el Home.
      home: const AuthWrapper(),
    );
  }
}

/// [AuthWrapper] es un Widget "guardián" de la autenticación.
/// Utiliza un StreamBuilder para reaccionar en tiempo real a los cambios de estado
/// (inicio de sesión, cierre de sesión o errores).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escuchamos el flujo de eventos de Firebase Auth.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Estado de Carga: Mientras Firebase nos responde.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // 2. Usuario Autenticado: Si snapshot.hasData es verdadero, hay un User.
        if (snapshot.hasData) {
          return const HomePage();
        }
        
        // 3. Usuario NO Autenticado: Si no hay datos, enviamos al Login.
        return const LoginPage();
      },
    );
  }
}
