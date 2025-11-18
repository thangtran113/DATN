/**
 * Script to add sample movies to Firestore
 *
 * Usage:
 *   node add_sample_movies.js
 *
 * Prerequisites:
 *   1. Install Node.js
 *   2. Place serviceAccountKey.json in this folder
 *   3. Run: npm install firebase-admin
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

// Load service account key
const keyPath = path.join(__dirname, "serviceAccountKey.json");
if (!fs.existsSync(keyPath)) {
  console.error("❌ serviceAccountKey.json not found!");
  console.log("📝 To get it:");
  console.log(
    "   1. Go to Firebase Console → Project Settings → Service Accounts"
  );
  console.log('   2. Click "Generate New Private Key"');
  console.log("   3. Save as serviceAccountKey.json in this folder");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(keyPath)),
});

const db = admin.firestore();

// Sample movies data (without subtitles - will use sample)
const sampleMovies = [
  {
    id: "the-shawshank-redemption",
    title: "The Shawshank Redemption",
    description:
      "Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=6hB3S9bIaco",
    videoUrl: "", // Empty - to be added later
    duration: 142,
    level: "intermediate",
    genres: ["Drama", "Crime"],
    language: "English",
    rating: 9.3,
    year: 1994,
    cast: ["Tim Robbins", "Morgan Freeman", "Bob Gunton"],
    director: "Frank Darabont",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {}, // Empty - will use sample subtitles
  },
  {
    id: "the-godfather",
    title: "The Godfather",
    description:
      "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=sY1S34973zA",
    videoUrl: "",
    duration: 175,
    level: "advanced",
    genres: ["Crime", "Drama"],
    language: "English",
    rating: 9.2,
    year: 1972,
    cast: ["Marlon Brando", "Al Pacino", "James Caan"],
    director: "Francis Ford Coppola",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {},
  },
  {
    id: "the-dark-knight",
    title: "The Dark Knight",
    description:
      "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=EXeTwQWrcwY",
    videoUrl: "",
    duration: 152,
    level: "intermediate",
    genres: ["Action", "Crime", "Drama"],
    language: "English",
    rating: 9.0,
    year: 2008,
    cast: ["Christian Bale", "Heath Ledger", "Aaron Eckhart"],
    director: "Christopher Nolan",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {},
  },
  {
    id: "forrest-gump",
    title: "Forrest Gump",
    description:
      "The presidencies of Kennedy and Johnson, the Vietnam War, and other historical events unfold from the perspective of an Alabama man.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/saHP97rTPS5eLmrLQEcANmKrsFl.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/7c9UVPPiTPltouxRVY6N9uEiVDP.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=bLvqoHBptjg",
    videoUrl: "",
    duration: 142,
    level: "beginner",
    genres: ["Drama", "Romance"],
    language: "English",
    rating: 8.8,
    year: 1994,
    cast: ["Tom Hanks", "Robin Wright", "Gary Sinise"],
    director: "Robert Zemeckis",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {},
  },
  {
    id: "inception",
    title: "Inception",
    description:
      "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=YoHD9XEInc0",
    videoUrl: "",
    duration: 148,
    level: "advanced",
    genres: ["Action", "Sci-Fi", "Thriller"],
    language: "English",
    rating: 8.8,
    year: 2010,
    cast: ["Leonardo DiCaprio", "Joseph Gordon-Levitt", "Ellen Page"],
    director: "Christopher Nolan",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {},
  },
  {
    id: "the-lion-king",
    title: "The Lion King",
    description:
      "Lion prince Simba and his father are targeted by his bitter uncle, who wants to ascend the throne himself.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/sKCr78MXSLixwmZ8DyJLrpMsd15.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/1TydhBbjMdlqCnwUVqmaqVyaSLy.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=4sj1MT05lAA",
    videoUrl: "",
    duration: 88,
    level: "beginner",
    genres: ["Animation", "Family", "Drama"],
    language: "English",
    rating: 8.5,
    year: 1994,
    cast: ["Matthew Broderick", "Jeremy Irons", "James Earl Jones"],
    director: "Roger Allers",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {},
  },
  {
    id: "finding-nemo",
    title: "Finding Nemo",
    description:
      "After his son is captured in the Great Barrier Reef and taken to Sydney, a timid clownfish sets out on a journey to bring him home.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/eHuGQ10FUzK1mdOY69wF5pGgEf5.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/x9oW0DaVeT1IfHpQhZVm4z2xpR5.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=wZdpNglLbt8",
    videoUrl: "",
    duration: 100,
    level: "beginner",
    genres: ["Animation", "Family", "Adventure"],
    language: "English",
    rating: 8.1,
    year: 2003,
    cast: ["Albert Brooks", "Ellen DeGeneres", "Alexander Gould"],
    director: "Andrew Stanton",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {},
  },
  {
    id: "toy-story",
    title: "Toy Story",
    description:
      "A cowboy doll is profoundly threatened and jealous when a new spaceman figure supplants him as top toy in a boy's room.",
    posterUrl:
      "https://image.tmdb.org/t/p/w500/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg",
    backdropUrl:
      "https://image.tmdb.org/t/p/original/8y6pRfuEfAd7tSEGKiYbwN27gbF.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=KYz2wyBy3kc",
    videoUrl: "",
    duration: 81,
    level: "beginner",
    genres: ["Animation", "Family", "Comedy"],
    language: "English",
    rating: 8.3,
    year: 1995,
    cast: ["Tom Hanks", "Tim Allen", "Don Rickles"],
    director: "John Lasseter",
    country: "USA",
    viewCount: 0,
    vocabularyCount: 0,
    subtitles: {},
  },
];

async function addMovies() {
  console.log("🎬 Starting to add sample movies...\n");

  const batch = db.batch();
  let count = 0;

  for (const movie of sampleMovies) {
    const movieRef = db.collection("movies").doc(movie.id);

    // Add timestamps
    const movieData = {
      ...movie,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: new Date().toISOString(),
    };

    batch.set(movieRef, movieData);
    count++;
    console.log(`✅ Prepared: ${movie.title} (${movie.year})`);
  }

  // Commit batch
  await batch.commit();

  console.log(`\n🎉 Successfully added ${count} movies to Firestore!`);
  console.log("\n📝 Note: Movies have empty videoUrl and subtitles.");
  console.log("   - App will fallback to sample subtitles for display");
  console.log("   - Add real videos and subtitles later\n");
}

// Run
addMovies()
  .then(() => {
    console.log("✅ Done!");
    process.exit(0);
  })
  .catch((err) => {
    console.error("❌ Error:", err);
    process.exit(1);
  });
