import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/saved_word.dart';

/// Màn hình thống kê học tập
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final vocabularyProvider = context.read<VocabularyProvider>();

    if (authProvider.user != null) {
      await vocabularyProvider.loadVocabulary(authProvider.user!.id);
      await vocabularyProvider.loadStatistics(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Thống Kê Học Tập'),
        centerTitle: true,
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }

          final totalWords = provider.statistics['totalWords'] ?? 0;
          
          if (totalWords == 0) {
            return _buildEmptyState();
          }
          
          return RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFE50914),
            backgroundColor: const Color(0xFF1E1E1E),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview cards
                  _buildOverviewCards(provider),

                  const SizedBox(height: 24),

                  // Mastery level distribution
                  _buildSectionTitle('Phân Bố Trình Độ'),
                  const SizedBox(height: 16),
                  _buildMasteryDistribution(provider),

                  const SizedBox(height: 24),

                  // Progress chart
                  _buildSectionTitle('Tiến Độ Học Tập'),
                  const SizedBox(height: 16),
                  _buildProgressChart(provider),

                  const SizedBox(height: 24),

                  // Learning insights
                  _buildSectionTitle('Thông Tin Chi Tiết'),
                  const SizedBox(height: 16),
                  _buildInsights(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverviewCards(VocabularyProvider provider) {
    final stats = provider.statistics;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.library_books,
          label: 'Tổng Từ',
          value: '${stats['totalWords'] ?? 0}',
          color: const Color(0xFF0EA5E9),
        ),
        _buildStatCard(
          icon: Icons.new_releases,
          label: 'Từ Mới (7 ngày)',
          value: '${stats['newWordsThisWeek'] ?? 0}',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.refresh,
          label: 'Cần Ôn Tập',
          value: '${stats['wordsNeedingReview'] ?? 0}',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.repeat,
          label: 'Số Lần Ôn',
          value: '${stats['totalReviews'] ?? 0}',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1E1E1E), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryDistribution(VocabularyProvider provider) {
    final stats = provider.statistics;
    final distribution = stats['masteryDistribution'] as Map<int, int>? ?? {};
    final totalWords = stats['totalWords'] as int? ?? 0;

    if (totalWords == 0) {
      return _buildEmptyChart('Chưa có dữ liệu về trình độ từ vựng');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Pie chart
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: PieChartPainter(distribution, totalWords),
              child: Container(),
            ),
          ),

          const SizedBox(height: 24),

          // Legend
          ...List.generate(5, (level) {
            final count = distribution[level] ?? 0;
            final percentage = totalWords > 0
                ? (count / totalWords * 100).toStringAsFixed(1)
                : '0.0';

            return _buildLegendItem(
              color: Color(
                int.parse(
                  SavedWord.getMasteryColor(level).replaceFirst('#', '0xFF'),
                ),
              ),
              label: SavedWord.getMasteryLabel(level),
              count: count,
              percentage: '$percentage%',
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
    required String percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            '$count từ ($percentage)',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(VocabularyProvider provider) {
    final masteryPercentage = provider.getMasteryPercentage();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Circular progress
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    value: masteryPercentage / 100,
                    strokeWidth: 20,
                    backgroundColor: Colors.grey[800],
                    color: const Color(0xFF4D96FF),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${masteryPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Thành thạo',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bars for each level
          ...List.generate(5, (level) {
            final count = provider.getWordCountByMastery(level);
            final total = provider.totalWords;
            final percentage = total > 0 ? count / total : 0.0;

            return _buildProgressBar(
              label: SavedWord.getMasteryLabel(level),
              count: count,
              percentage: percentage,
              color: Color(
                int.parse(
                  SavedWord.getMasteryColor(level).replaceFirst('#', '0xFF'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '$count từ',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey[800],
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(VocabularyProvider provider) {
    final stats = provider.statistics;
    final totalWords = stats['totalWords'] as int? ?? 0;
    final avgReviews = stats['averageReviewCount'] as double? ?? 0.0;
    final wordsNeedingReview = stats['wordsNeedingReview'] as int? ?? 0;

    return Column(
      children: [
        _buildInsightCard(
          icon: Icons.trending_up,
          title: 'Tốc Độ Học',
          description: totalWords > 0
              ? 'Bạn đã học trung bình ${avgReviews.toStringAsFixed(1)} lần/từ'
              : 'Chưa có dữ liệu',
          color: Colors.green,
        ),

        const SizedBox(height: 12),

        _buildInsightCard(
          icon: Icons.lightbulb_outline,
          title: 'Gợi Ý',
          description: wordsNeedingReview > 0
              ? 'Bạn có $wordsNeedingReview từ cần ôn tập. Hãy dùng Flashcard!'
              : 'Tuyệt vời! Bạn đã ôn tập đầy đủ.',
          color: wordsNeedingReview > 0 ? Colors.orange : Colors.green,
        ),

        const SizedBox(height: 12),

        _buildInsightCard(
          icon: Icons.emoji_events,
          title: 'Thành Tích',
          description: provider.getMasteryPercentage() >= 50
              ? 'Tuyệt vời! Bạn đã thành thạo hơn 50% từ vựng!'
              : 'Tiếp tục phấn đấu để đạt 50% từ thành thạo!',
          color: const Color(0xFFFFD700),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter cho pie chart
class PieChartPainter extends CustomPainter {
  final Map<int, int> distribution;
  final int total;

  PieChartPainter(this.distribution, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2; // Bắt đầu từ 12 giờ

    for (int level = 0; level < 5; level++) {
      final count = distribution[level] ?? 0;
      if (count == 0) continue;

      final sweepAngle = (count / total) * 2 * math.pi;
      final color = Color(
        int.parse(SavedWord.getMasteryColor(level).replaceFirst('#', '0xFF')),
      );

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Vẽ vòng tròn trắng ở giữa để tạo hiệu ứng donut
    final innerPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on _StatisticsScreenState {
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            // Illustration
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.2),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.insert_chart_outlined,
                size: 70,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Chưa có dữ liệu thống kê',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Bắt đầu học từ vựng để xem\ntiến độ và thống kê của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.movie, size: 20),
                  label: const Text('Xem phim'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/vocabulary'),
                  icon: const Icon(Icons.book, size: 20),
                  label: const Text('Từ vựng'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Info box
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
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFFFFB800),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Lưu từ khi xem phim để bắt đầu',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
}
