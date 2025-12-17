import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/watchlist_item.dart';

/// Repository quản lý watchlist
class WatchlistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'watchlist';

  /// Lấy collection reference
  CollectionReference get _watchlistCollection =>
      _firestore.collection(_collectionName);

  /// Thêm phim vào watchlist
  Future<bool> addToWatchlist({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
  }) async {
    try {
      // Kiểm tra đã tồn tại chưa
      final existing = await _watchlistCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return false; // Đã có rồi
      }

      // Thêm mới
      await _watchlistCollection.add({
        'userId': userId,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'moviePosterUrl': moviePosterUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error adding to watchlist: $e');
      return false;
    }
  }

  /// Xóa khỏi watchlist
  Future<bool> removeFromWatchlist({
    required String userId,
    required String movieId,
  }) async {
    try {
      final querySnapshot = await _watchlistCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      await querySnapshot.docs.first.reference.delete();
      return true;
    } catch (e) {
      print('Error removing from watchlist: $e');
      return false;
    }
  }

  /// Kiểm tra phim có trong watchlist không
  Future<bool> isInWatchlist({
    required String userId,
    required String movieId,
  }) async {
    try {
      final querySnapshot = await _watchlistCollection
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking watchlist: $e');
      return false;
    }
  }

  /// Lấy toàn bộ watchlist của user (stream)
  Stream<List<WatchlistItem>> getUserWatchlist(String userId) {
    return _watchlistCollection
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WatchlistItem.fromFirestore(doc))
              .toList();
        });
  }

  /// Lấy số lượng phim trong watchlist
  Future<int> getWatchlistCount(String userId) async {
    try {
      final snapshot = await _watchlistCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting watchlist count: $e');
      return 0;
    }
  }

  /// Xóa toàn bộ watchlist của user
  Future<bool> clearWatchlist(String userId) async {
    try {
      final querySnapshot = await _watchlistCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return true;
    } catch (e) {
      print('Error clearing watchlist: $e');
      return false;
    }
  }
}
