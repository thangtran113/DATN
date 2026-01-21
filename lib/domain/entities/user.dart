class User {
  final String id;
  final String username;
  final String? email; // Nullable cho anonymous users
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> favoriteMovieIds;
  final Map<String, dynamic>? preferences;
  final bool isAdmin; // Admin role
  final bool isBanned; // Banned users
  final bool isAnonymous; // Anonymous/guest users

  User({
    required this.id,
    required this.username,
    this.email, // Nullable
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.favoriteMovieIds = const [],
    this.preferences,
    this.isAdmin = false,
    this.isBanned = false,
    this.isAnonymous = false,
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
    Map<String, dynamic>? preferences,
    bool? isAdmin,
    bool? isBanned,
    bool? isAnonymous,
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
      preferences: preferences ?? this.preferences,
      isAdmin: isAdmin ?? this.isAdmin,
      isBanned: isBanned ?? this.isBanned,
      isAnonymous: isAnonymous ?? this.isAnonymous,
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
      'preferences': preferences,
      'isAdmin': isAdmin,
      'isBanned': isBanned,
      'isAnonymous': isAnonymous,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      favoriteMovieIds:
          (json['favoriteMovieIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferences: json['preferences'] as Map<String, dynamic>?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isBanned: json['isBanned'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }
}
