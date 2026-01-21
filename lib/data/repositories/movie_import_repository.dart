import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/tmdb_service.dart';
import '../../domain/entities/movie.dart';

/// Repository for importing movies from TMDB (metadata only)
/// Subtitles and videos are uploaded manually via admin panel
class MovieImportRepository {
  final TMDBService _tmdbService = TMDBService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Import a movie from TMDB by ID with Vietnamese metadata (fallback to English)
  /// Note: Only imports metadata (title, description, poster, etc.). Video, trailer and subtitles must be uploaded manually.
  Future<Movie> importMovieFromTMDB(int tmdbId) async {
    try {
      // Step 1: Get movie details from TMDB in Vietnamese
      print('Lấy thông tin chi tiết phim từ TMDB (Tiếng Việt)...');
      final tmdbMovieVi = await _tmdbService.getMovieDetails(
        tmdbId,
        language: 'vi',
      );

      // Step 2: Get English version for fallback (if Vietnamese is empty)
      print('Lấy phiên bản tiếng Anh để dự phòng...');
      final tmdbMovieEn = await _tmdbService.getMovieDetails(
        tmdbId,
        language: 'en-US',
      );

      // Step 3: Merge data - use Vietnamese if available, otherwise English
      final tmdbMovie = _mergeMovieData(tmdbMovieVi, tmdbMovieEn);

      // Step 4: Convert to our format
      final movieData = _tmdbService.convertToMovieFormat(tmdbMovie);
      movieData['trailerUrl'] =
          null; // Will be uploaded manually via admin panel
      movieData['videoUrl'] = null; // Will be uploaded manually via admin panel

      // Step 5: Create Firestore document
      print('Đang lưu vào Firestore...');
      final docRef = _firestore.collection('movies').doc();

      final movie = Movie(
        id: docRef.id,
        title: movieData['title'],
        description: movieData['description'],
        posterUrl: movieData['posterUrl'],
        backdropUrl: movieData['backdropUrl'],
        trailerUrl: movieData['trailerUrl'],
        videoUrl: movieData['videoUrl'],
        duration: movieData['duration'],
        genres: List<String>.from(movieData['genres']),
        languages: List<String>.from(movieData['languages']),
        rating: movieData['rating'],
        year: movieData['year'],
        cast: List<String>.from(movieData['cast']),
        director: movieData['director'],
        country: movieData['country'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subtitles: null, // Will be added when uploaded via admin panel
      );

      await docRef.set(movie.toJson());

      print('Phim đã nhập thành công: ${movie.title}');
      return movie;
    } catch (e) {
      throw Exception('Failed to import movie: $e');
    }
  }

  /// Import multiple popular movies with Vietnamese metadata
  Future<List<Movie>> importPopularMovies({int count = 20}) async {
    try {
      print('Lấy phim phổ biến từ TMDB (Tiếng Việt)...');
      final popularMovies = await _tmdbService.getPopularMovies(language: 'vi');

      final movies = <Movie>[];
      final limit = count > popularMovies.length ? popularMovies.length : count;

      for (var i = 0; i < limit; i++) {
        try {
          final tmdbId = popularMovies[i]['id'];
          print('Đang nhập phim ${i + 1}/$limit (TMDB ID: $tmdbId)...');

          final movie = await importMovieFromTMDB(tmdbId);

          movies.add(movie);

          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          print('Thất bại khi nhập phim ${i + 1}: $e');
          continue; // Skip failed imports
        }
      }

      return movies;
    } catch (e) {
      throw Exception('Failed to import popular movies: $e');
    }
  }

  /// Merge Vietnamese and English movie data
  /// Priority: Vietnamese > English
  Map<String, dynamic> _mergeMovieData(
    Map<String, dynamic> viData,
    Map<String, dynamic> enData,
  ) {
    final merged = Map<String, dynamic>.from(enData);

    // Override with Vietnamese data if available
    if (viData['title'] != null && viData['title'].toString().isNotEmpty) {
      merged['title'] = viData['title'];
    }

    if (viData['overview'] != null &&
        viData['overview'].toString().isNotEmpty) {
      merged['overview'] = viData['overview'];
    }

    // Merge genres (prefer Vietnamese names)
    if (viData['genres'] != null && (viData['genres'] as List).isNotEmpty) {
      merged['genres'] = viData['genres'];
    }

    // Keep English data for: release_date, vote_average, runtime, credits, videos
    // These don't change by language

    print(
      'Merged data - Title: ${merged['title']}, Has Vietnamese overview: ${viData['overview']?.toString().isNotEmpty}',
    );

    return merged;
  }

  /// Search movies on TMDB
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    return await _tmdbService.searchMovies(query);
  }
}
