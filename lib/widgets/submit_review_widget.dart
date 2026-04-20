import 'package:flutter/material.dart';

import '../config/app_colors.dart';

class SubmitReviewWidget extends StatefulWidget {
  const SubmitReviewWidget({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function(int rating, String body, List<String> tags, bool isRecentVisit) onSubmit;

  @override
  State<SubmitReviewWidget> createState() => _SubmitReviewWidgetState();
}

class _SubmitReviewWidgetState extends State<SubmitReviewWidget> {
  final _bodyController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  final List<String> _selectedTags = [];
  bool _isRecentVisit = false;

  static const _availableTags = [
    '☀️ Day trip',
    '🏕️ Camping',
    '👨👩👧 Family',
    '👫 Couple',
    '🎒 Solo',
    '🌙 Night visit'
  ];

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating from 1 to 5 stars.')),
      );
      return;
    }

    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(_rating, body, List.from(_selectedTags), _isRecentVisit);
      _bodyController.clear();
      setState(() {
        _rating = 0;
        _selectedTags.clear();
        _isRecentVisit = false;
      });
      // Do not need to show success message, the parent will rebuild.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
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
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 32,
                    color: AppColors.accent,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'How was your trip?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                backgroundColor: AppColors.cardBg,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isRecentVisit,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isRecentVisit = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  '✓ I visited this place in the last 6 months',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyController,
            enabled: !_isSubmitting,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isSubmitting 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface)
                  )
                : const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
