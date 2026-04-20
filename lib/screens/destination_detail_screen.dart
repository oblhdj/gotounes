import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../models/destination.dart';
import '../models/review.dart';
import '../services/supabase_service.dart';
import '../widgets/review_card.dart';
import '../widgets/submit_review_widget.dart';
import '../widgets/report_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({
    super.key,
    required this.destination,
    required this.onFavoriteToggle,
  });

  final Destination destination;
  final VoidCallback onFavoriteToggle;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late Destination _destination;
  SupabaseService? _supabaseService;
  List<Review>? _reviews;
  bool _isLoadingReviews = true;
  String? _currentUserid;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;

    if (!devAuthBypass) {
      _supabaseService = SupabaseService();
      _currentUserid = _supabaseService!.currentUser?.id;
      _loadReviews();
    } else {
      _isLoadingReviews = false;
      _reviews = [];
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _supabaseService!.getReviews(_destination.id);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _handleSubmitReview(int rating, String body, List<String> tags, bool isRecentVisit) async {
    await _supabaseService!.submitReview(_destination.id, rating, body, tags, isRecentVisit);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted!')),
    );
    await _loadReviews();
  }

  Future<void> _handleDeleteReview(String reviewId) async {
    try {
      await _supabaseService!.deleteReview(reviewId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted.')),
      );
      await _loadReviews();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete review.')),
      );
    }
  }

  Future<void> _handleLikeToggle(String reviewId) async {
    if (_currentUserid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to like reviews.')),
      );
      return;
    }

    final reviewIndex = _reviews!.indexWhere((r) => r.id == reviewId);
    if (reviewIndex == -1) return;

    final review = _reviews![reviewIndex];
    final wasLiked = review.isLikedByMe;

    // Optimistically update UI
    setState(() {
      _reviews![reviewIndex] = review.copyWith(
        isLikedByMe: !wasLiked,
        likeCount: review.likeCount + (wasLiked ? -1 : 1),
      );
    });

    try {
      await _supabaseService!.toggleReviewLike(reviewId);
    } catch (_) {
      // Revert on error
      if (!mounted) return;
      setState(() {
        _reviews![reviewIndex] = review;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like status.')),
      );
    }
  }

  double get _averageRating {
    if (_reviews == null || _reviews!.isEmpty) return 0.0;
    final total = _reviews!.fold<int>(0, (sum, item) => sum + item.rating);
    return total / _reviews!.length;
  }

  void _toggleFavorite() {
    widget.onFavoriteToggle();
    // Optimistically update the UI for immediate feedback.
    setState(() {
      _destination = _destination.copyWith(isFavorite: !_destination.isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'destination_${_destination.id}';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: heroTag,
                      child: (_destination.images.isNotEmpty || _destination.imageUrl.isNotEmpty)
                          ? PageView.builder(
                              itemCount: _destination.images.isNotEmpty ? _destination.images.length : 1,
                              onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                              itemBuilder: (context, index) {
                                final url = _destination.images.isNotEmpty ? _destination.images[index] : _destination.imageUrl;
                                return Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.cardBg,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.landscape_outlined, size: 56),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppColors.cardBg,
                              alignment: Alignment.center,
                              child: const Icon(Icons.landscape_outlined, size: 56),
                            ),
                    ),
                  ),
                  if (_destination.images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_destination.images.length, (idx) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == idx ? AppColors.primary : AppColors.surface.withValues(alpha: 0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 12,
                    child: Material(
                      color: AppColors.textPrimary.withValues(alpha: 0.25),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.surface,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 12,
                    child: Material(
                      color: AppColors.textPrimary.withValues(alpha: 0.25),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined),
                        color: AppColors.surface,
                        onPressed: () {
                          Share.share(
                            'Check out ${_destination.name} in ${_destination.region} '
                            'on GoTounes! 🇹🇳\n\n${_destination.description}\n\n'
                            'Price: ${_destination.avgPriceTnd}\n'
                            'Discover more places on GoTounes.',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${_destination.name} '),
                        if (_destination.isVerified)
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.verified, color: Colors.green, size: 28),
                          ),
                      ],
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_reviews != null && _reviews!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.accent, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${_reviews!.length} ${_reviews!.length == 1 ? 'review' : 'reviews'})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        backgroundColor:
                            AppColors.surface.withValues(alpha: 0.85),
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        label: Text(_destination.region),
                      ),
                      Chip(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        label: Text(_destination.category),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              _destination.isVerified ? Icons.verified : Icons.new_releases_outlined,
                              color: _destination.isVerified ? Colors.green : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _destination.isVerified ? 'Verified' : 'Unverified',
                              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 30, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                        Column(
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < _destination.safetyScore ? Icons.shield : Icons.shield_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Safety',
                              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 30, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                        Column(
                          children: [
                            const Icon(Icons.payments_outlined, color: AppColors.primary),
                            const SizedBox(height: 4),
                            Text(
                              _destination.avgPriceTnd.isEmpty ? 'N/A' : _destination.avgPriceTnd,
                              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _destination.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Reviews',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingReviews)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    if (_currentUserid != null && !_reviews!.any((r) => r.userId == _currentUserid))
                      SubmitReviewWidget(onSubmit: _handleSubmitReview),
                    if (_reviews!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                        child: Text(
                          'No reviews yet. Be the first to review this destination!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ..._reviews!.map((review) {
                        return ReviewCard(
                          review: review,
                          isOwner: review.userId == _currentUserid,
                          onDelete: () => _handleDeleteReview(review.id),
                          onLikeToggle: _handleLikeToggle,
                        );
                      }),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        if (_currentUserid == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sign in to report an issue')),
                          );
                        } else {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => ReportBottomSheet(destinationId: _destination.id),
                          );
                        }
                      },
                      icon: const Text('⚠️'),
                      label: const Text('Report an issue'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        textStyle: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        onPressed: _toggleFavorite,
        child: Icon(
          _destination.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }
}

