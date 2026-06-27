// =============================================================================
//  PISCINE MOBILE - MÓDULO 01: WEATHER APP (Nivel Inicial)
//  Este código crea la base de una aplicación de clima profesional. 
//  Aprenderemos a navegar entre pestañas y a usar un buscador de ciudades.
// =============================================================================

// 'import' es como ir a una biblioteca y coger un libro de herramientas.
// Aquí traemos 'material.dart', que tiene todas las piezas para construir apps.
import 'package:flutter/material.dart';

// 'void main' es el "interruptor general". Al pulsar "Play" en el ordenador,
// el móvil busca esta función para saber por dónde empezar.
void main() {
  // 'runApp' le dice al móvil: "Arranca y dibuja mi aplicación (MyApp)".
  runApp(const MyApp());
}

// 'MyApp' es el plano maestro de nuestra aplicación.
// Usamos 'StatelessWidget' porque la configuración general (nombre, tema) es fija.
// Imagina que es el chasis de un coche: no cambia mientras conduces.
class MyApp extends StatelessWidget {
  // El constructor 'const MyApp' es el DNI único de esta pieza.
  // 'super.key' ayuda a Flutter a saber dónde está el widget en el árbol visual.
  const MyApp({super.key});

  @override
  // 'Widget build' es el pincel. Cada vez que Flutter necesita dibujar la app,
  // llama a esta función para saber qué colores y formas usar.
  Widget build(BuildContext context) {
    // 'MaterialApp' es el motor de diseño. Configura cosas globales.
    return MaterialApp(
      title: 'Weather App',
      // Quitamos la banda roja de "DEBUG" para que parezca una app real.
      debugShowCheckedModeBanner: false,
      
      // 'theme' define el "look" de la app. Elegimos colores oscuros (Dark).
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        // Un color azul muy oscuro para el fondo, como el cielo profundo.
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      
      // 'home' es la primera pantalla que se abre al entrar.
      home: const WeatherHomeScreen(),
    );
  }
}

// 'WeatherHomeScreen' es un 'StatefulWidget' porque tiene MEMORIA.
// Necesita recordar en qué pestaña estamos y qué ciudad hemos escrito.
class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  // Esta línea conecta el widget con su "cerebro" o memoria (el Estado).
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

// Aquí vive la "memoria" y la lógica de nuestra pantalla principal.
class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  
  // === NUESTRA MEMORIA (EL ESTADO) ===
  
  // '_currentIndex' guarda qué botón de abajo está pulsado: 
  // 0 = "Ahora", 1 = "Hoy", 2 = "Semana". Como los canales de la tele.
  int _currentIndex = 0; 

  // El controlador para que el PageView (gestos) y el BottomBar (botones) vayan a la vez.
  final PageController _pageController = PageController();

  // '_searchText' guarda el nombre de la ciudad que el usuario escribe.
  String _searchText = "";
  
  // '_isGeolocation' es un interruptor (true/false) para el modo GPS.
  bool _isGeolocation = false;

  // Listas con los nombres e iconos de los botones de abajo.
  final List<String> _tabNames = ["Currently", "Today", "Weekly"];
  final List<IconData> _tabIcons = [
    Icons.sunny,          // Icono de sol para el tiempo de ahora.
    Icons.today,          // Icono de hoy para el pronóstico de 24h.
    Icons.calendar_month, // Icono de calendario para la semana.
  ];

  @override
  void dispose() {
    // Es buena práctica "apagar" el controlador cuando ya no se usa.
    _pageController.dispose();
    super.dispose();
  }

  // Función que se activa cuando el usuario escribe algo y pulsa "Enter".
  void _onSearchSubmitted(String value) {
    // 'setState' es fundamental: avisa a Flutter de que algo ha cambiado 
    // en la memoria y que debe volver a dibujar la pantalla AHORA.
    setState(() {
      // Guardamos el texto sin espacios vacíos al principio o final (.trim).
      _searchText = value.trim();
      // Si el usuario escribe una ciudad, apagamos el modo GPS.
      _isGeolocation = false; 
    });
  }

  // Función que se activa al pulsar el botón del GPS.
  void _onGeolocationPressed() {
    setState(() {
      // Encendemos el interruptor del GPS.
      _isGeolocation = true;
      // Al usar GPS, borramos cualquier ciudad escrita anteriormente.
      _searchText = ""; 
    });
  }

  // Una regla lógica para decidir qué texto mostrar en la franja azul de arriba.
  String _getDisplayText() {
    if (_isGeolocation) {
      return "Geolocation"; // Si el GPS está puesto, decimos que usamos GPS.
    } else if (_searchText.isNotEmpty) {
      return _searchText;   // Si hay ciudad, mostramos el nombre de la ciudad.
    }
    return ""; // Si no hay nada, no mostramos texto extra.
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el texto informativo antes de empezar a dibujar las piezas.
    final displayText = _getDisplayText();

    // 'Scaffold' es el lienzo en blanco que organiza las partes de la pantalla.
    return Scaffold(
      // ==================== BARRA SUPERIOR (App Bar) ====================
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0, // Quitamos la sombra para un diseño más plano y moderno.
        
        // El 'title' aquí es un buscador personalizado.
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1), // Un blanco muy transparente.
            borderRadius: BorderRadius.circular(12),
          ),
          // 'TextField' es el cuadro donde sale el teclado para escribir.
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search location...", // El texto que te guía.
              hintStyle: TextStyle(color: Colors.white60),
              prefixIcon: Icon(Icons.search, color: Colors.white60), // Lupa.
              border: InputBorder.none, // Quitamos el borde por defecto.
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            // Cuando pulsas "Buscar" en el teclado, llamamos a la función de arriba.
            onSubmitted: _onSearchSubmitted,
          ),
        ),
        
        // 'actions' son botones extra a la derecha de la barra superior.
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location), // Icono de mirilla / GPS.
            onPressed: _onGeolocationPressed,
          ),
        ],
      ),

      // ==================== CUERPO CENTRAL (Body) ====================
      // 'SafeArea' protege el contenido de los bordes físicos del móvil (cámaras, etc).
      body: SafeArea(
        child: Column(
          children: [
            // SI hay un lugar elegido (ciudad o GPS), mostramos la franja azul.
            if (displayText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue.withValues(alpha: 0.2), // Un azul muy suave.
                child: Text(
                  // Combinamos: Pestaña actual + Lugar elegido.
                  "${_tabNames[_currentIndex]} - $displayText",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            // 'Expanded' hace que este espacio crezca para ocupar todo el centro.
            // Usamos 'PageView' para permitir cambiar de pestaña deslizando el dedo.
            Expanded(
              child: PageView(
                controller: _pageController,
                // Cuando el usuario desliza el dedo, actualizamos el índice.
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  Center(child: Text(_tabNames[0], style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold))),
                  Center(child: Text(_tabNames[1], style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold))),
                  Center(child: Text(_tabNames[2], style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ],
        ),
      ),

      // ==================== BARRA DE NAVEGACIÓN (Bottom Bar) ====================
      // El menú inferior de 3 botones para cambiar de vista.
      bottomNavigationBar: BottomNavigationBar(
        // Indicamos qué botón está resaltado en azul.
        currentIndex: _currentIndex,
        // Cuando tocas un botón, actualizamos el índice y movemos el PageView.
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: const Color(0xFF0A0E21),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        
        // Creamos los 3 botones leyendo nuestras listas de nombres e iconos.
        items: List.generate(3, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_tabIcons[index]),
            label: _tabNames[index],
          );
        }),
      ),
    );
  }
}
