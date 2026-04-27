import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../models/destination.dart';
import '../screens/destination_detail_screen.dart';
import 'package:share_plus/share_plus.dart';

/// Card used on Home (list) and Explore (grid). Arabic-friendly spacing.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.onFavoriteToggle,
    this.compact = false,
    this.heroTagPrefix = '',
  });

  final Destination destination;
  final VoidCallback onFavoriteToggle;
  final bool compact;
  final String heroTagPrefix;

  bool _isSafeUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  String _pricePreview(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return 'Price unavailable';
    return value.length > 22 ? '${value.substring(0, 22)}...' : value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);
    final heroTag = '${heroTagPrefix}destination_${destination.id}';

    if (compact) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => DestinationDetailScreen(
                  destination: destination,
                  onFavoriteToggle: onFavoriteToggle,
                  heroTag: heroTag,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: _isSafeUrl(destination.images.isNotEmpty ? destination.images.first : destination.imageUrl)
                          ? Image.network(
                              destination.images.isNotEmpty ? destination.images.first : destination.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.cardBg,
                                alignment: Alignment.center,
                                child: const Icon(Icons.landscape_outlined, size: 48),
                              ),
                            )
                          : Container(
                              color: AppColors.cardBg,
                              alignment: Alignment.center,
                              child: const Icon(Icons.landscape_outlined, size: 48),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: AppColors.surface.withValues(alpha: 0.7),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(
                            destination.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: destination.isFavorite
                                ? AppColors.primary
                                : AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                          onPressed: onFavoriteToggle,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${destination.name} '),
                          if (destination.isVerified)
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(Icons.verified, color: Colors.green, size: 16),
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${destination.region}${destination.city.isNotEmpty ? ' · ${destination.city}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Safety ${destination.safetyScore}/5',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pricePreview(destination.avgPriceTnd),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => DestinationDetailScreen(
                destination: destination,
                onFavoriteToggle: onFavoriteToggle,
                heroTag: heroTag,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Hero(
                    tag: heroTag,
                    child: _isSafeUrl(destination.images.isNotEmpty ? destination.images.first : destination.imageUrl)
                        ? Image.network(
                            destination.images.isNotEmpty ? destination.images.first : destination.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.cardBg,
                              alignment: Alignment.center,
                              child: const Icon(Icons.landscape_outlined, size: 56),
                            ),
                          )
                        : Container(
                            color: AppColors.cardBg,
                            alignment: Alignment.center,
                            child: const Icon(Icons.landscape_outlined, size: 56),
                          ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: AppColors.surface.withValues(alpha: 0.7),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(
                        destination.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: destination.isFavorite
                            ? AppColors.primary
                            : AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          destination.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (destination.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Verified',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '${destination.name} '),
                              if (destination.isVerified)
                                const WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.verified, color: Colors.green, size: 20),
                                ),
                            ],
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${destination.region}${destination.city.isNotEmpty ? ' · ${destination.city}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Safety ${destination.safetyScore}/5',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.payments_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _pricePreview(destination.avgPriceTnd),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          destination.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 20),
                        color: AppColors.textSecondary,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Share.share(
                            'Check out ${destination.name} in ${destination.region} '
                            'on GoTounes! 🇹🇳\n\n${destination.description}\n\n'
                            'Price: ${destination.avgPriceTnd}\n'
                            'Discover more places on GoTounes.',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
