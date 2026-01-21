import 'package:flutter/foundation.dart';
import '../../domain/entities/saved_word.dart';
import '../../data/repositories/vocabulary_repository.dart';

/// Provider quản lý state của danh sách từ vựng
class VocabularyProvider extends ChangeNotifier {
  final VocabularyRepository _repository;

  List<SavedWord> _vocabulary = [];
  List<SavedWord> _filteredVocabulary = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _filterByMasteryLevel;

  VocabularyProvider({VocabularyRepository? repository})
    : _repository = repository ?? VocabularyRepository();

  // Getters
  List<SavedWord> get vocabulary => _filteredVocabulary;
  List<SavedWord> get allVocabulary => _vocabulary;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get filterByMasteryLevel => _filterByMasteryLevel;
  int get totalWords => _vocabulary.length;

  /// Tải danh sách từ vựng của user
  Future<void> loadVocabulary(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vocabulary = await _repository.getUserVocabulary(userId);
      _applyFilters();
      await loadStatistics(userId);
    } catch (e) {
      _error = e.toString();
      print('❌ Lỗi khi tải từ vựng: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải thống kê từ vựng
  Future<void> loadStatistics(String userId) async {
    try {
      _statistics = await _repository.getVocabularyStatistics(userId);
      notifyListeners();
    } catch (e) {
      print('❌ Lỗi khi tải thống kê: $e');
    }
  }

  /// Lưu một từ mới
  /// Returns: Map với keys 'isNew' (bool) và 'id' (string)
  Future<Map<String, dynamic>> saveWord(SavedWord word) async {
    try {
      final result = await _repository.saveWord(word);

      // Reload vocabulary sau khi lưu (chỉ khi là từ mới)
      if (result['isNew'] == true) {
        await loadVocabulary(word.userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      print('❌ Lỗi khi lưu từ: $e');
      notifyListeners();
      return {'isNew': false, 'id': '', 'error': e.toString()};
    }
  }

  /// Cập nhật mastery level của một từ (sau khi ôn tập)
  Future<void> updateMasteryLevel(String wordId, bool isCorrect) async {
    try {
      final word = _vocabulary.firstWhere((w) => w.id == wordId);
      final updatedWord = isCorrect
          ? word.incrementMasteryLevel()
          : word.decrementMasteryLevel();

      await _repository.updateMasteryLevel(wordId, updatedWord.masteryLevel);

      // Cập nhật local state
      final index = _vocabulary.indexWhere((w) => w.id == wordId);
      if (index != -1) {
        _vocabulary[index] = updatedWord;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật mastery level: $e');
    }
  }

  /// Cập nhật mastery level trực tiếp (cho Flashcard/Quiz)
  Future<void> updateWordMastery(String wordId, int newMasteryLevel) async {
    try {
      await _repository.updateMasteryLevel(wordId, newMasteryLevel);

      // Cập nhật local state
      final index = _vocabulary.indexWhere((w) => w.id == wordId);
      if (index != -1) {
        _vocabulary[index] = _vocabulary[index].copyWith(
          masteryLevel: newMasteryLevel,
          reviewCount: _vocabulary[index].reviewCount + 1,
          lastReviewedAt: DateTime.now(),
        );
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật mastery: $e');
    }
  }

  /// Xóa một từ
  Future<bool> deleteWord(String wordId) async {
    try {
      await _repository.deleteWord(wordId);

      // Xóa khỏi local state
      _vocabulary.removeWhere((w) => w.id == wordId);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Lỗi khi xóa từ: $e');
      notifyListeners();
      return false;
    }
  }

  /// Tìm kiếm từ vựng
  void searchVocabulary(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Lọc theo mastery level
  void filterByMastery(int? level) {
    _filterByMasteryLevel = level;
    _applyFilters();
    notifyListeners();
  }

  /// Áp dụng filters (search + mastery level)
  void _applyFilters() {
    _filteredVocabulary = _vocabulary;

    // Áp dụng search
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredVocabulary = _filteredVocabulary.where((word) {
        return word.word.toLowerCase().contains(lowerQuery) ||
            word.meaning.toLowerCase().contains(lowerQuery) ||
            (word.example?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Áp dụng filter theo mastery level
    if (_filterByMasteryLevel != null) {
      _filteredVocabulary = _filteredVocabulary
          .where((word) => word.masteryLevel == _filterByMasteryLevel)
          .toList();
    }
  }

  /// Lấy danh sách từ cần ôn tập
  Future<List<SavedWord>> getWordsForReview(String userId) async {
    try {
      return await _repository.getWordsForReview(userId);
    } catch (e) {
      print('❌ Lỗi khi lấy từ cần ôn tập: $e');
      return [];
    }
  }

  /// Kiểm tra xem một từ đã được lưu chưa
  Future<bool> isWordSaved(String userId, String word) async {
    try {
      final existingWord = await _repository.getWordByText(userId, word);
      return existingWord != null;
    } catch (e) {
      print('❌ Lỗi khi kiểm tra từ: $e');
      return false;
    }
  }

  /// Reset filters
  void resetFilters() {
    _searchQuery = '';
    _filterByMasteryLevel = null;
    _applyFilters();
    notifyListeners();
  }

  /// Lắng nghe realtime updates
  void watchVocabulary(String userId) {
    _repository
        .watchUserVocabulary(userId)
        .listen(
          (words) {
            _vocabulary = words;
            _applyFilters();
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            print('❌ Lỗi realtime: $error');
            notifyListeners();
          },
        );
  }

  /// Lấy số lượng từ theo từng mastery level
  int getWordCountByMastery(int level) {
    return _vocabulary.where((word) => word.masteryLevel == level).length;
  }

  /// Lấy phần trăm từ đã thành thạo (level 4)
  double getMasteryPercentage() {
    if (_vocabulary.isEmpty) return 0.0;
    final masteredWords = _vocabulary.where((w) => w.masteryLevel == 4).length;
    return (masteredWords / _vocabulary.length) * 100;
  }
}
