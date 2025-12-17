import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/movie_rating.dart';

/// Repository quản lý movie ratings
class MovieRatingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _ratingsCollection = 'movie_ratings';
  final String _moviesCollection = 'movies';

  /// Lấy ratings collection reference
  CollectionReference get _ratings => _firestore.collection(_ratingsCollection);

  /// Rate phim (create hoặc update)
  Future<bool> rateMovie({
    required String userId,
    required String movieId,
    required double rating,
    String? review,
  }) async {
    try {
      // Validate rating
      if (rating < 1 || rating > 5) {
        throw ArgumentError('Rating must be between 1 and 5');
      }

      // Tìm rating hiện tại của user
      final existing = await _ratings
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      final data = {
        'userId': userId,
        'movieId': movieId,
        'rating': rating,
        'review': review,
      };

      if (existing.docs.isEmpty) {
        // Create new rating
        data['createdAt'] = FieldValue.serverTimestamp();
        await _ratings.add(data);
      } else {
        // Update existing rating
        data['updatedAt'] = FieldValue.serverTimestamp();
        await existing.docs.first.reference.update(data);
      }

      // Update movie's average rating
      await _updateMovieRatingStats(movieId);

      return true;
    } catch (e) {
      print('Error rating movie: $e');
      return false;
    }
  }

  /// Lấy rating của user cho 1 phim
  Future<MovieRating?> getUserRating({
    required String userId,
    required String movieId,
  }) async {
    try {
      final snapshot = await _ratings
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return MovieRating.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting user rating: $e');
      return null;
    }
  }

  /// Stream user's rating cho realtime updates
  Stream<MovieRating?> watchUserRating({
    required String userId,
    required String movieId,
  }) {
    return _ratings
        .where('userId', isEqualTo: userId)
        .where('movieId', isEqualTo: movieId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return MovieRating.fromFirestore(snapshot.docs.first);
        });
  }

  /// Lấy tất cả ratings của 1 phim
  Stream<List<MovieRating>> getMovieRatings(String movieId) {
    return _ratings
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MovieRating.fromFirestore(doc))
              .toList();
        });
  }

  /// Tính rating stats cho phim
  Future<MovieRatingStats> getMovieRatingStats(String movieId) async {
    try {
      final snapshot = await _ratings
          .where('movieId', isEqualTo: movieId)
          .get();

      if (snapshot.docs.isEmpty) {
        return MovieRatingStats(
          movieId: movieId,
          averageRating: 0.0,
          totalRatings: 0,
          ratingDistribution: {},
        );
      }

      final ratings = snapshot.docs
          .map((doc) => MovieRating.fromFirestore(doc))
          .toList();

      // Calculate average
      final sum = ratings.fold(0.0, (sum, r) => sum + r.rating);
      final average = sum / ratings.length;

      // Calculate distribution
      final distribution = <int, int>{};
      for (final rating in ratings) {
        final stars = rating.rating.round();
        distribution[stars] = (distribution[stars] ?? 0) + 1;
      }

      return MovieRatingStats(
        movieId: movieId,
        averageRating: average,
        totalRatings: ratings.length,
        ratingDistribution: distribution,
      );
    } catch (e) {
      print('Error getting rating stats: $e');
      return MovieRatingStats(
        movieId: movieId,
        averageRating: 0.0,
        totalRatings: 0,
        ratingDistribution: {},
      );
    }
  }

  /// Update average rating trong movie document
  Future<void> _updateMovieRatingStats(String movieId) async {
    try {
      final stats = await getMovieRatingStats(movieId);

      await _firestore.collection(_moviesCollection).doc(movieId).update({
        'averageRating': stats.averageRating,
        'totalRatings': stats.totalRatings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating movie rating stats: $e');
    }
  }

  /// Xóa rating của user
  Future<bool> deleteRating({
    required String userId,
    required String movieId,
  }) async {
    try {
      final snapshot = await _ratings
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      await snapshot.docs.first.reference.delete();

      // Update movie stats
      await _updateMovieRatingStats(movieId);

      return true;
    } catch (e) {
      print('Error deleting rating: $e');
      return false;
    }
  }
}
