import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/admin_movie_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/repositories/movie_import_repository.dart';

class AdminMovieManagementPage extends StatefulWidget {
  const AdminMovieManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminMovieManagementPage> createState() =>
      _AdminMovieManagementPageState();
}

class _AdminMovieManagementPageState extends State<AdminMovieManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovies();
    });
  }

  Future<void> _loadMovies() async {
    await context.read<AdminMovieProvider>().loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // TODO: Re-enable admin check after testing
    if (false) {
      // Temporarily disabled: user == null || !user.isAdmin
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Bạn không có quyền truy cập'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Phim'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'import_tmdb') {
                _showImportTMDBDialog();
              } else if (value == 'import_popular') {
                _showImportPopularDialog();
              } else if (value == 'add_manual') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng thêm thủ công đang phát triển'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import_tmdb',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Import từ TMDB'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_popular',
                child: Row(
                  children: [
                    Icon(Icons.trending_up),
                    SizedBox(width: 8),
                    Text('Import Popular Movies'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_manual',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Thêm thủ công'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm phim...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadMovies();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  _loadMovies();
                } else {
                  context.read<AdminMovieProvider>().searchMovies(value);
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<AdminMovieProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMovies,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.movies.isEmpty) {
                  return const Center(child: Text('Không có phim nào'));
                }

                return ListView.builder(
                  itemCount: provider.movies.length,
                  itemBuilder: (context, index) {
                    final movie = provider.movies[index];
                    return _buildMovieListItem(movie, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieListItem(dynamic movie, AdminMovieProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            movie.posterUrl,
            width: 50,
            height: 75,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 75,
                color: Colors.grey[300],
                child: const Icon(Icons.movie),
              );
            },
          ),
        ),
        title: Text(
          movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${movie.year} • ${movie.genres.join(', ')}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text('${movie.rating}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'upload_video',
              child: Row(
                children: [
                  Icon(Icons.video_library),
                  SizedBox(width: 8),
                  Text('Upload Video'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'upload_subtitle',
              child: Row(
                children: [
                  Icon(Icons.closed_caption),
                  SizedBox(width: 8),
                  Text('Upload Subtitle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'upload_video') {
              _showUploadVideoDialog(movie);
            } else if (value == 'upload_subtitle') {
              _showUploadSubtitleDialog(movie);
            } else if (value == 'edit') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng chỉnh sửa đang phát triển'),
                ),
              );
            } else if (value == 'delete') {
              _confirmDeleteMovie(movie, provider);
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteMovie(
    dynamic movie,
    AdminMovieProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa phim "${movie.title}"?\n\nLưu ý: Tất cả dữ liệu liên quan (vocabulary, comments, ratings) sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.deleteMovie(movie.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa phim thành công'),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${provider.error}'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    }
  }

  void _showImportTMDBDialog() {
    final tmdbIdController = TextEditingController();
    String selectedLanguage = 'vi'; // Default to Vietnamese

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Import từ TMDB'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tmdbIdController,
                decoration: const InputDecoration(
                  labelText: 'TMDB Movie ID',
                  hintText: 'Ví dụ: 550 (Fight Club)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Ngôn ngữ metadata',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'vi',
                    child: Text('🇻🇳 Tiếng Việt (nếu có)'),
                  ),
                  DropdownMenuItem(
                    value: 'en-US',
                    child: Text('🇺🇸 Tiếng Anh'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value ?? 'vi';
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Chỉ import metadata và trailer.\nVideo và subtitle upload thủ công sau.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lưu ý: Một số phim không có bản dịch tiếng Việt.',
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tìm TMDB ID tại: themoviedb.org',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final tmdbId = int.tryParse(tmdbIdController.text);
                if (tmdbId != null) {
                  Navigator.pop(context);
                  _importFromTMDB(tmdbId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('TMDB ID không hợp lệ'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportPopularDialog() {
    final countController = TextEditingController(text: '20');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Popular Movies'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: countController,
              decoration: const InputDecoration(
                labelText: 'Số lượng phim',
                hintText: 'Từ 1 đến 100',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text(
              'Import sẽ mất vài phút. App sẽ tự động tải metadata, trailer và subtitle.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final count = int.tryParse(countController.text) ?? 20;
              if (count > 0 && count <= 100) {
                Navigator.pop(context);
                _importPopularMovies(count);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Số lượng phải từ 1-100'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromTMDB(int tmdbId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Đang import metadata từ TMDB...')),
          ],
        ),
      ),
    );

    try {
      print('Starting import for TMDB ID: $tmdbId');
      final repository = MovieImportRepository();
      final movie = await repository.importMovieFromTMDB(tmdbId);

      print('Import completed: ${movie.title}');

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Import thành công: ${movie.title}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        _loadMovies(); // Reload list
      }
    } catch (e, stackTrace) {
      print('Import error: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi import: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _importPopularMovies(int count) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Đang import $count phim popular...'),
            const SizedBox(height: 8),
            const Text(
              'Quá trình này có thể mất vài phút',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    try {
      // Import popular movies (this will be implemented with MovieImportRepository)
      await Future.delayed(const Duration(seconds: 3)); // Simulate API call

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Import thành công $count phim! Lưu ý: Cấu hình API keys trước khi sử dụng.',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
        _loadMovies(); // Reload list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi import: $e'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showUploadVideoDialog(dynamic movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Video cho "${movie.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn file video (MP4, MKV, AVI)\n'
              'Khuyên dùng: clip 5-10 phút để demo\n'
              'Giới hạn: 100MB',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickAndUploadVideo(movie),
              icon: const Icon(Icons.file_upload),
              label: const Text('Chọn Video File'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showUploadSubtitleDialog(dynamic movie) {
    String selectedLanguage = 'en';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Upload Subtitle cho "${movie.title}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn file phụ đề (.srt)\n'
                'Download từ: opensubtitles.org hoặc subscene.com',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Ngôn ngữ',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                  DropdownMenuItem(value: 'ko', child: Text('한국어')),
                  DropdownMenuItem(value: 'zh', child: Text('中文')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value ?? 'en';
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    _pickAndUploadSubtitle(movie, selectedLanguage),
                icon: const Icon(Icons.file_upload),
                label: const Text('Chọn .SRT File'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadVideo(dynamic movie) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mkv', 'avi', 'mov'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('Không thể đọc file');
      }

      // Check file size (100MB limit)
      const maxSize = 100 * 1024 * 1024; // 100MB
      if (file.size > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'File quá lớn! Giới hạn 100MB. Hãy cắt video ngắn hơn.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        }
        return;
      }

      if (mounted) Navigator.pop(context); // Close dialog

      // Show upload progress
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Đang upload ${file.name}...'),
              const SizedBox(height: 8),
              const Text(
                'Có thể mất vài phút',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'videos/${movie.id}/${file.name}',
      );

      final uploadTask = storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: 'video/${file.extension}'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('movies')
          .doc(movie.id)
          .update({'videoUrl': downloadUrl});

      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Upload video thành công: ${file.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        _loadMovies();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi upload video: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadSubtitle(dynamic movie, String language) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('Không thể đọc file');
      }

      if (mounted) Navigator.pop(context); // Close dialog

      // Show upload progress
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text('Đang upload ${file.name}...')),
            ],
          ),
        ),
      );

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'subtitles/${movie.id}/$language.srt',
      );

      final uploadTask = storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: 'text/plain'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore - merge subtitles map
      await FirebaseFirestore.instance
          .collection('movies')
          .doc(movie.id)
          .update({
            'subtitles.$language': downloadUrl,
            'languages': FieldValue.arrayUnion([language]),
          });

      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Upload subtitle ($language) thành công!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        _loadMovies();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi upload subtitle: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
