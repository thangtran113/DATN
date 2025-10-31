import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 4,
      title: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Row(
              children: [
                Image.network(
                  'logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Text(
                  'CINECHILL',
                  style: TextStyle(
                    color: Color(0xFF00BCD4),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),

          // Navigation items
          _buildNavItem(context, 'Home', () => context.go('/home')),
          _buildNavItem(context, 'My List', () {}),
        ],
      ),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          tooltip: 'Search',
          onPressed: () {
            // TODO: Implement search
          },
        ),
        const SizedBox(width: 8),

        // Notifications
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          tooltip: 'Notifications',
          onPressed: () {
            // TODO: Implement notifications
          },
        ),
        const SizedBox(width: 8),

        // User profile menu
        _buildProfileMenu(context, authProvider),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFE50914),
        child: Text(
          authProvider.user?.displayName?.substring(0, 1).toUpperCase() ??
              authProvider.user?.username.substring(0, 1).toUpperCase() ??
              'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authProvider.user?.displayName ??
                    authProvider.user?.username ??
                    'User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                authProvider.user?.email ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Divider(),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'profile',
          child: const Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: const Row(
            children: [
              Icon(Icons.settings_outlined, size: 20),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: const Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            // TODO: Navigate to profile
            break;
          case 'settings':
            // TODO: Navigate to settings
            break;
          case 'logout':
            await AuthRepository().signOut();
            authProvider.setUser(null);
            if (context.mounted) {
              context.go('/login');
            }
            break;
        }
      },
    );
  }
}
