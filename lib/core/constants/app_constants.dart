// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Movie Learning App';
  static const String appVersion = '1.0.0';

  // API Keys (To be replaced with actual keys)
  static const String dictionaryApiUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String moviesCollection = 'movies';
  static const String commentsCollection = 'comments';
  static const String vocabularyCollection = 'vocabulary';
  static const String historyCollection = 'history';
  static const String watchlistCollection = 'watchlist';
  static const String loopsCollection = 'loops';
  static const String notificationsCollection = 'notifications';
  static const String analyticsCollection = 'analytics';

  // Pagination
  static const int moviesPerPage = 20;
  static const int commentsPerPage = 20;

  // Video Player
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Learning Levels
  static const List<String> learningLevels = [
    'beginner',
    'intermediate',
    'advanced',
  ];

  // Movie Genres
  static const List<String> movieGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'War',
    'Western',
  ];

  // Subtitle Languages
  static const String englishLanguage = 'en';
  static const String vietnameseLanguage = 'vi';

  // User Roles
  static const String userRole = 'user';
  static const String adminRole = 'admin';

  // Mastery Levels
  static const String masteryNew = 'new';
  static const String masteryLearning = 'learning';
  static const String masteryMastered = 'mastered';
}
