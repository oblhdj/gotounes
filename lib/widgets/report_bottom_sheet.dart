import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../services/supabase_service.dart';

class ReportBottomSheet extends StatefulWidget {
  final String destinationId;

  const ReportBottomSheet({super.key, required this.destinationId});

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _supabaseService = SupabaseService();
  final _noteController = TextEditingController();
  
  String? _selectedType;
  bool _isSubmitting = false;

  final _options = [
    {'type': 'wrong_price', 'icon': '💰', 'label': 'Wrong price'},
    {'type': 'place_closed', 'icon': '🔒', 'label': 'Place is closed'},
    {'type': 'scam', 'icon': '⚠️', 'label': 'Scam warning'},
    {'type': 'safety_risk', 'icon': '🚨', 'label': 'Safety risk'},
    {'type': 'other', 'icon': '📝', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedType == null) return;

    setState(() => _isSubmitting = true);
    
    try {
      await _supabaseService.submitReport(
        destinationId: widget.destinationId,
        type: _selectedType!,
        note: _noteController.text.trim(),
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanks for reporting! We'll review this.")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting report: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: isKeyboardOpen ? MediaQuery.of(context).viewInsets.bottom + 16 : MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report an Issue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Help us keep GoTounes accurate', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._options.map((option) {
            final isSelected = _selectedType == option['type'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Text(option['icon']!, style: const TextStyle(fontSize: 20)),
                title: Text(option['label']!, style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : null,
                )),
                onTap: () => setState(() => _selectedType = option['type']),
              ),
            );
          }),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Add a note (optional)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _selectedType == null || _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                : const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
