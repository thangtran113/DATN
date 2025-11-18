import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/subtitle.dart';
import '../../../domain/entities/saved_word.dart';
import '../../../data/repositories/subtitle_repository.dart';
import '../../../data/services/dictionary_service.dart';
import '../../providers/movie_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/subtitle_display.dart';
import '../../widgets/dictionary_popup.dart';

// Web fullscreen sử dụng package:web (thay thế dart:html deprecated)
import 'package:web/web.dart' as web;

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

  // Phụ đề
  List<Subtitle> _subtitles = [];
  Subtitle? _currentSubtitle;
  final bool _showSubtitles = true;
  final _subtitleRepository = SubtitleRepository();

  // Dictionary
  final _dictionaryService = DictionaryService();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Listen to fullscreen changes on web (e.g., when user presses ESC)
    if (kIsWeb) {
      web.document.onfullscreenchange = (web.Event event) {
        // Only update if not currently toggling (avoid double setState)
        if (!_isTogglingFullscreen && mounted) {
          final isCurrentlyFullscreen = web.document.fullscreenElement != null;
          if (_isFullscreen != isCurrentlyFullscreen) {
            setState(() => _isFullscreen = isCurrentlyFullscreen);
          }
        }
      }.toJS;
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

      // Load subtitles
      _loadSubtitles(movie);
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

  Future<void> _loadSubtitles(Movie movie) async {
    try {
      // Check if movie has subtitle URL
      if (movie.subtitles != null && movie.subtitles!.isNotEmpty) {
        print('📝 Loading subtitles from URL...');
        print('📝 Subtitles map: ${movie.subtitles}');

        // Check for bilingual subtitles (en + vi)
        final enUrl = movie.subtitles!['en'] as String?;
        final viUrl = movie.subtitles!['vi'] as String?;

        print('📝 EN URL: $enUrl');
        print('📝 VI URL: $viUrl');

        if (enUrl != null && viUrl != null) {
          print('📝 Loading bilingual subtitles from URLs...');
          // Load bilingual subtitles
          final subtitles = await _subtitleRepository.loadBilingualFromUrls(
            englishUrl: enUrl,
            vietnameseUrl: viUrl,
          );

          print('📝 Loaded ${subtitles.length} subtitle entries');

          if (mounted && subtitles.isNotEmpty) {
            setState(() {
              _subtitles = subtitles;
              print('✅ Loaded ${subtitles.length} bilingual subtitles');
              print(
                '📝 First subtitle: ${subtitles.first.textEn} at ${subtitles.first.startTime}',
              );
            });
          } else {
            print('⚠️ Subtitle list is empty after loading!');
          }
        } else if (enUrl != null) {
          // Load single subtitle file (monolingual or bilingual in one file)
          final subtitles = await _subtitleRepository.loadFromUrl(enUrl);

          if (mounted && subtitles.isNotEmpty) {
            setState(() {
              _subtitles = subtitles;
              print('✅ Loaded ${subtitles.length} subtitles');
            });
          }
        }
      } else {
        print('⚠️ No subtitle URL found');
      }
    } catch (e) {
      print('❌ Lỗi tải phụ đề: $e');
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

          // Update current subtitle
          Subtitle? newSubtitle;
          for (final subtitle in _subtitles) {
            if (subtitle.isActiveAt(_currentPosition)) {
              newSubtitle = subtitle;
              break;
            }
          }
          if (_currentSubtitle != newSubtitle) {
            setState(() => _currentSubtitle = newSubtitle);
            if (newSubtitle != null) {
              print('📝 Subtitle updated: ${newSubtitle.textEn}');
            }
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
      // Web: Use package:web Fullscreen API
      _isTogglingFullscreen = true;

      try {
        if (!_isFullscreen) {
          // Enter fullscreen
          web.document.documentElement?.requestFullscreen();
        } else {
          // Exit fullscreen
          web.document.exitFullscreen();
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
            print(
              '🎵 Video is playing AFTER: ${_videoController?.value.isPlaying}',
            );
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

  /// Handle word tap from subtitle
  Future<void> _onWordTap(String word) async {
    print('📖 Word tapped: $word');

    // Pause video to let user read definition
    if (_videoController != null && _isPlaying) {
      _videoController!.pause();
      setState(() => _isPlaying = false);
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFE50914)),
      ),
    );

    // Lookup word
    final definition = await _dictionaryService.lookupWord(word);

    // Close loading
    if (mounted) {
      Navigator.pop(context);
    }

    if (definition != null) {
      // Show dictionary popup
      if (mounted) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => DictionaryPopup(
            wordDefinition: definition,
            onSaveWord: () {
              _saveWordToVocabulary(definition.word);
            },
          ),
        );
      }
    } else {
      // Word not found
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Word "$word" not found in dictionary'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Lưu từ vào danh sách từ vựng với Firestore
  Future<void> _saveWordToVocabulary(String word) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final vocabularyProvider = context.read<VocabularyProvider>();
      final movieProvider = context.read<MovieProvider>();

      if (authProvider.user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng đăng nhập để lưu từ vựng'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Lấy định nghĩa từ
      final definition = await _dictionaryService.lookupWord(word);
      if (definition == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không tìm thấy định nghĩa cho từ "$word"'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Lấy nghĩa đầu tiên
      final firstMeaning = definition.meanings.isNotEmpty
          ? definition.meanings.first
          : null;
      final meaningText = firstMeaning?.definitions.isNotEmpty == true
          ? firstMeaning!.definitions.first.definition
          : 'No definition available';
      final example = firstMeaning?.definitions.isNotEmpty == true
          ? firstMeaning!.definitions.first.example
          : null;

      // Tạo SavedWord
      final savedWord = SavedWord(
        id: '', // Firestore sẽ tự tạo ID
        userId: authProvider.user!.id,
        word: definition.word,
        meaning: meaningText,
        pronunciation: definition.phonetic,
        example: example,
        movieId: widget.movieId,
        movieTitle: movieProvider.selectedMovie?.title,
        timestamp: _videoController?.value.position.inMilliseconds,
        createdAt: DateTime.now(),
        masteryLevel: 0, // Chưa học
        reviewCount: 0,
      );

      // Lưu vào Firestore
      final success = await vocabularyProvider.saveWord(savedWord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã lưu từ "${definition.word}" vào từ vựng!'
                  : 'Lỗi khi lưu từ vựng',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Lỗi khi lưu từ: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
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
                      aspectRatio:
                          _videoController?.value.aspectRatio ?? 16 / 9,
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
                            Colors.black.withValues(alpha: 0.7),
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
                            Colors.black.withValues(alpha: 0.8),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
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
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
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
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: Text(
                                          movie.levelDisplay.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
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
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 48,
                            ),
                            onPressed: () {
                              _skipBackward();
                              _startHideControlsTimer();
                            },
                          ),
                          const SizedBox(width: 32),
                          // Play/Pause
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
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
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 48,
                            ),
                            onPressed: () {
                              _skipForward();
                              _startHideControlsTimer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Subtitles - Always visible (independent of controls)
                if (_showSubtitles && _currentSubtitle != null)
                  Positioned(
                    bottom: _showControls
                        ? 120
                        : 40, // Position higher when controls are shown
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: SubtitleDisplay(
                          currentSubtitle: _currentSubtitle,
                          showVietnamese: true,
                          fontSize: 18,
                          onWordTap: _onWordTap, // Enable word clicking
                        ),
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
                                inactiveTrackColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                                thumbColor: const Color(0xFFE50914),
                                overlayColor: const Color(
                                  0xFFE50914,
                                ).withValues(alpha: 0.3),
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
                                    _currentPosition = Duration(
                                      seconds: value.toInt(),
                                    );
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
                                        // Chức năng toggle phụ đề - sẽ implement sau
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cài đặt phụ đề - Sắp ra mắt!',
                                            ),
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
                                        // Chức năng cài đặt (chất lượng, tốc độ) - sẽ implement sau
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cài đặt - Sắp ra mắt!',
                                            ),
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
                    child: CircularProgressIndicator(color: Color(0xFFE50914)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
