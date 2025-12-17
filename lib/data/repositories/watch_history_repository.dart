import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/watch_history.dart';

/// Repository quản lý watch history
class WatchHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'watch_history';

  /// Lấy collection reference
  CollectionReference get _historyCollection =>
      _firestore.collection(_collectionName);

  /// Lưu/cập nhật watch progress
  Future<bool> saveWatchProgress({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
    required int progressSeconds,
    required int totalDurationSeconds,
  }) async {
    try {
      // Tìm record hiện tại
      final existing = await _historyCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      // Tính completed (xem > 95%)
      final completed = (progressSeconds / totalDurationSeconds * 100) >= 95;

      final data = {
        'userId': userId,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'moviePosterUrl': moviePosterUrl,
        'lastWatchedAt': FieldValue.serverTimestamp(),
        'progressSeconds': progressSeconds,
        'totalDurationSeconds': totalDurationSeconds,
        'completed': completed,
      };

      if (existing.docs.isEmpty) {
        // Tạo mới
        await _historyCollection.add(data);
        // Tăng viewCount trong movie document khi có lượt xem mới
        await _updateMovieViewCount(movieId);
      } else {
        // Cập nhật
        await existing.docs.first.reference.update(data);
      }

      return true;
    } catch (e) {
      print('Error saving watch progress: $e');
      return false;
    }
  }

  /// Lấy watch history của user (stream)
  Stream<List<WatchHistory>> getUserHistory(String userId) {
    return _historyCollection
        .where('userId', isEqualTo: userId)
        .orderBy('lastWatchedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WatchHistory.fromFirestore(doc))
              .toList();
        });
  }

  /// Lấy "Continue Watching" - phim đang xem dở (5% - 95%)
  Stream<List<WatchHistory>> getContinueWatching(String userId) {
    return _historyCollection
        .where('userId', isEqualTo: userId)
        .where('completed', isEqualTo: false)
        .orderBy('lastWatchedAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => WatchHistory.fromFirestore(doc))
              .where((item) => item.canContinueWatching)
              .toList();
          return items;
        });
  }

  /// Lấy progress của 1 phim cụ thể
  Future<WatchHistory?> getMovieProgress({
    required String userId,
    required String movieId,
  }) async {
    try {
      final snapshot = await _historyCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return WatchHistory.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting movie progress: $e');
      return null;
    }
  }

  /// Xóa 1 item khỏi history
  Future<bool> deleteHistoryItem({
    required String userId,
    required String movieId,
  }) async {
    try {
      final snapshot = await _historyCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      await snapshot.docs.first.reference.delete();
      return true;
    } catch (e) {
      print('Error deleting history item: $e');
      return false;
    }
  }

  /// Xóa toàn bộ history của user
  Future<bool> clearHistory(String userId) async {
    try {
      final snapshot = await _historyCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return true;
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }

  /// Đếm số phim đã xem hoàn thành
  Future<int> getCompletedCount(String userId) async {
    try {
      final snapshot = await _historyCollection
          .where('userId', isEqualTo: userId)
          .where('completed', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting completed count: $e');
      return 0;
    }
  }

  /// Update viewCount trong movie document (tính từ watch_history thật)
  Future<void> _updateMovieViewCount(String movieId) async {
    try {
      // Đếm số lượt xem unique (mỗi user chỉ tính 1 lần)
      final snapshot = await _historyCollection
          .where('movieId', isEqualTo: movieId)
          .get();

      final uniqueUsers = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String?;
        if (userId != null) uniqueUsers.add(userId);
      }

      // Cập nhật viewCount = số unique users đã xem
      await _firestore.collection('movies').doc(movieId).update({
        'viewCount': uniqueUsers.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating movie view count: $e');
    }
  }
}
