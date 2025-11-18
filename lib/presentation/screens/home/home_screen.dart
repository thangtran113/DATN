import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/constants/app_animations.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: SharedAppBar(
        title: AppStrings.appName,
        actions: [
          AppBarAction.logout(
            onPressed: () async {
              await AuthRepository().signOut();
              if (context.mounted) {
                context.read<AuthProvider>().setUser(null);
                context.go('/login');
              }
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            'https://images.unsplash.com/photo-1557683316-973673baf926?w=1920&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF001233),
                      Color(0xFF003d6b),
                      Color(0xFF0066a1),
                      Color(0xFF004d7a),
                      Color(0xFF001a33),
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              );
            },
          ),
          // Dark overlay
          Container(color: Colors.black.withValues(alpha: 0.35)),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome Message with animation
                    FadeInWidget(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 500),
                        padding: AppSpacing.paddingXL,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: AppRadius.radiusXL,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Logo
                            ScaleInAnimation(
                              delay: const Duration(milliseconds: 200),
                              child: Image.network(
                                'logo.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                            AppSpacing.gapLG,
                            ScaleInAnimation(
                              delay: const Duration(milliseconds: 400),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: AppShadows.primaryGlow,
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.primary,
                                  backgroundImage: user?.photoUrl != null
                                      ? NetworkImage(user!.photoUrl!)
                                      : null,
                                  child: user?.photoUrl == null
                                      ? const Icon(
                                          Icons.person_rounded,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            AppSpacing.gapLG,
                            SlideInFromBottom(
                              delay: const Duration(milliseconds: 600),
                              child: Text(
                                'Welcome back!',
                                style: Theme.of(context).textTheme.headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                            AppSpacing.gapSM,
                            SlideInFromBottom(
                              delay: const Duration(milliseconds: 700),
                              child: Text(
                                user?.displayName ?? 'User',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            AppSpacing.gapXS,
                            SlideInFromBottom(
                              delay: const Duration(milliseconds: 800),
                              child: Text(
                                user?.email ?? '',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapXXL,

                    // Browse Movies Button with animation
                    SlideInFromBottom(
                      delay: const Duration(milliseconds: 900),
                      child: SizedBox(
                        width: double.infinity,
                        child: AnimatedButton(
                          onPressed: () => context.go('/movies'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.movie_rounded,
                                size: AppIconSizes.md,
                                color: Colors.white,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Browse Movies',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.gapLG,

                    // Coming Soon Message with animation
                    FadeInWidget(
                      delay: const Duration(milliseconds: 1100),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 500),
                        padding: AppSpacing.paddingXL,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: AppRadius.radiusXL,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_rounded,
                              size: AppIconSizes.xxl,
                              color: AppColors.primary,
                            ),
                            AppSpacing.gapMD,
                            Text(
                              '📚 Learn English with Movies',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.gapSM,
                            Text(
                              'Video player with interactive subtitles coming in Week 5-6!',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
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
        ],
      ),
    );
  }
}
