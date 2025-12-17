import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/saved_word.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool _isLoading = true;
  String? _errorMessage;
  final Random _random = Random();
  int _remainingSeconds = 330; // 5:30 in seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQuiz();
    });
  }

  Future<void> _generateQuiz() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = context.read<AuthProvider>();
      final vocabularyProvider = context.read<VocabularyProvider>();

      if (authProvider.user == null) {
        throw Exception('Vui lòng đăng nhập');
      }

      await vocabularyProvider.loadVocabulary(authProvider.user!.id);
      final allWords = vocabularyProvider.vocabulary;

      if (allWords.length < 4) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _questions = [];
          });
        }
        return;
      }

      final shuffledWords = List<SavedWord>.from(allWords)..shuffle(_random);
      final quizWords = shuffledWords.take(10).toList();
      final questions = <QuizQuestion>[];

      for (final word in quizWords) {
        final wrongAnswers =
            allWords
                .where((w) => w.id != word.id && w.meaning != word.meaning)
                .toList()
              ..shuffle(_random);

        final uniqueWrongAnswers = <String>{};
        for (final w in wrongAnswers) {
          if (uniqueWrongAnswers.length >= 3) break;
          uniqueWrongAnswers.add(w.meaning);
        }

        if (uniqueWrongAnswers.length < 3) continue;

        final answers = [word.meaning, ...uniqueWrongAnswers]..shuffle(_random);

        questions.add(
          QuizQuestion(
            word: word,
            answers: answers,
            correctAnswer: word.meaning,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi tạo quiz: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;

      final question = _questions[_currentQuestionIndex];
      if (question.answers[index] == question.correctAnswer) {
        _score++;
        _updateMastery(question.word, true);
      } else {
        _updateMastery(question.word, false);
      }
    });
  }

  Future<void> _updateMastery(SavedWord word, bool isCorrect) async {
    final vocabularyProvider = context.read<VocabularyProvider>();
    int newMasteryLevel = word.masteryLevel;

    if (isCorrect) {
      newMasteryLevel = (word.masteryLevel + 1).clamp(0, 4);
    } else {
      newMasteryLevel = (word.masteryLevel - 1).clamp(0, 4);
    }

    await vocabularyProvider.updateWordMastery(word.id, newMasteryLevel);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    }
  }

  void _showResultDialog() {
    final percentage = (_score / _questions.length * 100).round();
    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = 'Xuất sắc! 🎉';
      icon = Icons.emoji_events;
      color = AppColors.rating;
    } else if (percentage >= 60) {
      message = 'Tốt lắm! 👍';
      icon = Icons.thumb_up;
      color = AppColors.success;
    } else if (percentage >= 40) {
      message = 'Khá ổn! 💪';
      icon = Icons.trending_up;
      color = AppColors.accent;
    } else {
      message = 'Cần cố gắng thêm! 📚';
      icon = Icons.school;
      color = AppColors.warning;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 80),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Điểm: $_score/${_questions.length} ($percentage%)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedAnswerIndex = null;
                _isAnswered = false;
                _remainingSeconds = 330;
              });
              _generateQuiz();
            },
            child: const Text(
              'Làm lại',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/vocabulary');
            },
            child: const Text(
              'Xong',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                : _questions.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 200,
                          ),
                          child: _buildQuizContent(),
                        ),

                        const AppFooter(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentQuestionIndex];
    final timeProgress = _remainingSeconds / 330;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Quiz: Movie Dialogue',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Timer bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Time Remaining',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppColors.textSecondary),
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
                    widthFactor: timeProgress,
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

            // Question card with image
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.9),
                  ],
                ),
                color: AppColors.backgroundCard,
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What is the meaning of "${question.word.word}"?',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...List.generate(
              question.answers.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOption(index, question),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0
                      ? _previousQuestion
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundCard,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.backgroundCard,
                    disabledForegroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isAnswered ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.backgroundCard,
                    disabledForegroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, QuizQuestion question) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = question.answers[index] == question.correctAnswer;

    Color borderColor = AppColors.border;
    Color backgroundColor = Colors.transparent;

    if (_isAnswered) {
      if (isSelected) {
        borderColor = isCorrect ? AppColors.success : AppColors.error;
        backgroundColor = isCorrect
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1);
      } else if (isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
      }
    } else if (isSelected) {
      borderColor = AppColors.accent;
      backgroundColor = AppColors.primary.withValues(alpha: 0.2);
    }

    return InkWell(
      onTap: () => _selectAnswer(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Answer text
            Expanded(
              child: Text(
                question.answers[index],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không đủ từ vựng để tạo quiz',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn cần ít nhất 4 từ vựng',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
            onPressed: _generateQuiz,
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

class QuizQuestion {
  final SavedWord word;
  final List<String> answers;
  final String correctAnswer;

  QuizQuestion({
    required this.word,
    required this.answers,
    required this.correctAnswer,
  });
}
