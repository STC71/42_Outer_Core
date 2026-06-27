// =============================================================================
//  PISCINE MOBILE - MÓDULO 04: LOGIN PAGE
//  Pantalla de bienvenida y acceso mediante Google Sign-In.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  /// Maneja el proceso de autenticación con Google.
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 1. Iniciamos el flujo de Google Sign-In.
      // El serverClientId es necesario para la validación en el backend de Firebase.
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        serverClientId: '808282081575-d0298oj4cfq04e86jbld54o2o5n3bafm.apps.googleusercontent.com',
      ).signIn();

      // Si el usuario cancela el diálogo de selección de cuenta, salimos.
      if (googleUser == null) return;

      // 2. Obtenemos los detalles de autenticación de la cuenta de Google.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Creamos una credencial para que Firebase la reconozca.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciamos sesión en Firebase con la credencial obtenida.
      // Una vez hecho esto, el AuthWrapper de main.dart detectará el cambio automáticamente.
      await FirebaseAuth.instance.signInWithCredential(credential);
      
    } catch (e) {
      // Gestión de errores básica para informar al usuario si algo falla.
      debugPrint("Error signing in with Google: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: $e')),
        );
      }
    }
  }

  /// Maneja el proceso de autenticación con GitHub.
  /// A diferencia de Google, GitHub utiliza el flujo de OAuthProvider genérico de Firebase.
  Future<void> _signInWithGitHub(BuildContext context) async {
    try {
      // 1. Creamos una instancia del proveedor de GitHub.
      final GithubAuthProvider githubProvider = GithubAuthProvider();

      // 2. Iniciamos el flujo de autenticación.
      // Esto abrirá una pestaña del navegador o una ventana emergente para que
      // el usuario autorice la aplicación en su cuenta de GitHub.
      // Firebase se encarga de gestionar el intercambio de códigos y tokens.
      await FirebaseAuth.instance.signInWithProvider(githubProvider);

    } catch (e) {
      // Gestión de errores para GitHub.
      debugPrint("Error signing in with GitHub: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión con GitHub: $e')),
        );
      }
    }
  }

  @override

  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario Personal'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: orientation == Orientation.portrait
                ? _buildPortraitLayout(context)
                : _buildLandscapeLayout(context),
          ),
        ),
      ),
    );
  }

  /// Diseño optimizado para vertical (clásico).
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_stories, size: 120, color: Colors.deepPurple),
        const SizedBox(height: 30),
        const Text(
          'Bienvenido a tu Diario',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Guarda tus recuerdos de forma segura en la nube.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 50),
        _buildLoginButton(context),
        const SizedBox(height: 12),
        _buildGitHubButton(context),
      ],
    );
  }

  /// Diseño optimizado para horizontal (en paralelo).
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Lado izquierdo: Icono un poco más pequeño.
        const Expanded(
          flex: 1,
          child: Icon(Icons.auto_stories, size: 100, color: Colors.deepPurple),
        ),
        const SizedBox(width: 20),
        // Lado derecho: Texto y botón.
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Bienvenido a tu Diario',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Guarda tus recuerdos en la nube.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildLoginButton(context),
              const SizedBox(height: 12),
              _buildGitHubButton(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Botón de Google extraído para evitar duplicidad.
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: 320, // Ancho fijo para evitar que se estire demasiado en horizontal.
      child: ElevatedButton.icon(
        onPressed: () => _signInWithGoogle(context),
        icon: const Icon(Icons.login),
        label: const Text('Entrar con Google'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 55), // Ya no necesitamos double.infinity aquí.
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Botón estilizado para el inicio de sesión con GitHub.
  Widget _buildGitHubButton(BuildContext context) {
    return SizedBox(
      width: 320, // Mantenemos la consistencia de ancho entre ambos botones.
      child: ElevatedButton.icon(
        onPressed: () => _signInWithGitHub(context),
        icon: const Icon(Icons.code),
        label: const Text('Entrar con GitHub'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 55),
          backgroundColor: const Color(0xFF24292F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
