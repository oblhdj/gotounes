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
  });

  final Destination destination;
  final VoidCallback onFavoriteToggle;
  final bool compact;

  bool _isSafeUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);
    final heroTag = 'destination_${destination.id}';

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
                      destination.region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (destination.city.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        destination.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.shield, size: 14, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          destination.safetyScore.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            destination.avgPriceTnd,
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
                    destination.region,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (destination.city.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      destination.city,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < destination.safetyScore ? Icons.shield : Icons.shield_outlined,
                            size: 16,
                            color: AppColors.primary,
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.payments_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.avgPriceTnd,
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
