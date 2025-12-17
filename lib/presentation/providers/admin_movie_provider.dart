import 'package:flutter/foundation.dart';
import '../../data/repositories/admin_movie_repository.dart';
import '../../domain/entities/movie.dart';

/// Provider for admin movie management
class AdminMovieProvider with ChangeNotifier {
  final AdminMovieRepository _repository = AdminMovieRepository();

  List<Movie> _movies = [];
  Map<String, dynamic>? _statistics;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Movie> get movies => _movies;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all movies
  Future<void> loadMovies({int limit = 20}) async {
    _isLoading = true;
    _error = null;

    try {
      _movies = await _repository.getAllMovies(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách phim: $e';
      _movies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search movies
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      await loadMovies();
      return;
    }

    _isLoading = true;
    _error = null;

    try {
      _movies = await _repository.searchMovies(query);
      _error = null;
    } catch (e) {
      _error = 'Không thể tìm kiếm: $e';
      _movies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new movie
  Future<bool> createMovie(Movie movie) async {
    try {
      await _repository.createMovie(movie);
      await loadMovies(); // Refresh list
      return true;
    } catch (e) {
      _error = 'Không thể tạo phim: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update movie
  Future<bool> updateMovie(Movie movie) async {
    try {
      await _repository.updateMovie(movie);
      await loadMovies(); // Refresh list
      return true;
    } catch (e) {
      _error = 'Không thể cập nhật phim: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete movie
  Future<bool> deleteMovie(String movieId) async {
    try {
      await _repository.deleteMovie(movieId);
      _movies.removeWhere((m) => m.id == movieId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Không thể xóa phim: $e';
      notifyListeners();
      return false;
    }
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _repository.getMovieStatistics();
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải thống kê: $e';
      notifyListeners();
    }
  }

  /// Bulk import movies
  Future<bool> bulkImportMovies(List<Map<String, dynamic>> moviesList) async {
    try {
      await _repository.bulkImportMovies(moviesList);
      await loadMovies();
      return true;
    } catch (e) {
      _error = 'Không thể import phim: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
