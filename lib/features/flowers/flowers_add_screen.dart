// lib/features/flowers/flowers_add_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/flower_provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class FlowersAddScreen extends StatefulWidget {
  const FlowersAddScreen({super.key});

  @override
  State<FlowersAddScreen> createState() => _FlowersAddScreenState();
}

class _FlowersAddScreenState extends State<FlowersAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaUmumController = TextEditingController();
  final _namaLatinController = TextEditingController();
  final _maknaController = TextEditingController();
  final _asalBudayaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageBytes;
  String _imageFilename = 'image.jpg';
  bool _isLoading = false;

  bool get _hasImage => _imageBytes != null;

  @override
  void dispose() {
    _namaUmumController.dispose();
    _namaLatinController.dispose();
    _maknaController.dispose();
    _asalBudayaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageFilename = picked.name;
      _imageFile = kIsWeb ? null : File(picked.path);
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<FlowerProvider>().addFlower(
      namaUmum: _namaUmumController.text.trim(),
      namaLatin: _namaLatinController.text.trim(),
      makna: _maknaController.text.trim(),
      asalBudaya: _asalBudayaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      imageFile: _imageFile,
      imageBytes: _imageBytes,
      imageFilename: _imageFilename,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bunga berhasil ditambahkan.')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<FlowerProvider>().errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const TopAppBarWidget(
        title: 'Tambah Bahasa Bunga',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Preview & Tombol Pilih Gambar ──
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: _hasImage
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: colorScheme.secondary),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk memilih gambar bunga *',
                        style:
                        TextStyle(color: colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildField(
                controller: _namaUmumController,
                label: 'Nama Umum',
                hint: 'Contoh: Mawar',
                icon: Icons.local_florist_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _namaLatinController,
                label: 'Nama Latin',
                hint: 'Contoh: Rosa',
                icon: Icons.science_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _maknaController,
                label: 'Makna',
                hint: 'Contoh: Cinta dan kasih sayang',
                icon: Icons.favorite_outline,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _asalBudayaController,
                label: 'Asal Budaya',
                hint: 'Contoh: Eropa Barat',
                icon: Icons.public_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _deskripsiController,
                label: 'Deskripsi',
                hint: 'Deskripsikan bunga ini...',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save_outlined),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label tidak boleh kosong.';
        }
        return null;
      },
    );
  }
}