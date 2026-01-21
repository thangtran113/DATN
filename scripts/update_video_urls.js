// Script update videoUrl trong Firestore từ backslash sang forward slash
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function updateVideoUrls() {
  console.log("🔄 Updating video URLs...");

  const moviesRef = db.collection("movies");
  const snapshot = await moviesRef.get();

  let updateCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();

    if (data.videoUrl && data.videoUrl.includes("\\")) {
      const oldUrl = data.videoUrl;
      const newUrl = oldUrl.replace(/\\/g, "/");

      await doc.ref.update({ videoUrl: newUrl });
      console.log(`✅ Updated ${doc.id}: ${oldUrl} → ${newUrl}`);
      updateCount++;
    }
  }

  console.log(`\n✅ Done! Updated ${updateCount} movies`);
  process.exit(0);
}

updateVideoUrls().catch(console.error);
