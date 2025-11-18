import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/saved_word.dart';

/// Màn hình danh sách từ vựng đã lưu
class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({Key? key}) : super(key: key);

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
    _loadVocabulary();
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
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
          tooltip: 'Quay về trang chủ',
        ),
        title: const Text('Từ Vựng Của Tôi'),
        centerTitle: true,
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, vocabularyProvider, child) {
          if (vocabularyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }

          if (vocabularyProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    vocabularyProvider.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadVocabulary,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar và filter
              _buildSearchAndFilter(vocabularyProvider),

              // Statistics summary
              _buildStatisticsSummary(vocabularyProvider),

              // Word list
              Expanded(
                child: vocabularyProvider.vocabulary.isEmpty
                    ? _buildEmptyState()
                    : _buildVocabularyList(vocabularyProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(VocabularyProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: provider.searchVocabulary,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm từ vựng...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        provider.searchVocabulary('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Mastery level filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', null, provider),
                const SizedBox(width: 8),
                _buildFilterChip('Chưa học', 0, provider),
                const SizedBox(width: 8),
                _buildFilterChip('Mới học', 1, provider),
                const SizedBox(width: 8),
                _buildFilterChip('Đang học', 2, provider),
                const SizedBox(width: 8),
                _buildFilterChip('Khá', 3, provider),
                const SizedBox(width: 8),
                _buildFilterChip('Thành thạo', 4, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    int? level,
    VocabularyProvider provider,
  ) {
    final isSelected = provider.filterByMasteryLevel == level;
    final color = level != null
        ? Color(
            int.parse(
              SavedWord.getMasteryColor(level).replaceFirst('#', '0xFF'),
            ),
          )
        : const Color(0xFF0EA5E9);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.filterByMastery(isSelected ? null : level),
      backgroundColor: const Color(0xFF2C2C2C),
      selectedColor: color.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[700]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildStatisticsSummary(VocabularyProvider provider) {
    final stats = provider.statistics;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0EA5E9), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.library_books,
            label: 'Tổng từ',
            value: '${stats['totalWords'] ?? 0}',
            color: const Color(0xFF0EA5E9),
          ),
          _buildStatItem(
            icon: Icons.new_releases,
            label: 'Tuần này',
            value: '${stats['newWordsThisWeek'] ?? 0}',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.refresh,
            label: 'Cần ôn',
            value: '${stats['wordsNeedingReview'] ?? 0}',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            // Illustration container
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE50914).withOpacity(0.2),
                    const Color(0xFFB20710).withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.book_outlined,
                size: 80,
                color: Color(0xFFE50914),
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Chưa có từ vựng nào',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Bắt đầu xem phim và lưu các từ mới\nđể xây dựng vốn từ vựng của bạn!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            // CTA Button
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.movie, size: 20),
              label: const Text(
                'Khám phá phim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFE50914).withOpacity(0.5),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Secondary info
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tips_and_updates,
                    color: Color(0xFFFFB800),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Mẹo: Click vào từ trong phụ đề để lưu',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildVocabularyList(VocabularyProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.vocabulary.length,
      itemBuilder: (context, index) {
        final word = provider.vocabulary[index];
        return _buildWordCard(word, provider);
      },
    );
  }

  Widget _buildWordCard(SavedWord word, VocabularyProvider provider) {
    final isSpeaking = _speakingWordId == word.id;
    final masteryColor = Color(
      int.parse(
        SavedWord.getMasteryColor(word.masteryLevel).replaceFirst('#', '0xFF'),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: masteryColor.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showWordDetail(word, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mastery level indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: masteryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 16),

              // Word info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word.word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (word.pronunciation != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            word.pronunciation!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.meaning,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Mastery badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: masteryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            SavedWord.getMasteryLabel(word.masteryLevel),
                            style: TextStyle(
                              color: masteryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time ago
                        Text(
                          timeago.format(word.createdAt, locale: 'vi'),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  // Speak button
                  IconButton(
                    icon: Icon(
                      isSpeaking ? Icons.stop : Icons.volume_up,
                      color: isSpeaking
                          ? const Color(0xFFE50914)
                          : Colors.grey[400],
                    ),
                    onPressed: () => _speakWord(word),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                    onPressed: () => _confirmDelete(word, provider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWordDetail(SavedWord word, VocabularyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word
            Text(
              word.word,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (word.pronunciation != null) ...[
              const SizedBox(height: 8),
              Text(
                word.pronunciation!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),

            // Meaning
            Text(
              'Nghĩa:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              word.meaning,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),

            // Example
            if (word.example != null) ...[
              const SizedBox(height: 16),
              Text(
                'Ví dụ:',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                word.example!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Movie info
            if (word.movieTitle != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.movie, color: Color(0xFFE50914), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Từ phim: ${word.movieTitle}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailStat(
                  icon: Icons.repeat,
                  label: 'Ôn tập',
                  value: '${word.reviewCount} lần',
                ),
                _buildDetailStat(
                  icon: Icons.star,
                  label: 'Trình độ',
                  value: SavedWord.getMasteryLabel(word.masteryLevel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0EA5E9), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Future<void> _confirmDelete(
    SavedWord word,
    VocabularyProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xóa từ vựng', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xóa từ "${word.word}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteWord(word.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa từ "${word.word}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
