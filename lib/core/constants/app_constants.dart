/// Hằng số toàn ứng dụng
class AppConstants {
  /// Thông tin ứng dụng
  static const String appName = 'Movie Learning App';
  static const String appVersion = '1.0.0';

  /// URL API từ điển
  static const String dictionaryApiUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Tên các collection trong Firestore
  static const String usersCollection = 'users';
  static const String moviesCollection = 'movies';
  static const String commentsCollection = 'comments';
  static const String vocabularyCollection = 'vocabulary';
  static const String historyCollection = 'history';
  static const String watchlistCollection = 'watchlist';
  static const String loopsCollection = 'loops';
  static const String notificationsCollection = 'notifications';
  static const String analyticsCollection = 'analytics';

  /// Cài đặt phân trang
  static const int moviesPerPage = 20;
  static const int commentsPerPage = 20;

  /// Tốc độ phát video
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  /// Thể loại phim
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

  /// Ngôn ngữ phụ đề
  static const String englishLanguage = 'en';
  static const String vietnameseLanguage = 'vi';

  /// Vai trò người dùng
  static const String userRole = 'user';
  static const String adminRole = 'admin';

  /// Mức độ thành thạo
  static const String masteryNew = 'new';
  static const String masteryLearning = 'learning';
  static const String masteryMastered = 'mastered';
}
