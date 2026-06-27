// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: DETALLE DE VIVENCIA
//  Pantalla para visualizar el contenido completo de una entrada específica.
//  Incluye soporte para edición, borrado y visualización de imágenes.
//  Utiliza animaciones 'Hero' para una transición fluida desde la lista.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'entry_editor_page.dart';

class DiaryDetailsPage extends StatelessWidget {
  /// El documento inicial que recibimos para mostrar.
  final DocumentSnapshot doc;

  const DiaryDetailsPage({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // Escuchamos solo este documento específico en tiempo real por si se edita.
      stream: FirebaseFirestore.instance
          .collection('diaries')
          .doc(doc.id)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Manejo de borrado externo: Si el documento deja de existir.
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Esta entrada ya no está disponible.')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final orientation = MediaQuery.of(context).orientation;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Leyendo recuerdo...'),
            actions: [
              // Acción de edición.
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntryEditorPage(
                      userId: data['userId'],
                      doc: snapshot.data, // Pasamos el doc actual para que el editor lo cargue.
                    ),
                  ),
                ),
                tooltip: 'Editar esta entrada',
              ),
              // Acción de borrado.
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, snapshot.data!),
                tooltip: 'Eliminar definitivamente',
              ),
            ],
          ),
          // Adaptamos la visualización a Portrait o Landscape.
          body: orientation == Orientation.portrait
              ? _buildPortraitLayout(context, data)
              : _buildLandscapeLayout(context, data),
        );
      },
    );
  }

  /// Muestra un diálogo de confirmación antes de destruir datos.
  void _confirmDelete(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar definitivamente?'),
        content: const Text('Si borras este recuerdo, se perderán el texto y la imagen asociada en la nube.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Cerramos el diálogo.
              Navigator.pop(context); // Volvemos a la pantalla anterior.

              final data = doc.data() as Map<String, dynamic>;
              final imageUrl = data['imageUrl'] as String?;

              // 1. Eliminamos de Firestore.
              await FirebaseFirestore.instance.collection('diaries').doc(doc.id).delete();

              // 2. Si tenía una imagen, la borramos de Storage para no malgastar espacio.
              if (imageUrl != null && imageUrl.isNotEmpty) {
                try {
                  await FirebaseStorage.instance.refFromURL(imageUrl).delete();
                } catch (e) {
                  debugPrint('No se pudo borrar la imagen de la nube: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Diseño para cuando el móvil está en VERTICAL.
  Widget _buildPortraitLayout(BuildContext context, Map<String, dynamic> data) {
    final imageUrl = data['imageUrl'] as String?;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null) _buildImage(imageUrl, 350),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildContent(context, data),
          ),
        ],
      ),
    );
  }

  /// Diseño para cuando el móvil está en HORIZONTAL.
  Widget _buildLandscapeLayout(BuildContext context, Map<String, dynamic> data) {
    final imageUrl = data['imageUrl'] as String?;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
          Expanded(
            flex: 1,
            child: SizedBox(
              height: double.infinity,
              child: _buildImage(imageUrl, null),
            ),
          ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildContent(context, data),
          ),
        ),
      ],
    );
  }

  /// Widget encargado de renderizar la imagen con animación Hero.
  Widget _buildImage(String url, double? height) {
    return Hero(
      tag: 'image_${doc.id}',
      child: Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        // Si hay un error de red o la imagen ya no existe.
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        ),
      ),
    );
  }

  /// Construye el bloque de texto con toda la información de la entrada.
  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila superior: Fecha y Sentimiento.
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMMM, yyyy - HH:mm').format(date),
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (data['feeling'] != null)
              Chip(
                label: Text(data['feeling']),
                backgroundColor: Colors.deepPurple[50],
                labelStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12),
                side: BorderSide.none,
              ),
          ],
        ),
        const Divider(height: 40),
        // Título de la entrada.
        Text(
          data['title'] ?? 'Sin Título',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 20),
        // Cuerpo del mensaje / Contenido.
        Text(
          data['content'] ?? '',
          style: const TextStyle(fontSize: 17, height: 1.6, color: Colors.black87),
        ),
        const SizedBox(height: 40),
        // Información de autoría (meta-data).
        if (data['userEmail'] != null)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Escrito por: ${data['userEmail']}',
              style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}
