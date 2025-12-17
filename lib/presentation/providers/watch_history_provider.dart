import 'package:flutter/foundation.dart';
import '../../data/repositories/watch_history_repository.dart';
import '../../domain/entities/watch_history.dart';

/// Provider quản lý watch history state
class WatchHistoryProvider with ChangeNotifier {
  final WatchHistoryRepository _repository = WatchHistoryRepository();

  List<WatchHistory> _history = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WatchHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Stream watch history theo real-time
  Stream<List<WatchHistory>> watchUserHistory(String userId) {
    return _repository.getUserHistory(userId);
  }

  /// Stream "Continue Watching"
  Stream<List<WatchHistory>> watchContinueWatching(String userId) {
    return _repository.getContinueWatching(userId);
  }

  /// Lưu watch progress
  Future<bool> saveWatchProgress({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
    required int progressSeconds,
    required int totalDurationSeconds,
  }) async {
    try {
      final success = await _repository.saveWatchProgress(
        userId: userId,
        movieId: movieId,
        movieTitle: movieTitle,
        moviePosterUrl: moviePosterUrl,
        progressSeconds: progressSeconds,
        totalDurationSeconds: totalDurationSeconds,
      );
      return success;
    } catch (e) {
      _error = 'Lỗi khi lưu tiến độ: $e';
      notifyListeners();
      return false;
    }
  }

  /// Lấy progress của 1 phim
  Future<WatchHistory?> getMovieProgress({
    required String userId,
    required String movieId,
  }) async {
    try {
      return await _repository.getMovieProgress(
        userId: userId,
        movieId: movieId,
      );
    } catch (e) {
      _error = 'Lỗi khi lấy tiến độ: $e';
      notifyListeners();
      return null;
    }
  }

  /// Xóa 1 item khỏi history
  Future<bool> deleteHistoryItem({
    required String userId,
    required String movieId,
  }) async {
    try {
      final success = await _repository.deleteHistoryItem(
        userId: userId,
        movieId: movieId,
      );
      return success;
    } catch (e) {
      _error = 'Lỗi khi xóa: $e';
      notifyListeners();
      return false;
    }
  }

  /// Xóa toàn bộ history
  Future<bool> clearHistory(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _repository.clearHistory(userId);

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Lỗi khi xóa lịch sử: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đếm số phim đã xem hoàn thành
  Future<int> getCompletedCount(String userId) async {
    return await _repository.getCompletedCount(userId);
  }
}
