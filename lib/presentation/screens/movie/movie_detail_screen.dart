import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';
import '../../providers/auth_provider.dart';
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
        movieProvider.fetchWatchlist(authProvider.user!.id);
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
      backgroundColor: const Color(0xFF0F0F0F),
      body: Consumer2<MovieProvider, AuthProvider>(
        builder: (context, movieProvider, authProvider, child) {
          if (movieProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }

          final movie = movieProvider.selectedMovie;
          if (movie == null) {
            return const Center(
              child: Text(
                'Movie not found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final isInWatchlist = movieProvider.isInWatchlist(movie.id);
          final isInFavorites = movieProvider.isInFavorites(movie.id);

          return CustomScrollView(
            slivers: [
              // Backdrop with gradient
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF0F0F0F),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (movie.backdropUrl != null)
                        Image.network(
                          movie.backdropUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: const Color(0xFF1A1A1A));
                          },
                        )
                      else
                        Image.network(
                          movie.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: const Color(0xFF1A1A1A));
                          },
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withAlpha(179),
                              AppColors.background,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Meta info
                      Row(
                        children: [
                          Text(
                            movie.year.toString(),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getLevelColor(movie.level),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              movie.levelDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            movie.formattedDuration,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD700),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VideoPlayerScreen(movieId: movie.id),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Watch Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE50914),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _toggleWatchlist(
                              movieProvider,
                              authProvider,
                              movie.id,
                              isInWatchlist,
                            ),
                            icon: Icon(
                              isInWatchlist
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _toggleFavorites(
                              movieProvider,
                              authProvider,
                              movie.id,
                              isInFavorites,
                            ),
                            icon: Icon(
                              isInFavorites
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Genres
                      const Text(
                        'Genres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genres.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Cast
                      if (movie.cast.isNotEmpty) ...[
                        const Text(
                          'Cast',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.cast.join(', '),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Director
                      const Text(
                        'Director',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.director,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // Available subtitles
                      const Text(
                        'Available Subtitles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: movie.languages.map((lang) {
                          return Chip(
                            label: Text(lang.toUpperCase()),
                            backgroundColor: const Color(0xFF1A1A1A),
                            labelStyle: const TextStyle(color: Colors.white),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        children: [
                          _buildStatItem(
                            Icons.visibility_outlined,
                            '${movie.viewCount} views',
                          ),
                          const SizedBox(width: 24),
                          _buildStatItem(
                            Icons.calendar_today_outlined,
                            'Added ${_getTimeAgo(movie.createdAt)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Related Movies
                      if (relatedMovies.isNotEmpty) ...[
                        const Text(
                          'More Like This',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: relatedMovies.length,
                            itemBuilder: (context, index) {
                              final relatedMovie = relatedMovies[index];
                              return Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => MovieDetailScreen(
                                          movieId: relatedMovie.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          relatedMovie.posterUrl,
                                          height: 150,
                                          width: 140,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  height: 150,
                                                  color: const Color(
                                                    0xFF1A1A1A,
                                                  ),
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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

                      // Comments Section (Preview)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Comments & Reviews',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Comments feature coming in Week 6-7!',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(color: Color(0xFF00BCD4)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey,
                              size: 40,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Be the first to comment on this movie!',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _toggleWatchlist(
    MovieProvider movieProvider,
    AuthProvider authProvider,
    String movieId,
    bool isInWatchlist,
  ) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    try {
      if (isInWatchlist) {
        await movieProvider.removeFromWatchlist(authProvider.user!.id, movieId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from watchlist')));
      } else {
        await movieProvider.addToWatchlist(authProvider.user!.id, movieId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to watchlist')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _toggleFavorites(
    MovieProvider movieProvider,
    AuthProvider authProvider,
    String movieId,
    bool isInFavorites,
  ) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    try {
      if (isInFavorites) {
        await movieProvider.removeFromFavorites(authProvider.user!.id, movieId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
      } else {
        await movieProvider.addToFavorites(authProvider.user!.id, movieId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
