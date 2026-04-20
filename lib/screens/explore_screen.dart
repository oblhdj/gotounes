import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../widgets/destination_card.dart';
import '../config/app_colors.dart';

const _categories = ['Beach', 'Desert', 'History', 'Food', 'Culture'];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.destinations,
    required this.onFavoriteToggle,
  });

  final List<Destination> destinations;
  final void Function(String id) onFavoriteToggle;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  String? _selectedCategory;
  String _selectedRegion = 'All';
  bool _verifiedOnly = false;

  List<String> get _regions {
    final regions = widget.destinations.map((d) => '${d.region} — ${d.city}').toSet().toList();
    regions.sort();
    return ['All', ...regions];
  }

  List<Destination> get _filtered {
    final q = _query.trim().toLowerCase();
    return widget.destinations.where((d) {
      final matchesSearch = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.region.toLowerCase().contains(q) ||
          d.city.toLowerCase().contains(q);
          
      final matchesCategory = _selectedCategory == null ||
          d.category == _selectedCategory;
          
      final matchesRegion = _selectedRegion == 'All' ||
          '${d.region} — ${d.city}' == _selectedRegion;
          
      final matchesVerified = !_verifiedOnly || d.isVerified;
          
      return matchesSearch && matchesCategory && matchesRegion && matchesVerified;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search places, regions…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                final selected = _selectedCategory == null;
                return FilterChip(
                  label: const Text('All'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = null);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.20),
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
                selectedColor: AppColors.primary.withValues(alpha: 0.20),
                checkmarkColor: AppColors.textPrimary,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Verified only',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _verifiedOnly,
                onChanged: (val) => setState(() => _verifiedOnly = val),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filtered.length} places',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              DropdownButton<String>(
                value: _selectedRegion,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                items: _regions.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r == 'All' ? 'All Regions' : r),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRegion = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_outlined,
                          size: 64,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No destinations found',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final d = _filtered[i];
                    return DestinationCard(
                      destination: d,
                      compact: true,
                      onFavoriteToggle: () => widget.onFavoriteToggle(d.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
