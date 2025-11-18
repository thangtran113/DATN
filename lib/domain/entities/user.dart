class User {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> favoriteMovieIds;
  final List<String> watchlistIds;
  final Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.favoriteMovieIds = const [],
    this.watchlistIds = const [],
    this.preferences,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? favoriteMovieIds,
    List<String>? watchlistIds,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteMovieIds: favoriteMovieIds ?? this.favoriteMovieIds,
      watchlistIds: watchlistIds ?? this.watchlistIds,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'favoriteMovieIds': favoriteMovieIds,
      'watchlistIds': watchlistIds,
      'preferences': preferences,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      favoriteMovieIds:
          (json['favoriteMovieIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      watchlistIds:
          (json['watchlistIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }
}
