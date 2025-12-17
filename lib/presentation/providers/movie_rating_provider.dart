import 'package:flutter/foundation.dart';
import '../../data/repositories/movie_rating_repository.dart';
import '../../domain/entities/movie_rating.dart';

/// Provider quản lý movie ratings state
class MovieRatingProvider with ChangeNotifier {
  final MovieRatingRepository _repository = MovieRatingRepository();

  MovieRating? _userRating;
  MovieRatingStats? _movieStats;
  bool _isLoading = false;
  String? _error;

  // Getters
  MovieRating? get userRating => _userRating;
  MovieRatingStats? get movieStats => _movieStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Rate phim
  Future<bool> rateMovie({
    required String userId,
    required String movieId,
    required double rating,
    String? review,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _repository.rateMovie(
        userId: userId,
        movieId: movieId,
        rating: rating,
        review: review,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Lỗi khi đánh giá: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Stream user's rating
  Stream<MovieRating?> watchUserRating({
    required String userId,
    required String movieId,
  }) {
    return _repository.watchUserRating(userId: userId, movieId: movieId);
  }

  /// Stream all ratings của phim
  Stream<List<MovieRating>> watchMovieRatings(String movieId) {
    return _repository.getMovieRatings(movieId);
  }

  /// Load rating stats
  Future<void> loadMovieStats(String movieId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _movieStats = await _repository.getMovieRatingStats(movieId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải thống kê: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete rating
  Future<bool> deleteRating({
    required String userId,
    required String movieId,
  }) async {
    try {
      final success = await _repository.deleteRating(
        userId: userId,
        movieId: movieId,
      );
      return success;
    } catch (e) {
      _error = 'Lỗi khi xóa đánh giá: $e';
      notifyListeners();
      return false;
    }
  }
}
