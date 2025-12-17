import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../providers/auth_provider.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    await context.read<AdminUserProvider>().loadUsers();
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
      appBar: AppBar(title: const Text('Quản Lý Người Dùng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo username hoặc email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadUsers();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  _loadUsers();
                } else {
                  context.read<AdminUserProvider>().searchUsers(value);
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<AdminUserProvider>(
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
                          onPressed: _loadUsers,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.users.isEmpty) {
                  return const Center(child: Text('Không có người dùng nào'));
                }

                return ListView.builder(
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final targetUser = provider.users[index];
                    final isCurrentUser =
                        user != null && targetUser.id == user.id;
                    return _buildUserListItem(
                      targetUser,
                      provider,
                      isCurrentUser,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(
    dynamic targetUser,
    AdminUserProvider provider,
    bool isCurrentUser,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: targetUser.photoUrl != null
              ? NetworkImage(targetUser.photoUrl!)
              : null,
          child: targetUser.photoUrl == null
              ? Text(targetUser.username[0].toUpperCase())
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                targetUser.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (targetUser.isAdmin)
              const Chip(
                label: Text('Admin', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 4),
              ),
            if (targetUser.isBanned)
              const Chip(
                label: Text('Banned', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 4),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(targetUser.email),
            const SizedBox(height: 4),
            Text(
              'Tham gia: ${_formatDate(targetUser.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: isCurrentUser
            ? const Chip(
                label: Text('Bạn', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.blue,
              )
            : PopupMenuButton(
                itemBuilder: (context) => [
                  if (!targetUser.isBanned)
                    const PopupMenuItem(
                      value: 'ban',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cấm', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  if (targetUser.isBanned)
                    const PopupMenuItem(
                      value: 'unban',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Bỏ cấm'),
                        ],
                      ),
                    ),
                  if (!targetUser.isAdmin)
                    const PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Thăng cấp Admin'),
                        ],
                      ),
                    ),
                  if (targetUser.isAdmin)
                    const PopupMenuItem(
                      value: 'demote',
                      child: Row(
                        children: [
                          Icon(Icons.remove_moderator),
                          SizedBox(width: 8),
                          Text('Hạ cấp Admin'),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'ban':
                      await provider.banUser(targetUser.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã cấm người dùng'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      break;
                    case 'unban':
                      await provider.unbanUser(targetUser.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã bỏ cấm người dùng'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      break;
                    case 'promote':
                      await provider.promoteToAdmin(targetUser.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thăng cấp thành Admin'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      break;
                    case 'demote':
                      await provider.demoteFromAdmin(targetUser.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã hạ cấp Admin'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      break;
                  }
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
