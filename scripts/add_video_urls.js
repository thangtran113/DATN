// Script to update movies with sample video URLs for testing
// Run: node scripts/add_video_urls.js

const admin = require("firebase-admin");

// Initialize Firebase Admin (nếu chưa có)
// const serviceAccount = require('./serviceAccountKey.json');
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

const db = admin.firestore();

// Sample video URLs for testing (Google's test videos)
const sampleVideos = [
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
];

// Sample subtitle URLs (you'll need to upload these)
const sampleSubtitles = {
  en: "https://firebasestorage.googleapis.com/path/to/english.srt",
  vi: "https://firebasestorage.googleapis.com/path/to/vietnamese.srt",
};

async function updateMoviesWithVideoUrls() {
  try {
    console.log("🎬 Starting to update movies with video URLs...");

    // Get all movies
    const moviesSnapshot = await db.collection("movies").get();

    if (moviesSnapshot.empty) {
      console.log("❌ No movies found in database");
      return;
    }

    console.log(`📊 Found ${moviesSnapshot.size} movies`);

    let updateCount = 0;
    const batch = db.batch();

    moviesSnapshot.forEach((doc, index) => {
      const movieRef = db.collection("movies").doc(doc.id);
      const videoUrl = sampleVideos[index % sampleVideos.length];

      // Update with video URL and subtitles
      batch.update(movieRef, {
        videoUrl: videoUrl,
        subtitles: sampleSubtitles,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Queued update for: ${doc.data().title}`);
      console.log(`   Video: ${videoUrl}`);
      updateCount++;
    });

    // Commit batch
    await batch.commit();
    console.log(`\n🎉 Successfully updated ${updateCount} movies!`);
  } catch (error) {
    console.error("❌ Error updating movies:", error);
  }
}

// Run the script
updateMoviesWithVideoUrls()
  .then(() => {
    console.log("\n✨ Done!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });
