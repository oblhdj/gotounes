/*
 * SUPABASE RLS CHECKLIST (do in Supabase dashboard before going live):
 * - Enable RLS on ALL tables (destinations, favorites, profiles)
 * - favorites: user can only SELECT/INSERT/DELETE their own rows
 *   Policy: auth.uid() = user_id
 * - destinations: public SELECT, no INSERT/UPDATE/DELETE for anon users
 * - profiles: user can only SELECT/UPDATE their own row
 *   Policy: auth.uid() = id
 */
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/destination.dart';
import '../models/review.dart';

class SupabaseService {
  SupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Future<List<Destination>> getDestinations() async {
    final favoriteIds = await _getFavoriteIds();
    final rows = await _client
        .from('destinations')
        .select('id, name, region, category, description, safety_note, image_url, is_verified, safety_score, avg_price_tnd, lat, lng, place_images(url, display_order)')
        .order('name');

    return rows.map<Destination>((row) {
      final id = row['id'].toString();
      final placeImages = row['place_images'] as List<dynamic>? ?? [];
      placeImages.sort((a, b) => (a['display_order'] as int? ?? 0).compareTo(b['display_order'] as int? ?? 0));
      final imagesList = placeImages.map((e) => e['url'].toString()).toList();

      return Destination(
        id: id,
        name: row['name'] as String? ?? '',
        region: row['region'] as String? ?? '',
        city: row['city'] as String? ?? '',
        category: row['category'] as String? ?? '',
        description: row['description'] as String? ?? '',
        imageUrl: row['image_url'] as String? ?? '',
        images: imagesList,
        isFavorite: favoriteIds.contains(id),
        isVerified: row['is_verified'] as bool? ?? false,
        safetyScore: row['safety_score'] as int? ?? 0,
        avgPriceTnd: row['avg_price_tnd'] as String? ?? '',
        lat: (row['lat'] as num?)?.toDouble(),
        lng: (row['lng'] as num?)?.toDouble(),
      );
    }).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('You must be signed in to save favorites.');
    }

