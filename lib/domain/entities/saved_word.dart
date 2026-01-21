/// Entity đại diện cho một từ vựng đã lưu của người dùng
class SavedWord {
  final String id;
  final String userId;
  final String word;
  final String meaning; // Nghĩa tiếng Anh
  final String? vietnameseMeaning; // Nghĩa tiếng Việt
  final String? pronunciation;
  final String? example;
  final DateTime createdAt;
  final int masteryLevel; // 0-4: chưa học -> thành thạo
  final int reviewCount; // Số lần ôn tập
  final DateTime? lastReviewedAt;

  SavedWord({
    required this.id,
    required this.userId,
    required this.word,
    required this.meaning,
    this.vietnameseMeaning,
    this.pronunciation,
    this.example,
    required this.createdAt,
    this.masteryLevel = 0,
    this.reviewCount = 0,
    this.lastReviewedAt,
  });

  /// Tạo SavedWord từ Firestore document
  factory SavedWord.fromMap(Map<String, dynamic> map, String id) {
    return SavedWord(
      id: id,
      userId: map['userId'] ?? '',
      word: map['word'] ?? '',
      meaning: map['meaning'] ?? '',
      vietnameseMeaning: map['vietnameseMeaning'],
      pronunciation: map['pronunciation'],
      example: map['example'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
      masteryLevel: map['masteryLevel'] ?? 0,
      reviewCount: map['reviewCount'] ?? 0,
      lastReviewedAt: map['lastReviewedAt'] != null
          ? (map['lastReviewedAt'] as dynamic).toDate()
          : null,
    );
  }

  /// Chuyển SavedWord thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'word': word,
      'meaning': meaning,
      'vietnameseMeaning': vietnameseMeaning,
      'pronunciation': pronunciation,
      'example': example,
      'createdAt': createdAt,
      'masteryLevel': masteryLevel,
      'reviewCount': reviewCount,
      'lastReviewedAt': lastReviewedAt,
    };
  }

  /// Tạo bản sao với một số field thay đổi
  SavedWord copyWith({
    String? id,
    String? userId,
    String? word,
    String? meaning,
    String? vietnameseMeaning,
    String? pronunciation,
    String? example,
    DateTime? createdAt,
    int? masteryLevel,
    int? reviewCount,
    DateTime? lastReviewedAt,
  }) {
    return SavedWord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      vietnameseMeaning: vietnameseMeaning ?? this.vietnameseMeaning,
      pronunciation: pronunciation ?? this.pronunciation,
      example: example ?? this.example,
      createdAt: createdAt ?? this.createdAt,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  /// Tăng mastery level (tối đa 4)
  SavedWord incrementMasteryLevel() {
    return copyWith(
      masteryLevel: masteryLevel < 4 ? masteryLevel + 1 : 4,
      reviewCount: reviewCount + 1,
      lastReviewedAt: DateTime.now(),
    );
  }

  /// Giảm mastery level (tối thiểu 0)
  SavedWord decrementMasteryLevel() {
    return copyWith(
      masteryLevel: masteryLevel > 0 ? masteryLevel - 1 : 0,
      reviewCount: reviewCount + 1,
      lastReviewedAt: DateTime.now(),
    );
  }

  /// Kiểm tra xem từ có cần ôn tập không (dựa trên mastery level và thời gian)
  bool needsReview() {
    // TODO: Bật lại logic thời gian khi test xong
    // Tạm thời return true để test - tất cả từ đều cần ôn
    return true;

    /* Logic thời gian gốc (uncomment khi cần):
    if (lastReviewedAt == null) return true;

    final daysSinceLastReview = DateTime.now().difference(lastReviewedAt!).inDays;

    // Càng thành thạo thì càng ít cần ôn tập
    switch (masteryLevel) {
      case 0:
        return daysSinceLastReview >= 1; // Ôn lại mỗi ngày
      case 1:
        return daysSinceLastReview >= 3; // Ôn lại sau 3 ngày
      case 2:
        return daysSinceLastReview >= 7; // Ôn lại sau 1 tuần
      case 3:
        return daysSinceLastReview >= 14; // Ôn lại sau 2 tuần
      case 4:
        return daysSinceLastReview >= 30; // Ôn lại sau 1 tháng
      default:
        return true;
    }
    */
  }

  /// Lấy màu đại diện cho mastery level
  static String getMasteryColor(int level) {
    switch (level) {
      case 0:
        return '#FF6B6B'; // Đỏ - Chưa học
      case 1:
        return '#FFA07A'; // Cam nhạt - Mới học
      case 2:
        return '#FFD93D'; // Vàng - Đang học
      case 3:
        return '#6BCB77'; // Xanh lá nhạt - Khá
      case 4:
        return '#4D96FF'; // Xanh dương - Thành thạo
      default:
        return '#95A5A6'; // Xám
    }
  }

  /// Lấy nhãn cho mastery level
  static String getMasteryLabel(int level) {
    switch (level) {
      case 0:
        return 'Chưa học';
      case 1:
        return 'Mới học';
      case 2:
        return 'Đang học';
      case 3:
        return 'Khá';
      case 4:
        return 'Thành thạo';
      default:
        return 'Không rõ';
    }
  }
}
