import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../services/supabase_service.dart';

class SubmitPlaceScreen extends StatefulWidget {
  const SubmitPlaceScreen({super.key});

  @override
  State<SubmitPlaceScreen> createState() => _SubmitPlaceScreenState();
}

class _SubmitPlaceScreenState extends State<SubmitPlaceScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _safetyNoteController = TextEditingController();
  final _priceController = TextEditingController();

  final List<XFile> _images = [];
  String _selectedRegion = 'Tunis';
  String _selectedCategory = 'Beach';
  bool _isSubmitting = false;

  final _regions = [
    'Tunis', 'Sfax', 'Sousse', 'Djerba', 'Tozeur', 
    'Tataouine', 'Kebili', 'Nabeul', 'Mahdia', 'Other'
  ];
  final _categories = [
    'Beach', 'Desert', 'History', 'Culture', 'Food', 'Hike', 'Camp'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _safetyNoteController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 3 photos.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _images.addAll(pickedFiles.take(3 - _images.length));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Description are required.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final supabaseService = SupabaseService();
      
      final imageBytes = <Uint8List>[];
      final imageExts = <String>[];
      
      for (final file in _images) {
        final bytes = await file.readAsBytes();
        final name = file.name.toLowerCase();
        final ext = name.contains('.') ? name.split('.').last : 'jpg';
        
        imageBytes.add(bytes);
        imageExts.add(ext);
      }

      await supabaseService.submitPlace(
        name: name,
        region: _selectedRegion,
        category: _selectedCategory,
        description: description,
        safetyNote: _safetyNoteController.text.trim(),
        avgPriceTnd: _priceController.text.trim(),
        images: imageBytes,
        imageExtensions: imageExts,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanks! We'll review within 48h.")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit place: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: 'Place Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: InputDecoration(
                labelText: 'Region *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: _isSubmitting ? null : (val) {
                if (val != null) setState(() => _selectedRegion = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: _isSubmitting ? null : (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _safetyNoteController,
              enabled: !_isSubmitting,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Safety Note',
                hintText: 'Any risks or scams to warn about?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: 'Price (TND)',
                hintText: 'What did you actually pay? e.g. Free / 15 TND',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Photos (Up to 3)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.surface,
                          ),
                          child: FutureBuilder<Uint8List>(
                            future: _images[index].readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: _isSubmitting ? null : () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (_images.length < 3) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Select Photos'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
                    )
                  : const Text('Submit Place', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
