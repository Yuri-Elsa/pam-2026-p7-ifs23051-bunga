// lib/features/flowers/flowers_edit_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/flower_model.dart';
import '../../providers/flower_provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class FlowersEditScreen extends StatefulWidget {
  const FlowersEditScreen({super.key, required this.flowerId});

  final String flowerId;

  @override
  State<FlowersEditScreen> createState() => _FlowersEditScreenState();
}

class _FlowersEditScreenState extends State<FlowersEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaUmumController = TextEditingController();
  final _namaLatinController = TextEditingController();
  final _maknaController = TextEditingController();
  final _asalBudayaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  File? _newImageFile;
  Uint8List? _newImageBytes;
  String _newImageFilename = 'image.jpg';
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get _hasNewImage => _newImageBytes != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        context.read<FlowerProvider>().loadFlowerById(widget.flowerId);
      }
    });
  }

  @override
  void dispose() {
    _namaUmumController.dispose();
    _namaLatinController.dispose();
    _maknaController.dispose();
    _asalBudayaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _populateForm(FlowerModel flower) {
    if (_isInitialized) return;
    _namaUmumController.text = flower.namaUmum;
    _namaLatinController.text = flower.namaLatin;
    _maknaController.text = flower.makna;
    _asalBudayaController.text = flower.asalBudaya;
    _deskripsiController.text = flower.deskripsi;
    _isInitialized = true;
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
      _newImageBytes = bytes;
      _newImageFilename = picked.name;
      _newImageFile = kIsWeb ? null : File(picked.path);
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

  Future<void> _submit(FlowerModel original) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<FlowerProvider>().editFlower(
      id: original.id!,
      namaUmum: _namaUmumController.text.trim(),
      namaLatin: _namaLatinController.text.trim(),
      makna: _maknaController.text.trim(),
      asalBudaya: _asalBudayaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      imageFile: _newImageFile,
      imageBytes: _newImageBytes,
      imageFilename: _newImageFilename,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bunga berhasil diperbarui.')),
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

    return Consumer<FlowerProvider>(
      builder: (context, provider, _) {
        final flower = provider.selectedFlower;
        if (flower != null) _populateForm(flower);

        return Scaffold(
          appBar: const TopAppBarWidget(
            title: 'Edit Bahasa Bunga',
            showBackButton: true,
          ),
          body: flower == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Preview Gambar ──
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _hasNewImage
                                ? Image.memory(
                              _newImageBytes!,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              flower.gambar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.local_florist,
                                size: 48,
                                color: colorScheme.secondary,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black45,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6),
                                child: const Text(
                                  'Ketuk untuk ganti gambar (opsional)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: _namaUmumController,
                    label: 'Nama Umum',
                    icon: Icons.local_florist_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _namaLatinController,
                    label: 'Nama Latin',
                    icon: Icons.science_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _maknaController,
                    label: 'Makna',
                    icon: Icons.favorite_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _asalBudayaController,
                    label: 'Asal Budaya',
                    icon: Icons.public_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _deskripsiController,
                    label: 'Deskripsi',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed:
                    _isLoading ? null : () => _submit(flower),
                    icon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                        _isLoading ? 'Menyimpan...' : 'Simpan'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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