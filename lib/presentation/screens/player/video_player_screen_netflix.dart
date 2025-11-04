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
  bool _isSeeking = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
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
            content: Text('Video không có sẵn. Vui lòng thêm videoUrl vào Firebase!'),
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

      print('✅ Video initialized! Duration: ${_videoController!.value.duration}');

      setState(() {
        _totalDuration = _videoController!.value.duration;
        _isLoading = false;
      });

      _videoController!.addListener(() {
        if (mounted && !_isSeeking) {
          setState(() {
            _currentPosition = _videoController!.value.position;
            _isPlaying = _videoController!.value.isPlaying;
          });
        }
      });

      _videoController!.play();
      setState(() => _isPlaying = true);
      _startHideControlsTimer();
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

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoController?.dispose();
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
        _hideControlsTimer?.cancel();
      } else {
        _videoController!.play();
        _startHideControlsTimer();
      }
      _isPlaying = !_isPlaying;
      _showControls = true;
    });
  }

  void _seekTo(Duration position) {
    _videoController?.seekTo(position);
    setState(() => _currentPosition = position);
  }

  void _skipBackward() {
    if (_videoController == null) return;
    final newPosition = _currentPosition - const Duration(seconds: 10);
    _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _skipForward() {
    if (_videoController == null) return;
    final newPosition = _currentPosition + const Duration(seconds: 10);
    _seekTo(newPosition > _totalDuration ? _totalDuration : newPosition);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }

          final movie = movieProvider.selectedMovie;
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return _buildNetflixPlayer(movie);
        },
      ),
    );
  }

  Widget _buildNetflixPlayer(Movie movie) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Video Player (Center)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                child: VideoPlayer(_videoController!),
              ),
            ),

            // Netflix-style Gradient Overlays
            if (_showControls) ...[
              // Top gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Top Controls (Back button + Title)
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${movie.year}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      movie.levelDisplay.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 11,
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
              ),

            // Center Play/Pause Button
            if (_showControls)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Skip Backward
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 48),
                      onPressed: _skipBackward,
                    ),
                    const SizedBox(width: 32),
                    // Play/Pause
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 64,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Skip Forward
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 48),
                      onPressed: _skipForward,
                    ),
                  ],
                ),
              ),

            // Bottom Controls (Progress Bar + Time + Fullscreen)
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtitles Area (Bilingual)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Column(
                          children: [
                            // English subtitle
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'English subtitle will appear here',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Vietnamese subtitle
                            Text(
                              'Phụ đề tiếng Việt sẽ hiện ở đây',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: const Color(0xFFE50914),
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: const Color(0xFFE50914),
                            overlayColor: const Color(0xFFE50914).withOpacity(0.3),
                          ),
                          child: Slider(
                            value: _currentPosition.inSeconds.toDouble(),
                            max: _totalDuration.inSeconds.toDouble(),
                            onChangeStart: (value) {
                              setState(() => _isSeeking = true);
                              _hideControlsTimer?.cancel();
                            },
                            onChanged: (value) {
                              setState(() {
                                _currentPosition = Duration(seconds: value.toInt());
                              });
                            },
                            onChangeEnd: (value) {
                              _seekTo(Duration(seconds: value.toInt()));
                              setState(() => _isSeeking = false);
                              _startHideControlsTimer();
                            },
                          ),
                        ),
                      ),

                      // Time Display and Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Time
                            Text(
                              '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Right controls
                            Row(
                              children: [
                                // Subtitles button
                                IconButton(
                                  icon: const Icon(
                                    Icons.closed_caption,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // TODO: Toggle subtitles
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Subtitle settings - Coming soon!'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Settings button
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // TODO: Open settings (quality, speed)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Settings - Coming soon!'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Fullscreen button
                                IconButton(
                                  icon: Icon(
                                    _isFullscreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: Colors.white,
                                    size: 28,
                                  ),
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
              ),

            // Loading indicator
            if (_isSeeking)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE50914),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
