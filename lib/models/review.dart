class Review {
  final String id;
  final String destinationId;
  final String userId;
  final String userDisplayName;
  final int rating;
  final String body;
  final DateTime createdAt;
  final List<String> tags;
  final int likeCount;
  final bool isLikedByMe;
  final bool isRecentVisit;

  const Review({
    required this.id,
    required this.destinationId,
    required this.userId,
    required this.userDisplayName,
    required this.rating,
    required this.body,
    required this.createdAt,
    this.tags = const [],
    this.likeCount = 0,
    this.isLikedByMe = false,
    this.isRecentVisit = false,
  });

  Review copyWith({
    String? id,
    String? destinationId,
    String? userId,
    String? userDisplayName,
    int? rating,
    String? body,
    DateTime? createdAt,
    List<String>? tags,
    int? likeCount,
    bool? isLikedByMe,
    bool? isRecentVisit,
  }) {
    return Review(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      rating: rating ?? this.rating,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isRecentVisit: isRecentVisit ?? this.isRecentVisit,
    );
  }
}
