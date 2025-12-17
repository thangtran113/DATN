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

  // Map để convert tên tiếng Việt sang tiếng Anh
  final Map<String, String> _genreMap = {
    'Hành động': 'Action',
    'Tình cảm': 'Romance',
    'Khoa học viễn tưởng': 'Science Fiction',
    'Hoạt hình': 'Animation',
    'Kinh dị': 'Horror',
    'Hài hước': 'Comedy',
    'Tâm lý': 'Drama',
    'Phiêu lưu': 'Adventure',
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      drawer: isMobile ? _buildDrawer() : null,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          return Row(
            children: [
              // Sidebar - only show on desktop
              if (!isMobile)
                Container(
                  width: 250,
                  color: const Color(0xFF1A1A1A),
                  child: _buildSidebar(),
                ),

              // Main content
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Search bar
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Filter action
                              },
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

                    // Movies grid
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
                          padding: const EdgeInsets.all(20),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _getGridColumns(context),
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 20,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final movie = displayMovies[index];
                              // Add staggered animation to movie cards
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

                    // Loading more
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

                    // Footer
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
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 900;

    if (isMobile) return 2;
    if (isTablet) return 3;
    return 5; // Desktop
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
          // Logo/Title
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
            {'name': 'Tâm lý', 'icon': Icons.psychology},
            {'name': 'Phiêu lưu', 'icon': Icons.explore},
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
      // Clear search khi filter
      _searchController.clear();
      movieProvider.clearSearch();

      // Nếu click vào item đang active thì bỏ filter
      if (_selectedGenre == label) {
        _selectedGenre = null;
        movieProvider.fetchMovies();
        return;
      }

      _selectedGenre = label;

      // Xác định loại filter
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
      onTap: () => context.push('/home/${movie.id}'),
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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
