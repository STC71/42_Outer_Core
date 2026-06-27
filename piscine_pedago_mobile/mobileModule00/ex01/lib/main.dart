// =============================================================================
//  PISCINE MOBILE - MÓDULO 00: EL CAMBIO DE ESTADO (ex01)
//  En este ejercicio aprendemos lo más importante de Flutter:
//  ¿Cómo hacemos que la pantalla cambie cuando el usuario interactúa?
// =============================================================================

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Nuestra aplicación principal. Sigue siendo un StatelessWidget (el chasis).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: Scaffold(
        // El cuerpo de nuestra pantalla será un widget que SÍ puede cambiar.
        body: const MyStatefulWidget(),
      ),
    );
  }
}

// 'MyStatefulWidget' es como un cuaderno que puede ser escrito y borrado.
// Se compone de dos partes: el widget y su "Estado" (su memoria).
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  // Esta línea crea la conexión con la memoria (el Estado).
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

// Esta es la clase de "Estado". Aquí es donde vive la memoria de la pantalla.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // 'bool _isHello' es nuestra variable de memoria.
  // Es como un interruptor: puede estar en 'true' (encendido) o 'false' (apagado).
  bool _isHello = false;

  // Esta función es el "cerebro" que decide qué pasa al pulsar el botón.
  void _toggleText() {
    // 'setState' es la palabra más importante aquí.
    // Imagina que es como gritarle al pintor: "¡Oye, he cambiado de idea, vuelve a pintar!"
    // Sin setState, la memoria cambiaría pero la pantalla seguiría igual (congelada).
    setState(() {
      // Usamos el símbolo '!' para decir "lo contrario".
      // Si era false, pasa a true. Si era true, pasa a false.
      _isHello = !_isHello;
    });

    // Seguimos imprimiendo en la consola para los programadores.
    debugPrint("Button pressed");
  }

  @override
  Widget build(BuildContext context) {
    // 'Center' coloca todo en el centro, como el corazón en el pecho.
    return Center(
      // 'Column' pone los elementos en fila vertical (uno arriba, otro abajo).
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Este texto es "inteligente". Decide qué decir mirando la variable '_isHello'.
          // Es como una pregunta: ¿_isHello es verdad? 
          // SI -> "Hello World!" / NO -> "A simple text"
          Text(
            _isHello ? "Hello World!" : "A simple text",
            style: const TextStyle(fontSize: 24),
          ),
          
          // Un espacio de 20 píxeles, como un respiro entre el texto y el botón.
          const SizedBox(height: 20),
          
          // El botón que el usuario puede tocar.
          ElevatedButton(
            // Al tocarlo, llamamos a la función '_toggleText' que tiene el 'setState'.
            onPressed: _toggleText,
            child: const Text("Click me"),
          ),
        ],
      ),
    );
  }
}
