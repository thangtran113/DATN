import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';

// Import for web fullscreen
import 'dart:html' as html show document;

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
  bool _isTogglingFullscreen = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _hideControlsTimer;
  Timer? _syncTimer;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    // Listen to fullscreen changes on web (e.g., when user presses ESC)
    if (kIsWeb) {
      html.document.onFullscreenChange.listen((_) {
        // Only update if not currently toggling (avoid double setState)
        if (!_isTogglingFullscreen) {
          final isCurrentlyFullscreen = html.document.fullscreenElement != null;
          if (mounted && _isFullscreen != isCurrentlyFullscreen) {
            setState(() => _isFullscreen = isCurrentlyFullscreen);
          }
        }
      });
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovie();
      _focusNode.requestFocus(); // Request focus for keyboard events
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
            // Don't sync _isPlaying from controller to avoid conflicts
            // Only update position for progress bar
          });
        }
      });

      _videoController!.play();
      setState(() => _isPlaying = true);
      _startHideControlsTimer();
      
      // Periodic sync to ensure UI matches video state
      _syncTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted && _videoController != null) {
          final actuallyPlaying = _videoController!.value.isPlaying;
          if (_isPlaying != actuallyPlaying) {
            setState(() => _isPlaying = actuallyPlaying);
          }
        }
      });
      
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
    _syncTimer?.cancel();
    _videoController?.dispose();
    _focusNode.dispose();
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
      _isPlaying = !_isPlaying;
      _showControls = true;
    });

    if (_isPlaying) {
      _videoController!.play();
      _startHideControlsTimer();
    } else {
      _videoController!.pause();
      _hideControlsTimer?.cancel();
    }
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
    print('🔲 Toggle fullscreen: $_isFullscreen -> ${!_isFullscreen}');
    print('🎵 Video is playing BEFORE: ${_videoController?.value.isPlaying}');
    
    // Remember if video was playing
    final wasPlaying = _videoController?.value.isPlaying ?? false;
    
    if (kIsWeb) {
      // Web: Use HTML5 Fullscreen API
      _isTogglingFullscreen = true;
      
      try {
        if (!_isFullscreen) {
          // Enter fullscreen
          html.document.documentElement?.requestFullscreen();
        } else {
          // Exit fullscreen
          html.document.exitFullscreen();
        }
        
        // Update state without affecting video playback
        setState(() {
          _isFullscreen = !_isFullscreen;
          _showControls = true; // Show controls when toggling fullscreen
        });
        
        // FORCE video to continue playing if it was playing before
        Future.delayed(const Duration(milliseconds: 100), () {
          if (wasPlaying && _videoController != null) {
            if (!_videoController!.value.isPlaying) {
              print('🔄 Forcing video to continue playing...');
              _videoController!.play();
            }
            print('🎵 Video is playing AFTER: ${_videoController?.value.isPlaying}');
          }
        });
        
        _startHideControlsTimer(); // Auto-hide controls after 3s
        
        // Reset flag after a delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _isTogglingFullscreen = false;
        });
      } catch (e) {
        _isTogglingFullscreen = false;
        print('Fullscreen error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fullscreen không được hỗ trợ'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Mobile: Use SystemChrome
      setState(() {
        _isFullscreen = !_isFullscreen;
        _showControls = true;
      });

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
      _startHideControlsTimer();
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
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          // Space bar - Play/Pause
          if (event.logicalKey == LogicalKeyboardKey.space) {
            _togglePlayPause();
          }
          // Arrow Right - Skip forward 10s
          else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _skipForward();
            setState(() => _showControls = true);
            _startHideControlsTimer();
          }
          // Arrow Left - Skip backward 10s
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _skipBackward();
            setState(() => _showControls = true);
            _startHideControlsTimer();
          }
          // F or f - Toggle fullscreen
          else if (event.logicalKey == LogicalKeyboardKey.keyF) {
            _toggleFullscreen();
          }
          // Escape - Exit fullscreen
          else if (event.logicalKey == LogicalKeyboardKey.escape) {
            if (_isFullscreen) {
              _toggleFullscreen();
            }
          }
        }
      },
      child: MouseRegion(
        onHover: (_) {
          if (!_showControls) {
            setState(() => _showControls = true);
          }
          _startHideControlsTimer();
        },
        child: GestureDetector(
          onTap: _toggleControls,
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
            // Video Player (Single instance, never rebuilt)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isFullscreen ? double.infinity : null,
                height: _isFullscreen ? double.infinity : null,
                child: AspectRatio(
                  aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                  child: VideoPlayer(
                    _videoController!,
                    key: const ValueKey('single_video_player'),
                  ),
                ),
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
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from propagating to parent
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip Backward
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white, size: 48),
                        onPressed: () {
                          _skipBackward();
                          _startHideControlsTimer();
                        },
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
                        onPressed: () {
                          _skipForward();
                          _startHideControlsTimer();
                        },
                      ),
                    ],
                  ),
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
        ),
      ),
    );
  }
}
