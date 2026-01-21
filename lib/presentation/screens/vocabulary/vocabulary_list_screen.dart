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

/// Màn hình danh sách từ vựng - Redesigned to match templates
class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  String? _speakingWordId;

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVocabulary();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() => _speakingWordId = null);
    });
  }

  Future<void> _loadVocabulary() async {
    final authProvider = context.read<AuthProvider>();
    final vocabularyProvider = context.read<VocabularyProvider>();

    if (authProvider.user != null) {
      await vocabularyProvider.loadVocabulary(authProvider.user!.id);
    }
  }

  Future<void> _speakWord(SavedWord word) async {
    if (_speakingWordId == word.id) {
      await _flutterTts.stop();
      setState(() => _speakingWordId = null);
      return;
    }

    setState(() => _speakingWordId = word.id);
    await _flutterTts.speak(word.word);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Yêu cầu đăng nhập để truy cập từ vựng
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
                      Icons.book_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vui lòng đăng nhập để xem từ vựng',
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
            child: Consumer<VocabularyProvider>(
              builder: (context, vocabularyProvider, child) {
                if (vocabularyProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }

                if (vocabularyProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          vocabularyProvider.error!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadVocabulary,
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

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                const Text(
                                  'Từ Vựng Của Tôi',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Search & Filter
                                _buildSearchAndFilter(vocabularyProvider),
                                const SizedBox(height: 24),

                                // Table
                                vocabularyProvider.vocabulary.isEmpty
                                    ? _buildEmptyState()
                                    : _buildVocabularyTable(vocabularyProvider),

                                const SizedBox(height: 24),

                                // Action buttons
                                _buildActionButtons(vocabularyProvider),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const AppFooter(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(VocabularyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        SizedBox(
          width: 500,
          child: TextField(
            controller: _searchController,
            onChanged: provider.searchVocabulary,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm từ vựng...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        provider.searchVocabulary('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.backgroundCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tab filter
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              _buildTab('Tất Cả', provider.filterByMasteryLevel == null, () {
                provider.filterByMastery(null);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVocabularyTable(VocabularyProvider provider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header row
            TableRow(
              decoration: const BoxDecoration(color: AppColors.backgroundLight),
              children: [
                _buildTableHeader('Word'),
                _buildTableHeader('Definition (En)'),
                _buildTableHeader('Definition (Vn)'),
                _buildTableHeader('Level'),
                _buildTableHeader('Actions'),
              ],
            ),
            // Data rows
            ...provider.vocabulary.map(
              (word) => _buildTableRow(word, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  TableRow _buildTableRow(SavedWord word, VocabularyProvider provider) {
    final masteryPercent = (word.masteryLevel * 25).toInt();

    return TableRow(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      children: [
        // Word
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _speakingWordId == word.id
                      ? Icons.stop_circle
                      : Icons.volume_up,
                  color: _speakingWordId == word.id
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => _speakWord(word),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // Definition (En)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            word.meaning,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Definition (Vn)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            word.vietnameseMeaning ?? '(Chưa có bản dịch)',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Level
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Progress bar
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: masteryPercent / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Percentage
              Text(
                '$masteryPercent',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDeleteWord(word, provider),
            tooltip: 'Xóa từ vựng',
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteWord(
    SavedWord word,
    VocabularyProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Xóa từ vựng',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa từ "${word.word}" khỏi danh sách từ vựng của bạn?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteWord(word.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa từ vựng'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có từ vựng nào',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy xem phim và lưu các từ vựng bạn muốn học!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(VocabularyProvider provider) {
    final hasWords = provider.vocabulary.isNotEmpty;
    final hasEnoughWords = provider.vocabulary.length >= 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: hasWords
              ? () => context.go('/vocabulary/flashcard')
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.backgroundCard,
            disabledForegroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Bắt Đầu Học',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: hasEnoughWords
              ? () => context.go('/vocabulary/quiz')
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.backgroundCard,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.backgroundCard,
            disabledForegroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Làm Bài Kiểm Tra',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
