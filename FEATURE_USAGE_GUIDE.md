# HƯỚNG DẪN SỬ DỤNG CÁC CHỨC NĂNG MỚI

## 📋 Overview

Các chức năng backend đã implement:

1. ✅ **Watchlist** - Thêm/xóa phim yêu thích
2. ✅ **Watch History** - Lưu tiến độ xem, continue watching
3. ✅ **Ratings** - Đánh giá phim 1-5 sao

## 🎯 Cách tích hợp vào UI

### 1. WATCHLIST BUTTON

Thêm nút "Add to Watchlist" vào movie cards:

```dart
// Import providers
import 'package:provider/provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/auth_provider.dart';

// Trong movie card widget
IconButton(
  icon: Icon(
    isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
    color: Colors.white,
  ),
  onPressed: () async {
    final authProvider = context.read<AuthProvider>();
    final watchlistProvider = context.read<WatchlistProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    final success = await watchlistProvider.toggleWatchlist(
      userId: authProvider.user!.id,
      movieId: movie.id,
      movieTitle: movie.title,
      moviePosterUrl: movie.posterUrl,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isInWatchlist
              ? 'Đã xóa khỏi danh sách'
              : 'Đã thêm vào danh sách',
          ),
        ),
      );
    }
  },
)
```

**Check xem phim có trong watchlist không:**

```dart
// Sử dụng StreamBuilder
StreamBuilder<bool>(
  stream: context.read<WatchlistProvider>()
    .watchUserWatchlist(userId)
    .map((list) => list.any((item) => item.movieId == movie.id)),
  builder: (context, snapshot) {
    final isInWatchlist = snapshot.data ?? false;
    return Icon(
      isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
    );
  },
)
```

---

### 2. CONTINUE WATCHING SECTION

Thêm section "Continue Watching" ở Home Screen:

```dart
import '../../providers/watch_history_provider.dart';

// Trong Home Screen
StreamBuilder<List<WatchHistory>>(
  stream: context.read<WatchHistoryProvider>()
    .watchContinueWatching(userId),
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return SizedBox.shrink();
    }

    final continueWatching = snapshot.data!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Watching',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: continueWatching.length,
            itemBuilder: (context, index) {
              final item = continueWatching[index];
              return _buildContinueWatchingCard(item);
            },
          ),
        ),
      ],
    );
  },
)
```

**Card với progress bar:**

```dart
Widget _buildContinueWatchingCard(WatchHistory item) {
  return Container(
    width: 300,
    margin: EdgeInsets.only(right: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Movie poster
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              Image.network(
                item.moviePosterUrl ?? '',
                fit: BoxFit.cover,
              ),
              // Progress bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: item.progressPercentage / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          item.movieTitle,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${item.progressPercentage.toStringAsFixed(0)}% watched',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  );
}
```

---

### 3. LƯU WATCH PROGRESS

Trong Video Player, lưu progress định kỳ:

```dart
import '../../providers/watch_history_provider.dart';

// Trong VideoPlayerScreen
Timer? _progressTimer;

@override
void initState() {
  super.initState();
  // Save progress every 10 seconds
  _progressTimer = Timer.periodic(Duration(seconds: 10), (_) {
    _saveProgress();
  });
}

Future<void> _saveProgress() async {
  final authProvider = context.read<AuthProvider>();
  final historyProvider = context.read<WatchHistoryProvider>();

  if (authProvider.user == null) return;

  final position = _controller.value.position.inSeconds;
  final duration = _controller.value.duration.inSeconds;

  await historyProvider.saveWatchProgress(
    userId: authProvider.user!.id,
    movieId: widget.movieId,
    movieTitle: widget.movieTitle,
    moviePosterUrl: widget.moviePosterUrl,
    progressSeconds: position,
    totalDurationSeconds: duration,
  );
}

@override
void dispose() {
  _progressTimer?.cancel();
  _saveProgress(); // Save final progress
  super.dispose();
}
```

**Resume từ vị trí đã xem:**

