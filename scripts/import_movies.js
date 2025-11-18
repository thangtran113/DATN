const admin = require("firebase-admin");
const movies = require("./sample_movies.json");

// Khởi tạo Firebase Admin với Service Account
const serviceAccount = require("../firebase-service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: "cinechill-dev",
});

const db = admin.firestore();

async function importMovies() {
  try {
    console.log("🎬 Đang import 10 phim vào Firestore...\n");

    let count = 0;
    for (const movie of movies) {
      // Thêm timestamp
      const movieData = {
        ...movie,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
      };

      const docRef = await db.collection("movies").add(movieData);
      count++;
      console.log(
        `✅ [${count}/10] Đã thêm: ${movie.title} (ID: ${docRef.id})`
      );
    }

    console.log(`\n🎉 Hoàn thành! Đã import ${count} phim vào Firestore.`);
    console.log("🔥 Firebase Project: cinechill-dev");
    process.exit(0);
  } catch (error) {
    console.error("\n❌ Lỗi:", error.message);
    console.error("\n💡 Hướng dẫn sửa lỗi:");
    console.error("1. Tải Service Account Key từ Firebase Console");
    console.error(
      "2. Lưu file vào root với tên: firebase-service-account.json"
    );
    console.error("3. Bỏ comment dòng 5-8, comment lại dòng 11-13");
    process.exit(1);
  }
}

importMovies();
