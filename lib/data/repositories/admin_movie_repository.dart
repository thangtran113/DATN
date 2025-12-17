import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/movie.dart';

/// Repository for admin movie management
class AdminMovieRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new movie
  Future<void> createMovie(Movie movie) async {
    try {
      await _firestore.collection('movies').doc(movie.id).set({
        'id': movie.id,
        'title': movie.title,
        'description': movie.description,
        'posterUrl': movie.posterUrl,
        'backdropUrl': movie.backdropUrl,
        'trailerUrl': movie.trailerUrl,
        'videoUrl': movie.videoUrl,
        'duration': movie.duration,
        'genres': movie.genres,
        'languages': movie.languages,
        'rating': movie.rating,
        'year': movie.year,
        'cast': movie.cast,
        'director': movie.director,
        'subtitles': movie.subtitles,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create movie: $e');
    }
  }

  /// Update an existing movie
  Future<void> updateMovie(Movie movie) async {
    try {
      await _firestore.collection('movies').doc(movie.id).update({
        'title': movie.title,
        'description': movie.description,
        'posterUrl': movie.posterUrl,
        'backdropUrl': movie.backdropUrl,
        'trailerUrl': movie.trailerUrl,
        'videoUrl': movie.videoUrl,
        'duration': movie.duration,
        'genres': movie.genres,
        'languages': movie.languages,
        'rating': movie.rating,
        'year': movie.year,
        'cast': movie.cast,
        'director': movie.director,
        'subtitles': movie.subtitles,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update movie: $e');
    }
  }

  /// Delete a movie
  Future<void> deleteMovie(String movieId) async {
    try {
      // Delete movie document
      await _firestore.collection('movies').doc(movieId).delete();

      // Clean up related data (optional - có thể để cascade)
      // Delete vocabulary for this movie
      final vocabSnapshot = await _firestore
          .collection('vocabulary')
          .where('movieId', isEqualTo: movieId)
          .get();

      for (final doc in vocabSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete comments
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('movieId', isEqualTo: movieId)
          .get();

      for (final doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete ratings
      final ratingsSnapshot = await _firestore
          .collection('movie_ratings')
          .where('movieId', isEqualTo: movieId)
          .get();

      for (final doc in ratingsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete from watchlists
      final watchlistSnapshot = await _firestore
          .collection('watchlist')
          .where('movieId', isEqualTo: movieId)
          .get();

      for (final doc in watchlistSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete from watch history
      final historySnapshot = await _firestore
          .collection('watch_history')
          .where('movieId', isEqualTo: movieId)
          .get();

      for (final doc in historySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete movie: $e');
    }
  }

  /// Get all movies (paginated)
  Future<List<Movie>> getAllMovies({
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
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get movies: $e');
    }
  }

  /// Search movies by title
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  /// Get movie statistics (calculated from real data)
  Future<Map<String, dynamic>> getMovieStatistics() async {
    try {
      // Get total movies
      final moviesSnapshot = await _firestore.collection('movies').get();
      final totalMovies = moviesSnapshot.docs.length;

      // Count REAL view count from watch_history
      final historySnapshot = await _firestore
          .collection('watch_history')
          .get();
      final uniqueViews = <String>{}; // Track unique movie views
      for (final doc in historySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          final movieId = data?['movieId'];
          if (movieId != null && movieId is String) uniqueViews.add(movieId);
        } catch (e) {
          // Skip invalid documents
          continue;
        }
      }
      final totalViews = historySnapshot.docs.length; // Total watch sessions

      // Calculate REAL average rating from movie_ratings
      final ratingsSnapshot = await _firestore
          .collection('movie_ratings')
          .get();
      double totalRating = 0;
      int ratedMovies = 0;
      final movieRatings = <String, List<double>>{};

      for (final doc in ratingsSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final movieId = data['movieId'];
          final rating = data['rating'];

          if (movieId != null && movieId is String && rating != null) {
            final ratingValue = (rating is num) ? rating.toDouble() : 0.0;
            if (ratingValue > 0) {
              movieRatings.putIfAbsent(movieId, () => []).add(ratingValue);
            }
          }
        } catch (e) {
          // Skip invalid documents
          continue;
        }
      }

      // Calculate average for each movie
      for (final ratings in movieRatings.values) {
        final avg = ratings.reduce((a, b) => a + b) / ratings.length;
        totalRating += avg;
        ratedMovies++;
      }

      return {
        'totalMovies': totalMovies,
        'totalViews': totalViews,
        'averageRating': ratedMovies > 0 ? totalRating / ratedMovies : 0,
        'ratedMovies': ratedMovies,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Bulk import movies (from JSON list)
  Future<void> bulkImportMovies(List<Map<String, dynamic>> moviesList) async {
    try {
      final batch = _firestore.batch();

      for (final movieData in moviesList) {
        final docRef = _firestore.collection('movies').doc();
        batch.set(docRef, {
          ...movieData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk import: $e');
    }
  }
}
