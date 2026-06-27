// =============================================================================
//  PISCINE MOBILE - MÓDULO 00: EL COMIENZO (ex00)
//  Este código crea nuestra primera aplicación: un texto y un botón.
//  Es la base de todo lo que vendrá después.
// =============================================================================

// 'import' nos permite traer herramientas de otros lugares.
// Aquí traemos 'material.dart', que contiene las piezas de construcción de Google.
import 'package:flutter/material.dart';

// 'void main' es el punto de entrada, el "botón de encendido" de la app.
void main() {
  // 'runApp' le dice al móvil: "Dibuja esto que te mando (MyApp)".
  runApp(const MyApp());
}

// 'class MyApp' es el contenedor principal de nuestra aplicación.
// 'extends StatelessWidget' significa que esta parte de la app es como un cuadro:
// una vez que se dibuja, no cambia por sí sola.
class MyApp extends StatelessWidget {
  // El constructor 'const MyApp' es el "carné de identidad" de la clase.
  // 'super.key' sirve para que Flutter sepa dónde está este widget en la pantalla.
  const MyApp({super.key});

  @override
  // '@override' indica que vamos a personalizar cómo se construye este widget.
  // 'Widget build' es la función que realmente "pinta" la pantalla.
  Widget build(BuildContext context) {
    // 'MaterialApp' es el armazón de la casa. Aquí definimos el estilo general.
    return MaterialApp(
      title: 'ex00 - Basic Display',
      // 'debugShowCheckedModeBanner: false' quita la etiqueta "Debug" de la esquina.
      debugShowCheckedModeBanner: false,
      
      // 'theme' es como elegir la decoración de nuestra casa (colores, fuentes...).
      theme: ThemeData(
        useMaterial3: true, // Usamos la versión más moderna del diseño de Google.
      ),
      
      // 'home' indica cuál es la primera habitación que vemos al entrar en la casa.
      home: const MyHomePage(),
    );
  }
}

// 'MyHomePage' es la pantalla real que vamos a ver.
// Aunque es un 'StatefulWidget' (un widget que puede recordar cosas),
// en este primer ejercicio todavía no vamos a cambiar nada en pantalla.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Aquí es donde vive la lógica y el diseño de nuestra pantalla.
class _MyHomePageState extends State<MyHomePage> {
  // Una variable de texto simple para mostrar en pantalla.
  String displayText = "A simple text";

  // Esta función es la que se activa cuando alguien pulsa el botón.
  void _onButtonPressed() {
    // 'debugPrint' escribe un mensaje en la consola del programador (abajo en el PC).
    // Es como dejar una nota en un diario para saber que el botón funciona.
    // OJO: En este ejercicio, el texto de la pantalla NO cambiará.
    debugPrint("Button pressed");
  }

  @override
  Widget build(BuildContext context) {
    // 'Scaffold' es el lienzo en blanco. Nos da la estructura básica de una pantalla.
    return Scaffold(
      backgroundColor: Colors.white, // Fondo de color blanco, limpio.

      // 'Center' es como un imán que coloca todo justo en el medio.
      body: Center(
        // 'Column' apila las cosas una debajo de otra, como los pisos de un edificio.
        child: Column(
          // Centramos los "pisos" del edificio verticalmente.
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            // El primer elemento: Un contenedor que guarda el texto.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              // 'BoxDecoration' es como el marco de un cuadro.
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A), // Un color verde suave.
                borderRadius: BorderRadius.circular(8), // Bordes redondeados.
              ),
              child: Text(
                displayText,
                style: const TextStyle(
                  color: Colors.black, // Texto en color negro.
                  fontSize: 18,
                  fontWeight: FontWeight.bold, // Texto en negrita.
                ),
              ),
            ),

            // 'SizedBox' es un espacio invisible, como un escalón, para separar cosas.
            const SizedBox(height: 30),

            // El segundo elemento: Un botón.
            ElevatedButton(
              // Al pulsar (onPressed), ejecutamos la función que definimos arriba.
              onPressed: _onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A), // Botón también verde.
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Press me"),
            ),
          ],
        ),
      ),
    );
  }
}
