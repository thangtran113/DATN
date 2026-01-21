import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/saved_word.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';

/// Màn hình thống kê học tập
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

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
    final authProvider = context.watch<AuthProvider>();

    // Yêu cầu đăng nhập để truy cập thống kê
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
                      Icons.bar_chart,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vui lòng đăng nhập để xem thống kê',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
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
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.accent,
                  backgroundColor: AppColors.backgroundCard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                vertical: 40,
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  const Text(
                                    'Thống Kê Học Tập',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Overview cards with animation
                                  FadeInWidget(
                                    duration: const Duration(milliseconds: 500),
                                    child: _buildOverviewCards(provider),
                                  ),

                                  const SizedBox(height: 32),

                                  // Mastery level distribution
                                  SlideInFromBottom(
                                    delay: const Duration(milliseconds: 200),
                                    child: _buildSectionTitle(
                                      'Phân Bố Trình Độ',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SlideInFromBottom(
                                    delay: const Duration(milliseconds: 300),
                                    child: _buildMasteryDistribution(provider),
                                  ),

                                  const SizedBox(height: 32),

                                  // Progress chart
                                  SlideInFromBottom(
                                    delay: const Duration(milliseconds: 400),
                                    child: _buildSectionTitle(
                                      'Tiến Độ Học Tập',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SlideInFromBottom(
                                    delay: const Duration(milliseconds: 500),
                                    child: _buildProgressChart(provider),
                                  ),

                                  const SizedBox(height: 32),

                                  // Learning insights
                                  SlideInFromBottom(
                                    delay: const Duration(milliseconds: 600),
                                    child: _buildSectionTitle(
                                      'Thông Tin Chi Tiết',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SlideInFromBottom(
                                    delay: const Duration(milliseconds: 700),
                                    child: _buildInsights(provider),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const AppFooter(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverviewCards(VocabularyProvider provider) {
    final stats = provider.statistics;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.library_books,
            label: 'Tổng Từ Vựng',
            value: '${stats['totalWords'] ?? 0}',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.new_releases,
            label: 'Từ Mới (7 ngày)',
            value: '${stats['newWordsThisWeek'] ?? 0}',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.refresh,
            label: 'Cần Ôn Tập',
            value: '${stats['wordsNeedingReview'] ?? 0}',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.repeat,
            label: 'Tổng Lượt Ôn',
            value: '${stats['totalReviews'] ?? 0}',
            color: AppColors.primary,
          ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân bố theo trình độ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Legend bars
          ...List.generate(5, (level) {
            final count = distribution[level] ?? 0;
            final percentage = totalWords > 0 ? (count / totalWords) : 0.0;

            return _buildLevelBar(
              color: Color(
                int.parse(
                  SavedWord.getMasteryColor(level).replaceFirst('#', '0xFF'),
                ),
              ),
              label: SavedWord.getMasteryLabel(level),
              count: count,
              percentage: percentage,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLevelBar({
    required Color color,
    required String label,
    required int count,
    required double percentage,
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '$count từ (${(percentage * 100).toStringAsFixed(1)}%)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
              widthFactor: percentage,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(VocabularyProvider provider) {
    final masteryPercentage = provider.getMasteryPercentage();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiến độ học tập',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tổng cộng ${provider.totalWords} từ vựng',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${masteryPercentage.toStringAsFixed(1)}% thành thạo',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              widthFactor: masteryPercentage / 100,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '$count từ',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.border,
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gợi ý học tập',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Tốc độ học
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tốc độ học',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalWords > 0
                          ? 'Trung bình ${avgReviews.toStringAsFixed(1)} lần/từ'
                          : 'Chưa có dữ liệu',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Gợi ý ôn tập
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      (wordsNeedingReview > 0
                              ? AppColors.warning
                              : AppColors.success)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: wordsNeedingReview > 0
                      ? AppColors.warning
                      : AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ôn tập',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wordsNeedingReview > 0
                          ? '$wordsNeedingReview từ cần ôn tập'
                          : 'Đã ôn tập đầy đủ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Thành tích
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thành tích',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.getMasteryPercentage() >= 50
                          ? 'Đã thành thạo hơn 50% từ vựng'
                          : 'Tiếp tục học để đạt 50%',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.bar_chart,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
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
      ..color = AppColors.backgroundCard
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
