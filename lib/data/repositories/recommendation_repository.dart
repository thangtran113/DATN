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
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
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
      print('Error getting similar movies: $e');
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

      return snapshot.docs
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting trending movies: $e');
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

      return snapshot.docs
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting popular movies: $e');
      return [];
    }
  }

  /// Recommendations dựa trên watch history
  Future<List<Movie>> getPersonalizedRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Lấy watch history của user
      final historySnapshot = await _firestore
          .collection('watch_history')
          .where('userId', isEqualTo: userId)
          .orderBy('lastWatchedAt', descending: true)
          .limit(20)
          .get();

      if (historySnapshot.docs.isEmpty) {
        // Nếu chưa có history, return trending
        return await _getTrendingMovies(limit: limit);
      }

      // Lấy movieIds từ history
      final watchedMovieIds = historySnapshot.docs
          .map((doc) => doc['movieId'] as String)
          .toList();

      // Lấy thông tin các movies đã xem
      final moviesSnapshot = await _firestore
          .collection('movies')
          .where(
            FieldPath.documentId,
            whereIn: watchedMovieIds.take(10).toList(),
          )
          .get();

      // Collect tất cả genres user đã xem
      final allGenres = <String>{};
      for (final doc in moviesSnapshot.docs) {
        final movie = Movie.fromJson(doc.data() as Map<String, dynamic>);
        allGenres.addAll(movie.genres);
      }

      if (allGenres.isEmpty) {
        return await _getTrendingMovies(limit: limit);
      }

      // Recommend movies với genres tương tự (nhưng chưa xem)
      final recommendSnapshot = await _firestore
          .collection('movies')
          .where('genres', arrayContainsAny: allGenres.take(10).toList())
          .limit(limit * 3)
          .get();

      final recommendations = recommendSnapshot.docs
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .where((movie) => !watchedMovieIds.contains(movie.id))
          .toList();

      // Sort theo số genre match
      recommendations.sort((a, b) {
        final aMatches = a.genres.where((g) => allGenres.contains(g)).length;
        final bMatches = b.genres.where((g) => allGenres.contains(g)).length;
        if (bMatches != aMatches) return bMatches.compareTo(aMatches);
        // Secondary sort by rating
        return b.rating.compareTo(a.rating);
      });

      return recommendations.take(limit).toList();
    } catch (e) {
      print('Error getting personalized recommendations: $e');
      return await _getTrendingMovies(limit: limit);
    }
  }

  /// Recommendations dựa trên ratings của user
  Future<List<Movie>> getRecommendationsFromRatings({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Lấy movies user đã rate >= 4 stars
      final ratingsSnapshot = await _firestore
          .collection('movie_ratings')
          .where('userId', isEqualTo: userId)
          .where('rating', isGreaterThanOrEqualTo: 4.0)
          .limit(20)
          .get();

      if (ratingsSnapshot.docs.isEmpty) {
        return await _getTrendingMovies(limit: limit);
      }

      // Lấy movieIds
      final likedMovieIds = ratingsSnapshot.docs
          .map((doc) => doc['movieId'] as String)
          .toList();

      // Lấy thông tin movies
      final moviesSnapshot = await _firestore
          .collection('movies')
          .where(FieldPath.documentId, whereIn: likedMovieIds.take(10).toList())
          .get();

      // Collect genres
      final favoriteGenres = <String>{};
      for (final doc in moviesSnapshot.docs) {
        final movie = Movie.fromJson(doc.data() as Map<String, dynamic>);
        favoriteGenres.addAll(movie.genres);
      }

      if (favoriteGenres.isEmpty) {
        return await _getTrendingMovies(limit: limit);
      }

      // Recommend similar movies
      final recommendSnapshot = await _firestore
          .collection('movies')
          .where('genres', arrayContainsAny: favoriteGenres.take(10).toList())
          .where('rating', isGreaterThanOrEqualTo: 3.5)
          .limit(limit * 3)
          .get();

      final recommendations = recommendSnapshot.docs
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .where((movie) => !likedMovieIds.contains(movie.id))
          .toList();

      // Sort
      recommendations.sort((a, b) {
        final aMatches = a.genres
            .where((g) => favoriteGenres.contains(g))
            .length;
        final bMatches = b.genres
            .where((g) => favoriteGenres.contains(g))
            .length;
        if (bMatches != aMatches) return bMatches.compareTo(aMatches);
        return b.rating.compareTo(a.rating);
      });

      return recommendations.take(limit).toList();
    } catch (e) {
      print('Error getting recommendations from ratings: $e');
      return await _getTrendingMovies(limit: limit);
    }
  }

  /// New releases (phim mới nhất)
  Future<List<Movie>> getNewReleases({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('year', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting new releases: $e');
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

      return snapshot.docs
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting top rated: $e');
      return [];
    }
  }
}
