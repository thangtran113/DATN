import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

// Run this script once to seed sample movies into Firestore
// Execute: dart run lib/data/seed_data.dart

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  final sampleMovies = [
    {
      'title': 'The Shawshank Redemption',
      'description':
          'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency. A timeless tale of hope and friendship.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg',
      'duration': 142,
      'level': 'intermediate',
      'genres': ['Drama', 'Crime'],
      'languages': ['en', 'vi'],
      'rating': 9.3,
      'year': 1994,
      'cast': ['Tim Robbins', 'Morgan Freeman', 'Bob Gunton'],
      'director': 'Frank Darabont',
      'viewCount': 1500,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Forrest Gump',
      'description':
          'The presidencies of Kennedy and Johnson, the Vietnam War, and other historical events unfold from the perspective of an Alabama man with an IQ of 75.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/saHP97rTPS5eLmrLQEcANmKrsFl.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/3h1JZGDhZ8nzxdgvkxha0qBqi05.jpg',
      'duration': 142,
      'level': 'beginner',
      'genres': ['Drama', 'Romance'],
      'languages': ['en', 'vi'],
      'rating': 8.8,
      'year': 1994,
      'cast': ['Tom Hanks', 'Robin Wright', 'Gary Sinise'],
      'director': 'Robert Zemeckis',
      'viewCount': 2100,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'The Pursuit of Happyness',
      'description':
          'A struggling salesman takes custody of his son as he\'s poised to begin a life-changing professional career. An inspiring true story.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/iB6MikNT9anEZFHT83T7vH1T5rY.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/j5wkiYFvUWeqCKH1KUEV2DPTfLN.jpg',
      'duration': 117,
      'level': 'beginner',
      'genres': ['Biography', 'Drama'],
      'languages': ['en', 'vi'],
      'rating': 8.0,
      'year': 2006,
      'cast': ['Will Smith', 'Jaden Smith', 'Thandiwe Newton'],
      'director': 'Gabriele Muccino',
      'viewCount': 1800,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Inception',
      'description':
          'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
      'duration': 148,
      'level': 'advanced',
      'genres': ['Action', 'Sci-Fi', 'Thriller'],
      'languages': ['en', 'vi'],
      'rating': 8.8,
      'year': 2010,
      'cast': ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Ellen Page'],
      'director': 'Christopher Nolan',
      'viewCount': 2500,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'The Devil Wears Prada',
      'description':
          'A smart but sensible new graduate lands a job as an assistant to Miranda Priestly, the demanding editor-in-chief of a high fashion magazine.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/8912AsVuS7Sj915apArUFbv6F9L.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/5qIxHq40gZnR7d69wQ03R6xYHOr.jpg',
      'duration': 109,
      'level': 'intermediate',
      'genres': ['Comedy', 'Drama', 'Romance'],
      'languages': ['en', 'vi'],
      'rating': 6.9,
      'year': 2006,
      'cast': ['Anne Hathaway', 'Meryl Streep', 'Emily Blunt'],
      'director': 'David Frankel',
      'viewCount': 1600,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'The Social Network',
      'description':
          'As Harvard student Mark Zuckerberg creates the social networking site that would become Facebook, he is sued by the twins who claimed he stole their idea.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/n0ybibhJtQ5icDqTp8eRytcIHJx.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/20dPpqSXiA5c2Hu8uNxcBkWGGpC.jpg',
      'duration': 120,
      'level': 'intermediate',
      'genres': ['Biography', 'Drama'],
      'languages': ['en', 'vi'],
      'rating': 7.7,
      'year': 2010,
      'cast': ['Jesse Eisenberg', 'Andrew Garfield', 'Justin Timberlake'],
      'director': 'David Fincher',
      'viewCount': 1400,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Finding Nemo',
      'description':
          'After his son is captured in the Great Barrier Reef and taken to Sydney, a timid clownfish sets out on a journey to bring him home.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/eHuGQ10FUzK1mdOY69wF5pGgEf5.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/n1y094tVDFATSzkTnFxoGZ1qNsG.jpg',
      'duration': 100,
      'level': 'beginner',
      'genres': ['Animation', 'Family', 'Adventure'],
      'languages': ['en', 'vi'],
      'rating': 8.1,
      'year': 2003,
      'cast': ['Albert Brooks', 'Ellen DeGeneres', 'Alexander Gould'],
      'director': 'Andrew Stanton',
      'viewCount': 3000,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Interstellar',
      'description':
          'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      'backdropUrl':
          'https://image.tmdb.org/t/p/w1280/xu9zaAevzQ5nnrsXN6JcahLnG4i.jpg',
      'duration': 169,
      'level': 'advanced',
      'genres': ['Adventure', 'Drama', 'Sci-Fi'],
      'languages': ['en', 'vi'],
      'rating': 8.6,
      'year': 2014,
      'cast': ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain'],
      'director': 'Christopher Nolan',
      'viewCount': 2200,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
  ];

  print('🎬 Starting to seed movies...');

  for (var movie in sampleMovies) {
    try {
      await firestore.collection('movies').add(movie);
      print('✅ Added: ${movie['title']}');
    } catch (e) {
      print('❌ Failed to add ${movie['title']}: $e');
    }
  }

  print('\n🎉 Seeding completed! Total movies: ${sampleMovies.length}');
  print('📊 You can now view them in your app.');
}
