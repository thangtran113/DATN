import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/admin_movie_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../../data/repositories/movie_import_repository.dart';
import '../../../domain/entities/movie.dart';

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
    final authProvider = context.watch<app_auth.AuthProvider>();

    // TODO: Kích hoạt lại kiểm tra admin sau khi thử nghiệm
    if (false) {
      // Tạm thời vô hiệu hóa: authProvider.user == null || !authProvider.user!.isAdmin
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
              } else if (value == 'add_manual') {
                _showAddManualDialog();
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

  Widget _buildMovieListItem(Movie movie, AdminMovieProvider provider) {
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
            // ⛔ COMMENTED OUT - Using local assets instead of Firebase upload
            // const PopupMenuItem(
            //   value: 'upload_video',
            //   child: Row(
            //     children: [
            //       Icon(Icons.video_library),
            //       SizedBox(width: 8),
            //       Text('Tải Lên Video'),
            //     ],
            //   ),
            // ),
            const PopupMenuItem(
              value: 'upload_subtitle',
              child: Row(
                children: [
                  Icon(Icons.closed_caption),
                  SizedBox(width: 8),
                  Text('Tải Lên Phụ Đề'),
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
            // ⛔ COMMENTED OUT - Using local assets instead of Firebase upload
            // if (value == 'upload_video') {
            //   _showUploadVideoDialog(movie);
            // } else
            if (value == 'upload_subtitle') {
              _showUploadSubtitleDialog(movie);
            } else if (value == 'edit') {
              _showEditMovieDialog(movie);
            } else if (value == 'delete') {
              _confirmDeleteMovie(movie, provider);
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteMovie(
    Movie movie,
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
      // Gỡ lỗi: Kiểm tra ID phim
      print('Đối tượng phim: $movie');
      print('ID phim: ${movie.id}');
      print('Tiêu đề phim: ${movie.title}');

      if (movie.id == null || movie.id.toString().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Lỗi: ID phim không hợp lệ'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Hiển thị đang tải
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final success = await provider.deleteMovie(movie.id);

        if (mounted) {
          Navigator.pop(context); // Close loading

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Đã xóa phim thành công'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${provider.error ?? "Không thể xóa phim"}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
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
                  DropdownMenuItem(value: 'vi', child: Text('🇻🇳 Tiếng Việt')),
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

  void _showAddManualDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final posterUrlController = TextEditingController();
    final backdropUrlController = TextEditingController();
    final videoUrlController = TextEditingController();
    final durationController = TextEditingController();
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );
    final castController = TextEditingController();
    final directorController = TextEditingController();
    final countryController = TextEditingController();
    final ratingController = TextEditingController(text: '5.0');

    bool isUploadingPoster = false;
    bool isUploadingBackdrop = false;

    final List<String> selectedGenres = [];
    final List<String> availableGenres = [
      'Action',
      'Adventure',
      'Animation',
      'Comedy',
      'Crime',
      'Documentary',
      'Drama',
      'Family',
      'Fantasy',
      'History',
      'Horror',
      'Music',
      'Mystery',
      'Romance',
      'Science Fiction',
      'Thriller',
      'War',
      'Western',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm Phim Thủ Công'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên phim *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập tên phim'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập mô tả'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: posterUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Poster URL *',
                              hintText: 'https://... hoặc chọn file',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Vui lòng nhập URL hoặc chọn ảnh';
                              if (!value.startsWith('http'))
                                return 'URL không hợp lệ';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton.icon(
                            onPressed: isUploadingPoster
                                ? null
                                : () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.image,
                                          allowMultiple: false,
                                        );

                                    if (result != null &&
                                        result.files.first.bytes != null) {
                                      setState(() => isUploadingPoster = true);

                                      try {
                                        final file = result.files.first;
                                        final ref = FirebaseStorage.instance
                                            .ref()
                                            .child(
                                              'posters/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                                            );

                                        await ref.putData(
                                          file.bytes!,
                                          SettableMetadata(
                                            contentType:
                                                'image/${file.extension}',
                                          ),
                                        );

                                        final url = await ref.getDownloadURL();
                                        posterUrlController.text = url;

                                        setState(
                                          () => isUploadingPoster = false,
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✅ Upload poster thành công',
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      } catch (e) {
                                        setState(
                                          () => isUploadingPoster = false,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('❌ Lỗi upload: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: isUploadingPoster
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file, size: 18),
                            label: Text(
                              isUploadingPoster ? 'Uploading...' : 'Chọn ảnh',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: backdropUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Backdrop URL (tùy chọn)',
                              hintText: 'https://... hoặc chọn file',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton.icon(
                            onPressed: isUploadingBackdrop
                                ? null
                                : () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.image,
                                          allowMultiple: false,
                                        );

                                    if (result != null &&
                                        result.files.first.bytes != null) {
                                      setState(
                                        () => isUploadingBackdrop = true,
                                      );

                                      try {
                                        final file = result.files.first;
                                        final ref = FirebaseStorage.instance
                                            .ref()
                                            .child(
                                              'backdrops/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                                            );

                                        await ref.putData(
                                          file.bytes!,
                                          SettableMetadata(
                                            contentType:
                                                'image/${file.extension}',
                                          ),
                                        );

                                        final url = await ref.getDownloadURL();
                                        backdropUrlController.text = url;

                                        setState(
                                          () => isUploadingBackdrop = false,
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✅ Upload backdrop thành công',
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      } catch (e) {
                                        setState(
                                          () => isUploadingBackdrop = false,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('❌ Lỗi upload: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: isUploadingBackdrop
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file, size: 18),
                            label: Text(
                              isUploadingBackdrop ? 'Uploading...' : 'Chọn ảnh',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: videoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Video URL 🎬',
                        hintText: 'assets/videos/movie.mp4 hoặc https://...',
                        helperText:
                            '✅ Local: assets/videos/movie.mp4 (hoặc assets\\videos\\movie.mp4)\n'
                            '✅ Firebase: https://firebasestorage...\n'
                            '✅ Direct: https://example.com/video.mp4\n'
                            '💡 Backslash (\\) sẽ tự động chuyển thành /',
                        helperMaxLines: 5,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        // Auto-normalize backslashes to forward slashes
                        if (value.contains('\\')) {
                          final normalized = value.replaceAll('\\', '/');
                          videoUrlController.value = videoUrlController.value
                              .copyWith(
                                text: normalized,
                                selection: TextSelection.collapsed(
                                  offset: normalized.length,
                                ),
                              );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: yearController,
                            decoration: const InputDecoration(
                              labelText: 'Năm *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final year = int.tryParse(value ?? '');
                              return (year == null ||
                                      year < 1900 ||
                                      year > 2100)
                                  ? 'Năm không hợp lệ'
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: durationController,
                            decoration: const InputDecoration(
                              labelText: 'Thời lượng (phút) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final duration = int.tryParse(value ?? '');
                              return (duration == null || duration <= 0)
                                  ? 'Không hợp lệ'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Thể loại *', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: availableGenres.map((genre) {
                        final isSelected = selectedGenres.contains(genre);
                        return FilterChip(
                          label: Text(
                            genre,
                            style: const TextStyle(fontSize: 12),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedGenres.add(genre);
                              } else {
                                selectedGenres.remove(genre);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (selectedGenres.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Vui lòng chọn ít nhất 1 thể loại',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: directorController,
                      decoration: const InputDecoration(
                        labelText: 'Đạo diễn *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập đạo diễn'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: castController,
                      decoration: const InputDecoration(
                        labelText: 'Diễn viên *',
                        hintText: 'Ngăn cách bằng dấu phẩy',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập diễn viên'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: countryController,
                            decoration: const InputDecoration(
                              labelText: 'Quốc gia',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: ratingController,
                            decoration: const InputDecoration(
                              labelText: 'Rating (0-10)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final rating = double.tryParse(value ?? '');
                              return (rating == null ||
                                      rating < 0 ||
                                      rating > 10)
                                  ? 'Từ 0-10'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Lưu ý: Video và subtitle sẽ upload sau khi tạo phim.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Gỡ lỗi xác thực
                print('Biểu mẫu hợp lệ: ${formKey.currentState!.validate()}');
                print('Thể loại đã chọn: ${selectedGenres.isNotEmpty}');
                print('URL Áp phích: ${posterUrlController.text}');
                print('Thể loại đã chọn: $selectedGenres');

                if (formKey.currentState!.validate() &&
                    selectedGenres.isNotEmpty) {
                  Navigator.pop(context);
                  await _addManualMovie(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    posterUrl: posterUrlController.text.trim(),
                    backdropUrl: backdropUrlController.text.trim().isEmpty
                        ? null
                        : backdropUrlController.text.trim(),
                    videoUrl: videoUrlController.text.trim().isEmpty
                        ? null
                        : videoUrlController.text.trim(),
                    year: int.parse(yearController.text),
                    duration: int.parse(durationController.text),
                    genres: selectedGenres,
                    director: directorController.text.trim(),
                    cast: castController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(),
                    country: countryController.text.trim().isEmpty
                        ? null
                        : countryController.text.trim(),
                    rating: double.parse(ratingController.text),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedGenres.isEmpty
                            ? 'Vui lòng chọn ít nhất 1 thể loại'
                            : 'Vui lòng điền đầy đủ thông tin bắt buộc (*)',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Thêm Phim'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addManualMovie({
    required String title,
    required String description,
    required String posterUrl,
    String? backdropUrl,
    String? videoUrl,
    required int year,
    required int duration,
    required List<String> genres,
    required String director,
    required List<String> cast,
    String? country,
    required double rating,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Đang lưu phim...')),
          ],
        ),
      ),
    );

    try {
      // Kiểm tra xác thực
      final currentUser = FirebaseAuth.instance.currentUser;
      print('=== Bắt đầu tạo phim thủ công ===');
      print('Người dùng hiện tại: ${currentUser?.uid}');
      print('Email người dùng: ${currentUser?.email}');
      print('Mã xác thực: ${await currentUser?.getIdToken()}');
      print('Tiêu đề: $title');
      print('URL Áp phích: $posterUrl');
      print('Thể loại: $genres');

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final docRef = FirebaseFirestore.instance.collection('movies').doc();
      print('ID tài liệu đã tạo: ${docRef.id}');

      final movie = {
        'id': docRef.id,
        'title': title,
        'description': description,
        'posterUrl': posterUrl,
        'backdropUrl': backdropUrl,
        'trailerUrl': null,
        'videoUrl': videoUrl,
        'duration': duration,
        'genres': genres,
        'languages': <String>[],
        'rating': rating,
        'year': year,
        'cast': cast,
        'director': director,
        'country': country,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'subtitles': null,
      };

      print('Dữ liệu phim đã chuẩn bị, đang lưu vào Firestore...');
      await docRef.set(movie);
      print('Phim đã lưu thành công!');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã thêm phim: $title'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _loadMovies();
      }
    } catch (e, stackTrace) {
      print('=== LỖI khi tạo phim ===');
      print('Lỗi: $e');
      print('Theo dõi ngăn xếp: $stackTrace');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi thêm phim: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
      print('Bắt đầu nhập cho TMDB ID: $tmdbId');
      final repository = MovieImportRepository();
      final movie = await repository.importMovieFromTMDB(tmdbId);

      print('Nhập hoàn tất: ${movie.title}');

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
      print('Lỗi nhập: $e');
      print('Theo dõi ngăn xếp: $stackTrace');

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

  // ⛔ COMMENTED OUT - Using local assets instead of Firebase upload
  // void _showUploadVideoDialog(dynamic movie) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Tải Lên Video'),
  //       content: const Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'Chọn file video để tải lên Firebase Storage.\n\n'
  //             'Giới hạn: 100MB (cắt video ngắn hơn nếu quá lớn)',
  //             style: TextStyle(fontSize: 13),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Hủy'),
  //         ),
  //         ElevatedButton.icon(
  //           onPressed: () => _pickAndUploadVideo(movie),
  //           icon: const Icon(Icons.upload_file),
  //           label: const Text('Chọn Video'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showUploadSubtitleDialog(dynamic movie) {
    String selectedLanguage = 'en';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Tải Phụ Đề Cho "${movie.title}"'),
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
                  DropdownMenuItem(value: 'en', child: Text('Tiếng Anh')),
                  DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
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

  // ⛔ COMMENTED OUT - Using local assets instead of Firebase upload
  // Future<void> _pickAndUploadVideo(dynamic movie) async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['mp4', 'mkv', 'avi', 'mov'],
  //       withData: true,
  //     );
  //
  //     if (result == null || result.files.isEmpty) return;
  //
  //     final file = result.files.first;
  //     if (file.bytes == null) {
  //       throw Exception('Không thể đọc file');
  //     }
  //
  //     // Check file size (100MB limit)
  //     const maxSize = 100 * 1024 * 1024; // 100MB
  //     if (file.size > maxSize) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text(
  //               'File quá lớn! Giới hạn 100MB. Hãy cắt video ngắn hơn.',
  //             ),
  //             backgroundColor: Colors.red,
  //             duration: Duration(seconds: 1),
  //           ),
  //         );
  //       }
  //       return;
  //     }
  //
  //     if (mounted) Navigator.pop(context); // Close dialog
  //
  //     // Show upload progress
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => AlertDialog(
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const CircularProgressIndicator(),
  //             const SizedBox(height: 16),
  //             Text('Đang upload ${file.name}...'),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'Có thể mất vài phút',
  //               style: TextStyle(fontSize: 12, color: Colors.grey),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //
  //     // Upload to Firebase Storage
  //     final storageRef = FirebaseStorage.instance.ref().child(
  //       'videos/${movie.id}/${file.name}',
  //     );
  //
  //     final uploadTask = storageRef.putData(
  //       file.bytes!,
  //       SettableMetadata(contentType: 'video/${file.extension}'),
  //     );
  //
  //     final snapshot = await uploadTask;
  //     final downloadUrl = await snapshot.ref.getDownloadURL();
  //
  //     // Update Firestore
  //     await FirebaseFirestore.instance
  //         .collection('movies')
  //         .doc(movie.id)
  //         .update({'videoUrl': downloadUrl});
  //
  //     if (mounted) {
  //       Navigator.pop(context); // Close progress dialog
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('✅ Tải lên video thành công: ${file.name}'),
  //           backgroundColor: Colors.green,
  //           duration: const Duration(seconds: 1),
  //         ),
  //       );
  //       _loadMovies();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       Navigator.pop(context); // Close progress dialog
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('❌ Lỗi tải lên video: $e'),
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 1),
  //         ),
  //       );
  //     }
  //   }
  // }

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

      // Hiển thị tiến trình tải lên
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

      // Tải lên Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'subtitles/${movie.id}/$language.srt',
      );

      final uploadTask = storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: 'text/plain'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Cập nhật Firestore - gộp bản đồ phụ đề
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
            content: Text('✅ Tải lên phụ đề ($language) thành công!'),
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
            content: Text('❌ Lỗi tải lên phụ đề: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // === EDIT MOVIE ===

  void _showEditMovieDialog(Movie movie) {
    // LƯU ROOT CONTEXT trước khi hiển thị dialog
    final rootContext = context;

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: movie.title);
    final descriptionController = TextEditingController(
      text: movie.description,
    );
    final posterUrlController = TextEditingController(
      text: movie.posterUrl ?? '',
    );
    final backdropUrlController = TextEditingController(
      text: movie.backdropUrl ?? '',
    );
    final videoUrlController = TextEditingController(
      text: movie.videoUrl ?? '',
    );
    final yearController = TextEditingController(text: movie.year.toString());
    final durationController = TextEditingController(
      text: movie.duration.toString(),
    );
    final directorController = TextEditingController(
      text: movie.director ?? '',
    );
    final castController = TextEditingController(
      text: movie.cast?.join(', ') ?? '',
    );
    final countryController = TextEditingController(text: movie.country ?? '');
    final ratingController = TextEditingController(
      text: movie.rating.toString(),
    );

    bool isUploadingPoster = false;
    bool isUploadingBackdrop = false;

    Set<String> selectedGenres = Set<String>.from(movie.genres ?? []);

    final availableGenres = [
      'Action',
      'Adventure',
      'Animation',
      'Comedy',
      'Crime',
      'Documentary',
      'Drama',
      'Family',
      'Fantasy',
      'History',
      'Horror',
      'Music',
      'Mystery',
      'Romance',
      'Science Fiction',
      'Thriller',
      'War',
      'Western',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chỉnh Sửa Phim'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên phim *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập tên phim'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập mô tả'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: posterUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Poster URL *',
                              hintText: 'https://... hoặc chọn file',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Vui lòng nhập URL hoặc chọn ảnh';
                              if (!value.startsWith('http'))
                                return 'URL không hợp lệ';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton.icon(
                            onPressed: isUploadingPoster
                                ? null
                                : () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.image,
                                          allowMultiple: false,
                                        );

                                    if (result != null &&
                                        result.files.first.bytes != null) {
                                      setState(() => isUploadingPoster = true);

                                      try {
                                        final file = result.files.first;
                                        final ref = FirebaseStorage.instance
                                            .ref()
                                            .child(
                                              'posters/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                                            );

                                        await ref.putData(file.bytes!);
                                        final url = await ref.getDownloadURL();

                                        setState(() {
                                          posterUrlController.text = url;
                                          isUploadingPoster = false;
                                        });
                                      } catch (e) {
                                        setState(
                                          () => isUploadingPoster = false,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Lỗi upload: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                            icon: isUploadingPoster
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file, size: 16),
                            label: const Text('Chọn'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: backdropUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Backdrop URL',
                              hintText: 'https://... hoặc chọn file',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !value.startsWith('http')) {
                                return 'URL không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton.icon(
                            onPressed: isUploadingBackdrop
                                ? null
                                : () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.image,
                                          allowMultiple: false,
                                        );

                                    if (result != null &&
                                        result.files.first.bytes != null) {
                                      setState(
                                        () => isUploadingBackdrop = true,
                                      );

                                      try {
                                        final file = result.files.first;
                                        final ref = FirebaseStorage.instance
                                            .ref()
                                            .child(
                                              'backdrops/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
                                            );

                                        await ref.putData(file.bytes!);
                                        final url = await ref.getDownloadURL();

                                        setState(() {
                                          backdropUrlController.text = url;
                                          isUploadingBackdrop = false;
                                        });
                                      } catch (e) {
                                        setState(
                                          () => isUploadingBackdrop = false,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Lỗi upload: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                            icon: isUploadingBackdrop
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file, size: 16),
                            label: const Text('Chọn'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: videoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Video URL',
                        hintText: 'assets/videos/movie.mp4 hoặc https://...',
                        helperText:
                            'Hỗ trợ: assets/, gs://, http://, https://\nBackslash (\\) tự động chuyển thành /',
                        helperMaxLines: 2,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        // Auto-normalize backslashes to forward slashes
                        if (value.contains('\\')) {
                          final normalized = value.replaceAll('\\', '/');
                          videoUrlController.value = videoUrlController.value
                              .copyWith(
                                text: normalized,
                                selection: TextSelection.collapsed(
                                  offset: normalized.length,
                                ),
                              );
                        }
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Chuẩn hóa để xác thực
                          final normalized = value.replaceAll('\\', '/');
                          if (!normalized.startsWith('gs://') &&
                              !normalized.startsWith('http') &&
                              !normalized.startsWith('assets/')) {
                            return 'URL phải bắt đầu với: assets/, gs://, http://, hoặc https://';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: yearController,
                            decoration: const InputDecoration(
                              labelText: 'Năm phát hành *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final year = int.tryParse(value ?? '');
                              return (year == null ||
                                      year < 1900 ||
                                      year > 2100)
                                  ? 'Năm không hợp lệ'
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: durationController,
                            decoration: const InputDecoration(
                              labelText: 'Thời lượng (phút) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final duration = int.tryParse(value ?? '');
                              return (duration == null || duration <= 0)
                                  ? 'Thời lượng không hợp lệ'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thể loại *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableGenres.map((genre) {
                        final isSelected = selectedGenres.contains(genre);
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedGenres.add(genre);
                              } else {
                                selectedGenres.remove(genre);
                              }
                            });
                          },
                          selectedColor: Colors.blue.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                    if (selectedGenres.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Vui lòng chọn ít nhất 1 thể loại',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: directorController,
                      decoration: const InputDecoration(
                        labelText: 'Đạo diễn *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập đạo diễn'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: castController,
                      decoration: const InputDecoration(
                        labelText: 'Diễn viên *',
                        hintText: 'Ngăn cách bằng dấu phẩy',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập diễn viên'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: countryController,
                            decoration: const InputDecoration(
                              labelText: 'Quốc gia',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: ratingController,
                            decoration: const InputDecoration(
                              labelText: 'Rating (0-10)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final rating = double.tryParse(value ?? '');
                              return (rating == null ||
                                      rating < 0 ||
                                      rating > 10)
                                  ? 'Từ 0-10'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    selectedGenres.isNotEmpty) {
                  // LẤY PROVIDER TRƯỚC KHI ĐÓNG DIALOG
                  final provider = Provider.of<AdminMovieProvider>(
                    context,
                    listen: false,
                  );

                  // Đóng edit dialog
                  Navigator.pop(context);

                  // Hiển thị dialog tiến trình
                  BuildContext? progressDialogContext;
                  showDialog(
                    context: rootContext,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      progressDialogContext = dialogContext;
                      return const AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Expanded(child: Text('Đang cập nhật phim...')),
                          ],
                        ),
                      );
                    },
                  );

                  try {
                    // Gỡ lỗi ID phim
                    print('Chỉnh sửa - ID phim: ${movie.id}');
                    print('Chỉnh sửa - Tiêu đề phim: ${movie.title}');

                    if (movie.id == null || movie.id.isEmpty) {
                      throw Exception('ID phim không hợp lệ');
                    }

                    print('Đang phân tích các giá trị đầu vào...');
                    final duration = int.parse(durationController.text);
                    final rating = double.parse(ratingController.text);
                    final year = int.parse(yearController.text);
                    print(
                      'Parsed: duration=$duration, rating=$rating, year=$year',
                    );

                    // Buộc làm mới mã thông báo
                    print('Đang lấy người dùng hiện tại...');
                    final currentUser = FirebaseAuth.instance.currentUser;
                    print('Người dùng hiện tại: ${currentUser?.uid}');
                    if (currentUser != null) {
                      print('Refreshing token...');
                      await currentUser.getIdToken(true);
                      print('Token refreshed');
                    }

                    print('Đang tạo đối tượng phim đã cập nhật...');
                    final updatedMovie = Movie(
                      id: movie.id,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      posterUrl: posterUrlController.text.trim(),
                      backdropUrl: backdropUrlController.text.trim().isEmpty
                          ? null
                          : backdropUrlController.text.trim(),
                      trailerUrl: movie.trailerUrl,
                      videoUrl: videoUrlController.text.trim().isEmpty
                          ? null
                          : videoUrlController.text.trim(),
                      duration: duration,
                      genres: selectedGenres.toList(),
                      languages: movie.languages,
                      rating: rating,
                      year: year,
                      cast: castController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      director: directorController.text.trim(),
                      country: countryController.text.trim().isEmpty
                          ? null
                          : countryController.text.trim(),
                      createdAt: movie.createdAt,
                      updatedAt: DateTime.now(),
                      subtitles: movie.subtitles,
                    );
                    print('Đối tượng phim đã được tạo thành công');

                    final success = await provider.updateMovie(updatedMovie);

                    // Đóng progress dialog
                    if (progressDialogContext != null &&
                        progressDialogContext!.mounted) {
                      Navigator.of(progressDialogContext!).pop();
                    }

                    // Hiển thị kết quả
                    if (rootContext.mounted) {
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '✅ Cập nhật phim thành công!'
                                : '❌ Không thể cập nhật phim',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    // Đóng progress dialog
                    if (progressDialogContext != null &&
                        progressDialogContext!.mounted) {
                      Navigator.of(progressDialogContext!).pop();
                    }

                    // Hiển thị lỗi
                    if (rootContext.mounted) {
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(
                          content: Text('❌ Lỗi: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedGenres.isEmpty
                            ? 'Vui lòng chọn ít nhất 1 thể loại'
                            : 'Vui lòng điền đầy đủ thông tin bắt buộc (*)',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Cập Nhật'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
