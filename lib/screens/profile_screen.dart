import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.favoritesCount,
    required this.visitedCount,
    required this.submittedCount,
    required this.displayName,
    required this.email,
    required this.bio,
    required this.location,
    required this.avatarUrl,
    required this.onLogout,
    required this.onProfileUpdated,
  });

  final int favoritesCount;
  final int visitedCount;
  final int submittedCount;
  final String displayName;
  final String email;
  final String bio;
  final String location;
  final String avatarUrl;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withValues(alpha: 0.25),
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? Text(
                _initials,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ) : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (location.isNotEmpty) ...[
                    Text(
                      location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    email.isEmpty
                        ? 'Manage your saved places and preferences'
                        : email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      currentDisplayName: displayName,
                      currentBio: bio,
                      currentLocation: location,
                      currentAvatarUrl: avatarUrl,
                    ),
                  ),
                );
                if (result == true) {
                  onProfileUpdated();
                }
              },
            ),
          ],
        ),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            bio,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                count: favoritesCount,
                label: 'Favorites',
              ),
              Container(width: 1, height: 32, color: AppColors.textSecondary.withValues(alpha: 0.2)),
              _StatItem(
                count: visitedCount,
                label: 'Visited',
              ),
              Container(width: 1, height: 32, color: AppColors.textSecondary.withValues(alpha: 0.2)),
              _StatItem(
                count: submittedCount,
                label: 'Submitted',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ProfileTile(
          icon: Icons.info_outline,
          title: 'App Version',
          subtitle: '1.0.0',
        ),
        _ProfileTile(
          icon: Icons.language_outlined,
          title: 'Language',
          subtitle: 'English',
        ),
        _ProfileTile(
          icon: Icons.auto_awesome_outlined,
          title: 'About GoTounes',
          subtitle: 'Discover Tunisia — coast, desert, heritage, and flavors.',
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // TODO: call Supabase signOut()
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ),
      ],
    );
  }

  String get _initials {
    final source = displayName.trim().isEmpty ? 'Traveler' : displayName.trim();
    final parts = source.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final letters = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return letters.isEmpty ? 'TR' : letters;
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: theme.textTheme.bodySmall),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
