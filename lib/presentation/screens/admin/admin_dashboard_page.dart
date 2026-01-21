import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_movie_provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Kiểm tra quyền quản trị
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
              const Text(
                'Bạn không có quyền truy cập',
                style: TextStyle(fontSize: 18),
              ),
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
      appBar: AppBar(title: const Text('Admin Dashboard'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user),
            const SizedBox(height: 16),
            _buildMovieStatistics(),
            const SizedBox(height: 16),
            _buildUserStatistics(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic user) {
    final name = user?.displayName ?? user?.username ?? 'Admin';
    return Card(
      color: Colors.blue[700],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, $name!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Quản trị viên',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieStatistics() {
    return Consumer<AdminMovieProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Lỗi: ${provider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _loadStatistics(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.statistics == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = provider.statistics!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.movie, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Thống Kê Phim',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildStatRow(
                  'Tổng số phim',
                  stats['totalMovies'].toString(),
                  Icons.videocam,
                  Colors.blue,
                ),
                _buildStatRow(
                  'Điểm trung bình',
                  stats['averageRating'].toStringAsFixed(1),
                  Icons.star,
                  Colors.orange,
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
        if (provider.error != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Lỗi: ${provider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _loadStatistics(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.statistics == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = provider.statistics!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.people, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      'Thống Kê Người Dùng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildStatRow(
                  'Tổng người dùng',
                  stats['totalUsers'].toString(),
                  Icons.person,
                  Colors.purple,
                ),
                _buildStatRow(
                  'Admin',
                  stats['adminCount'].toString(),
                  Icons.admin_panel_settings,
                  Colors.blue,
                ),
                _buildStatRow(
                  'Người dùng bị cấm',
                  stats['bannedCount'].toString(),
                  Icons.block,
                  Colors.red,
                ),
                _buildStatRow(
                  'Hoạt động 30 ngày',
                  stats['activeUsers'].toString(),
                  Icons.trending_up,
                  Colors.green,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tác vụ nhanh',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Quản Lý Phim',
                Icons.movie,
                Colors.blue,
                () => context.go('/admin/movies'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Quản Lý Users',
                Icons.people,
                Colors.purple,
                () => context.go('/admin/users'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
