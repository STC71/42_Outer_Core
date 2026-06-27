// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: DIARY FEED PAGE (Muro del Diario)
//  Esta pantalla muestra todas las vivencias del usuario ordenadas por fecha.
//  Utiliza StreamBuilder para que la lista se actualice sola cuando el usuario
//  añade, edita o borra una nota desde cualquier dispositivo.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'details_page.dart';
import 'entry_editor_page.dart';

class DiaryFeedPage extends StatelessWidget {
  const DiaryFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Vivencias'),
        elevation: 2,
        // El botón para abrir el Drawer aparece automáticamente gracias a Scaffold.
      ),

      // Cuerpo reactivo que cambia según la orientación del móvil.
      body: isLandscape 
          ? _buildLandscapeBody(context, user) 
          : _buildPortraitBody(context, user),

      // Botón flotante para crear una nueva nota rápidamente.
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntryEditorPage(userId: user?.uid),
          ),
        ),
        tooltip: 'Añadir nuevo recuerdo',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Layout vertical estándar: una lista simple.
  Widget _buildPortraitBody(BuildContext context, User? user) {
    return _buildStreamList(context, user);
  }

  /// Layout horizontal: aprovechamos el ancho usando dos columnas (Grid).
  Widget _buildLandscapeBody(BuildContext context, User? user) {
    return _buildStreamList(context, user, crossAxisCount: 2);
  }

  /// El núcleo de la pantalla: escucha a Firestore y construye la lista.
  Widget _buildStreamList(BuildContext context, User? user, {int crossAxisCount = 1}) {
    return StreamBuilder<QuerySnapshot>(
      // La consulta: "Trae todas las notas de este usuario ordenadas por fecha reciente".
      stream: FirebaseFirestore.instance
          .collection('diaries')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Control de errores básicos.
        if (snapshot.hasError) {
          return Center(child: Text('Error al conectar con la nube: ${snapshot.error}'));
        }

        // Estado de carga inicial.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // Si el usuario no tiene ninguna nota, mostramos un diseño amigable.
        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        // Si tenemos más de una columna (landscape), usamos GridView.
        if (crossAxisCount > 1) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) => _buildDiaryCard(context, docs[index]),
          );
        }

        // Si es una sola columna (portrait), usamos ListView.
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) => _buildDiaryCard(context, docs[index]),
        );
      },
    );
  }

  /// Widget que se muestra cuando el diario está vacío.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no has escrito nada.\n¡Pulsa el botón + para empezar!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta visual para representar una nota del diario.
  Widget _buildDiaryCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final imageUrl = data['imageUrl'] as String?;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Miniatura de la imagen si existe.
        leading: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: 'image_${doc.id}', // Transición suave hacia la pantalla de detalle.
                  child: Image.network(
                    imageUrl,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              ),
        title: Text(
          data['title'] ?? 'Sin Título',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['content'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy • HH:mm').format(date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        // Al pulsar, vamos al detalle de la nota.
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailsPage(doc: doc),
          ),
        ),
        // Botón de eliminar con confirmación.
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context, doc.id, imageUrl),
        ),
      ),
    );
  }

  /// Muestra un diálogo para evitar borrados accidentales.
  void _confirmDelete(BuildContext context, String docId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta entrada?'),
        content: const Text('Esta acción no se puede deshacer. Se borrará también la imagen asociada de la nube.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerramos el diálogo inmediatamente.

              // 1. Borramos el registro de la base de datos (Firestore).
              await FirebaseFirestore.instance.collection('diaries').doc(docId).delete();

              // 2. Si tenía foto, la borramos del almacén de archivos (Storage).
              if (imageUrl != null && imageUrl.isNotEmpty) {
                try {
                  await FirebaseStorage.instance.refFromURL(imageUrl).delete();
                } catch (e) {
                  debugPrint('Error técnico al borrar imagen de Storage: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Sí, borrar'),
          ),
        ],
      ),
    );
  }
}
