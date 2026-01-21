import 'package:flutter/foundation.dart';
import '../../domain/entities/movie.dart';
import '../../data/repositories/movie_repository.dart';

class MovieProvider with ChangeNotifier {
  final MovieRepository _movieRepository = MovieRepository();

  List<Movie> _movies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _favorites = [];
  Movie? _selectedMovie;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<Movie> get movies => _movies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get favorites => _favorites;
  Movie? get selectedMovie => _selectedMovie;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  // Fetch all movies
  Future<void> fetchMovies({bool loadMore = false}) async {
    // Prevent duplicate loading
    if (loadMore && (_isLoadingMore || _isLoading)) return;
    if (!loadMore && _isLoading) return;

    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _errorMessage = null;
    }
    notifyListeners();

    try {
      final fetchedMovies = await _movieRepository.getMovies(limit: 20);

      if (loadMore) {
        // Check for duplicates before adding
        final existingIds = _movies.map((m) => m.id).toSet();
        final newMovies = fetchedMovies
            .where((m) => !existingIds.contains(m.id))
            .toList();
        _movies.addAll(newMovies);

        // If no new movies, we've reached the end
        if (newMovies.isEmpty) {
          print('📭Không còn phim nào để tải');
        }
      } else {
        _movies = fetchedMovies;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Lỗi khi tải phim: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Fetch popular movies
  Future<void> fetchPopularMovies() async {
    try {
      _popularMovies = await _movieRepository.getPopularMovies(limit: 10);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải phim phổ biến: $e');
    }
  }

  // Fetch movie by ID
  Future<void> fetchMovieById(String movieId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedMovie = await _movieRepository.getMovieById(movieId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Lỗi khi tải phim: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search movies
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _movieRepository.searchMovies(query);
    } catch (e) {
      print('Lỗi khi tìm kiếm phim: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // Filter by genre
  Future<void> filterByGenre(String genre) async {
    _isLoading = true;
    notifyListeners();

    try {
      _movies = await _movieRepository.getMoviesByGenre(genre);
    } catch (e) {
      print('Lỗi khi lọc theo thể loại: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch movies by genre (without changing _movies state)
  Future<List<Movie>> fetchMoviesByGenre(String genre, {int limit = 20}) async {
    try {
      return await _movieRepository.getMoviesByGenre(genre, limit: limit);
    } catch (e) {
      print('Lỗi khi tải phim theo thể loại: $e');
      return [];
    }
  }

  // Filter by year
  Future<void> filterByYear(int year) async {
    _isLoading = true;
    notifyListeners();

    try {
      _movies = await _movieRepository.getMoviesByYear(year);
    } catch (e) {
      print('Lỗi khi lọc theo năm: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter by country
  Future<void> filterByCountry(String country) async {
    _isLoading = true;
    notifyListeners();

    try {
      _movies = await _movieRepository.getMoviesByCountry(country);
    } catch (e) {
      print('Lỗi khi lọc theo quốc gia: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user's favorites
  Future<void> fetchFavorites(String userId) async {
    try {
      _favorites = await _movieRepository.getUserFavorites(userId);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải danh sách yêu thích: $e');
    }
  }

  // Add to favorites
  Future<void> addToFavorites(String userId, String movieId) async {
    try {
      await _movieRepository.addToFavorites(userId, movieId);
      await fetchFavorites(userId);
    } catch (e) {
      print('Lỗi khi thêm vào yêu thích: $e');
      rethrow;
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String movieId) async {
    try {
      await _movieRepository.removeFromFavorites(userId, movieId);
      await fetchFavorites(userId);
    } catch (e) {
      print('Lỗi khi xóa khỏi yêu thích: $e');
      rethrow;
    }
  }

  // Check if movie is in favorites
  bool isInFavorites(String movieId) {
    return _favorites.any((movie) => movie.id == movieId);
  }

  // Clear selected movie
  void clearSelectedMovie() {
    _selectedMovie = null;
    notifyListeners();
  }
}
