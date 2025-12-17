import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity cho watch history
class WatchHistory {
  final String id;
  final String userId;
  final String movieId;
  final String movieTitle;
  final String? moviePosterUrl;
  final DateTime lastWatchedAt;
  final int progressSeconds; // Vị trí xem cuối cùng (giây)
  final int totalDurationSeconds; // Tổng thời lượng phim (giây)
  final bool completed; // Đã xem hết chưa

  WatchHistory({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterUrl,
    required this.lastWatchedAt,
    required this.progressSeconds,
    required this.totalDurationSeconds,
    this.completed = false,
  });

  /// Tính % tiến độ
  double get progressPercentage {
    if (totalDurationSeconds == 0) return 0.0;
    return (progressSeconds / totalDurationSeconds * 100).clamp(0.0, 100.0);
  }

  /// Kiểm tra có thể continue watching không (xem > 5% và < 95%)
  bool get canContinueWatching {
    final percent = progressPercentage;
    return percent >= 5 && percent < 95 && !completed;
  }

  /// Tạo từ Firestore document
  factory WatchHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WatchHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      moviePosterUrl: data['moviePosterUrl'],
      lastWatchedAt:
          (data['lastWatchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progressSeconds: data['progressSeconds'] ?? 0,
      totalDurationSeconds: data['totalDurationSeconds'] ?? 0,
      completed: data['completed'] ?? false,
    );
  }

  /// Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'lastWatchedAt': Timestamp.fromDate(lastWatchedAt),
      'progressSeconds': progressSeconds,
      'totalDurationSeconds': totalDurationSeconds,
      'completed': completed,
    };
  }

  WatchHistory copyWith({
    String? id,
    String? userId,
    String? movieId,
    String? movieTitle,
    String? moviePosterUrl,
    DateTime? lastWatchedAt,
    int? progressSeconds,
    int? totalDurationSeconds,
    bool? completed,
  }) {
    return WatchHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      progressSeconds: progressSeconds ?? this.progressSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      completed: completed ?? this.completed,
    );
  }
}