    final existing = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', user.id)
        .eq('destination_id', id)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('destination_id', id);
      return;
    }

    await _client.from('favorites').insert({
      'user_id': user.id,
      'destination_id': id,
    });
  }

  Future<Map<String, String>> getUserProfile() async {
    final user = currentUser;
    if (user == null) return const {};

    final row = await _client
        .from('profiles')
        .select('email, display_name, bio, location, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final email = (row?['email'] as String?) ?? user.email ?? '';
    final displayName =
        (row?['display_name'] as String?) ?? _fallbackDisplayName(email);

    return {
      'email': email,
      'display_name': displayName,
      'bio': row?['bio'] as String? ?? '',
      'location': row?['location'] as String? ?? '',
      'avatar_url': row?['avatar_url'] as String? ?? '',
    };
  }

  Future<void> updateProfile({String? displayName, String? bio, String? location}) async {
    final user = currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;

    if (updates.isEmpty) return;

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  Future<String> uploadAvatar(Uint8List bytes, String extension) async {
    final user = currentUser;
    if (user == null) throw const AuthException('Not authenticated.');

    final path = '${user.id}/avatar.$extension';

    await _client.storage.from('avatars').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
    await _client.from('profiles').update({'avatar_url': publicUrl}).eq('id', user.id);

    return publicUrl;
  }

  Future<void> submitPlace({
    required String name,
    required String region,
    required String category,
    required String description,
    required String safetyNote,
    required String avgPriceTnd,
    required List<Uint8List> images,
    required List<String> imageExtensions,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('Not authenticated.');

    final response = await _client.from('destinations').insert({
      'name': name,
      'region': region,
      'category': category,
      'description': description,
      'safety_note': safetyNote,
      'avg_price_tnd': avgPriceTnd,
      'status': 'pending',
      'submitted_by': user.id,
    }).select('id').single();

    final destinationId = response['id'].toString();

    int order = 0;
    for (int i = 0; i < images.length; i++) {
      final path = '$destinationId/$i.${imageExtensions[i]}';
      await _client.storage.from('place-images').uploadBinary(path, images[i], fileOptions: const FileOptions(upsert: true));
      final url = _client.storage.from('place-images').getPublicUrl(path);

      if (i == 0) {
        await _client.from('destinations').update({'image_url': url}).eq('id', destinationId);
      }

      await _client.from('place_images').insert({
        'destination_id': destinationId,
        'url': url,
        'display_order': order++,
      });
    }
  }

  Future<List<Review>> getReviews(String destinationId) async {
    final rows = await _client
        .from('reviews')
        .select('*, profiles(display_name), review_likes(user_id)')
        .eq('destination_id', destinationId)
        .order('created_at', ascending: false);

    final currentUserId = currentUser?.id;

    return rows.map<Review>((row) {
      final likes = row['review_likes'] as List<dynamic>? ?? [];
      return Review(
        id: row['id'].toString(),
        destinationId: row['destination_id'].toString(),
        userId: row['user_id'].toString(),
        userDisplayName: row['profiles']?['display_name'] as String? ?? 'Traveler',
        rating: row['rating'] as int? ?? 5,
        body: row['body'] as String? ?? '',
        tags: List<String>.from(row['tags'] as List<dynamic>? ?? []),
        createdAt: DateTime.parse(row['created_at'].toString()),
        likeCount: likes.length,
        isLikedByMe: currentUserId != null && likes.any((like) => like['user_id'] == currentUserId),
        isRecentVisit: row['is_recent_visit'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> submitReview(String destinationId, int rating, String body, List<String> tags, [bool isRecentVisit = false]) async {
    final user = currentUser;
    if (user == null) throw const AuthException('You must be signed in to submit a review.');

    await syncCurrentUserProfile();

    final basePayload = <String, dynamic>{
      'destination_id': destinationId,
      'user_id': user.id,
      'rating': rating,
      'body': body,
    };

    try {
      await _client.from('reviews').insert({
        ...basePayload,
        'tags': tags,
        'is_recent_visit': isRecentVisit,
      });
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();
      final hasSchemaMismatch = message.contains('schema cache') ||
          message.contains("'tags' column") ||
          message.contains('column tags') ||
          message.contains("'is_recent_visit' column") ||
          message.contains('column is_recent_visit');

      if (hasSchemaMismatch) {
        final retryPayload = <String, dynamic>{...basePayload};

        // Keep only columns that are likely available on older schemas.
        if (!message.contains("'tags' column") && !message.contains('column tags')) {
          retryPayload['tags'] = tags;
        }
        if (!message.contains("'is_recent_visit' column") && !message.contains('column is_recent_visit')) {
          retryPayload['is_recent_visit'] = isRecentVisit;
        }

        try {
          await _client.from('reviews').insert(retryPayload);
          return;
        } on PostgrestException catch (fallbackError) {
          final fallbackMessage = fallbackError.message.toLowerCase();
          final stillSchemaMismatch = fallbackMessage.contains('schema cache') ||
              fallbackMessage.contains("'tags' column") ||
              fallbackMessage.contains('column tags') ||
              fallbackMessage.contains("'is_recent_visit' column") ||
              fallbackMessage.contains('column is_recent_visit');

          if (stillSchemaMismatch) {
            await _client.from('reviews').insert(basePayload);
            return;
          }

          if (fallbackMessage.contains('duplicate') ||
              fallbackMessage.contains('unique') ||
              fallbackMessage.contains('already')) {
            throw Exception('You already submitted a review for this place.');
          }
          if (fallbackMessage.contains('row-level security') ||
              fallbackMessage.contains('permission') ||
              fallbackMessage.contains('policy')) {
            throw Exception('You do not have permission to submit reviews right now. Please sign out and sign in again.');
          }
          throw Exception('Could not submit review: ${fallbackError.message}');
        }
      }

      if (message.contains('duplicate') ||
          message.contains('unique') ||
          message.contains('already')) {
        throw Exception('You already submitted a review for this place.');
      }
      if (message.contains('row-level security') ||
          message.contains('permission') ||
          message.contains('policy')) {
        throw Exception('You do not have permission to submit reviews right now. Please sign out and sign in again.');
      }
      throw Exception('Could not submit review: ${e.message}');
    }
  }

  Future<void> toggleReviewLike(String reviewId) async {
    final user = currentUser;
    if (user == null) throw const AuthException('Must be signed in.');
    
    final existing = await _client
        .from('review_likes')
        .select('id')
        .eq('review_id', reviewId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      await _client.from('review_likes')
          .delete()
          .eq('review_id', reviewId)
          .eq('user_id', user.id);
    } else {
      await _client.from('review_likes').insert({
        'review_id': reviewId,
        'user_id': user.id,
      });
    }
  }

  Future<void> submitReport({
    required String destinationId,
    required String type,
    String note = '',
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('Must be signed in to report.');
    await _client.from('reports').insert({
      'destination_id': destinationId,
      'user_id': user.id,
      'type': type,
      'note': note,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    final user = currentUser;
    if (user == null) return;
    
    await _client.from('reviews').delete().eq('id', reviewId).eq('user_id', user.id);
  }

  Future<void> syncCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return;

    final email = user.email ?? '';
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final metadataDisplayName = metadata['display_name'] as String?;
    final metadataLocation = metadata['location'] as String?;
    await _client.from('profiles').upsert({
      'id': user.id,
      'email': email,
      'display_name': (metadataDisplayName != null && metadataDisplayName.trim().isNotEmpty)
          ? metadataDisplayName.trim()
          : _fallbackDisplayName(email),
      'location': metadataLocation,
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Set<String>> _getFavoriteIds() async {
    final user = currentUser;
    if (user == null) return <String>{};

    final rows = await _client
        .from('favorites')
        .select('destination_id')
        .eq('user_id', user.id);

    return rows
        .map<String>((row) => row['destination_id'].toString())
        .toSet();
  }

  String _fallbackDisplayName(String email) {
    if (email.isEmpty) return 'Traveler';
    final namePart = email.split('@').first.trim();
    if (namePart.isEmpty) return 'Traveler';

    return namePart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
