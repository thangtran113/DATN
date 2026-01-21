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

  /// Tìm kiếm phim theo tên (không phân biệt chữ hoa/thường)
  Future<List<Movie>> searchMovies(String query) async {
    try {
      // Lấy tất cả phim để search ở client side (case-insensitive)
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('title')
          .limit(100)
          .get();

      final queryLower = query.toLowerCase().trim();

      // Filter ở client side để không phân biệt hoa/thường
      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .where((movie) => movie.title.toLowerCase().contains(queryLower))
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

  /// Lọc phim theo năm
  Future<List<Movie>> getMoviesByYear(int year, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('year', isEqualTo: year)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải phim theo năm: $e');
    }
  }

  /// Lọc phim theo quốc gia (case-insensitive search)
  Future<List<Movie>> getMoviesByCountry(
    String countryQuery, {
    int limit = 100,
  }) async {
    try {
      // Lấy tất cả phim và filter ở client side
      final snapshot = await _firestore.collection('movies').limit(limit).get();

      final queryLower = countryQuery.toLowerCase().trim();

      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .where(
            (movie) =>
                movie.country != null &&
                movie.country!.toLowerCase().contains(queryLower),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể tải phim theo quốc gia: $e');
    }
  }

  /// Lấy phim phổ biến (theo rating)
  Future<List<Movie>> getPopularMovies({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Movie.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải phim phổ biến: $e');
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
