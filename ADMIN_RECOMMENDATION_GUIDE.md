# Hướng Dẫn Sử Dụng Recommendation System và Admin Panel

Tài liệu này hướng dẫn cách sử dụng **Recommendation System** và **Admin Panel** trong ứng dụng.

---

## 🎯 Recommendation System

### 1. Load Recommendations trong HomePage

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final authProvider = context.read<AuthProvider>();
    final recommendationProvider = context.read<RecommendationProvider>();

    if (authProvider.user != null) {
      // Load all categories
      await recommendationProvider.loadAllRecommendations(
        userId: authProvider.user!.id,
        limit: 10,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trang Chủ')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTrendingSection(),
            _buildPersonalizedSection(),
            _buildPopularSection(),
            _buildNewReleasesSection(),
            _buildTopRatedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Consumer<RecommendationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTrending) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.trendingMovies.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '🔥 Trending Hôm Nay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.trendingMovies.length,
                itemBuilder: (context, index) {
                  final movie = provider.trendingMovies[index];
                  return _buildMovieCard(movie);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalizedSection() {
    return Consumer<RecommendationProvider>(
      builder: (context, provider, child) {
        if (provider.personalizedMovies.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '✨ Gợi Ý Cho Bạn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.personalizedMovies.length,
                itemBuilder: (context, index) {
                  final movie = provider.personalizedMovies[index];
                  return _buildMovieCard(movie);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        // Navigate to movie detail
        Navigator.pushNamed(context, '/movie-detail', arguments: movie.id);
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie.posterPath,
                height: 160,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    width: 120,
                    color: Colors.grey,
                    child: Icon(Icons.movie),
                  );
                },
              ),
            ),
            SizedBox(height: 4),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Similar Movies trong Movie Detail Page

```dart
class MovieDetailPage extends StatefulWidget {
  final String movieId;

  const MovieDetailPage({required this.movieId});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? _movie;

  @override
  void initState() {
    super.initState();
    _loadMovieAndRecommendations();
  }

  Future<void> _loadMovieAndRecommendations() async {
    final movieProvider = context.read<MovieProvider>();
    _movie = await movieProvider.getMovieById(widget.movieId);

    if (_movie != null) {
      final recommendationProvider = context.read<RecommendationProvider>();
      await recommendationProvider.loadSimilarMovies(
        movieId: _movie!.id,
        genres: _movie!.genres,
        limit: 10,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_movie == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_movie!.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Movie details...
            _buildMovieInfo(),

            // Similar movies section
            _buildSimilarMoviesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarMoviesSection() {
    return Consumer<RecommendationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSimilar) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.similarMovies.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Phim Tương Tự',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.similarMovies.length,
                itemBuilder: (context, index) {
                  final movie = provider.similarMovies[index];
                  return _buildMovieCard(movie);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

---

## 🔐 Admin Panel

### 1. Check Admin Role

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        // Check if user is logged in and is admin
        if (user == null || !user.isAdmin) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Bạn không có quyền truy cập',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Quay lại'),
                  ),
                ],
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
```

### 2. Admin Dashboard

```dart
class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final movieProvider = context.read<AdminMovieProvider>();
    final userProvider = context.read<AdminUserProvider>();

    await Future.wait([
      movieProvider.loadStatistics(),
      userProvider.loadStatistics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(title: Text('Admin Dashboard')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMovieStatistics(),
              SizedBox(height: 16),
              _buildUserStatistics(),
              SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieStatistics() {
    return Consumer<AdminMovieProvider>(
      builder: (context, provider, child) {
        if (provider.statistics == null) {
          return Center(child: CircularProgressIndicator());
        }

        final stats = provider.statistics!;
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Thống Kê Phim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                _buildStatRow('Tổng số phim', stats['totalMovies'].toString()),
                _buildStatRow('Tổng lượt xem', stats['totalViews'].toString()),
                _buildStatRow(
                  'Điểm trung bình',
                  stats['averageRating'].toStringAsFixed(1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserStatistics() {
    return Consumer<AdminUserProvider>(
      builder: (context, provider, child) {
        if (provider.statistics == null) {
          return Center(child: CircularProgressIndicator());
        }

        final stats = provider.statistics!;
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👥 Thống Kê Người Dùng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                _buildStatRow('Tổng người dùng', stats['totalUsers'].toString()),
                _buildStatRow('Admin', stats['adminCount'].toString()),
                _buildStatRow('Người dùng bị cấm', stats['bannedCount'].toString()),
                _buildStatRow('Hoạt động 30 ngày', stats['activeUsers'].toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/admin/movies'),
          icon: Icon(Icons.movie),
          label: Text('Quản Lý Phim'),
        ),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/admin/users'),
          icon: Icon(Icons.people),
          label: Text('Quản Lý Người Dùng'),
        ),
      ],
    );
  }
}
```

### 3. Movie Management Page

```dart
class AdminMovieManagementPage extends StatefulWidget {
  @override
  _AdminMovieManagementPageState createState() => _AdminMovieManagementPageState();
}

class _AdminMovieManagementPageState extends State<AdminMovieManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminMovieProvider>().loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quản Lý Phim'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showCreateMovieDialog(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm phim...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<AdminMovieProvider>().loadMovies();
                  } else {
                    context.read<AdminMovieProvider>().searchMovies(value);
                  }
                },
              ),
            ),

            // Movies list
            Expanded(
              child: Consumer<AdminMovieProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Text(
                        provider.error!,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (provider.movies.isEmpty) {
                    return Center(child: Text('Không có phim nào'));
                  }

                  return ListView.builder(
                    itemCount: provider.movies.length,
                    itemBuilder: (context, index) {
                      final movie = provider.movies[index];
                      return _buildMovieListItem(movie);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieListItem(Movie movie) {
    return ListTile(
      leading: Image.network(
        movie.posterPath,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.movie);
        },
      ),
      title: Text(movie.title),
      subtitle: Text('${movie.releaseDate} • ${movie.genres.join(', ')}'),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text('Chỉnh sửa'),
            onTap: () => _showEditMovieDialog(movie),
          ),
          PopupMenuItem(
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmDeleteMovie(movie),
          ),
        ],
      ),
    );
  }

  void _showCreateMovieDialog() {
    // Show dialog to create movie
    // Implementation depends on your UI design
  }

  void _showEditMovieDialog(Movie movie) {
    // Show dialog to edit movie
  }

  Future<void> _confirmDeleteMovie(Movie movie) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa phim "${movie.title}"?'),
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

    if (confirm == true) {
      final provider = context.read<AdminMovieProvider>();
      final success = await provider.deleteMovie(movie.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa phim thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${provider.error}')),
        );
      }
    }
  }
}
```

### 4. User Management Page

```dart
class AdminUserManagementPage extends StatefulWidget {
  @override
  _AdminUserManagementPageState createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminUserProvider>().loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(title: Text('Quản Lý Người Dùng')),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo username hoặc email...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<AdminUserProvider>().loadUsers();
                  } else {
                    context.read<AdminUserProvider>().searchUsers(value);
                  }
                },
              ),
            ),

            // Users list
            Expanded(
              child: Consumer<AdminUserProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.users.isEmpty) {
                    return Center(child: Text('Không có người dùng nào'));
                  }

                  return ListView.builder(
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return _buildUserListItem(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null ? Icon(Icons.person) : null,
      ),
      title: Text(user.username),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          Row(
            children: [
              if (user.isAdmin)
                Chip(label: Text('Admin'), backgroundColor: Colors.orange),
              if (user.isBanned)
                Chip(label: Text('Banned'), backgroundColor: Colors.red),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          if (!user.isBanned)
            PopupMenuItem(
              child: Text('Cấm', style: TextStyle(color: Colors.red)),
              onTap: () => _banUser(user.id),
            ),
          if (user.isBanned)
            PopupMenuItem(
              child: Text('Bỏ cấm'),
              onTap: () => _unbanUser(user.id),
            ),
          if (!user.isAdmin)
            PopupMenuItem(
              child: Text('Thăng cấp Admin'),
              onTap: () => _promoteToAdmin(user.id),
            ),
          if (user.isAdmin)
            PopupMenuItem(
              child: Text('Hạ cấp Admin'),
              onTap: () => _demoteFromAdmin(user.id),
            ),
        ],
      ),
    );
  }

  Future<void> _banUser(String userId) async {
    final provider = context.read<AdminUserProvider>();
    await provider.banUser(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã cấm người dùng')),
    );
  }

  Future<void> _unbanUser(String userId) async {
    final provider = context.read<AdminUserProvider>();
    await provider.unbanUser(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã bỏ cấm người dùng')),
    );
  }

  Future<void> _promoteToAdmin(String userId) async {
    final provider = context.read<AdminUserProvider>();
    await provider.promoteToAdmin(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thăng cấp thành Admin')),
    );
  }

  Future<void> _demoteFromAdmin(String userId) async {
    final provider = context.read<AdminUserProvider>();
    await provider.demoteFromAdmin(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã hạ cấp Admin')),
    );
  }
}
```

---

## 🔒 Security Notes

1. **isAdmin Check**: Firestore rules check `isAdmin` field từ user document
2. **Ban Users**: Banned users nên bị chặn ở AuthProvider (check `isBanned` sau khi login)
3. **Admin Routes**: Wrap admin pages với `AdminGuard` widget
4. **Firestore Rules**: Đã deploy rules cho phép admin CRUD movies và users

---

## 📝 Lưu Ý Quan Trọng

1. **Set Admin Manually**: Lần đầu cần set `isAdmin = true` trong Firestore Console cho user đầu tiên
2. **Testing**: Test admin features với user có `isAdmin = true`
3. **Banned Check**: Implement logic check `isBanned` trong `AuthProvider.signIn()`

---

## 🚀 Next Steps

1. Implement UI screens theo mẫu trên
2. Add file upload cho movie posters (Firebase Storage)
3. Add CSV import cho bulk movies
4. Tạo admin navigation menu
5. Add logging cho admin actions
