import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity cho watchlist item
class WatchlistItem {
  final String id;
  final String userId;
  final String movieId;
  final String movieTitle;
  final String? moviePosterUrl;
  final DateTime addedAt;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterUrl,
    required this.addedAt,
  });

  /// Tạo từ Firestore document
  factory WatchlistItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WatchlistItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      moviePosterUrl: data['moviePosterUrl'],
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  WatchlistItem copyWith({
    String? id,
    String? userId,
    String? movieId,
    String? movieTitle,
    String? moviePosterUrl,
    DateTime? addedAt,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
