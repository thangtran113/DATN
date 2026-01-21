import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/constants/app_animations.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';
import 'package:go_router/go_router.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGenre;

  // Bản đồ để chuyển đổi tên hiển thị sang tên trong Firebase
  final Map<String, String> _genreMap = {
    'Hành động': 'Phim Hành Động',
    'Tình cảm': 'Phim Tình Cảm',
    'Khoa học viễn tưởng': 'Phim Khoa Học Viễn Tưởng',
    'Hoạt hình': 'Phim Hoạt Hình',
    'Kinh dị': 'Phim Kinh Dị',
    'Hài hước': 'Phim Hài',
    'Chính kịch': 'Phim Chính Kịch',
    'Phiêu lưu': 'Phim Phiêu Lưu',
    'Gia đình': 'Phim Gia Đình',
    'Hình sự': 'Phim Hình Sự',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      movieProvider.fetchMovies();
      movieProvider.fetchPopularMovies();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      drawer: !isDesktop ? _buildDrawer() : null,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          return Row(
            children: [
              // Thanh bên - chỉ hiển trên màn hình lớn
              if (isDesktop)
                Container(
                  width: screenWidth > 1400 ? 280 : 250,
                  color: const Color(0xFF1A1A1A),
                  child: _buildSidebar(),
                ),

              // Nội dung chính
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Thanh tìm kiếm
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 20),
                        color: const Color(0xFF1A1A1A),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    movieProvider.searchMovies(value);
                                  } else {
                                    movieProvider.clearSearch();
                                  }
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm phim...',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF2A2A2A),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 12 : 16,
                                    vertical: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ),
                            if (!isMobile) const SizedBox(width: 12),
                            if (!isMobile)
                              ElevatedButton.icon(
                                onPressed: () {
                                  final query = _searchController.text.trim();
                                  if (query.isNotEmpty) {
                                    movieProvider.searchMovies(query);
                                  }
                                },
                                icon: const Icon(Icons.search, size: 18),
                                label: const Text('Tìm Kiếm'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE50914),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Lưới phim
                    Builder(
                      builder: (context) {
                        final displayMovies = _searchController.text.isNotEmpty
                            ? movieProvider.searchResults
                            : movieProvider.movies;

                        if (movieProvider.isLoading && displayMovies.isEmpty)
                          return const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFE50914),
                              ),
                            ),
                          );

                        if (displayMovies.isEmpty)
                          return SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.movie_outlined,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'Không tìm thấy phim "${_searchController.text}"'
                                        : 'Không tìm thấy phim',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                        return SliverPadding(
                          padding: EdgeInsets.all(_getGridPadding(context)),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _getGridColumns(context),
                                  childAspectRatio: _getChildAspectRatio(
                                    context,
                                  ),
                                  crossAxisSpacing: _getCrossAxisSpacing(
                                    context,
                                  ),
                                  mainAxisSpacing: _getMainAxisSpacing(context),
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final movie = displayMovies[index];
                              // Thêm hiệu ứng chuyển động lệch thời gian cho các thẻ phim
                              return SlideInFromBottom(
                                delay: Duration(
                                  milliseconds: 50 * (index % 10),
                                ),
                                child: _buildRoPhimCard(movie),
                              );
                            }, childCount: displayMovies.length),
                          ),
                        );
                      },
                    ),

                    // Đang tải thêm
                    if (movieProvider.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFE50914),
                            ),
                          ),
                        ),
                      ),

                    // Chân trang
                    const SliverToBoxAdapter(child: AppFooter()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Mobile: < 600px
    if (width < 600) return 2;

    // Máy tính bảng: 600-900px
    if (width < 900) return 3;

    // Màn hình nhỏ: 900-1200px
    if (width < 1200) return 4;

    // Màn hình trung bình: 1200-1600px
    if (width < 1600) return 5;

    // Màn hình lớn: >= 1600px
    return 6;
  }

  double _getCrossAxisSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 8.0;
    if (width < 900) return 12.0;
    return 16.0;
  }

  double _getMainAxisSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12.0;
    if (width < 900) return 16.0;
    return 20.0;
  }

  double _getGridPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12.0;
    if (width < 900) return 16.0;
    return 20.0;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600 ? 0.7 : 0.65;
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: _buildSidebar(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A1A1A), const Color(0xFF0F0F0F)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // Logo/Tiêu đề
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Text(
              'Danh Mục',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildSidebarSection('THỂ LOẠI', Icons.category, [
            {'name': 'Hành động', 'icon': Icons.local_fire_department},
            {'name': 'Tình cảm', 'icon': Icons.favorite},
            {'name': 'Khoa học viễn tưởng', 'icon': Icons.rocket_launch},
            {'name': 'Hoạt hình', 'icon': Icons.animation},
            {'name': 'Kinh dị', 'icon': Icons.nightlight},
            {'name': 'Hài hước', 'icon': Icons.emoji_emotions},
            {'name': 'Chính kịch', 'icon': Icons.psychology},
            {'name': 'Phiêu lưu', 'icon': Icons.explore},
            {'name': 'Gia đình', 'icon': Icons.family_restroom},
            {'name': 'Hình sự', 'icon': Icons.gavel},
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Divider(color: Color(0xFF2A2A2A), height: 1),
          ),
          _buildSidebarSection('QUỐC GIA', Icons.public, [
            {'name': 'Âu Mỹ', 'icon': Icons.flag},
            {'name': 'Hàn Quốc', 'icon': Icons.flag},
            {'name': 'Nhật Bản', 'icon': Icons.flag},
            {'name': 'Trung Quốc', 'icon': Icons.flag},
            {'name': 'Việt Nam', 'icon': Icons.flag},
            {'name': 'Thái Lan', 'icon': Icons.flag},
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Divider(color: Color(0xFF2A2A2A), height: 1),
          ),
          _buildSidebarSection('NĂM PHÁT HÀNH', Icons.calendar_today, [
            {'name': '2024', 'icon': Icons.new_releases},
            {'name': '2023', 'icon': Icons.star},
            {'name': '2022', 'icon': Icons.star},
            {'name': '2021', 'icon': Icons.star},
            {'name': '2020', 'icon': Icons.star},
            {'name': 'Cũ hơn', 'icon': Icons.history},
          ]),
        ],
      ),
    );
  }

  Widget _buildSidebarSection(
    String title,
    IconData titleIcon,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(titleIcon, color: const Color(0xFFE50914), size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE50914),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...items.map(
          (item) => _buildSidebarItem(
            item['name'] as String,
            item['icon'] as IconData,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(String label, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _handleFilterSelection(label);
        },
        hoverColor: const Color(0xFF2A2A2A),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                color: _selectedGenre == label
                    ? const Color(0xFFE50914)
                    : Colors.white54,
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _selectedGenre == label
                        ? Colors.white
                        : Colors.white70,
                    fontSize: 14,
                    fontWeight: _selectedGenre == label
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (_selectedGenre == label)
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFE50914),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFilterSelection(String label) {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    setState(() {
      // Xóa tìm kiếm khi lọc
      _searchController.clear();
      movieProvider.clearSearch();

      // Nếu click vào mục đang active thì bỏ lọc
      if (_selectedGenre == label) {
        _selectedGenre = null;
        movieProvider.fetchMovies();
        return;
      }

      _selectedGenre = label;

      // Xác định loại bộ lọc
      if (_genreMap.containsKey(label)) {
        // Lọc theo thể loại
        final englishGenre = _genreMap[label]!;
        movieProvider.filterByGenre(englishGenre);
      } else if (['2024', '2023', '2022', '2021', '2020'].contains(label)) {
        // Lọc theo năm
        movieProvider.filterByYear(int.parse(label));
      } else if (label == 'Cũ hơn') {
        // Lọc phim cũ hơn (trước 2020)
        movieProvider.filterByYear(2019);
      } else if ([
        'Âu Mỹ',
        'Hàn Quốc',
        'Nhật Bản',
        'Trung Quốc',
        'Việt Nam',
        'Thái Lan',
      ].contains(label)) {
        // Lọc theo quốc gia
        // Map tên tiếng Việt sang từ khóa search
        final countryKeywords = {
          'Âu Mỹ': 'United States',
          'Hàn Quốc': 'Korea',
          'Nhật Bản': 'Japan',
          'Trung Quốc': 'China',
          'Việt Nam': 'Vietnam',
          'Thái Lan': 'Thailand',
        };
        movieProvider.filterByCountry(countryKeywords[label] ?? label);
      } else {
        // Hiển thị tất cả phim
        movieProvider.fetchMovies();
      }
    });

    // Đóng drawer nếu đang mở (mobile)
    if (MediaQuery.of(context).size.width < 600) {
      Navigator.pop(context);
    }
  }

  Widget _buildRoPhimCard(movie) {
    return AnimatedCard(
      onTap: () => context.go('/home/${movie.id}'),
      color: AppColors.backgroundCard,
      borderRadius: AppRadius.radiusMD,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: AppColors.textTertiary.withAlpha(51),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    movie.posterUrl.isNotEmpty
                        ? Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF2A2A2A),
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFF2A2A2A),
                            child: const Icon(
                              Icons.movie,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                    // Quality badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 600 ? 8.0 : 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width < 600
                          ? 12
                          : 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        movie.year.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
