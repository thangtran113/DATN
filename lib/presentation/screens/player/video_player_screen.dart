import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/subtitle.dart';
import '../../../domain/entities/saved_word.dart';
import '../../../data/repositories/subtitle_repository.dart';
import '../../../data/services/dictionary_service.dart';
import '../../../data/services/translation_service.dart';
import '../../providers/movie_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/subtitle_display.dart';
import '../../widgets/dictionary_popup.dart';

// Fullscreen cho Web sử dụng package:web (thay thế dart:html đã lỗi thời)
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
  bool _showSubtitleList = false; // 🆕 Show/hide subtitle list panel
  final _subtitleRepository = SubtitleRepository();

  // Dictionary
  final _dictionaryService = DictionaryService();
  final _translationService = TranslationService();

  // 🆕 Playback Speed
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // 🆕 Volume Control
  double _volume = 1.0;
  bool _isMuted = false;
  bool _showVolumeSlider = false;

  // 🆕 Bookmarked sentences
  final List<Subtitle> _bookmarkedSubtitles = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Lắng nghe thay đổi chế độ fullscreen trên web (ví dụ: khi người dùng nhấn ESC)
    if (kIsWeb) {
      web.document.onfullscreenchange = (web.Event event) {
        // Chỉ cập nhật nếu không đang chuyển đổi (tránh setState hai lần)
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

      // Tải phụ đề
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
      // Kiểm tra xem phim có URL phụ đề không
      if (movie.subtitles != null && movie.subtitles!.isNotEmpty) {
        print('📝 Loading subtitles from URL...');
        print('📝 Subtitles map: ${movie.subtitles}');

        // Kiểm tra phụ đề song ngữ (en + vi)
        final enUrl = movie.subtitles!['en'] as String?;
        final viUrl = movie.subtitles!['vi'] as String?;

        print('📝 EN URL: $enUrl');
        print('📝 VI URL: $viUrl');

        if (enUrl != null && viUrl != null) {
          print('📝 Loading bilingual subtitles from URLs...');
          // Tải phụ đề song ngữ
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
          // Tải file phụ đề đơn (một ngôn ngữ hoặc song ngữ trong một file)
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
            // Không đồng bộ _isPlaying từ controller để tránh xung đột
            // Chỉ cập nhật vị trí cho thanh tiến trình
          });
        }
      });

      _videoController!.play();
      setState(() => _isPlaying = true);
      _startHideControlsTimer();

      // Đồng bộ định kỳ để đảm bảo UI khớp với trạng thái video
      _syncTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted && _videoController != null) {
          final actuallyPlaying = _videoController!.value.isPlaying;
          if (_isPlaying != actuallyPlaying) {
            setState(() => _isPlaying = actuallyPlaying);
          }

          // Cập nhật phụ đề hiện tại
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
            duration: const Duration(seconds: 1),
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

  // 🆕 ============ VOLUME CONTROL METHODS ============

  void _toggleMute() {
    if (_videoController == null) return;

    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _videoController!.setVolume(0.0);
      } else {
        _videoController!.setVolume(_volume);
      }
    });
  }

  void _setVolume(double volume) {
    if (_videoController == null) return;

    setState(() {
      _volume = volume;
      if (!_isMuted) {
        _videoController!.setVolume(volume);
      }
      if (volume > 0 && _isMuted) {
        _isMuted = false;
      }
    });
  }

  // 🆕 ============ SPEED CONTROL METHODS ============

  void _changePlaybackSpeed(double speed) {
    if (_videoController == null) return;

    setState(() {
      _playbackSpeed = speed;
    });

    _videoController!.setPlaybackSpeed(speed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tốc độ phát: ${speed}x'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 🆕 ============ SUBTITLE JUMP METHODS ============

  void _jumpToSubtitle(Subtitle subtitle) {
    if (_videoController == null) return;

    _videoController!.seekTo(subtitle.startTime);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã nhảy tới: ${subtitle.textEn}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 🆕 ============ BOOKMARK METHODS ============

  void _toggleBookmark(Subtitle subtitle) {
    setState(() {
      final index = _bookmarkedSubtitles.indexWhere(
        (s) => s.startTime == subtitle.startTime,
      );
      if (index >= 0) {
        _bookmarkedSubtitles.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa đánh dấu'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        _bookmarkedSubtitles.add(subtitle);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm đánh dấu'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.blue,
          ),
        );
      }
    });
  }

  bool _isBookmarked(Subtitle subtitle) {
    return _bookmarkedSubtitles.any((s) => s.startTime == subtitle.startTime);
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

    // Ghi nhớ xem video có đang phát không
    final wasPlaying = _videoController?.value.isPlaying ?? false;

    if (kIsWeb) {
      // Web: Sử dụng package:web Fullscreen API
      _isTogglingFullscreen = true;

      try {
        if (!_isFullscreen) {
          // Vào chế độ fullscreen
          web.document.documentElement?.requestFullscreen();
        } else {
          // Thoát chế độ fullscreen
          web.document.exitFullscreen();
        }

        // Cập nhật trạng thái mà không ảnh hưởng đến video
        setState(() {
          _isFullscreen = !_isFullscreen;
          _showControls = true; // Show controls when toggling fullscreen
        });

        // BẮT BUỘC video tiếp tục phát nếu nó đang phát trước đó
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

        // Đặt lại cờ sau một chút
        Future.delayed(const Duration(milliseconds: 500), () {
          _isTogglingFullscreen = false;
        });
      } catch (e) {
        _isTogglingFullscreen = false;
        print('Fullscreen error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fullscreen không được hỗ trợ'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Mobile: Sử dụng SystemChrome
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

    // Tạm dừng video để người dùng đọc định nghĩa
    if (_videoController != null && _isPlaying) {
      _videoController!.pause();
      setState(() => _isPlaying = false);
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFE50914)),
      ),
    );

    // Tra từ
    final definition = await _dictionaryService.lookupWord(word);

    // Đóng loading
    if (mounted) {
      Navigator.pop(context);
    }

    if (definition != null) {
      // Hiển thị popup từ điển
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
      // Không tìm thấy từ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy từ "$word" trong từ điển'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 1),
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

      // Dịch nghĩa sang tiếng Việt
      String? vietnameseMeaning;
      try {
        vietnameseMeaning = await _translationService.translateDefinition(
          meaningText,
        );
        if (vietnameseMeaning != null) {
          print('✅ Đã dịch sang tiếng Việt: $vietnameseMeaning');
        }
      } catch (e) {
        print('⚠️ Không thể dịch sang tiếng Việt: $e');
        // Tiếp tục lưu từ ngay cả khi không dịch được
      }

      // Tạo SavedWord
      final savedWord = SavedWord(
        id: '', // Firestore sẽ tự tạo ID
        userId: authProvider.user!.id,
        word: definition.word,
        meaning: meaningText,
        vietnameseMeaning: vietnameseMeaning,
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
            duration: const Duration(seconds: 1),
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
                      backgroundColor: AppColors.primary,
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
          // Phím Space - Phát/Tạm dừng
          if (event.logicalKey == LogicalKeyboardKey.space) {
            _togglePlayPause();
          }
          // Phím mũi tên phải - Tiến 10 giây
          else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _skipForward();
            setState(() => _showControls = true);
            _startHideControlsTimer();
          }
          // Phím mũi tên trái - Lùi 10 giây
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _skipBackward();
            setState(() => _showControls = true);
            _startHideControlsTimer();
          }
          // Phím F - Bật/tắt fullscreen
          else if (event.logicalKey == LogicalKeyboardKey.keyF) {
            _toggleFullscreen();
          }
          // Phím Escape - Thoát fullscreen
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
                // Trình phát video (Một instance duy nhất, không rebuild)
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

                // Lớp phủ gradient kiểu Netflix
                if (_showControls) ...[
                  // Gradient trên đỉnh
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

                  // Gradient dưới đáy
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

                // Điều khiển trên cùng (Nút quay lại + Tiêu đề)
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

                // Nút Phát/Tạm dừng giữa màn hình
                if (_showControls)
                  Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap from propagating to parent
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Lùi lại
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
                          // Phát/Tạm dừng
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
                          // Tiến tới
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

                // Phụ đề - Luôn hiển thị (độc lập với điều khiển)
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
                          fontSize: 28,
                          onWordTap: _onWordTap, // Enable word clicking
                        ),
                      ),
                    ),
                  ),

                // Điều khiển dưới cùng (Thanh tiến trình + Thời gian + Fullscreen)
                if (_showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Thanh tiến trình
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
                                activeTrackColor: AppColors.accent,
                                inactiveTrackColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                                thumbColor: AppColors.accent,
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

                          // Hiển thị thời gian và điều khiển
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Thời gian
                                Expanded(
                                  child: Text(
                                    '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Điều khiển bên phải
                                Row(
                                  children: [
                                    // 🆕 Volume Control
                                    MouseRegion(
                                      onEnter: (_) {
                                        setState(
                                          () => _showVolumeSlider = true,
                                        );
                                      },
                                      onExit: (_) {
                                        setState(
                                          () => _showVolumeSlider = false,
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              _isMuted || _volume == 0
                                                  ? Icons.volume_off
                                                  : _volume < 0.5
                                                  ? Icons.volume_down
                                                  : Icons.volume_up,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            onPressed: _toggleMute,
                                            tooltip: _isMuted
                                                ? 'Unmute'
                                                : 'Mute',
                                          ),
                                          if (_showVolumeSlider)
                                            Container(
                                              width: 100,
                                              child: SliderTheme(
                                                data: SliderThemeData(
                                                  trackHeight: 2,
                                                  thumbShape:
                                                      const RoundSliderThumbShape(
                                                        enabledThumbRadius: 5,
                                                      ),
                                                  overlayShape:
                                                      const RoundSliderOverlayShape(
                                                        overlayRadius: 10,
                                                      ),
                                                  activeTrackColor:
                                                      Colors.white,
                                                  inactiveTrackColor: Colors
                                                      .white
                                                      .withOpacity(0.3),
                                                  thumbColor: Colors.white,
                                                  overlayColor: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                                child: Slider(
                                                  value: _isMuted ? 0 : _volume,
                                                  min: 0.0,
                                                  max: 1.0,
                                                  onChanged: _setVolume,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // 🆕 Speed Control
                                    PopupMenuButton<double>(
                                      icon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${_playbackSpeed}x',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      color: Colors.black87,
                                      onSelected: _changePlaybackSpeed,
                                      itemBuilder: (context) {
                                        return _speedOptions.map((speed) {
                                          return PopupMenuItem<double>(
                                            value: speed,
                                            child: Row(
                                              children: [
                                                if (speed == _playbackSpeed)
                                                  Icon(
                                                    Icons.check,
                                                    color: AppColors.accent,
                                                    size: 18,
                                                  )
                                                else
                                                  const SizedBox(width: 18),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${speed}x',
                                                  style: TextStyle(
                                                    color:
                                                        speed == _playbackSpeed
                                                        ? const Color(
                                                            0xFFE50914,
                                                          )
                                                        : Colors.white,
                                                    fontWeight:
                                                        speed == _playbackSpeed
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                    const SizedBox(width: 8),

                                    // 🆕 Subtitle List Toggle
                                    IconButton(
                                      icon: Icon(
                                        _showSubtitleList
                                            ? Icons.list
                                            : Icons.list_outlined,
                                        color: _showSubtitleList
                                            ? AppColors.accent
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showSubtitleList =
                                              !_showSubtitleList;
                                        });
                                      },
                                      tooltip: 'Subtitle List',
                                    ),
                                    const SizedBox(width: 8),

                                    // Nút fullscreen
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

                // Chỉ báo đang tải
                if (_isSeeking)
                  Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),

                // 🆕 Subtitle List Panel
                if (_showSubtitleList)
                  Positioned(
                    right: 0,
                    top: 80,
                    bottom: 180,
                    width: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.9),
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Tiêu đề
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE50914,
                              ).withValues(alpha: 0.2),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtitles',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() => _showSubtitleList = false);
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Danh sách phụ đề
                          Expanded(
                            child: ListView.builder(
                              itemCount: _subtitles.length,
                              itemBuilder: (context, index) {
                                final subtitle = _subtitles[index];
                                final isActive = _currentSubtitle == subtitle;
                                final isBookmarked = _isBookmarked(subtitle);

                                return InkWell(
                                  onTap: () => _jumpToSubtitle(subtitle),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(
                                              0xFFE50914,
                                            ).withValues(alpha: 0.3)
                                          : Colors.transparent,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Thời gian
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            _formatDuration(subtitle.startTime),
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.white
                                                  : Colors.white.withValues(
                                                      alpha: 0.6,
                                                    ),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Nội dung phụ đề
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                subtitle.textEn,
                                                style: TextStyle(
                                                  color: isActive
                                                      ? Colors.white
                                                      : Colors.white.withValues(
                                                          alpha: 0.8,
                                                        ),
                                                  fontSize: 14,
                                                  fontWeight: isActive
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              if (subtitle
                                                  .textVi
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  subtitle.textVi,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),

                                        // Nút đánh dấu
                                        IconButton(
                                          icon: Icon(
                                            isBookmarked
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: isBookmarked
                                                ? AppColors.accent
                                                : Colors.white.withValues(
                                                    alpha: 0.5,
                                                  ),
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _toggleBookmark(subtitle),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
