// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: PROFILE PAGE
//  Sección personal donde el usuario ve su información, estadísticas de uso
//  y un resumen de sus últimas vivencias.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'stats_page.dart';
import 'entry_editor_page.dart';
import 'details_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Realiza la desconexión total del usuario.
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
    final user = FirebaseAuth.instance.currentUser;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          // Acceso rápido para cerrar sesión.
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: isLandscape 
          ? _buildLandscapeLayout(context, user) 
          : _buildPortraitLayout(context, user),
    );
  }

  /// Diseño vertical: scroll único con toda la información apilada.
  Widget _buildPortraitLayout(BuildContext context, User? user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildUserInfo(user),
          const Divider(),
          _buildActionButton(context, user),
          const Divider(),
          _buildRecentEntries(user?.uid),
          const Divider(),
          // Sección de estadísticas (extraída a un widget propio para limpieza).
          const StatsPage(),
          const SizedBox(height: 20),
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Diseño horizontal: Dos columnas para aprovechar el espacio.
  Widget _buildLandscapeLayout(BuildContext context, User? user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna Izquierda: Información del usuario y botón de acción.
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildUserInfo(user),
                const Divider(),
                _buildActionButton(context, user),
                const SizedBox(height: 10),
                _buildLogoutButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const VerticalDivider(),
        // Columna Derecha: Últimas notas y estadísticas detalladas.
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildRecentEntries(user?.uid),
                const Divider(),
                const StatsPage(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Botón principal para añadir una nueva entrada desde el perfil.
  Widget _buildActionButton(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EntryEditorPage(userId: user?.uid)),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 20),
        label: const Text('Escribir en el diario'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// Botón de cierre de sesión con estilo de alerta (rojo).
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar mi cuenta'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: Colors.redAccent),
          foregroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// Muestra el avatar, nombre y correo del usuario logueado.
  Widget _buildUserInfo(User? user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.deepPurple[50],
          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
          child: user?.photoURL == null 
              ? const Icon(Icons.person, size: 65, color: Colors.deepPurple) 
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? 'Viajero del Tiempo',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'correo@ejemplo.com',
          style: const TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getFeelingColor(String feeling) {
    if (feeling.contains('Feliz')) return Colors.amber;
    if (feeling.contains('Neutral')) return Colors.blueGrey;
    if (feeling.contains('Triste')) return Colors.blue;
    if (feeling.contains('Enfadado')) return Colors.red;
    if (feeling.contains('Tranquilo')) return Colors.teal;
    if (feeling.contains('Emocionado')) return Colors.orange;
    if (feeling.contains('Enamorado')) return Colors.pink;
    if (feeling.contains('Sorprendido')) return Colors.purple;
    if (feeling.contains('Cansado')) return Colors.blueGrey;
    return Colors.deepPurple;
  }

  /// Pequeño listado de las 2 entradas más recientes para acceso rápido.
  Widget _buildRecentEntries(String? userId) {
    if (userId == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            'Recuerdos Recientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('diaries')
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .limit(2) // Limitamos a 2 para no saturar el perfil.
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Aún no has guardado recuerdos.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
                final feeling = data['feeling'] as String? ?? '📝';
                final feelingColor = _getFeelingColor(feeling);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    elevation: 0,
                    color: feelingColor.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: feelingColor.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: feelingColor.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          feeling.split(' ').first,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      title: Text(
                        data['title'] ?? 'Sin título',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormat('EEEE, d MMMM').format(date),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      trailing: Icon(Icons.chevron_right, color: feelingColor),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiaryDetailsPage(doc: doc)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
