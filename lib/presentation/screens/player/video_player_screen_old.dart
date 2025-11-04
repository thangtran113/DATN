import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String movieId;

  const VideoPlayerScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _isLoading = true;
  bool _isHoveringProgress = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovie();
    });
  }

  Future<void> _loadMovie() async {
    print('🎬 Loading movie: ${widget.movieId}');
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    await movieProvider.fetchMovieById(widget.movieId);

    final movie = movieProvider.selectedMovie;
    print('🎬 Movie loaded: ${movie?.title}');
    print('🎬 Video URL: ${movie?.videoUrl}');

    if (movie != null && movie.videoUrl != null && movie.videoUrl!.isNotEmpty) {
      print('🎬 Initializing video player with URL: ${movie.videoUrl}');
      _initializeVideoPlayer(movie.videoUrl!);
    } else {
      print('❌ No video URL found for movie');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Video không có sẵn. Vui lòng thêm videoUrl vào Firebase!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    try {
      print('🎥 Creating VideoPlayerController...');
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      print('🎥 Initializing video player...');
      await _videoController!.initialize();

      print(
        '✅ Video initialized! Duration: ${_videoController!.value.duration}',
      );

      setState(() {
        _totalDuration = _videoController!.value.duration;
        _isLoading = false;
      });

      // Listen to video position updates
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            _currentPosition = _videoController!.value.position;
            _isPlaying = _videoController!.value.isPlaying;
          });
        }
      });

      // Auto-play
      _videoController!.play();
      setState(() => _isPlaying = true);
      print('▶️ Video playing');
    } catch (e) {
      print('❌ Error initializing video: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi load video: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null) return;

    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _seekTo(Duration position) {
    _videoController?.seekTo(position);
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // Enter fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Exit fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _skipBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _skipForward() {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    _seekTo(newPosition > _totalDuration ? _totalDuration : newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          final movie = movieProvider.selectedMovie;

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
            );
          }

          if (movie == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Movie not found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: _isFullscreen
                ? _buildFullscreenPlayer(movie)
                : _buildNormalPlayer(movie),
          );
        },
      ),
    );
  }

  Widget _buildNormalPlayer(Movie movie) {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Video Player Area
        Expanded(
          child: Center(
            child: AspectRatio(aspectRatio: 16 / 9, child: _buildVideoPlayer()),
          ),
        ),

        // Subtitle Area (Placeholder for Week 5)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.black87,
          child: Column(
            children: [
              // English subtitle
              Text(
                'English subtitle will appear here',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Vietnamese subtitle
              Text(
                'Phụ đề tiếng Việt sẽ hiện ở đây',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Additional Info
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${movie.year}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    movie.formattedDuration,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      movie.levelDisplay,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullscreenPlayer(Movie movie) {
    return Stack(
      children: [
        Center(
          child: AspectRatio(aspectRatio: 16 / 9, child: _buildVideoPlayer()),
        ),
        // Subtitle overlay for fullscreen
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Column(
              children: [
                Text(
                  'English subtitle will appear here',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    backgroundColor: Colors.black.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Phụ đề tiếng Việt sẽ hiện ở đây',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                    backgroundColor: Colors.black.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video
          VideoPlayer(_videoController!),

          // Controls Overlay
          if (_showControls)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Center controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Skip backward
                      IconButton(
                        icon: const Icon(Icons.replay_10, size: 40),
                        color: Colors.white,
                        onPressed: _skipBackward,
                      ),
                      const SizedBox(width: 40),
                      // Play/Pause
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 64,
                        ),
                        color: Colors.white,
                        onPressed: _togglePlayPause,
                      ),
                      const SizedBox(width: 40),
                      // Skip forward
                      IconButton(
                        icon: const Icon(Icons.forward_10, size: 40),
                        color: Colors.white,
                        onPressed: _skipForward,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Progress bar
                        Row(
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: _currentPosition.inSeconds.toDouble(),
                                min: 0,
                                max: _totalDuration.inSeconds.toDouble(),
                                activeColor: const Color(0xFF00BCD4),
                                inactiveColor: Colors.grey,
                                onChanged: (value) {
                                  _seekTo(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        // Additional controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Speed control (placeholder)
                            TextButton(
                              onPressed: () {
                                // TODO: Speed control in Phase 5
                              },
                              child: const Text(
                                '1.0x',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            // Fullscreen toggle
                            IconButton(
                              icon: Icon(
                                _isFullscreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                              ),
                              color: Colors.white,
                              onPressed: _toggleFullscreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
