// =============================================================================
//  PISCINE MOBILE - MÓDULO 04: DETALLE DE ENTRADA
//  Muestra el contenido completo de una vivencia. Utiliza un StreamBuilder
//  específico para el documento para reflejar ediciones al instante.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'entry_editor_page.dart';

class DiaryDetailsPage extends StatelessWidget {
  final DocumentSnapshot doc;

  const DiaryDetailsPage({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // Escuchamos solo este documento específico en tiempo real.
      stream: FirebaseFirestore.instance
          .collection('diaries')
          .doc(doc.id)
          .snapshots(),
      builder: (context, snapshot) {
        // Manejamos el caso donde el documento sea borrado mientras se visualiza.
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('La entrada ya no existe.')));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final orientation = MediaQuery.of(context).orientation;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalles de la Nota'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EntryEditorPage(
                      userId: data['userId'],
                      doc: snapshot.data,
                    ),
                  ),
                ),
                tooltip: 'Editar',
              ),
            ],
          ),
          body: orientation == Orientation.portrait
              ? _buildPortraitLayout(context, data)
              : _buildLandscapeLayout(context, data),
        );
      },
    );
  }

  /// Diseño vertical: Imagen arriba, texto abajo.
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

  /// Diseño horizontal: Imagen a la izquierda, texto a la derecha.
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

  /// Widget de imagen optimizado.
  Widget _buildImage(String url, double? height) {
    return Hero(
      tag: 'image_${doc.id}',
      child: Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))),
      ),
    );
  }

  /// Widget que contiene el texto y metadatos de la nota.
  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMMM, yyyy - HH:mm').format(date),
              style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (data['feeling'] != null)
              Chip(
                label: Text(data['feeling']),
                backgroundColor: Colors.deepPurple[50],
                labelStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                side: BorderSide.none,
              ),
          ],
        ),
        if (data['userEmail'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Autor: ${data['userEmail']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
            ),
          ),
        const Divider(height: 48),
        Text(
          data['title'] ?? 'Sin Título',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          data['content'] ?? '',
          style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
        ),
      ],
    );
  }
}
