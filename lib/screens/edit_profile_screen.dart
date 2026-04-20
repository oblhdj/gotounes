import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../data/tunisia_regions.dart';
import '../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentDisplayName;
  final String currentBio;
  final String currentLocation;
  final String currentAvatarUrl;

  const EditProfileScreen({
    super.key,
    required this.currentDisplayName,
    required this.currentBio,
    required this.currentLocation,
    required this.currentAvatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  String? _selectedGovernorate;
  String? _selectedDelegation;

  bool _isLoading = false;
  Uint8List? _newAvatarBytes;
  String? _newAvatarExtension;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentDisplayName);
    _bioController = TextEditingController(text: widget.currentBio);
    
    final loc = widget.currentLocation;
    if (loc.isNotEmpty && loc.contains(', ')) {
      final parts = loc.split(', ');
      if (parts.length >= 2) {
        final gov = parts.last;
        final del = parts.sublist(0, parts.length - 1).join(', ');
        if (tunisiaRegions.containsKey(gov)) {
          _selectedGovernorate = gov;
          if (tunisiaRegions[gov]!.contains(del)) {
            _selectedDelegation = del;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final name = pickedFile.name.toLowerCase();
    final ext = name.contains('.') ? name.split('.').last : 'jpg';

    setState(() {
      _newAvatarBytes = bytes;
      _newAvatarExtension = ext;
    });
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();

      if (_newAvatarBytes != null && _newAvatarExtension != null) {
        await supabaseService.uploadAvatar(_newAvatarBytes!, _newAvatarExtension!);
      }

      final newLocation = (_selectedGovernorate != null && _selectedDelegation != null) 
          ? '$_selectedDelegation, $_selectedGovernorate'
          : '';

      await supabaseService.updateProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        location: newLocation,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface,
                      backgroundImage: _newAvatarBytes != null
                          ? MemoryImage(_newAvatarBytes!)
                          : (widget.currentAvatarUrl.isNotEmpty
                              ? NetworkImage(widget.currentAvatarUrl) as ImageProvider
                              : null),
                      child: (_newAvatarBytes == null && widget.currentAvatarUrl.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: AppColors.surface, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGovernorate,
              items: getAllGovernorates().map((gov) {
                return DropdownMenuItem(value: gov, child: Text(gov));
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Governorate',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: _isLoading
                  ? null
                  : (val) {
                      setState(() {
                        _selectedGovernorate = val;
                        _selectedDelegation = null;
                      });
                    },
            ),
            if (_selectedGovernorate != null) ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedDelegation,
                items: tunisiaRegions[_selectedGovernorate]!.map((del) {
                  return DropdownMenuItem(value: del, child: Text(del));
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Delegation',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                onChanged: _isLoading
                    ? null
                    : (val) {
                        setState(() {
                          _selectedDelegation = val;
                        });
                      },
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              enabled: !_isLoading,
              maxLines: 4,
              maxLength: 150,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
