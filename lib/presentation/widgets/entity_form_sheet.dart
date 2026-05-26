import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_palette.dart';
import 'rk_snack.dart';

class EntityFormData {
  const EntityFormData({
    required this.title,
    required this.description,
    required this.colorValue,
    this.imageUrl,
    this.localImagePath,
  });

  final String title;
  final String description;
  final int colorValue;
  final String? imageUrl;
  final String? localImagePath;
}

class EntityFormSheet extends StatefulWidget {
  const EntityFormSheet({
    super.key,
    required this.heading,
    required this.submitLabel,
    this.initialTitle = '',
    this.initialDescription = '',
    this.initialColorValue,
    this.initialImageUrl,
    this.initialLocalImagePath,
  });

  final String heading;
  final String submitLabel;
  final String initialTitle;
  final String initialDescription;
  final int? initialColorValue;
  final String? initialImageUrl;
  final String? initialLocalImagePath;

  static Future<EntityFormData?> show(
    BuildContext context, {
    required String heading,
    required String submitLabel,
    String initialTitle = '',
    String initialDescription = '',
    int? initialColorValue,
    String? initialImageUrl,
    String? initialLocalImagePath,
  }) {
    return showModalBottomSheet<EntityFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EntityFormSheet(
        heading: heading,
        submitLabel: submitLabel,
        initialTitle: initialTitle,
        initialDescription: initialDescription,
        initialColorValue: initialColorValue,
        initialImageUrl: initialImageUrl,
        initialLocalImagePath: initialLocalImagePath,
      ),
    );
  }

  @override
  State<EntityFormSheet> createState() => _EntityFormSheetState();
}

class _EntityFormSheetState extends State<EntityFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late int _colorValue;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _imageUrlController = TextEditingController(text: widget.initialImageUrl ?? '');
    _colorValue = widget.initialColorValue ?? AppPalette.cardPaletteValues.first;
    _localImagePath = widget.initialLocalImagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        decoration: const BoxDecoration(
          color: AppPalette.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(color: AppPalette.cream.withOpacity(0.22), borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(widget.heading, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Title is required.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Short description'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL', hintText: 'https://...'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickLocalImage,
                        icon: const Icon(Icons.photo_library_rounded),
                        label: Text(_localImagePath == null ? 'Choose local image' : 'Image selected'),
                      ),
                    ),
                    if (_localImagePath != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() => _localImagePath = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Card color', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppPalette.cardPaletteValues.map((value) {
                    final selected = value == _colorValue;
                    return GestureDetector(
                      onTap: () => setState(() => _colorValue = value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Color(value),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppPalette.cream : AppPalette.cream.withOpacity(0.14),
                            width: selected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.submitLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocalImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
      if (picked == null) return;
      setState(() => _localImagePath = picked.path);
    } catch (_) {
      if (mounted) RkSnack.showError(context, 'Image picker could not open. Check app permissions.');
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      EntityFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        colorValue: _colorValue,
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        localImagePath: _localImagePath,
      ),
    );
  }
}
