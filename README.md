# 🎬 Movie Learning App - Học Tiếng Anh Qua Phim

Ứng dụng xem phim trực tuyến với phụ đề song ngữ, tích hợp các tính năng học tiếng Anh hiện đại.

## 📋 Tổng quan

**Movie Learning App** là một nền tảng xem phim học tiếng Anh độc đáo, cho phép người dùng:

- ✅ Xem phim với phụ đề song ngữ (Anh - Việt)
- ✅ Tra từ điển trực tiếp từ phụ đề
- ✅ Lưu và quản lý từ vựng cá nhân
- ✅ Luyện nghe qua tính năng loop câu thoại
- ✅ Nhận gợi ý phim phù hợp với sở thích
- ✅ Tương tác với cộng đồng qua bình luận và đánh giá

## 🚀 Bắt đầu

### Yêu cầu hệ thống

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Android Studio / VS Code
- Firebase Account

### Cài đặt dependencies

```bash
flutter pub get
```

## 📚 Tài liệu dự án

Xem các tài liệu chi tiết:

- **[DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)** - Kế hoạch phát triển 2 tháng chi tiết
- **[TECHNICAL_REQUIREMENTS.md](TECHNICAL_REQUIREMENTS.md)** - Yêu cầu kỹ thuật và công nghệ
- **[DATABASE_DESIGN.md](DATABASE_DESIGN.md)** - Thiết kế database Firestore

## 📅 Tiến độ dự án

### ✅ Tuần 1-2: Authentication System

- ✅ Firebase Authentication (Email/Password, Google Sign-In)
- ✅ Đăng ký, đăng nhập
- ✅ Firestore user profile management
- ✅ Auto-redirect flow (register → login → home)
- ✅ Password reset functionality

### ✅ Tuần 3-4: Movie Listing & Details

- ✅ Movie entity & repository
- ✅ Movie listing page (grid layout)
- ✅ Search & filter by level (Beginner/Intermediate/Advanced)
- ✅ Movie detail page
- ✅ Watchlist & Favorites management
- ✅ Popular movies section
- ✅ Lazy loading & infinite scroll

### ⏳ Tuần 5-6: Video Player & Interactive Subtitles

- Video player integration (video_player package)
- Bilingual subtitle display (EN-VI)
- Clickable words for dictionary lookup
- Auto-pause feature
- Playback speed control
- Progress tracking

### ⏳ Tuần 7-8: Vocabulary Learning & SRS

- Dictionary API integration (Free Dictionary API + MyMemory Translation)
- Vocabulary saving & management
- Flashcard review system (Spaced Repetition)
- Learning statistics
- Word pronunciation

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9.2+
- **Backend**: Firebase (Auth, Firestore, Storage, Hosting)
- **State Management**: Provider
- **Video**: Chewie, Video Player
- **UI**: Material Design 3, Google Fonts

## 📁 Cấu trúc dự án

```
lib/
├── core/              # Constants, theme, utils
├── features/          # Feature modules (auth, movies, player, etc.)
└── shared/            # Shared widgets & services
```

## 🚀 Run app

```bash
# Web (Recommended for this project)
flutter run -d chrome

# Check available devices
flutter devices
```

## 📊 Adding Sample Movies

### Option 1: Firebase Console (Quick & Easy)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `cinechill-dev`
3. Navigate to **Firestore Database** → **movies** collection
4. Click **Add document** and use this structure:

```json
{
  "title": "The Shawshank Redemption",
  "description": "Two imprisoned men bond over years...",
  "posterUrl": "https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
  "backdropUrl": "https://image.tmdb.org/t/p/w1280/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
  "duration": 142,
  "level": "intermediate",
  "genres": ["Drama", "Crime"],
  "languages": ["en", "vi"],
  "rating": 9.3,
  "year": 1994,
  "cast": ["Tim Robbins", "Morgan Freeman"],
  "director": "Frank Darabont",
  "viewCount": 0,
  "createdAt": "2025-10-23T10:00:00.000Z",
  "updatedAt": "2025-10-23T10:00:00.000Z"
}
```

### Option 2: Use Seed Script

See `lib/data/seed_data.dart` for 8 pre-configured sample movies.

## 📁 Firestore Collections

### `users/{uid}`

- displayName, email, photoUrl
- createdAt, lastLoginAt
- watchlist[], favorites[]
- preferences: {bilingual, autoPause, speed, fontSize}

### `movies/{movieId}`

- title, description, posterUrl, backdropUrl
- duration, level, genres[], languages[]
- rating, year, cast[], director
- viewCount, createdAt, updatedAt

## Getting Started (Flutter Default)

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
