import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/movie.dart';

/// Repository xử lý dữ liệu phim
class MovieRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách phim với phân trang
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

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách phim: $e');
    }
  }

  /// Lấy phim theo ID
  Future<Movie?> getMovieById(String movieId) async {
    try {
      final doc = await _firestore.collection('movies').doc(movieId).get();
      if (!doc.exists) return null;
      return Movie.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Không thể tải phim: $e');
    }
  }

  /// Tìm kiếm phim theo tên
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
      throw Exception('Không thể tìm kiếm phim: $e');
    }
  }

  /// Lọc phim theo thể loại
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
      throw Exception('Không thể tải phim theo thể loại: $e');
    }
  }

  /// Lọc phim theo cấp độ
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
      throw Exception('Không thể tải phim theo cấp độ: $e');
    }
  }

  /// Lấy phim phổ biến (theo lượt xem)
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
      throw Exception('Không thể tải phim phổ biến: $e');
    }
  }

  /// Tăng lượt xem phim
  Future<void> incrementViewCount(String movieId) async {
    try {
      await _firestore.collection('movies').doc(movieId).update({
        'viewCount': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Không thể tăng lượt xem: $e');
    }
  }

  /// Thêm phim vào danh sách xem sau
  Future<void> addToWatchlist(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'watchlist': FieldValue.arrayUnion([movieId]),
      });
    } catch (e) {
      throw Exception('Không thể thêm vào watchlist: $e');
    }
  }

  /// Xóa phim khỏi danh sách xem sau
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'watchlist': FieldValue.arrayRemove([movieId]),
      });
    } catch (e) {
      throw Exception('Không thể xóa khỏi watchlist: $e');
    }
  }

  /// Thêm phim vào yêu thích
  Future<void> addToFavorites(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([movieId]),
      });
    } catch (e) {
      throw Exception('Không thể thêm vào yêu thích: $e');
    }
  }

  /// Xóa phim khỏi yêu thích
  Future<void> removeFromFavorites(String userId, String movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([movieId]),
      });
    } catch (e) {
      throw Exception('Không thể xóa khỏi yêu thích: $e');
    }
  }

  /// Lấy danh sách phim xem sau của user
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
      throw Exception('Không thể tải watchlist: $e');
    }
  }

  /// Lấy danh sách phim yêu thích của user
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
      throw Exception('Không thể tải danh sách yêu thích: $e');
    }
  }

  /// [ADMIN] Thêm phim mới
  Future<void> addMovie(Movie movie) async {
    try {
      await _firestore.collection('movies').add(movie.toJson());
    } catch (e) {
      throw Exception('Không thể thêm phim: $e');
    }
  }

  /// [ADMIN] Cập nhật phim
  Future<void> updateMovie(Movie movie) async {
    try {
      await _firestore
          .collection('movies')
          .doc(movie.id)
          .update(movie.toJson());
    } catch (e) {
      throw Exception('Không thể cập nhật phim: $e');
    }
  }

  /// [ADMIN] Xóa phim
  Future<void> deleteMovie(String movieId) async {
    try {
      await _firestore.collection('movies').doc(movieId).delete();
    } catch (e) {
      throw Exception('Không thể xóa phim: $e');
    }
  }
}
