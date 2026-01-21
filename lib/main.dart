import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/movie_provider.dart';
import 'presentation/providers/vocabulary_provider.dart';
import 'presentation/providers/comment_provider.dart';
import 'presentation/providers/recommendation_provider.dart';
import 'presentation/providers/admin_movie_provider.dart';
import 'presentation/providers/admin_user_provider.dart';
import 'data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup Vietnamese locale for timeago
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => MovieProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => VocabularyProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => CommentProvider(), lazy: true),
        ChangeNotifierProvider(
          create: (_) => RecommendationProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(create: (_) => AdminMovieProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => AdminUserProvider(), lazy: true),
        StreamProvider(
          create: (_) => AuthRepository().userStream,
          initialData: null,
          lazy: false,
        ),
      ],
      child: MaterialApp.router(
        title: 'CineChill',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