```dart
// Khi mở video player
Future<void> _loadLastPosition() async {
  final authProvider = context.read<AuthProvider>();
  final historyProvider = context.read<WatchHistoryProvider>();

  if (authProvider.user == null) return;

  final history = await historyProvider.getMovieProgress(
    userId: authProvider.user!.id,
    movieId: widget.movieId,
  );

  if (history != null && history.canContinueWatching) {
    // Show dialog to resume
    final resume = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tiếp tục xem?'),
        content: Text(
          'Bạn đã xem ${history.progressPercentage.toStringAsFixed(0)}% phim này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Xem từ đầu'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Tiếp tục'),
          ),
        ],
      ),
    );

    if (resume == true) {
      _controller.seekTo(Duration(seconds: history.progressSeconds));
    }
  }
}
```

---

### 4. RATING SYSTEM

Thêm rating widget trong MovieDetailScreen:

```dart
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../providers/movie_rating_provider.dart';

// Trong MovieDetailScreen
StreamBuilder<MovieRating?>(
  stream: context.read<MovieRatingProvider>().watchUserRating(
    userId: authProvider.user!.id,
    movieId: movie.id,
  ),
  builder: (context, snapshot) {
    final userRating = snapshot.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Đánh giá của bạn:', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        RatingBar.builder(
          initialRating: userRating?.rating ?? 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) async {
            final success = await context.read<MovieRatingProvider>().rateMovie(
              userId: authProvider.user!.id,
              movieId: movie.id,
              rating: rating,
            );

            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã lưu đánh giá')),
              );
            }
          },
        ),
      ],
    );
  },
)
```

**Hiển thị average rating:**

```dart
// Load stats
@override
void initState() {
  super.initState();
  context.read<MovieRatingProvider>().loadMovieStats(widget.movieId);
}

// Display
Consumer<MovieRatingProvider>(
  builder: (context, provider, child) {
    final stats = provider.movieStats;

    if (stats == null) {
      return CircularProgressIndicator();
    }

    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 24),
        SizedBox(width: 8),
        Text(
          stats.averageRating.toStringAsFixed(1),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          ' / 5',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(width: 16),
        Text(
          '(${stats.totalRatings} đánh giá)',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  },
)
```

**Rating distribution bars:**

```dart
Widget _buildRatingDistribution(MovieRatingStats stats) {
  return Column(
    children: [
      for (int stars = 5; stars >= 1; stars--)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text('$stars ⭐'),
              SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: stats.getPercentage(stars) / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation(Colors.amber),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${stats.getPercentage(stars).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
    ],
  );
}
```

---

### 5. WATCHLIST PAGE

Tạo màn hình hiển thị danh sách phim yêu thích:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/entities/watchlist_item.dart';

class WatchlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Watchlist'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearWatchlist(context, userId),
          ),
        ],
      ),
      body: StreamBuilder<List<WatchlistItem>>(
        stream: context.read<WatchlistProvider>().watchUserWatchlist(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Watchlist trống',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final watchlist = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              return _buildWatchlistCard(context, watchlist[index], userId);
            },
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    return 2;
  }

  Widget _buildWatchlistCard(BuildContext context, WatchlistItem item, String userId) {
    return Stack(
      children: [
        // Movie card
        GestureDetector(
          onTap: () {
            // Navigate to movie detail
            context.go('/movies/${item.movieId}');
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.moviePosterUrl ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
            onPressed: () async {
              final success = await context.read<WatchlistProvider>()
                .removeFromWatchlist(userId: userId, movieId: item.movieId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa khỏi watchlist')),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClearWatchlist(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa toàn bộ watchlist?'),
        content: Text('Hành động này không thể hoàn tác'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<WatchlistProvider>()
        .clearWatchlist(userId);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa toàn bộ watchlist')),
        );
      }
    }
  }
}
```

---

## 📦 Dependencies cần thêm

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter_rating_bar: ^4.0.1 # For star rating widget
```

Chạy:

```bash
flutter pub get
```

---

## 🔥 Firebase Setup

Collections đã tạo trong Firestore:

- `watchlist` - Danh sách phim yêu thích
- `watch_history` - Lịch sử xem với progress
- `movie_ratings` - Đánh giá phim

Security rules đã deploy, data tự động sync real-time!

---

## 🎬 Next Steps

1. Tích hợp các widget trên vào UI hiện tại
2. Test với dữ liệu thật
3. Thêm animations cho better UX
4. Implement Recommendation System (similar movies, trending)
5. Build Admin Panel để quản lý movies

Bạn muốn tôi implement UI cho chức năng nào trước?
