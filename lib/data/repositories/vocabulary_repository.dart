import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/saved_word.dart';
import '../../core/constants/app_constants.dart';

/// Repository để quản lý từ vựng đã lưu của người dùng trong Firestore
class VocabularyRepository {
  final FirebaseFirestore _firestore;

  VocabularyRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lưu một từ vào danh sách từ vựng
  /// Returns: {'id': string, 'isNew': bool}
  Future<Map<String, dynamic>> saveWord(SavedWord word) async {
    try {
      // Kiểm tra xem từ đã tồn tại chưa
      final existing = await getWordByText(word.userId, word.word);
      if (existing != null) {
        // Từ đã tồn tại, không lưu lại
        return {'id': existing.id, 'isNew': false};
      }

      // Thêm từ mới
      final docRef = await _firestore
          .collection(AppConstants.vocabularyCollection)
          .add(word.toMap());

      return {'id': docRef.id, 'isNew': true};
    } catch (e) {
      throw Exception('Lỗi khi lưu từ: $e');
    }
  }

  /// Lấy một từ theo text và userId
  Future<SavedWord?> getWordByText(String userId, String wordText) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.vocabularyCollection)
          .where('userId', isEqualTo: userId)
          .where('word', isEqualTo: wordText)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return SavedWord.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('Lỗi khi lấy từ: $e');
      return null;
    }
  }

  /// Lấy tất cả từ vựng của một user
  Future<List<SavedWord>> getUserVocabulary(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.vocabularyCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SavedWord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách từ vựng: $e');
    }
  }

  /// Lấy từ vựng theo mastery level
  Future<List<SavedWord>> getVocabularyByMasteryLevel(
    String userId,
    int masteryLevel,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.vocabularyCollection)
          .where('userId', isEqualTo: userId)
          .where('masteryLevel', isEqualTo: masteryLevel)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SavedWord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lọc từ theo trình độ: $e');
    }
  }

  /// Lấy từ cần ôn tập (dựa trên mastery level và thời gian)
  Future<List<SavedWord>> getWordsForReview(String userId) async {
    try {
      final allWords = await getUserVocabulary(userId);
      return allWords.where((word) => word.needsReview()).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy từ cần ôn tập: $e');
    }
  }

  /// Cập nhật một từ
  Future<void> updateWord(String wordId, SavedWord word) async {
    try {
      await _firestore
          .collection(AppConstants.vocabularyCollection)
          .doc(wordId)
          .update(word.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật từ: $e');
    }
  }

  /// Cập nhật mastery level của một từ
  Future<void> updateMasteryLevel(String wordId, int newLevel) async {
    try {
      await _firestore
          .collection(AppConstants.vocabularyCollection)
          .doc(wordId)
          .update({
            'masteryLevel': newLevel,
            'reviewCount': FieldValue.increment(1),
            'lastReviewedAt': DateTime.now(),
          });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trình độ: $e');
    }
  }

  /// Xóa một từ
  Future<void> deleteWord(String wordId) async {
    try {
      await _firestore
          .collection(AppConstants.vocabularyCollection)
          .doc(wordId)
          .delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa từ: $e');
    }
  }

  /// Lấy thống kê từ vựng của user
  Future<Map<String, dynamic>> getVocabularyStatistics(String userId) async {
    try {
      final allWords = await getUserVocabulary(userId);

      // Tính tổng số từ
      final totalWords = allWords.length;

      // Đếm số từ theo mastery level
      final masteryDistribution = <int, int>{
        0: 0, // Chưa học
        1: 0, // Mới học
        2: 0, // Đang học
        3: 0, // Khá
        4: 0, // Thành thạo
      };

      for (var word in allWords) {
        masteryDistribution[word.masteryLevel] =
            (masteryDistribution[word.masteryLevel] ?? 0) + 1;
      }

      // Đếm số từ mới trong tuần
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final newWordsThisWeek = allWords
          .where((word) => word.createdAt.isAfter(oneWeekAgo))
          .length;

      // Đếm số từ cần ôn tập
      final wordsNeedingReview = allWords
          .where((word) => word.needsReview())
          .length;

      // Tính tổng số lần ôn tập
      final totalReviews = allWords.fold<int>(
        0,
        (sum, word) => sum + word.reviewCount,
      );

      return {
        'totalWords': totalWords,
        'masteryDistribution': masteryDistribution,
        'newWordsThisWeek': newWordsThisWeek,
        'wordsNeedingReview': wordsNeedingReview,
        'totalReviews': totalReviews,
        'averageReviewCount': totalWords > 0 ? totalReviews / totalWords : 0.0,
      };
    } catch (e) {
      throw Exception('Lỗi khi lấy thống kê: $e');
    }
  }

  /// Tìm kiếm từ vựng
  Future<List<SavedWord>> searchVocabulary(String userId, String query) async {
    try {
      final allWords = await getUserVocabulary(userId);
      final lowerQuery = query.toLowerCase();

      return allWords.where((word) {
        return word.word.toLowerCase().contains(lowerQuery) ||
            word.meaning.toLowerCase().contains(lowerQuery) ||
            (word.example?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm từ vựng: $e');
    }
  }

  /// Stream để lắng nghe realtime updates
  Stream<List<SavedWord>> watchUserVocabulary(String userId) {
    return _firestore
        .collection(AppConstants.vocabularyCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedWord.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
