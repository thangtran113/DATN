import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_animations.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/saved_word.dart';

/// Màn hình flashcard để ôn tập từ vựng
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showBack = false;
  int _currentIndex = 0;
  List<SavedWord> _reviewWords = [];
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initFlipAnimation();
    _initTts();
    _loadReviewWords();
  }

  void _initFlipAnimation() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
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
      setState(() {
        _reviewWords = [];
      });
      return;
    }

    final userId = authProvider.user!.id;
    final words = await vocabularyProvider.getWordsForReview(userId);
    setState(() {
      _reviewWords = words;
    });
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

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  void _onSwipeLeft() {
    // Chưa biết - Giảm mastery
    _handleAnswer(false);
  }

  void _onSwipeRight() {
    // Đã biết - Tăng mastery
    _handleAnswer(true);
  }

  Future<void> _handleAnswer(bool isCorrect) async {
    if (_reviewWords.isEmpty) return;

    final vocabularyProvider = context.read<VocabularyProvider>();
    final currentWord = _reviewWords[_currentIndex];

    // Cập nhật mastery level
    await vocabularyProvider.updateMasteryLevel(currentWord.id, isCorrect);

    // Chuyển sang thẻ tiếp theo
    setState(() {
      if (_currentIndex < _reviewWords.length - 1) {
        _currentIndex++;
        _showBack = false;
        _flipController.reset();
      } else {
        // Hết flashcard
        _showCompletionDialog();
      }
    });
  }

  Future<void> _showCompletionDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          '🎉 Hoàn thành!',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn đã ôn tập xong ${_reviewWords.length} từ vựng!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                dialogContext,
              ).pop('continue'); // Đóng dialog với result
            },
            child: const Text('Ôn tiếp'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop('exit'); // Đóng dialog với result
            },
            child: const Text('Xong'),
          ),
        ],
      ),
    );

    // Xử lý sau khi dialog đóng
    if (!mounted) return;

    if (result == 'continue') {
      // Reset và reload lại danh sách
      setState(() {
        _currentIndex = 0;
        _showBack = false;
        _flipController.reset();
      });
      await _loadReviewWords(); // Reload từ cần ôn
    } else if (result == 'exit') {
      // Quay về trang vocabulary hoặc home
      if (mounted) {
        context.go('/vocabulary'); // Dùng go_router thay vì Navigator.pop
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Flashcard Ôn Tập'),
        centerTitle: true,
        actions: [
          // Hiển thị tiến độ
          if (_reviewWords.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentIndex + 1}/${_reviewWords.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _reviewWords.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Progress bar
                FadeInWidget(
                  duration: const Duration(milliseconds: 400),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _reviewWords.length,
                    backgroundColor: Colors.grey[800],
                    color: const Color(0xFFE50914),
                    minHeight: 4,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: ScaleInAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: _buildFlashcard(),
                    ),
                  ),
                ),

                // Action buttons with animation
                SlideInFromBottom(
                  delay: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Chưa biết
                        _buildActionButton(
                          icon: Icons.close,
                          label: 'Chưa biết',
                          color: Colors.red,
                          onPressed: _onSwipeLeft,
                        ),

                        // Lật thẻ
                        _buildActionButton(
                          icon: Icons.flip,
                          label: 'Lật thẻ',
                          color: Colors.blue,
                          onPressed: _flipCard,
                        ),

                        // Đã biết
                        _buildActionButton(
                          icon: Icons.check,
                          label: 'Đã biết',
                          color: Colors.green,
                          onPressed: _onSwipeRight,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Không có từ nào cần ôn tập',
            style: TextStyle(color: Colors.grey[400], fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm từ vựng để bắt đầu học!',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard() {
    final word = _reviewWords[_currentIndex];

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * 3.14159;
          final isFront = angle < 1.5708; // 90 degrees

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isFront
                      ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                      : [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isFront
                  ? _buildFrontCard(word)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildBackCard(word),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(SavedWord word) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Từ vựng
          Text(
            word.word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // Phiên âm
          if (word.pronunciation != null) ...[
            const SizedBox(height: 16),
            Text(
              word.pronunciation!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Nút phát âm
          ElevatedButton.icon(
            onPressed: _speakWord,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            label: Text(_isSpeaking ? 'Dừng' : 'Phát âm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          const Spacer(),

          // Hint
          Text(
            'Nhấn để lật thẻ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(SavedWord word) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nghĩa
          const Text(
            'Nghĩa:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.meaning,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.5,
            ),
          ),

          // Ví dụ
          if (word.example != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Ví dụ:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word.example!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],

          const Spacer(),

          // Mastery level
          _buildMasteryLevelIndicator(word.masteryLevel),
        ],
      ),
    );
  }

  Widget _buildMasteryLevelIndicator(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Color(
              int.parse(
                SavedWord.getMasteryColor(level).replaceFirst('#', '0xFF'),
              ),
            ),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            SavedWord.getMasteryLabel(level),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}
