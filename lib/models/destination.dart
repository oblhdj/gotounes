class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.region,
    required this.city,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.images = const [],
    this.isFavorite = false,
    this.isVerified = false,
    this.safetyScore = 0,
    this.avgPriceTnd = '',
    this.lat,
    this.lng,
    this.safetyNote = '',
  });

  final String safetyNote;
  final String id;
  final String name;
  final String region;
  final String city;
  final String category;
  final String description;
  final String imageUrl;
  final List<String> images;
  final bool isFavorite;
  final bool isVerified;
  final int safetyScore;
  final String avgPriceTnd;
  final double? lat;
  final double? lng;

  Destination copyWith({
    String? id,
    String? name,
    String? region,
    String? city,
    String? category,
    String? description,
    String? imageUrl,
    List<String>? images,
    bool? isFavorite,
    bool? isVerified,
    int? safetyScore,
    String? avgPriceTnd,
    double? lat,
    double? lng,
    String? safetyNote,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      city: city ?? this.city,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      isFavorite: isFavorite ?? this.isFavorite,
      isVerified: isVerified ?? this.isVerified,
      safetyScore: safetyScore ?? this.safetyScore,
      avgPriceTnd: avgPriceTnd ?? this.avgPriceTnd,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      safetyNote: safetyNote ?? this.safetyNote,
    );
  }
}
