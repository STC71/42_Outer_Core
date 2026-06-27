// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: CALENDAR PAGE
//  Muestra las entradas filtradas por fecha usando la librería table_calendar.
//  Permite visualizar de un vistazo qué días tienen actividad y ver sus detalles.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'details_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // El día que está actualmente visible o enfocado en el calendario.
  DateTime _focusedDay = DateTime.now();
  // El día que el usuario ha pulsado para ver sus notas.
  DateTime? _selectedDay;
  // Controla si vemos el calendario por mes, semana o quincena.
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Al iniciar, seleccionamos el día actual por defecto.
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Usamos un StreamBuilder para obtener la lista de todos los días con eventos.
    // Esto permite que los marcadores del calendario se actualicen solos.
    return StreamBuilder<Set<DateTime>>(
      stream: _getAllEntryDates(user?.uid),
      builder: (context, snapshot) {
        final eventDays = snapshot.data ?? {};

        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendario de Recuerdos'),
          ),
          body: isLandscape
              ? _buildLandscapeLayout(user, eventDays)
              : _buildPortraitLayout(user, eventDays),
        );
      },
    );
  }

  /// Layout para móviles en vertical: Calendario arriba, lista de notas abajo.
  Widget _buildPortraitLayout(User? user, Set<DateTime> eventDays) {
    return Column(
      children: [
        _buildCalendar(eventDays),
        const Divider(),
        Expanded(child: _buildEntriesList(user)),
      ],
    );
  }

  /// Layout para móviles en horizontal: Calendario a la izquierda, lista a la derecha.
  Widget _buildLandscapeLayout(User? user, Set<DateTime> eventDays) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: _buildCalendar(eventDays),
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 3,
          child: _buildEntriesList(user),
        ),
      ],
    );
  }

  /// Construye el widget del calendario interactivo.
  Widget _buildCalendar(Set<DateTime> eventDays) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Mes',
        CalendarFormat.twoWeeks: '2 Semanas',
        CalendarFormat.week: 'Semana',
      },
      // Lógica para saber qué día está marcado como seleccionado.
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      // Carga una lista (aunque sea de un elemento) para indicar que hay un evento ese día.
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return eventDays.contains(normalizedDay) ? [true] : [];
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
        ),
        // Estilo del pequeño punto indicador bajo el número del día.
        markerDecoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
        ),
      ),
      // Personalización visual avanzada del calendario.
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          // Si el día tiene notas, lo ponemos en negrita y color primario.
          if (eventDays.contains(normalizedDay)) {
            return Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  /// Lista de notas que coinciden con el día seleccionado en el calendario.
  Widget _buildEntriesList(User? user) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _getEntriesForDay(user?.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar datos de la nube'));
        }

        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No hay vivencias para el ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return ListTile(
              leading: Text(
                data['feeling']?.split(' ').first ?? '📝',
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(data['title'] ?? 'Sin Título', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                data['content'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailsPage(doc: doc),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Obtiene de Firestore las entradas específicas para el día seleccionado.
  Stream<List<QueryDocumentSnapshot>> _getEntriesForDay(String? userId) {
    if (userId == null || _selectedDay == null) {
      return const Stream.empty();
    }

    // Definimos el rango del día (desde las 00:00 hasta las 23:59:59).
    final startOfDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 0, 0, 0);
    final endOfDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 23, 59, 59, 999);

    return FirebaseFirestore.instance
        .collection('diaries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      // Filtramos en cliente para mayor simplicidad y evitar crear demasiados índices en Firebase.
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final date = (data['date'] as Timestamp?)?.toDate();
        if (date == null) return false;
        return date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfDay.add(const Duration(seconds: 1)));
      }).toList();
    });
  }

  /// Obtiene un conjunto (Set) con todas las fechas que tienen al menos una entrada.
  /// Se usa para dibujar los marcadores en el calendario.
  Stream<Set<DateTime>> _getAllEntryDates(String? userId) {
    if (userId == null) return Stream.value({});
    return FirebaseFirestore.instance
        .collection('diaries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp?;
        if (timestamp == null) return null;
        final date = timestamp.toDate();
        // Normalizamos a solo Año-Mes-Día para poder comparar fácilmente.
        return DateTime(date.year, date.month, date.day);
      }).whereType<DateTime>().toSet();
    });
  }
}
