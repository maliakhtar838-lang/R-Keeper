import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_palette.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/media_item_entity.dart';
import '../providers/rkeeper_provider.dart';
import '../widgets/decorated_scaffold.dart';
import '../widgets/rk_snack.dart';

class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({
    super.key,
    required this.categoryId,
    this.groupId,
    this.existingItem,
  });

  final String categoryId;
  final String? groupId;
  final MediaItemEntity? existingItem;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _progressLabelController;
  late final TextEditingController _progressController;
  late final TextEditingController _sourceController;
  late final TextEditingController _coverUrlController;

  late MediaStatus _status;
  late int _colorValue;
  String? _selectedGroupId;
  String? _localImagePath;
  bool _saving = false;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _progressLabelController = TextEditingController(text: item?.progressLabel ?? 'Ch');
    _progressController = TextEditingController(text: '${item?.currentProgress ?? 0}');
    _sourceController = TextEditingController(text: item?.sourceUrl ?? '');
    _coverUrlController = TextEditingController(text: item?.coverImageUrl ?? '');
    _status = item?.status ?? MediaStatus.reading;
    _colorValue = item?.colorValue ?? AppPalette.cardPaletteValues.first;
    _selectedGroupId = item?.groupId ?? widget.groupId;
    _localImagePath = item?.localImagePath;
    if (item == null) _prefillLinkFromClipboard();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _progressLabelController.dispose();
    _progressController.dispose();
    _sourceController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RKeeperProvider>();
    final groups = provider.groupsFor(widget.categoryId);

    return DecoratedScaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Item' : 'New Item',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PreviewCard(colorValue: _colorValue, title: _titleController.text.isEmpty ? 'Your title' : _titleController.text),
            const SizedBox(height: 18),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Title is required.' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _progressLabelController,
                    decoration: const InputDecoration(labelText: 'Progress label', hintText: 'Ch / Ep / Page'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _progressController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Current'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source link',
                hintText: 'https://where-you-read-or-watch.com',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MediaStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: MediaStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(status.label))).toList(),
              onChanged: (value) => setState(() => _status = value ?? MediaStatus.reading),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGroupId ?? '',
              decoration: const InputDecoration(labelText: 'Group / sub-folder'),
              items: [
                const DropdownMenuItem<String>(value: '', child: Text('Ungrouped')),
                ...groups.map((group) => DropdownMenuItem<String>(value: group.id, child: Text(group.title))),
              ],
              onChanged: (value) => setState(() => _selectedGroupId = value == null || value.isEmpty ? null : value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _coverUrlController,
              decoration: const InputDecoration(labelText: 'Cover image URL', hintText: 'https://...'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickLocalImage,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(_localImagePath == null ? 'Choose local cover' : 'Local cover selected'),
                  ),
                ),
                if (_localImagePath != null) ...[
                  const SizedBox(width: 8),
                  IconButton(onPressed: () => setState(() => _localImagePath = null), icon: const Icon(Icons.close_rounded)),
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
                      border: Border.all(color: selected ? AppPalette.cream : AppPalette.cream.withOpacity(0.14), width: selected ? 3 : 1),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_rounded),
                label: Text(_isEditing ? 'Save item' : 'Create item'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _prefillLinkFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (!mounted || text == null || _sourceController.text.isNotEmpty) return;
      if (Validators.isValidHttpUrl(text)) {
        _sourceController.text = text;
        RkSnack.showSuccess(context, 'Source link detected from clipboard.');
      }
    } catch (_) {
      // Clipboard access can fail on some platforms; the form still works normally.
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<RKeeperProvider>();
    final progress = Validators.safeProgress(_progressController.text);
    final item = widget.existingItem;
    final coverUrl = _coverUrlController.text.trim();
    bool ok;
    if (item == null) {
      ok = await provider.createItem(
        categoryId: widget.categoryId,
        groupId: _selectedGroupId,
        title: _titleController.text,
        description: _descriptionController.text,
        progressLabel: _progressLabelController.text,
        currentProgress: progress,
        sourceUrl: _sourceController.text,
        status: _status,
        colorValue: _colorValue,
        coverImageUrl: coverUrl.isEmpty ? null : coverUrl,
        localImagePath: _localImagePath,
      );
    } else {
      ok = await provider.updateItem(
        item.copyWith(
          categoryId: widget.categoryId,
          groupId: _selectedGroupId,
          clearGroup: _selectedGroupId == null,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          progressLabel: _progressLabelController.text.trim().isEmpty ? 'Ch' : _progressLabelController.text.trim(),
          currentProgress: progress,
          sourceUrl: _sourceController.text.trim(),
          status: _status,
          colorValue: _colorValue,
          coverImageUrl: coverUrl.isEmpty ? null : coverUrl,
          clearCoverImageUrl: coverUrl.isEmpty,
          localImagePath: _localImagePath,
          clearLocalImagePath: _localImagePath == null,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      RkSnack.showError(context, provider.errorMessage ?? 'Item could not be saved.');
    }
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.colorValue, required this.title});

  final int colorValue;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(colorValue), AppPalette.black],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.26), blurRadius: 20, offset: const Offset(0, 14))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -28,
            child: Icon(Icons.auto_stories_rounded, size: 132, color: AppPalette.cream.withOpacity(0.08)),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.04),
            ),
          ),
        ],
      ),
    );
  }
}
