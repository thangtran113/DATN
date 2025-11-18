import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/movie/movie_list_screen.dart';
import '../../presentation/screens/movie/movie_detail_screen.dart';
import '../../presentation/screens/movie/search_screen.dart';
import '../../presentation/screens/player/video_player_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/vocabulary/vocabulary_list_screen.dart';
import '../../presentation/screens/vocabulary/flashcard_screen.dart';
import '../../presentation/screens/statistics/statistics_screen.dart';

class AppRouter {
  // Custom page transition builder for smooth animations
  static CustomTransitionPage _buildPageWithFadeTransition({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const SplashScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const LoginScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const RegisterScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const MovieListScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/home/:id',
        name: 'movie-detail',
        pageBuilder: (context, state) {
          final movieId = state.pathParameters['id']!;
          return _buildPageWithFadeTransition(
            child: MovieDetailScreen(movieId: movieId),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const SearchScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/player/:id',
        name: 'player',
        pageBuilder: (context, state) {
          final movieId = state.pathParameters['id']!;
          return _buildPageWithFadeTransition(
            child: VideoPlayerScreen(movieId: movieId),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/vocabulary',
        name: 'vocabulary',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const VocabularyListScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/flashcard',
        name: 'flashcard',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const FlashcardScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          child: const StatisticsScreen(),
          state: state,
        ),
      ),
    ],
  );
}
