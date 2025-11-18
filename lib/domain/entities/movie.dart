class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String? backdropUrl;
  final String? trailerUrl;
  final String? videoUrl;
  final int duration; // in minutes
  final String level; // beginner, intermediate, advanced
  final List<String> genres;
  final List<String> languages; // Available subtitle languages
  final double rating;
  final int year;
  final List<String> cast;
  final String director;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final Map<String, dynamic>? subtitles; // {en: url, vi: url}

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    this.backdropUrl,
    this.trailerUrl,
    this.videoUrl,
    required this.duration,
    required this.level,
    required this.genres,
    required this.languages,
    this.rating = 0.0,
    required this.year,
    this.cast = const [],
    required this.director,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.subtitles,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Handle subtitles - can be either array or map
    Map<String, dynamic>? subtitlesMap;
    final subtitlesData = json['subtitles'];
    if (subtitlesData is Map<String, dynamic>) {
      subtitlesMap = subtitlesData;
    } else if (subtitlesData is List) {
      // Convert array to map if needed (for backward compatibility)
      subtitlesMap = null; // Store as null, use languages field instead
    }

    // Safely parse arrays
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is Map) {
        // If map, extract values
        return value.values.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Safely parse languages from subtitles or languages field
    List<String> parseLanguages() {
      final subsData = json['subtitles'];
      if (subsData is Map) {
        return subsData.keys.map((e) => e.toString()).toList();
      }
      return parseStringList(json['languages']);
    }

    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      backdropUrl: json['backdropUrl'],
      trailerUrl: json['trailerUrl'],
      videoUrl: json['videoUrl'],
      duration: json['duration'] ?? 0,
      level: json['level'] ?? 'beginner',
      genres: parseStringList(json['genres']),
      languages: parseLanguages(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      year: json['year'] ?? 2024,
      cast: parseStringList(json['cast']),
      director: json['director'] ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      viewCount: json['viewCount'] ?? 0,
      subtitles: subtitlesMap,
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    } else {
      // Handle Firestore Timestamp (has toDate() method)
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'trailerUrl': trailerUrl,
      'videoUrl': videoUrl,
      'duration': duration,
      'level': level,
      'genres': genres,
      'languages': languages,
      'rating': rating,
      'year': year,
      'cast': cast,
      'director': director,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'viewCount': viewCount,
      'subtitles': subtitles,
    };
  }

  Movie copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    String? backdropUrl,
    String? trailerUrl,
    String? videoUrl,
    int? duration,
    String? level,
    List<String>? genres,
    List<String>? languages,
    double? rating,
    int? year,
    List<String>? cast,
    String? director,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    Map<String, dynamic>? subtitles,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      genres: genres ?? this.genres,
      languages: languages ?? this.languages,
      rating: rating ?? this.rating,
      year: year ?? this.year,
      cast: cast ?? this.cast,
      director: director ?? this.director,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      subtitles: subtitles ?? this.subtitles,
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get levelDisplay {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return level;
    }
  }
}
