// =============================================================================
//  WEATHER HOME: EL CORAZÓN DE NUESTRA APP DE CLIMA
//  Aquí es donde ocurre la magia: buscamos ciudades, usamos el GPS y 
//  mostramos los datos del tiempo reales (o simulados).
// =============================================================================

import 'package:flutter/material.dart';
// Importamos herramientas para saber dónde está el usuario (GPS).
import 'package:geolocator/geolocator.dart';

// Importamos nuestros propios "especialistas" (servicios).
import '../services/weather_service.dart';   // El experto en el tiempo.
import '../services/location_service.dart';  // El experto en mapas y GPS.

// Importamos los dibujos de cada sección.
import '../widgets/currently_view.dart';
import '../widgets/today_view.dart';
import '../widgets/weekly_view.dart';
import '../models/weather_data.dart'; // El formato de los datos.

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  // === ESTADO (LA MEMORIA DE LA PANTALLA) ===
  
  int _currentIndex = 0;           // ¿En qué pestaña estamos?
  late PageController _pageController; // Controla el deslizamiento entre pestañas.
  bool _isLoading = false;         // ¿Estamos esperando datos de internet? (La ruedita girando).
  String _errorMessage = "";       // Por si algo sale mal (ej: sin internet).
  String _locationName = "Unknown Location"; // El nombre del sitio donde estamos.

  // Aquí guardaremos toda la información del tiempo cuando llegue.
  WeatherData? _weatherData;

  // Creamos a nuestros especialistas.
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  // Herramientas para el buscador de ciudades.
  List<dynamic> _suggestions = []; // Lista de ciudades que coinciden con lo que escribimos.
  final TextEditingController _searchController = TextEditingController(); // Controla el texto del buscador.

  // Esta función se ejecuta UNA VEZ al abrir la app.
  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador para el PageView.
    _pageController = PageController(initialPage: _currentIndex);
    // Le decimos al buscador que nos avise cada vez que el usuario escriba algo.
    _searchController.addListener(() => setState(() {}));
    // Nada más empezar, intentamos saber dónde está el usuario.
    _getCurrentLocation();
  }

  @override
  void dispose() {
    // Limpiamos los controladores para liberar memoria.
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN PARA USAR EL GPS ---
  // 'Future<void>' significa que es una tarea que lleva tiempo (como pedir comida).
  // 'async' permite que la app no se congele mientras espera.
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Empezamos a cargar.
      _errorMessage = "";
    });
    try {
      // Le pedimos al especialista de localización la posición actual.
      Position? position = await _locationService.getCurrentLocation();
      if (!mounted) return;

      if (position != null) {
        // Si tenemos la posición, buscamos el tiempo para esas coordenadas.
        await _updateWeather(position.latitude, position.longitude);
        if (!mounted) return;

        // Y también buscamos cómo se llama ese sitio (Ciudad, País).
        String? name = await _weatherService.getCityName(position.latitude, position.longitude);
        if (!context.mounted) return;

        if (name != null) setState(() => _locationName = name);
      }
    } catch (e) {
      // Si hay un error con el GPS (denegado o apagado), informamos.
      if (mounted) {
        setState(() => _errorMessage = "Geolocation is not available. Please check your GPS settings or permissions.");
      }
    } finally {
      // Terminemos bien o mal, ya no estamos cargando.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- FUNCIÓN PARA ACTUALIZAR EL TIEMPO ---
  Future<void> _updateWeather(double lat, double lon) async {
    // Pedimos al experto en clima los datos para esa latitud y longitud.
    final data = await _weatherService.fetchWeather(lat, lon);
    
    if (!mounted) return;

    if (data != null) {
      setState(() {
        _weatherData = data; // Guardamos los datos.
        _errorMessage = "";  // Limpiamos errores anteriores.
      });
    } else {
      setState(() {
        _weatherData = null; // Limpiamos datos viejos si falla la conexión.
        _errorMessage = "Could not connect to the weather service. Please check your internet connection.";
      });
    }
  }

  // --- LÓGICA DEL BUSCADOR ---
  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = "";
      });
      return;
    }
    // Buscamos ciudades que se llamen parecido a lo que el usuario escribe.
    final suggestions = await _weatherService.getSuggestions(query);

    if (!mounted) return;

    setState(() {
      _suggestions = suggestions;
      // Si ha escrito mucho y no sale nada, avisamos que la ciudad es inválida.
      if (query.length >= 3 && suggestions.isEmpty) {
        _errorMessage = "The city name is invalid or does not exist.";
      } else {
        _errorMessage = "";
      }
    });
  }

  void _selectCity(dynamic city) async {
    // Escondemos el teclado AL PRINCIPIO, antes de cualquier 'await'.
    // Así evitamos el warning de "usar el context tras una espera".
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = "";
      // Formateamos el nombre (Ej: Málaga, Andalusia, Spain).
      _locationName = "${city['name']}, ${city['admin1'] ?? ''}, ${city['country']}";
      _suggestions = []; // Cerramos la lista de sugerencias.
      _searchController.text = city['name']; // Ponemos el nombre en el cuadro.
    });

    // Llamamos a la actualización (que es asíncrona).
    await _updateWeather(city['latitude'], city['longitude']);
    
    if (!context.mounted) return;
    setState(() => _isLoading = false);
  }

  // ==================== DIBUJO DE LA INTERFAZ ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el buscador.
      appBar: _buildAppBar(),
      body: SafeArea(
        // 'Stack' permite poner cosas unas encima de otras (como capas).
        // Aquí ponemos el contenido de fondo y la lista de sugerencias encima.
        child: Stack(
          children: [
            _buildMainContent(), // El contenido principal (el tiempo).
            if (_suggestions.isNotEmpty) _buildSuggestionsList(), // La lista desplegable de búsqueda.
          ],
        ),
      ),
      // Menú inferior para cambiar entre "Ahora", "Hoy" y "Semana".
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Al pulsar en el menú, animamos el cambio de página.
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sunny), label: "Currently"),
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Weekly"),
        ],
      ),
    );
  }

  // --- CONSTRUCTOR DE LA BARRA SUPERIOR ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search Location...",
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          // Si hay texto, mostramos una 'X' para borrarlo rápido.
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _suggestions = []);
                  },
                )
              : null,
          border: InputBorder.none,
        ),
        onChanged: _onSearchChanged,
        onSubmitted: (value) async {
          // Si el usuario pulsa Enter, elegimos la primera sugerencia.
          if (_suggestions.isNotEmpty) {
            _selectCity(_suggestions[0]);
          } else {
            // Si no hay sugerencias, intentamos buscar directamente.
            final city = await _weatherService.searchCity(value);
            if (!mounted) return;
            if (city != null) _selectCity(city);
          }
        },
      ),
      actions: [
        // Botón para usar el GPS.
        IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: _getCurrentLocation,
        ),
      ],
    );
  }

  // --- CONSTRUCTOR DEL CONTENIDO PRINCIPAL ---
  Widget _buildMainContent() {
    return Column(
      children: [
        // Si hay un error (ej: sin conexión), lo mostramos en rojo arriba.
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          ),
        // Si estamos cargando, mostramos la ruedita girando.
        if (_isLoading)
          const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        
        // Aquí mostramos las vistas en un PageView para permitir el deslizamiento lateral.
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              // Si el usuario desliza con el dedo, actualizamos el índice del menú inferior.
              setState(() => _currentIndex = index);
            },
            children: [
              _buildCurrentlyTab(),
              _buildTodayTab(),
              _buildWeeklyTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- CONSTRUCTOR DE LA LISTA DE SUGERENCIAS ---
  Widget _buildSuggestionsList() {
    return Container(
      // Ponemos un fondo casi opaco para que no se vea lo de atrás mientras buscamos.
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final city = _suggestions[index];
          return ListTile(
            title: Text(city['name'] ?? ''),
            subtitle: Text("${city['admin1'] ?? ''}, ${city['country'] ?? ''}"),
            onTap: () => _selectCity(city), // Al tocar una ciudad, la seleccionamos.
          );
        },
      ),
    );
  }

  // --- VISTAS DE LAS PESTAÑAS ---
  
  Widget _buildCurrentlyTab() {
    // Vista ACTUAL. Usamos LayoutBuilder para que se adapte a cualquier tamaño de pantalla.
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CurrentlyView(
                locationName: _locationName,
                current: _weatherData?.current,
                // Traducimos el código numérico del tiempo (ej: 0) a algo humano (ej: "Soleado").
                description: _weatherData != null
                    ? WeatherData.getWeatherDescription(_weatherData!.current.weatherCode)
                    : null,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTodayTab() {
    // Vista de HOY (pronóstico por horas).
    return TodayView(
      locationName: _locationName,
      hourlyData: _weatherData?.hourly ?? [],
    );
  }

  Widget _buildWeeklyTab() {
    // Vista de la SEMANA.
    return WeeklyView(
      locationName: _locationName,
      dailyData: _weatherData?.daily ?? [],
    );
  }
}
