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

### ✅ Tuần 1-2: Phân tích & Thiết kế

- Phân tích yêu cầu hệ thống
- Thiết kế kiến trúc và database
- Setup project cơ bản

### 🔄 Tuần 3-4: Authentication & UI

- Đăng ký, đăng nhập
- Giao diện chính (Home, Browse, Search)
- Movie details screen

### ⏳ Tuần 5-7: Core Features

- Video player với phụ đề song ngữ
- Dictionary integration
- Vocabulary management
- Comments & ratings

### ⏳ Tuần 8-10: Advanced & Deploy

- Recommendation system
- Admin panel
- Testing
- Deployment

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
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Getting Started (Flutter Default)

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
