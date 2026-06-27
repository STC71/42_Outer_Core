// ================================================
//  calculator_app  - main.dart
// ================================================

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // Paquete exterior para calcular expresiones matemáticas

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "0"; // Quitamos 'final' porque vamos a modificar esta variable a medida que se teclea
  String _result = "0";     // Quitamos 'final' porque evaluaremos el resultado final aquí

  // Función principal que maneja los clics de cada uno de los botones
  void _onButtonPressed(String value) {
    debugPrint("button pressed: $value");  // Imprimimos el valor siempre en la consola

    // El estado de la aplicación cambia con cada clic, repintando el árbol de la UI
    setState(() {
      // 1. Si se pulsa botón "AC" (All Clear), reiniciamos expresión y resultado a "0"
      if (value == "AC") {
        _expression = "0";
        _result = "0";
      } 
      // 2. Si se pulsa el botón "C" (Clear character), borramos el último caracter puesto
      else if (value == "C") {
        if (_expression.length > 1) { // Si hay varios números en pantalla, simplemente quitamos el último
          _expression = _expression.substring(0, _expression.length - 1);
        } else {
          // Si solo quedaba 1 número aisado en pantalla al borrarlo, dejamos un "0"
          _expression = "0";
        }
      } 
      // 3. Si se le da la instrucción de calcular total "=" se llama al método encargado de calcularlo
      else if (value == "=") {
        _evaluateExpression();
      } 
      // 4. Se ha tecleado un punto ".", un número cualquiera, un operador matemático
      else {
        // En caso de que el valor inicial sea un triste 0 por defecto, lo sustituiremos (excepto que traten de adjuntarle un signo de sumar o restar por ejemplo)
        if (_expression == "0" && value != "+" && value != "-" && value != "*" && value != "/" && value != ".") {
          _expression = value;
        } else {
          // En caso rutinario añadiremos todo al texto a ser parseado posteriormente
          _expression += value;
        }
      }
    });
  }

  // Función para transformar el texto _expression en ecuaciones evaluables, calculando y seteando _result
  void _evaluateExpression() {
    try {
      // Usamos el paquete math_expressions para quitarnos complejidad.
      // Creamos un Parser que es el que se encarga de analizar nuestro texto (ex "4+4") y convertirlo.
      GrammarParser p = GrammarParser();

      Expression exp = p.parse(_expression); // Devuelve una clase Expresión de math_expressions.

      // ContextBuilder por defecto sin variables avanzadas.
      ContextModel cm = ContextModel();
      
      // Lo evaluamos retornando un número con decimales de doble presición (double).
      var eval = RealEvaluator(cm);
      double evalResult = eval.evaluate(exp).toDouble();  // Convertimos a double para que siempre tenga decimales aunque sean .0
      _result = evalResult.toString();                    // Lo convertimos a texto para mostrarlo en pantalla

      /*
      // Si el número es completamente exacto con 0 decimales reales (ex 5.0).
      if (eval % 1 == 0) {
        // Lo mandaremos como int para quitarnos el ".0" de visual y sea una app con calidad pulida, todo en tipado texto final.
        _result = eval.toInt().toString(); 
      } else {
        // Si hay decimales reales que sí aportan (ej. 3.5), se deja normal
        _result = eval.toString();
      }
      */

    } catch (e) {
      // En caso de que pusiéramos 5 + - o una invalidación humana el compilador daría crash, esto nos salva sacando "Error" en _result por pantalla.
      _result = "Error";
    }
  }

  // Widget para crear botones de forma consistente
  Widget _buildButton(String text, 
                     {Color? color, 
                      Color textColor = Colors.white, 
                      int flex = 1,
                      bool isLandscape = false}) {
    // Si el texto está vacío, renderizamos un espacio en blanco para cuadrar la cuadrícula
    if (text.isEmpty) {
      return Expanded(flex: flex, child: const SizedBox.shrink());
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(isLandscape ? 2.0 : 6.0), // Menos padding (separación) en horizontal
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF2A2A2A),
            foregroundColor: textColor,
            minimumSize: const Size(0, 0), // Previene overflow en pantallas horizontal
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero, // Eliminado padding fijo para que sea responsive (ocupa el máximo que le permite Expanded)
            elevation: 3,
          ),
          onPressed: () => _onButtonPressed(text),
          child: Text(
            text,
            style: TextStyle(
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
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calculator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // === PANTALLA (Expression + Result) ===
            Expanded(
              flex: 1, // En landscape damos la misma proporción que al teclado para no cortar texto
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1E1E1E),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // Para que el texto que exceda se oculte por la izquierda como en calculadoras reales
                      child: Text(
                        _expression,
                        style: TextStyle(fontSize: isLandscape ? 20 : 28, color: Colors.white70),
                      ),
                    ),
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

            // === TECLADO ===
            Expanded(
              flex: isLandscape ? 2 : 2, // Si es horizontal o vertical le damos flex 2 para botones más altos
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                color: const Color(0xFF121212),
                child: Column(
                  children: [
                    // Fila 1 (Envueltos en Expanded para que se estiren verticalmente y sean full responsive)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch, // ESTO ESTIRA LOS BOTONES VERTICALMENTE
                        children: [
                        _buildButton("AC", color: Colors.redAccent, isLandscape: isLandscape),
                        _buildButton("C", color: Colors.orange, isLandscape: isLandscape),
                        _buildButton("", color: Colors.transparent, isLandscape: isLandscape), // Hueco vacío
                        _buildButton("/", color: Colors.blue, isLandscape: isLandscape),
                      ]),
                    ),
                    // Fila 2
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
                    // Fila 3
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
                    // Fila 4
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
                    // Fila 5 - Botón 0  .  00  =
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        _buildButton("0", isLandscape: isLandscape),
                        _buildButton(".", isLandscape: isLandscape),
                        _buildButton("00", isLandscape: isLandscape),
                        _buildButton("=", color: Colors.green, textColor: Colors.black, isLandscape: isLandscape), // Unico botón =
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