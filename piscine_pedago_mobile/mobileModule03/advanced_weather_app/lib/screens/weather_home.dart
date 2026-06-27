// =============================================================================
//  WEATHER HOME: GESTIÓN DE ESTADO Y NAVEGACIÓN AVANZADA
//  En el Módulo 03, usamos TabController para una navegación más fluida.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../widgets/currently_view.dart';
import '../widgets/today_view.dart';
import '../widgets/weekly_view.dart';
import '../models/weather_data.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> with SingleTickerProviderStateMixin {
  
  // === CONTROLADORES Y SERVICIOS ===
  late TabController _tabController;
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  // === ESTADO DE LA APP ===
  bool _isLoading = false;
  String _errorMessage = "";
  String _locationName = "Detecting location...";
  WeatherData? _weatherData;
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador de pestañas (3 vistas: Ahora, Hoy, Semana).
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _searchController.addListener(() => setState(() {}));
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE GEOLOCALIZACIÓN ---
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        await _updateWeather(position.latitude, position.longitude);
        String? name = await _weatherService.getCityName(position.latitude, position.longitude);
        if (name != null) setState(() => _locationName = name);
      }
    } catch (e) {
      setState(() => _errorMessage = "Geolocation error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- ACTUALIZACIÓN DE DATOS ---
  Future<void> _updateWeather(double lat, double lon) async {
    final data = await _weatherService.fetchWeather(lat, lon);
    if (data != null) {
      setState(() {
        _weatherData = data;
        _errorMessage = "";
      });
    } else {
      setState(() {
        _weatherData = null;
        _errorMessage = "Connection error. Please check your internet.";
      });
    }
  }

  // --- LÓGICA DE BÚSQUEDA ---
  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = "";
      });
      return;
    }
    final results = await _weatherService.getSuggestions(query);
    setState(() {
      _suggestions = results;
      if (query.length >= 3 && results.isEmpty) {
        _errorMessage = "The city name is invalid or does not exist.";
      } else {
        _errorMessage = "";
      }
    });
  }

  void _selectCity(dynamic city) async {
    // Cerramos el teclado antes de la operación asíncrona para evitar alertas de BuildContext
    // y mejorar la experiencia de usuario (el teclado se oculta inmediatamente).
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _locationName = "${city['name']}, ${city['admin1'] ?? ''}, ${city['country']}";
      _suggestions = [];
      _searchController.text = city['name'];
    });

    await _updateWeather(city['latitude'], city['longitude']);

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos la orientación del dispositivo para adaptar la UI.
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                // === NAVEGACIÓN LATERAL (MODO HORIZONTAL) ===
                // Solo se muestra si el dispositivo está en horizontal (Landscape).
                if (isLandscape)
                  NavigationRail(
                    selectedIndex: _tabController.index,
                    onDestinationSelected: (int index) {
                      setState(() {
                        // Animamos el cambio de pestaña en el controlador.
                        _tabController.animateTo(index);
                      });
                    },
                    groupAlignment: 0.0, // Centra los elementos verticalmente.
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: const Color(0xFF0A0E21),
                    indicatorColor: Colors.blueAccent.withValues(alpha: 0.2),
                    selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
                    unselectedIconTheme: const IconThemeData(color: Colors.white60),
                    selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent),
                    unselectedLabelTextStyle: const TextStyle(color: Colors.white60),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.wb_sunny_outlined),
                        label: Text("Currently"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.timer_outlined),
                        label: Text("Today"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.calendar_month_outlined),
                        label: Text("Weekly"),
                      ),
                    ],
                  ),
                
                // === CONTENIDO PRINCIPAL ===
                Expanded(
                  child: Column(
                    children: [
                      // Barra de pestañas superior: Solo visible en modo vertical (Portrait).
                      if (!isLandscape)
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.blueAccent,
                          labelColor: Colors.blueAccent,
                          unselectedLabelColor: Colors.white60,
                          tabs: const [
                            Tab(text: "Currently", icon: Icon(Icons.wb_sunny_outlined)),
                            Tab(text: "Today", icon: Icon(Icons.timer_outlined)),
                            Tab(text: "Weekly", icon: Icon(Icons.calendar_month_outlined)),
                          ],
                        ),
                      
                      // Gestión de mensajes de error dinámicos.
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        ),
                      // Indicador de carga mientras esperamos a la API o al GPS.
                      if (_isLoading)
                        const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        
                      // TabBarView: Muestra el widget correspondiente a la pestaña seleccionada.
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            CurrentlyView(
                              locationName: _locationName,
                              current: _weatherData?.current,
                              description: _weatherData != null 
                                  ? WeatherData.getWeatherDescription(_weatherData!.current.weatherCode) 
                                  : null,
                            ),
                            TodayView(
                              locationName: _locationName,
                              hourlyData: _weatherData?.hourly ?? [],
                            ),
                            WeeklyView(
                              locationName: _locationName,
                              dailyData: _weatherData?.daily ?? [],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Capa superior (Overlay) para mostrar sugerencias mientras el usuario escribe.
            if (_suggestions.isNotEmpty) _buildSuggestionsOverlay(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search Location...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _suggestions = []);
                  },
                )
              : null,
          border: InputBorder.none,
        ),
        onChanged: _onSearchChanged,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.my_location, color: Colors.blueAccent),
          onPressed: _getCurrentLocation,
        ),
      ],
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.98),
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final city = _suggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_city, color: Colors.blueAccent),
            title: Text(city['name'] ?? ''),
            subtitle: Text("${city['admin1'] ?? ''}, ${city['country'] ?? ''}"),
            onTap: () => _selectCity(city),
          );
        },
      ),
    );
  }
}
