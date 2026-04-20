import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../widgets/destination_card.dart';
import '../config/app_colors.dart';
import '../config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'submit_place_screen.dart';

const _categories = ['Beach', 'Desert', 'History', 'Food', 'Culture'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.destinations,
    required this.onFavoriteToggle,
    required this.onSearchTap,
  });

  final List<Destination> destinations;
  final void Function(String id) onFavoriteToggle;
  final VoidCallback onSearchTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  List<Destination> get _filtered {
    if (_selectedCategory == null) return widget.destinations;
    return widget.destinations
        .where((d) => d.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // TODO: fetch fresh data from Supabase
          setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discover Tunisia',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.surface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coast, desert, heritage, and flavors — in one place.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.surface.withValues(alpha: 0.95),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Ink(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: InkWell(
                      onTap: widget.onSearchTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text(
                              'Search places, cities, regions…',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Categories',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final selected = _selectedCategory == null;
                          return FilterChip(
                            label: const Text('All'),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _selectedCategory = null);
                            },
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.20),
                            checkmarkColor: AppColors.textPrimary,
                          );
                        }
                        final cat = _categories[index - 1];
                        final selected = _selectedCategory == cat;
                        return FilterChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (value) {
                            setState(() {
                              _selectedCategory = value ? cat : null;
                            });
                          },
                          selectedColor: AppColors.primary
                              .withValues(alpha: 0.20),
                          checkmarkColor: AppColors.textPrimary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Destinations',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final d = _filtered[i];
                  return DestinationCard(
                    destination: d,
                    onFavoriteToggle: () => widget.onFavoriteToggle(d.id),
                  );
                },
                childCount: _filtered.length,
              ),
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: (devAuthBypass || Supabase.instance.client.auth.currentSession != null)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubmitPlaceScreen()),
                );
              },
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.surface,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add Place'),
            )
          : null,
    );
  }
}
