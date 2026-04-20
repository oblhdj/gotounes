import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../widgets/destination_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.destinations,
    required this.onFavoriteToggle,
  });

  final List<Destination> destinations;
  final void Function(String id) onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final favorites = destinations.where((d) => d.isFavorite).toList();

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Start exploring to save places',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final d = favorites[i];
                return DestinationCard(
                  destination: d,
                  onFavoriteToggle: () => onFavoriteToggle(d.id),
                );
              },
              childCount: favorites.length,
            ),
          ),
        ),
      ],
    );
  }
}
