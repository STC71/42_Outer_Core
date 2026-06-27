// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: LOGIN PAGE
//  Pantalla de acceso que soporta Google y GitHub.
//  Incluye diseño responsivo para Portrait (Vertical) y Landscape (Horizontal).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  /// Método para autenticar al usuario mediante su cuenta de Google.
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Iniciamos el flujo visual de selección de cuenta de Google.
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        // Identificador del cliente necesario para entornos Android.
        serverClientId: '808282081575-d0298oj4cfq04e86jbld54o2o5n3bafm.apps.googleusercontent.com',
      ).signIn();

      // Si el usuario cancela la selección, salimos.
      if (googleUser == null) return;

      // Obtenemos los tokens de autenticación de la cuenta seleccionada.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Creamos la credencial que Firebase entiende a partir de los tokens de Google.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Enviamos la credencial a Firebase Auth para iniciar la sesión.
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error Google Sign-In: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al entrar con Google: $e')),
        );
      }
    }
  }

  /// Método para autenticar al usuario mediante GitHub.
  Future<void> _signInWithGitHub(BuildContext context) async {
    try {
      // GitHubAuthProvider abre un WebView para que el usuario se loguee en GitHub.
      await FirebaseAuth.instance.signInWithProvider(GithubAuthProvider());
    } catch (e) {
      debugPrint("Error GitHub Sign-In: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al entrar con GitHub: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos la orientación del dispositivo para adaptar la UI.
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
            // Decidimos qué layout mostrar según la orientación.
            child: orientation == Orientation.portrait
                ? _buildPortraitLayout(context)
                : _buildLandscapeLayout(context),
          ),
        ),
      ),
    );
  }

  /// Interfaz diseñada para cuando el móvil está en VERTICAL.
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_stories, size: 120, color: Colors.deepPurple),
        const SizedBox(height: 30),
        const Text(
          'Bienvenido a tu Diario',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Guarda tus recuerdos de forma segura en la nube.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 50),
        _buildGoogleButton(context),
        const SizedBox(height: 12),
        _buildGitHubButton(context),
      ],
    );
  }

  /// Interfaz diseñada para cuando el móvil está en HORIZONTAL (Landscape).
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          flex: 1,
          child: Icon(Icons.auto_stories, size: 100, color: Colors.deepPurple),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bienvenido a tu Diario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tus recuerdos, siempre contigo.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildGoogleButton(context),
              const SizedBox(height: 12),
              _buildGitHubButton(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Botón personalizado para el inicio de sesión con Google.
  Widget _buildGoogleButton(BuildContext context) {
    return SizedBox(
      width: 320,
      child: ElevatedButton.icon(
        onPressed: () => _signInWithGoogle(context),
        icon: const Icon(Icons.login),
        label: const Text('Entrar con Google'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 55),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// Botón personalizado para el inicio de sesión con GitHub.
  Widget _buildGitHubButton(BuildContext context) {
    return SizedBox(
      width: 320,
      child: ElevatedButton.icon(
        onPressed: () => _signInWithGitHub(context),
        icon: const Icon(Icons.code),
        label: const Text('Entrar con GitHub'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 55),
          backgroundColor: const Color(0xFF24292F), // Color oficial de GitHub
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
