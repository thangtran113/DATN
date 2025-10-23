import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/movie/movie_list_screen.dart';
import '../../presentation/screens/movie/movie_detail_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movies',
        name: 'movies',
        builder: (context, state) => const MovieListScreen(),
      ),
      GoRoute(
        path: '/movies/:id',
        name: 'movie-detail',
        builder: (context, state) {
          final movieId = state.pathParameters['id']!;
          return MovieDetailScreen(movieId: movieId);
        },
      ),
    ],
  );
}
