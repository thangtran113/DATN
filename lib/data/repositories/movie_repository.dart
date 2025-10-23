import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/movie.dart';

class MovieRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all movies with pagination
  Future<List<Movie>> getMovies({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('movies')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    }
  }

  // Get movie by ID
  Future<Movie?> getMovieById(String movieId) async {
    try {
      final doc = await _firestore.collection('movies').doc(movieId).get();
      if (doc.exists) {
        return Movie.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch movie: $e');
    }
  }

  // Search movies by title
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  // Filter movies by genre
  Future<List<Movie>> getMoviesByGenre(String genre, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('genres', arrayContains: genre)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movies by genre: $e');
    }
  }

  // Filter movies by level
  Future<List<Movie>> getMoviesByLevel(String level, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('level', isEqualTo: level)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movies by level: $e');
    }
  }

  // Get popular movies (by view count)
  Future<List<Movie>> getPopularMovies({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular movies: $e');
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String movieId) async {
    try {
      await _firestore.collection('movies').doc(movieId).update({
        'viewCount': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to increment view count: $e');
    }
  }

  // Add movie to user's watchlist
  Future<void> addToWatchlist(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'watchlist': FieldValue.arrayUnion([movieId]),
      });
    } catch (e) {
      throw Exception('Failed to add to watchlist: $e');
    }
  }

  // Remove movie from user's watchlist
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'watchlist': FieldValue.arrayRemove([movieId]),
      });
    } catch (e) {
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  // Add movie to user's favorites
  Future<void> addToFavorites(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([movieId]),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // Remove movie from user's favorites
  Future<void> removeFromFavorites(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([movieId]),
      });
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Get user's watchlist
  Future<List<Movie>> getUserWatchlist(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final watchlist = List<String>.from(userDoc.data()?['watchlist'] ?? []);

      if (watchlist.isEmpty) return [];

      final movies = await Future.wait(
        watchlist.map((movieId) => getMovieById(movieId)),
      );

      return movies.whereType<Movie>().toList();
    } catch (e) {
      throw Exception('Failed to fetch watchlist: $e');
    }
  }

  // Get user's favorites
  Future<List<Movie>> getUserFavorites(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);

      if (favorites.isEmpty) return [];

      final movies = await Future.wait(
        favorites.map((movieId) => getMovieById(movieId)),
      );

      return movies.whereType<Movie>().toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  // Admin: Add new movie
  Future<void> addMovie(Movie movie) async {
    try {
      await _firestore.collection('movies').add(movie.toJson());
    } catch (e) {
      throw Exception('Failed to add movie: $e');
    }
  }

  // Admin: Update movie
  Future<void> updateMovie(Movie movie) async {
    try {
      await _firestore.collection('movies').doc(movie.id).update(movie.toJson());
    } catch (e) {
      throw Exception('Failed to update movie: $e');
    }
  }

  // Admin: Delete movie
  Future<void> deleteMovie(String movieId) async {
    try {
      await _firestore.collection('movies').doc(movieId).delete();
    } catch (e) {
      throw Exception('Failed to delete movie: $e');
    }
  }
}
