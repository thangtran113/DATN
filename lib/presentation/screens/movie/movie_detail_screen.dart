import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/comments_section.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_footer.dart';
import '../player/video_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  List<Movie> relatedMovies = [];
  bool isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      movieProvider.fetchMovieById(widget.movieId);
      if (authProvider.user != null) {
        movieProvider.fetchFavorites(authProvider.user!.id);
      }
      _loadRelatedMovies();
    });
  }

  Future<void> _loadRelatedMovies() async {
    setState(() => isLoadingRelated = true);
    try {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final currentMovie = movieProvider.selectedMovie;
      if (currentMovie != null && currentMovie.genres.isNotEmpty) {
        final movies = await movieProvider.fetchMoviesByGenre(
          currentMovie.genres.first,
          limit: 6,
        );
        setState(() {
          relatedMovies = movies
              .where((m) => m.id != widget.movieId)
              .take(5)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading related movies: $e');
    } finally {
      setState(() => isLoadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer2<MovieProvider, AuthProvider>(
        builder: (context, movieProvider, authProvider, child) {
          if (movieProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          final movie = movieProvider.selectedMovie;
          if (movie == null) {
            return const Center(
              child: Text(
                'Không tìm thấy phim',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final isInFavorites = movieProvider.isInFavorites(movie.id);

          return Column(
            children: [
              const AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Banner with gradient
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.width > 768
                                    ? 400
                                    : 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      movie.backdropUrl ?? movie.posterUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        AppColors.background.withOpacity(0.7),
                                        AppColors.background,
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(24),
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${movie.year} • ${movie.formattedDuration}',
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPlayerScreen(
                                                movieId: movie.id,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      'Play',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _toggleFavorites(
                                      movieProvider,
                                      authProvider,
                                      movie.id,
                                      isInFavorites,
                                    ),
                                    icon: Icon(
                                      isInFavorites ? Icons.check : Icons.add,
                                      size: 20,
                                    ),
                                    label: Text(
                                      isInFavorites
                                          ? 'Yêu Thích'
                                          : 'Thêm Vào Yêu Thích',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.backgroundCard,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Description
                              Text(
                                movie.description,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Cast Section
                              if (movie.cast.isNotEmpty) ...[
                                const Text(
                                  'Diễn Viên',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 140,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: movie.cast.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 24),
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          Container(
                                            width: 96,
                                            height: 96,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.backgroundCard,
                                              border: Border.all(
                                                color: AppColors.backgroundCard,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                movie.cast[index][0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              movie.cast[index],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],

                              // Related Movies
                              if (relatedMovies.isNotEmpty) ...[
                                const Text(
                                  'Phim Liên Quan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 240,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: relatedMovies.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final relatedMovie = relatedMovies[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailScreen(
                                                    movieId: relatedMovie.id,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: 160,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  relatedMovie.posterUrl,
                                                  height: 200,
                                                  width: 160,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          height: 200,
                                                          color: AppColors
                                                              .backgroundCard,
                                                          child: const Icon(
                                                            Icons.movie,
                                                            color: Colors.grey,
                                                            size: 40,
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                relatedMovie.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],

                              // Comments Section
                              CommentsSection(movieId: movie.id),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleFavorites(
    MovieProvider movieProvider,
    AuthProvider authProvider,
    String movieId,
    bool isInFavorites,
  ) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập trước'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      if (isInFavorites) {
        await movieProvider.removeFromFavorites(authProvider.user!.id, movieId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi yêu thích'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        await movieProvider.addToFavorites(authProvider.user!.id, movieId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm vào yêu thích'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
