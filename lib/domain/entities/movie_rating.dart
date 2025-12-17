import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity cho movie rating
class MovieRating {
  final String id;
  final String userId;
  final String movieId;
  final double rating; // 1-5 stars
  final String? review; // Optional review text
  final DateTime createdAt;
  final DateTime? updatedAt;

  MovieRating({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    this.review,
    required this.createdAt,
    this.updatedAt,
  });

  /// Validate rating (1-5)
  bool get isValidRating => rating >= 1 && rating <= 5;

  /// Tạo từ Firestore document
  factory MovieRating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MovieRating(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      review: data['review'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': movieId,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MovieRating copyWith({
    String? id,
    String? userId,
    String? movieId,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MovieRating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Aggregated rating stats cho movie
class MovieRatingStats {
  final String movieId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // {1: count, 2: count, ...}

  MovieRatingStats({
    required this.movieId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  /// Get percentage for each star level
  double getPercentage(int stars) {
    if (totalRatings == 0) return 0.0;
    final count = ratingDistribution[stars] ?? 0;
    return (count / totalRatings * 100);
  }
}
