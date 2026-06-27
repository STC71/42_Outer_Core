// =============================================================================
//  PISCINE MOBILE - MÓDULO 04: EDITOR DE ENTRADAS
//  Permite crear y editar notas, gestionar sentimientos y subir imágenes a
//  Firebase Storage.
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EntryEditorPage extends StatefulWidget {
  final String? userId;
  final DocumentSnapshot? doc; // Si este doc existe, estamos editando; si no, creando.

  const EntryEditorPage({super.key, this.userId, this.doc});

  @override
  State<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends State<EntryEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _currentImageUrl;
  String _selectedFeeling = 'Feliz';
  XFile? _pickedImage;
  bool _isLoading = false;

  // Lista de sentimientos predefinidos para el diario.
  final List<String> _feelings = ['Feliz', 'Triste', 'Enojado', 'Entusiasmado', 'Neutral', 'Cansado'];

  @override
  void initState() {
    super.initState();
    final isEditing = widget.doc != null;
    
    // Si estamos editando, precargamos los datos del documento de Firestore.
    _titleController = TextEditingController(text: isEditing ? widget.doc!['title'] : '');
    _contentController = TextEditingController(text: isEditing ? widget.doc!['content'] : '');
    _currentImageUrl = isEditing ? (widget.doc!.data() as Map<String, dynamic>)['imageUrl'] : null;
    if (isEditing) {
      final data = widget.doc!.data() as Map<String, dynamic>;
      _selectedFeeling = data['feeling'] ?? 'Feliz';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Gestiona el guardado o actualización de la nota en la nube.
  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede estar vacío')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _currentImageUrl;
      final User? user = FirebaseAuth.instance.currentUser;

      // 1. GESTIÓN DE IMAGEN EN STORAGE
      if (_pickedImage != null) {
        // Si el usuario subió una nueva imagen, borramos la anterior si existía.
        if (_currentImageUrl != null) {
          try {
            await FirebaseStorage.instance.refFromURL(_currentImageUrl!).delete();
          } catch (e) {
            debugPrint('Error al borrar imagen antigua: $e');
          }
        }

        // Subimos el nuevo archivo con un nombre basado en el timestamp actual.
        final ref = FirebaseStorage.instance
            .ref()
            .child('diaries')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(File(_pickedImage!.path));
        // Obtenemos la URL pública generada por Firebase Storage.
        imageUrl = await ref.getDownloadURL();
      } else if (_currentImageUrl == null && widget.doc != null) {
        // Si el usuario quitó la imagen durante la edición.
        final oldData = widget.doc!.data() as Map<String, dynamic>;
        final oldUrl = oldData['imageUrl'] as String?;
        if (oldUrl != null) {
          try {
            await FirebaseStorage.instance.refFromURL(oldUrl).delete();
          } catch (e) {
            debugPrint('Error al borrar imagen eliminada: $e');
          }
        }
      }

      // 2. PREPARACIÓN DE DATOS PARA FIRESTORE
      final data = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'feeling': _selectedFeeling,
        // Si es una nota nueva, ponemos la fecha actual; si no, mantenemos la original.
        'date': widget.doc != null ? widget.doc!['date'] : Timestamp.now(),
        'userId': widget.userId,
        'userEmail': user?.email,
        'imageUrl': imageUrl,
      };

      // 3. PERSISTENCIA EN CLOUD FIRESTORE
      if (widget.doc != null) {
        // Actualizamos el documento existente.
        await FirebaseFirestore.instance.collection('diaries').doc(widget.doc!.id).update(data);
      } else {
        // Creamos un nuevo documento en la colección 'diaries'.
        await FirebaseFirestore.instance.collection('diaries').add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error al guardar: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc != null ? 'Editar Entrada' : 'Nueva Entrada'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de Imagen: Al pulsar, abre un diálogo de selección.
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                            )
                          : _currentImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_currentImageUrl!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Toca para añadir una foto', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  // Botón para quitar la foto seleccionada.
                  if (_pickedImage != null || _currentImageUrl != null)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          _pickedImage = null;
                          _currentImageUrl = null;
                        }),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Quitar Foto', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Campo de Texto: Título.
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  
                  // Selector desplegable: Estado de ánimo.
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFeeling,
                    decoration: const InputDecoration(
                      labelText: '¿Cómo te sientes hoy?',
                      border: OutlineInputBorder(),
                    ),
                    items: _feelings.map((feeling) {
                      return DropdownMenuItem(
                        value: feeling,
                        child: Text(feeling),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedFeeling = newValue);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo de Texto: Contenido del diario.
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: '¿Qué tienes en mente?',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 10,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
    );
  }

  /// Abre un menú inferior para elegir entre Galería o Cámara usando image_picker.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    }
  }
}
