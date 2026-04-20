import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../models/review.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.isOwner,
    required this.onDelete,
    required this.onLikeToggle,
  });

  final Review review;
  final bool isOwner;
  final VoidCallback onDelete;
  final Future<void> Function(String reviewId) onLikeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format date nicely instead of just toString
    final formattedDate = '${review.createdAt.day.toString().padLeft(2, '0')}/${review.createdAt.month.toString().padLeft(2, '0')}/${review.createdAt.year}';

    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    review.userDisplayName.isNotEmpty ? review.userDisplayName[0].toUpperCase() : 'T',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userDisplayName,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        formattedDate,
                        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (review.isRecentVisit) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '✓ Recent visit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red[400],
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: AppColors.accent,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              review.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            if (review.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: review.tags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: false,
                    onSelected: (_) {},
                    backgroundColor: AppColors.cardBg,
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    showCheckmark: false,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    review.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 18,
                  ),
                  color: review.isLikedByMe ? AppColors.primary : AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => onLikeToggle(review.id),
                ),
                const SizedBox(width: 6),
                Text(
                  'Helpful (${review.likeCount})',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: review.isLikedByMe ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
