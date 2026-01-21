import 'package:flutter/foundation.dart';
import '../../data/repositories/recommendation_repository.dart';
import '../../domain/entities/movie.dart';

/// Provider quản lý recommendations
class RecommendationProvider with ChangeNotifier {
  final RecommendationRepository _repository = RecommendationRepository();

  List<Movie> _similarMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _personalizedMovies = [];
  List<Movie> _newReleases = [];
  List<Movie> _topRated = [];

  bool _isLoadingSimilar = false;
  bool _isLoadingTrending = false;
  bool _isLoadingPopular = false;
  bool _isLoadingPersonalized = false;
  bool _isLoadingNewReleases = false;
  bool _isLoadingTopRated = false;

  String? _error;

  // Getters
  List<Movie> get similarMovies => _similarMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get personalizedMovies => _personalizedMovies;
  List<Movie> get newReleases => _newReleases;
  List<Movie> get topRated => _topRated;

  bool get isLoadingSimilar => _isLoadingSimilar;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingPersonalized => _isLoadingPersonalized;
  bool get isLoadingNewReleases => _isLoadingNewReleases;
  bool get isLoadingTopRated => _isLoadingTopRated;

  String? get error => _error;

  /// Load similar movies
  Future<void> loadSimilarMovies({
    required String movieId,
    required List<String> genres,
    int limit = 10,
  }) async {
    _isLoadingSimilar = true;
    _error = null;
    notifyListeners();

    try {
      _similarMovies = await _repository.getSimilarMovies(
        movieId: movieId,
        genres: genres,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải phim tương tự: $e';
      _similarMovies = [];
    } finally {
      _isLoadingSimilar = false;
      notifyListeners();
    }
  }

  /// Load trending movies
  Future<void> loadTrendingMovies({int limit = 10}) async {
    _isLoadingTrending = true;
    _error = null;
    notifyListeners();

    try {
      _trendingMovies = await _repository.getTrendingMovies(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải phim trending: $e';
      _trendingMovies = [];
    } finally {
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  /// Load popular movies
  Future<void> loadPopularMovies({int limit = 10}) async {
    _isLoadingPopular = true;
    _error = null;
    notifyListeners();

    try {
      _popularMovies = await _repository.getPopularMovies(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải phim phổ biến: $e';
      _popularMovies = [];
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  /// Load personalized recommendations
  Future<void> loadPersonalizedRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    _isLoadingPersonalized = true;
    _error = null;
    notifyListeners();

    try {
      // Chỉ dùng ratings vì chưa có watch history
      final fromRatings = await _repository.getRecommendationsFromRatings(
        userId: userId,
        limit: limit,
      );

      _personalizedMovies = fromRatings;

      // Sort by rating
      _personalizedMovies.sort((a, b) => b.rating.compareTo(a.rating));

      // Take top limit
      if (_personalizedMovies.length > limit) {
        _personalizedMovies = _personalizedMovies.take(limit).toList();
      }

      _error = null;
    } catch (e) {
      _error = 'Không thể tải gợi ý cá nhân: $e';
      _personalizedMovies = [];
    } finally {
      _isLoadingPersonalized = false;
      notifyListeners();
    }
  }

  /// Load new releases
  Future<void> loadNewReleases({int limit = 10}) async {
    _isLoadingNewReleases = true;
    _error = null;
    notifyListeners();

    try {
      _newReleases = await _repository.getNewReleases(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải phim mới: $e';
      _newReleases = [];
    } finally {
      _isLoadingNewReleases = false;
      notifyListeners();
    }
  }

  /// Load top rated
  Future<void> loadTopRated({int limit = 10}) async {
    _isLoadingTopRated = true;
    _error = null;
    notifyListeners();

    try {
      _topRated = await _repository.getTopRated(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải phim đánh giá cao: $e';
      _topRated = [];
    } finally {
      _isLoadingTopRated = false;
      notifyListeners();
    }
  }

  /// Load all recommendation categories
  Future<void> loadAllRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    await Future.wait([
      loadTrendingMovies(limit: limit),
      loadPopularMovies(limit: limit),
      loadPersonalizedRecommendations(userId: userId, limit: limit),
      loadNewReleases(limit: limit),
      loadTopRated(limit: limit),
    ]);
  }

  /// Clear all recommendations
  void clearAll() {
    _similarMovies = [];
    _trendingMovies = [];
    _popularMovies = [];
    _personalizedMovies = [];
    _newReleases = [];
    _topRated = [];
    _error = null;
    notifyListeners();
  }
}
