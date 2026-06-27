// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: EDITOR DE VIVENCIAS
//  Pantalla para crear o editar notas del diario.
//  Incluye: Selección de fecha, redacción de texto, elección de sentimientos
//  y gestión de fotografías (Cámara/Galería) con carga a Cloud Storage.
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class EntryEditorPage extends StatefulWidget {
  final String? userId;
  /// Si [doc] es nulo, creamos una entrada nueva. Si no, editamos la existente.
  final DocumentSnapshot? doc;

  const EntryEditorPage({super.key, this.userId, this.doc});

  @override
  State<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends State<EntryEditorPage> {
  // Llave global para validar el formulario antes de guardar.
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para capturar el texto introducido por el usuario.
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _selectedFeeling;
  XFile? _imageFile;          // Para nuevas fotos seleccionadas.
  String? _existingImageUrl;  // Para fotos que ya están en la nube (al editar).
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Lista de estados de ánimo disponibles con emojis.
  final List<String> _feelings = [
    '😊 Feliz',
    '😐 Neutral',
    '😢 Triste',
    '😠 Enfadado',
    '😌 Tranquilo',
    '🤩 Emocionado',
    '🥰 Enamorado',
    '😱 Sorprendido',
    '😴 Cansado',
  ];

  @override
  void initState() {
    super.initState();
    // Si estamos editando, precargamos los datos del documento en los campos.
    if (widget.doc != null) {
      final data = widget.doc!.data() as Map<String, dynamic>;

      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      _existingImageUrl = data['imageUrl'];

      final savedFeeling = data['feeling'] as String?;
      if (savedFeeling != null && _feelings.contains(savedFeeling)) {
        _selectedFeeling = savedFeeling;
      }

      final timestamp = data['date'] as Timestamp?;
      if (timestamp != null) {
        _selectedDate = timestamp.toDate();
      }
    }
  }

  @override
  void dispose() {
    // Es vital liberar los controladores para evitar fugas de memoria.
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Despliega el selector de fecha nativo de Android/iOS.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // No permitimos escribir vivencias en el futuro.
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Abre la galería o la cámara para seleccionar una imagen.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80, // Comprimimos un poco para ahorrar datos en la nube.
        maxWidth: 1080,
      );

      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al acceder a la imagen: $e')),
        );
      }
    }
  }

  /// Sube la imagen actual a Firebase Storage y devuelve su URL pública.
  Future<String?> _uploadImage() async {
    // Si el usuario no ha elegido una imagen nueva, devolvemos la que ya existía (si la había).
    if (_imageFile == null) return _existingImageUrl;

    try {
      final user = FirebaseAuth.instance.currentUser;
      // Generamos un nombre de archivo único usando la fecha actual.
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('diary_images/${user?.uid}/$fileName');

      // Subimos el archivo físico.
      await ref.putFile(File(_imageFile!.path));
      // Obtenemos el link para guardarlo en la base de datos.
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Fallo al subir archivo a Storage: $e');
      return null;
    }
  }

  /// Lógica principal para guardar o actualizar la entrada en Firestore.
  Future<void> _saveEntry() async {
    // Validamos que el título, contenido y sentimiento estén rellenos.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final imageUrl = await _uploadImage();

      // Preparamos el objeto JSON que enviaremos a la nube.
      final entryData = {
        'userId': user?.uid,
        'userEmail': user?.email,
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'feeling': _selectedFeeling,
        'imageUrl': imageUrl,
        'date': Timestamp.fromDate(_selectedDate),
      };

      if (widget.doc == null) {
        // CREACIÓN: Añadimos un documento nuevo a la colección 'diaries'.
        await FirebaseFirestore.instance.collection('diaries').add(entryData);
      } else {
        // EDICIÓN: Actualizamos el documento existente usando su ID.
        await FirebaseFirestore.instance
            .collection('diaries')
            .doc(widget.doc!.id)
            .update(entryData);
      }

      if (mounted) {
        Navigator.pop(context); // Volvemos atrás al terminar.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Vivencia guardada correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error técnico al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc == null ? 'Nueva Vivencia' : 'Editar Vivencia'),
        actions: [
          // Botón de guardado en la parte superior.
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveEntry,
              tooltip: 'Guardar cambios',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout(),
      bottomNavigationBar: _buildBottomSaveButton(),
    );
  }

  /// Diseño para cuando el móvil está en VERTICAL.
  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePickerSection(),
            const SizedBox(height: 25),
            ..._buildFormFields(),
            const SizedBox(height: 80), // Espacio para el botón inferior.
          ],
        ),
      ),
    );
  }

  /// Diseño para cuando el móvil está en HORIZONTAL (estilo Leyendo Recuerdo).
  Widget _buildLandscapeLayout() {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parte izquierda: Captura de imagen.
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _buildImagePickerSection(isLandscape: true),
            ),
          ),
          // Parte derecha: Formulario de texto.
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFormFields(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de campos del formulario para reutilizar en ambos layouts.
  List<Widget> _buildFormFields() {
    return [
      // Selector de Fecha.
      _buildDatePickerTile(),
      const Divider(),
      const SizedBox(height: 20),

      // Campo de Título.
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Título del momento',
          hintText: 'Ej: Un paseo por la playa',
          prefixIcon: Icon(Icons.edit_outlined),
          border: OutlineInputBorder(),
        ),
        validator: (value) => value?.isEmpty ?? true ? 'Ponle un título a tu recuerdo' : null,
        maxLength: 60,
      ),
      const SizedBox(height: 15),

      // Selector de Sentimiento (Dropdown).
      DropdownButtonFormField<String>(
        value: _selectedFeeling,
        decoration: const InputDecoration(
          labelText: '¿Cómo te sientes?',
          prefixIcon: Icon(Icons.mood_outlined),
          border: OutlineInputBorder(),
        ),
        items: _feelings.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
        onChanged: (val) => setState(() => _selectedFeeling = val),
        validator: (val) => val == null ? 'Dinos cómo te sientes' : null,
      ),
      const SizedBox(height: 20),

      // Campo de Contenido (Multilínea).
      TextFormField(
        controller: _contentController,
        decoration: const InputDecoration(
          labelText: 'Cuéntalo todo...',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        maxLines: 10,
        validator: (value) => value?.isEmpty ?? true ? 'No dejes la página en blanco' : null,
      ),
    ];
  }

  /// Widget para elegir la fecha.
  Widget _buildDatePickerTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event, color: Colors.deepPurple),
      title: const Text('¿Cuándo ocurrió?', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(DateFormat('EEEE, d MMMM yyyy').format(_selectedDate)),
      trailing: TextButton(
        onPressed: _pickDate,
        child: const Text('Cambiar'),
      ),
    );
  }

  /// Sección visual para gestionar la foto de la entrada.
  Widget _buildImagePickerSection({bool isLandscape = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Captura el momento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showImageSourceOptions(),
          child: Container(
            height: isLandscape ? 300 : 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: _buildImagePreview(),
          ),
        ),
        if (_imageFile != null || _existingImageUrl != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() { _imageFile = null; _existingImageUrl = null; }),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Quitar imagen', style: TextStyle(color: Colors.red)),
            ),
          ),
      ],
    );
  }

  /// Decide qué imagen mostrar en el cuadro de previsualización.
  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
      );
    } else if (_existingImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
      );
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('Toca para añadir una foto', style: TextStyle(color: Colors.grey)),
        ],
      );
    }
  }

  /// Muestra un menú inferior para elegir entre Cámara o Galería.
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Usar Cámara'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de Galería'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  /// El botón principal de guardado fijado en la parte inferior.
  Widget _buildBottomSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveEntry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(
            widget.doc == null ? 'GUARDAR RECUERDO' : 'ACTUALIZAR RECUERDO',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }
}
