import 'dart:convert';
import 'package:http/http.dart' as http;

/// TMDB API Service for fetching movie data
///
/// Get your free API key at: https://www.themoviedb.org/settings/api
/// Documentation: https://developers.themoviedb.org/3
class TMDBService {
  // TMDB API key
  static const String _apiKey = '84eb090f804d064459576ad0ddf4a7cb';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  /// Get popular movies
  Future<List<Map<String, dynamic>>> getPopularMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=$language&page=$page',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception(
          'Failed to load popular movies: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching popular movies: $e');
    }
  }

  /// Get movie details by TMDB ID
  /// language: 'vi' for Vietnamese, 'en-US' for English
  Future<Map<String, dynamic>> getMovieDetails(
    int movieId, {
    String language = 'vi',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=$language&append_to_response=videos,credits',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }

  /// Get movie trailer URL (YouTube)
  Future<String?> getMovieTrailer(int movieId, {String language = 'vi'}) async {
    try {
      final details = await getMovieDetails(movieId, language: language);
      final videos = details['videos']?['results'] as List?;

      if (videos != null && videos.isNotEmpty) {
        // Find official trailer or teaser
        final trailer = videos.firstWhere(
          (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
          orElse: () => videos.firstWhere(
            (v) => v['site'] == 'YouTube',
            orElse: () => null,
          ),
        );

        if (trailer != null) {
          final key = trailer['key'];
          return 'https://www.youtube.com/watch?v=$key';
        }
      }

      return null;
    } catch (e) {
      print('Lỗi khi lấy trailer: $e');
      return null;
    }
  }

  /// Search movies by title
  Future<List<Map<String, dynamic>>> searchMovies(
    String query, {
    int page = 1,
    String language = 'vi',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&language=$language&query=${Uri.encodeComponent(query)}&page=$page',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }

  /// Convert TMDB movie data to our Movie format
  Map<String, dynamic> convertToMovieFormat(Map<String, dynamic> tmdbMovie) {
    // Get genres from genre_ids or genres array
    List<String> genres = [];
    if (tmdbMovie['genres'] != null) {
      genres = (tmdbMovie['genres'] as List)
          .map((g) => g['name'] as String)
          .toList();
    } else if (tmdbMovie['genre_ids'] != null) {
      // Map genre IDs to names (common genres)
      final genreMap = {
        28: 'Action',
        12: 'Adventure',
        16: 'Animation',
        35: 'Comedy',
        80: 'Crime',
        99: 'Documentary',
        18: 'Drama',
        10751: 'Family',
        14: 'Fantasy',
        36: 'History',
        27: 'Horror',
        10402: 'Music',
        9648: 'Mystery',
        10749: 'Romance',
        878: 'Science Fiction',
        10770: 'TV Movie',
        53: 'Thriller',
        10752: 'War',
        37: 'Western',
      };

      genres = (tmdbMovie['genre_ids'] as List)
          .map((id) => genreMap[id] ?? 'Unknown')
          .toList();
    }

    // Get cast
    List<String> cast = [];
    if (tmdbMovie['credits'] != null && tmdbMovie['credits']['cast'] != null) {
      cast = (tmdbMovie['credits']['cast'] as List)
          .take(10) // Top 10 actors
          .map((c) => c['name'] as String)
          .toList();
    }

    // Get director
    String director = 'Unknown';
    if (tmdbMovie['credits'] != null && tmdbMovie['credits']['crew'] != null) {
      final crew = tmdbMovie['credits']['crew'] as List;
      final directorData = crew.firstWhere(
        (c) => c['job'] == 'Director',
        orElse: () => null,
      );
      if (directorData != null) {
        director = directorData['name'];
      }
    }

    // Extract year from release_date
    int year = DateTime.now().year;
    if (tmdbMovie['release_date'] != null &&
        tmdbMovie['release_date'].toString().isNotEmpty) {
      try {
        year = int.parse(tmdbMovie['release_date'].toString().substring(0, 4));
      } catch (e) {
        // Keep default year
      }
    }

    // Get production country
    String? country;
    if (tmdbMovie['production_countries'] != null &&
        (tmdbMovie['production_countries'] as List).isNotEmpty) {
      final countries = tmdbMovie['production_countries'] as List;
      country = countries[0]['name'] as String?;
    }

    return {
      'title': tmdbMovie['title'] ?? 'Unknown',
      'description': tmdbMovie['overview'] ?? '',
      'posterUrl': tmdbMovie['poster_path'] != null
          ? '$_imageBaseUrl/w500${tmdbMovie['poster_path']}'
          : '',
      'backdropUrl': tmdbMovie['backdrop_path'] != null
          ? '$_imageBaseUrl/original${tmdbMovie['backdrop_path']}'
          : null,
      'genres': genres,
      'year': year,
      'rating':
          (tmdbMovie['vote_average'] ?? 0.0).toDouble() /
          2, // Convert 0-10 to 0-5
      'cast': cast,
      'director': director,
      'country': country,
      'duration':
          tmdbMovie['runtime'] ?? 120, // Default 2 hours if not available
      'languages': ['en'], // Default English
      'viewCount': 0,
      // IMDB ID for OpenSubtitles
      'imdbId': tmdbMovie['imdb_id'],
    };
  }

  /// Get full image URL
  static String getImageUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    return '$_imageBaseUrl/$size$path';
  }
}
