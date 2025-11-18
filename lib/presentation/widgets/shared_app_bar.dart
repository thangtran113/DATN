import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_design_system.dart';

/// Shared AppBar component - Đồng nhất cho toàn app
class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const SharedAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )
          : null,
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  iconSize: AppIconSizes.sm,
                  onPressed: onBackPressed ?? () => context.pop(),
                  tooltip: 'Back',
                )
              : null),
      actions: actions,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }
}

/// AppBar Actions - Common action buttons
class AppBarAction {
  static Widget search({required VoidCallback onPressed, Color? color}) {
    return IconButton(
      icon: const Icon(Icons.search_rounded),
      onPressed: onPressed,
      color: color ?? AppColors.textPrimary,
      iconSize: AppIconSizes.md,
      tooltip: 'Search',
    );
  }

  static Widget logout({required VoidCallback onPressed, Color? color}) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      onPressed: onPressed,
      color: color ?? AppColors.textPrimary,
      iconSize: AppIconSizes.md,
      tooltip: 'Logout',
    );
  }

  static Widget profile({required VoidCallback onPressed, String? photoUrl}) {
    return Padding(
      padding: AppSpacing.paddingHorizontalMD,
      child: GestureDetector(
        onTap: onPressed,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null
              ? const Icon(Icons.person, size: 20, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  static Widget settings({required VoidCallback onPressed, Color? color}) {
    return IconButton(
      icon: const Icon(Icons.settings_rounded),
      onPressed: onPressed,
      color: color ?? AppColors.textPrimary,
      iconSize: AppIconSizes.md,
      tooltip: 'Settings',
    );
  }

  static Widget more({required VoidCallback onPressed, Color? color}) {
    return IconButton(
      icon: const Icon(Icons.more_vert_rounded),
      onPressed: onPressed,
      color: color ?? AppColors.textPrimary,
      iconSize: AppIconSizes.md,
      tooltip: 'More options',
    );
  }
}
