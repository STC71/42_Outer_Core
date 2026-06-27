// =============================================================================
//  PISCINE MOBILE - MÓDULO 04: PROFILE / HOME PAGE
//  Esta es la pantalla principal del diario. Muestra la lista de entradas
//  en tiempo real desde Firestore utilizando un StreamBuilder.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'details_page.dart';
import 'entry_editor_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Cierra la sesión del usuario actual tanto en Firebase como en el proveedor de Google.
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual para filtrar sus notas.
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      
      // Menú lateral con la información del usuario autenticado.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: Text(user?.displayName ?? 'Usuario'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 50, color: Colors.deepPurple)
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: true, // Indica que ya estamos en Inicio
              selectedColor: Colors.deepPurple,
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
          ],
        ),
      ),
      
      // El cuerpo utiliza un StreamBuilder para escuchar cambios en Firestore en tiempo real.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('diaries')
            // Solo traemos las notas que pertenecen al usuario actual (Seguridad).
            .where('userId', isEqualTo: user?.uid)
            // Ordenamos por fecha de forma descendente (más recientes primero).
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ocurrió un error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          // Estado vacío: mostramos un mensaje amigable.
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tu diario está vacío.\n¡Empieza a escribir hoy!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Lista de entradas representadas en Cards.
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
              final imageUrl = data['imageUrl'] as String?;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  // Si hay imagen, la mostramos en miniatura.
                  leading: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Hero(
                            tag: 'image_${doc.id}',
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'Sin Título',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Etiqueta para el sentimiento/mood.
                      if (data['feeling'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data['feeling'],
                            style: TextStyle(fontSize: 10, color: Colors.deepPurple[700]),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        data['content'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMMM, yyyy').format(date),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailsPage(doc: doc),
                    ),
                  ),
                  // Botón de borrado rápido.
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, doc.id, imageUrl),
                  ),
                ),
              );
            },
          );
        },
      ),
      
      // Botón flotante para añadir una nueva entrada.
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntryEditorPage(userId: user?.uid),
          ),
        ),
        tooltip: 'Añadir Entrada',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de borrar una entrada y su imagen de la nube.
  void _confirmDelete(BuildContext context, String docId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Entrada'),
        content: const Text('¿Estás seguro de que quieres borrar este recuerdo para siempre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // 1. Borramos el documento de Firestore.
              await FirebaseFirestore.instance.collection('diaries').doc(docId).delete();
              
              // 2. Si la nota tenía una imagen asociada, también la borramos de Storage (Clean up).
              if (imageUrl != null) {
                try {
                  await FirebaseStorage.instance.refFromURL(imageUrl).delete();
                } catch (e) {
                  debugPrint('Error al borrar la imagen de Storage: $e');
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
