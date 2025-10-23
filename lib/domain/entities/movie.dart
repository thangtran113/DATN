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
      genres: List<String>.from(json['genres'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      year: json['year'] ?? 2024,
      cast: List<String>.from(json['cast'] ?? []),
      director: json['director'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      viewCount: json['viewCount'] ?? 0,
      subtitles: json['subtitles'] as Map<String, dynamic>?,
    );
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
