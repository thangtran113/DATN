import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/saved_word.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';

/// Màn hình flashcard - Redesigned to match templates
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  List<SavedWord> _reviewWords = [];
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _initTts();
      await _loadReviewWords();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi tải dữ liệu: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _loadReviewWords() async {
    final vocabularyProvider = context.read<VocabularyProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user == null) {
      if (mounted) {
        setState(() {
          _reviewWords = [];
          _isLoading = false;
        });
      }
      return;
    }

    final userId = authProvider.user!.id;
    final words = await vocabularyProvider.getWordsForReview(userId);
    if (mounted) {
      setState(() {
        _reviewWords = words;
        _isLoading = false;
        _currentIndex = 0;
        _isFlipped = false;
      });
    }
  }

  Future<void> _speakWord() async {
    if (_reviewWords.isEmpty) return;

    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(_reviewWords[_currentIndex].word);
  }

  void _handleNext() async {
    if (_reviewWords.isEmpty) return;

    final vocabularyProvider = context.read<VocabularyProvider>();
    final currentWord = _reviewWords[_currentIndex];

    // Cập nhật độ thạo (giả sử người dùng biết từ khi nhấn tiếp theo)
    await vocabularyProvider.updateMasteryLevel(currentWord.id, true);

    setState(() {
      if (_currentIndex < _reviewWords.length - 1) {
        _currentIndex++;
        _isFlipped = false;
      } else {
        _showCompletionDialog();
      }
    });
  }

  Future<void> _showCompletionDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          '🎉 Hoàn thành!',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Bạn đã ôn tập xong ${_reviewWords.length} từ vựng!',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('continue'),
            child: const Text(
              'Ôn tiếp',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('exit'),
            child: const Text(
              'Xong',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == 'continue') {
      setState(() {
        _currentIndex = 0;
        _isFlipped = false;
      });
      await _loadReviewWords();
    } else if (result == 'exit') {
      if (mounted) {
        context.go('/vocabulary');
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Yêu cầu đăng nhập để truy cập flashcard
    if (authProvider.user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.style_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vui lòng đăng nhập để sử dụng flashcard',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                      ),
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _errorMessage != null
                ? _buildErrorState()
                : _reviewWords.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    child: Column(
                      children: [_buildFlashcardContent(), const AppFooter()],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardContent() {
    final currentWord = _reviewWords[_currentIndex];
    final progress = (_currentIndex + 1) / _reviewWords.length;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000, minHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card: ${_currentIndex + 1}/${_reviewWords.length}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Card
            Container(
              constraints: const BoxConstraints(minHeight: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.backgroundCard),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use responsive layout
                  if (constraints.maxWidth > 600) {
                    return _buildCardContentWide(currentWord);
                  } else {
                    return _buildCardContentNarrow(currentWord);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Next button
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContentWide(SavedWord word) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder (if movie has image)
        const SizedBox(width: 32),
        // Content
        Expanded(flex: 1, child: _buildCardText(word)),
      ],
    );
  }

  Widget _buildCardContentNarrow(SavedWord word) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.movie,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildCardText(word),
      ],
    );
  }

  Widget _buildCardText(SavedWord word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word with speaker icon
        Row(
          children: [
            Text(
              word.word,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                color: AppColors.accent,
              ),
              onPressed: _speakWord,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // English definition
        Text(
          word.meaning,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),
        ),
        const SizedBox(height: 16),

        // Vietnamese definition
        Text(
          word.vietnameseMeaning ?? '(Chưa có bản dịch)',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có từ vựng nào cần ôn!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/vocabulary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Quay về'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initialize,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
