import 'package:flutter/foundation.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../../domain/entities/watchlist_item.dart';

/// Provider quản lý watchlist state
class WatchlistProvider with ChangeNotifier {
  final WatchlistRepository _repository = WatchlistRepository();

  List<WatchlistItem> _watchlist = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WatchlistItem> get watchlist => _watchlist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Stream watchlist theo real-time
  Stream<List<WatchlistItem>> watchUserWatchlist(String userId) {
    return _repository.getUserWatchlist(userId);
  }

  /// Thêm phim vào watchlist
  Future<bool> addToWatchlist({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
  }) async {
    try {
      final success = await _repository.addToWatchlist(
        userId: userId,
        movieId: movieId,
        movieTitle: movieTitle,
        moviePosterUrl: moviePosterUrl,
      );
      return success;
    } catch (e) {
      _error = 'Lỗi khi thêm vào danh sách: $e';
      notifyListeners();
      return false;
    }
  }

  /// Xóa khỏi watchlist
  Future<bool> removeFromWatchlist({
    required String userId,
    required String movieId,
  }) async {
    try {
      final success = await _repository.removeFromWatchlist(
        userId: userId,
        movieId: movieId,
      );
      return success;
    } catch (e) {
      _error = 'Lỗi khi xóa khỏi danh sách: $e';
      notifyListeners();
      return false;
    }
  }

  /// Toggle watchlist (thêm nếu chưa có, xóa nếu đã có)
  Future<bool> toggleWatchlist({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
  }) async {
    final isInList = await _repository.isInWatchlist(
      userId: userId,
      movieId: movieId,
    );

    if (isInList) {
      return await removeFromWatchlist(userId: userId, movieId: movieId);
    } else {
      return await addToWatchlist(
        userId: userId,
        movieId: movieId,
        movieTitle: movieTitle,
        moviePosterUrl: moviePosterUrl,
      );
    }
  }

  /// Kiểm tra phim có trong watchlist không
  Future<bool> isInWatchlist({
    required String userId,
    required String movieId,
  }) async {
    return await _repository.isInWatchlist(userId: userId, movieId: movieId);
  }

  /// Lấy số lượng phim trong watchlist
  Future<int> getWatchlistCount(String userId) async {
    return await _repository.getWatchlistCount(userId);
  }

  /// Xóa toàn bộ watchlist
  Future<bool> clearWatchlist(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _repository.clearWatchlist(userId);

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Lỗi khi xóa danh sách: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
