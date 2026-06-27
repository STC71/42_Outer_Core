// =============================================================================
//  EX02 - DISEÑO DE CALCULADORA (Módulo 00 - Piscine Mobile)
//  Este código se centra en crear una interfaz visual (UI) que sea
//  "responsive" (que se adapte bien si giras el móvil).
// =============================================================================

import 'package:flutter/material.dart';

// El punto de partida, como en cualquier aplicación Flutter.
void main() {
  runApp(const MyApp());
}

// Clase principal que configura el estilo visual de toda la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      // Quitamos la banda de "Debug" (depuración).
      debugShowCheckedModeBanner: false,
      
      // Personalizamos el tema visual para que sea oscuro y elegante.
      // '.dark()' nos da la base oscura y '.copyWith' nos permite cambiar colores específicos.
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey,
        // Color de fondo de toda la aplicación (un gris casi negro).
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), 
      ),
      
      // La pantalla de inicio de nuestra calculadora.
      home: const CalculatorScreen(),
    );
  }
}

// Nuestra calculadora tiene memoria (aunque por ahora solo para imprimir en consola).
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Variables que representan lo que vemos en pantalla.
  // En este ejercicio son fijas, en el siguiente ejercicio (ex03) cambiarán.
  final String _expression = "0"; // Lo que estamos escribiendo.
  final String _result = "0";     // El resultado del cálculo.

  // Esta función se activa cuando tocamos un botón.
  void _onButtonPressed(String value) {
    // El 'subject' (instrucciones) pide que cada clic se registre en la consola.
    // Es como el registro de una caja registradora.
    debugPrint("button pressed: $value");
  }

  // Esta es nuestra "fábrica de botones". En lugar de escribir el código de 20 botones,
  // creamos esta función que los fabrica todos iguales siguiendo nuestras reglas.
  Widget _buildButton(String text, 
                     {Color? color, 
                      Color textColor = Colors.white, 
                      int flex = 1,
                      bool isLandscape = false}) {
    
    // Si el texto está vacío, devolvemos un espacio invisible para que la cuadrícula no se descuadre.
    if (text.isEmpty) {
      return Expanded(flex: flex, child: const SizedBox.shrink());
    }

    // 'Expanded' hace que el botón se estire para ocupar el espacio disponible.
    // Como un muelle que empuja para llenar el hueco.
    return Expanded(
      flex: flex,
      child: Padding(
        // Añadimos un poco de separación entre botones.
        // Si el móvil está tumbado (landscape), ponemos menos separación para aprovechar el espacio.
        padding: EdgeInsets.all(isLandscape ? 2.0 : 6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // Si no nos pasan un color, usamos el gris oscuro por defecto.
            backgroundColor: color ?? const Color(0xFF2A2A2A),
            foregroundColor: textColor,
            // Ajustamos el tamaño mínimo a cero para que el botón pueda encogerse 
            // si la pantalla es pequeña (evita el famoso error de las rayas amarillas).
            minimumSize: const Size(0, 0),
            // Bordes redondeados para un aspecto moderno.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
            elevation: 3, // Una pequeña sombra para que parezca que "flota".
          ),
          // Al pulsar, llamamos a la función que imprime en consola.
          onPressed: () => _onButtonPressed(text),
          // El texto que va dentro del botón.
          child: Text(
            text,
            style: TextStyle(
              // Si el móvil está tumbado, hacemos la letra un poco más pequeña.
              fontSize: isLandscape ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 'MediaQuery' es como un sensor: le pregunta al sistema "¿cómo de grande es la pantalla?"
    // e "¿está el móvil tumbado o de pie?".
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calculator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0, // Sin sombra debajo de la barra para que parezca una sola pieza.
      ),
      // 'SafeArea' evita que el contenido se tape con la cámara (notch) o los bordes redondeados del móvil.
      body: SafeArea(
        child: Column(
          children: [
            // === ZONA DE PANTALLA (Donde se ven los números) ===
            Expanded(
              flex: 1, // Esta zona ocupa una parte del espacio vertical.
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1E1E1E),
                alignment: Alignment.bottomRight, // Alineamos los números abajo a la derecha.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 'SingleChildScrollView' permite que si el número es larguísimo,
                    // el usuario pueda deslizarlo con el dedo en lugar de que la app se rompa.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // Empezamos a ver desde la derecha (como una calculadora real).
                      child: Text(
                        _expression,
                        style: TextStyle(fontSize: isLandscape ? 20 : 28, color: Colors.white70),
                      ),
                    ),
                    // Una línea fina para separar la operación del resultado.
                    const Divider(color: Colors.grey, height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: TextStyle(
                          fontSize: isLandscape ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === ZONA DEL TECLADO (Donde están los botones) ===
            Expanded(
              flex: 2, // El teclado ocupa el doble de espacio que la pantalla de números.
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                color: const Color(0xFF121212), // Un fondo un poco más oscuro para el teclado.
                child: Column(
                  children: [
                    // Cada 'Row' es una fila de botones. 
                    // Usamos 'Expanded' en la fila para que todas midan lo mismo de alto.
                    
                    // Fila 1: Botones de limpieza y división.
                    Expanded(
                      child: Row(
                        // 'stretch' obliga a los botones a estirarse para llenar todo el alto de la fila.
                        crossAxisAlignment: CrossAxisAlignment.stretch, 
                        children: [
                        _buildButton("AC", color: Colors.redAccent, isLandscape: isLandscape),
                        _buildButton("C", color: Colors.orange, isLandscape: isLandscape),
                        _buildButton("", color: Colors.transparent, isLandscape: isLandscape), // Hueco vacío para diseño.
                        _buildButton("/", color: Colors.blue, isLandscape: isLandscape),
                      ]),
                    ),
                    
                    // Fila 2: Números 7, 8, 9 y multiplicación.
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        _buildButton("7", isLandscape: isLandscape),
                        _buildButton("8", isLandscape: isLandscape),
                        _buildButton("9", isLandscape: isLandscape),
                        _buildButton("*", color: Colors.blue, isLandscape: isLandscape),
                      ]),
                    ),
                    
                    // Fila 3: Números 4, 5, 6 y resta.
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        _buildButton("4", isLandscape: isLandscape),
                        _buildButton("5", isLandscape: isLandscape),
                        _buildButton("6", isLandscape: isLandscape),
                        _buildButton("-", color: Colors.blue, isLandscape: isLandscape),
                      ]),
                    ),
                    
                    // Fila 4: Números 1, 2, 3 y suma.
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        _buildButton("1", isLandscape: isLandscape),
                        _buildButton("2", isLandscape: isLandscape),
                        _buildButton("3", isLandscape: isLandscape),
                        _buildButton("+", color: Colors.blue, isLandscape: isLandscape),
                      ]),
                    ),
                    
                    // Fila 5: Cero, punto, doble cero e igual.
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        _buildButton("0", isLandscape: isLandscape),
                        _buildButton(".", isLandscape: isLandscape),
                        _buildButton("00", isLandscape: isLandscape),
                        _buildButton("=", color: Colors.green, textColor: Colors.black, isLandscape: isLandscape),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
