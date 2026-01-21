import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/movie.dart';

/// Repository cho recommendation system
class RecommendationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy similar movies dựa trên genres
  Future<List<Movie>> getSimilarMovies({
    required String movieId,
    required List<String> genres,
    int limit = 10,
  }) async {
    try {
      if (genres.isEmpty) {
        return await _getTrendingMovies(limit: limit);
      }

      // Lấy movies có cùng genre
      final snapshot = await _firestore
          .collection('movies')
          .where('genres', arrayContainsAny: genres.take(10).toList())
          .limit(limit * 2)
          .get();

      final movies = snapshot.docs
          .map((doc) => Movie.fromJson(doc.data()))
          .where((movie) => movie.id != movieId) // Loại bỏ chính phim đó
          .toList();

      // Sort theo số genre match
      movies.sort((a, b) {
        final aMatches = a.genres.where((g) => genres.contains(g)).length;
        final bMatches = b.genres.where((g) => genres.contains(g)).length;
        return bMatches.compareTo(aMatches);
      });

      return movies.take(limit).toList();
    } catch (e) {
      print('Lỗi khi lấy phim tương tự: $e');
      return [];
    }
  }

  /// Lấy trending movies (nhiều views nhất tuần này)
  Future<List<Movie>> getTrendingMovies({int limit = 10}) async {
    return await _getTrendingMovies(limit: limit);
  }

  Future<List<Movie>> _getTrendingMovies({required int limit}) async {
    try {
      // Lấy movies có viewCount cao nhất
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList();
    } catch (e) {
      print('Lỗi khi lấy phim đang thịnh hành: $e');
      return [];
    }
  }

  /// Lấy popular movies (rating cao + nhiều ratings)
  Future<List<Movie>> getPopularMovies({int limit = 10}) async {
    try {
      // Lấy movies có rating >= 4.0
      final snapshot = await _firestore
          .collection('movies')
          .where('rating', isGreaterThanOrEqualTo: 4.0)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList();
    } catch (e) {
      print('Lỗi khi lấy phim phổ biến: $e');
      return [];
    }
  }

  /// Tạm thời bỏ getPersonalizedRecommendations do chưa có watch history
  /// Sẽ trả về trending movies thay thế
  Future<List<Movie>> getPersonalizedRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    // Return trending movies instead
    return await _getTrendingMovies(limit: limit);
  }

  /// Tạm thời bỏ getRecommendationsFromRatings vì chưa có rating UI
  /// Sẽ trả về trending movies thay thế
  Future<List<Movie>> getRecommendationsFromRatings({
    required String userId,
    int limit = 10,
  }) async {
    // Return trending movies instead
    return await _getTrendingMovies(limit: limit);
  }

  /// New releases (phim mới nhất)
  Future<List<Movie>> getNewReleases({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('year', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList();
    } catch (e) {
      print('Lỗi khi lấy phim mới phát hành: $e');
      return [];
    }
  }

  /// Top rated movies all time
  Future<List<Movie>> getTopRated({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('rating', isGreaterThan: 0)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList();
    } catch (e) {
      print('Lỗi khi lấy phim được đánh giá cao: $e');
      return [];
    }
  }
}
