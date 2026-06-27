// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: HOME PAGE
//  Contenedor principal que gestiona la navegación de la aplicación.
//  Implementa una BottomNavigationBar para móviles y una NavigationRail para tablets/landscape.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'diary_feed_page.dart';
import 'calendar_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Índice que controla qué página estamos visualizando actualmente.
  int _currentIndex = 0;

  // Lista de las tres secciones principales de la aplicación.
  final List<Widget> _pages = [
    const DiaryFeedPage(),
    const CalendarPage(),
    const ProfilePage(),
  ];

  /// Método para cerrar sesión de forma segura tanto en Firebase como en Google.
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si el dispositivo está en modo horizontal (Landscape).
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Usamos un Drawer (menú lateral) para mejorar la UX y centralizar acciones globales.
    final drawer = Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            accountName: Text(
              FirebaseAuth.instance.currentUser?.displayName ?? 'Usuario',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                  ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                  : null,
              child: FirebaseAuth.instance.currentUser?.photoURL == null
                  ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Mi Diario'),
            selected: _currentIndex == 0,
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendario'),
            selected: _currentIndex == 1,
            onTap: () {
              setState(() => _currentIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil y Estadísticas'),
            selected: _currentIndex == 2,
            onTap: () {
              setState(() => _currentIndex = 2);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: _signOut,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );

    if (isLandscape) {
      // Diseño para Tablets o Móviles en horizontal: Usamos NavigationRail.
      return Scaffold(
        drawer: drawer,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Colors.deepPurple),
              selectedLabelTextStyle: const TextStyle(color: Colors.deepPurple),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.list_alt),
                  label: Text('Diario'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month),
                  label: Text('Calendario'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Perfil'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // IndexedStack mantiene el estado de las páginas (no se reinician al cambiar).
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    // Diseño para Móviles en vertical: Usamos BottomNavigationBar.
    return Scaffold(
      drawer: drawer,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Diario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
