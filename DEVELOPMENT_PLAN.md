# KẾ HOẠCH PHÁT TRIỂN HỆ THỐNG XEM PHIM HỌC TIẾNG ANH - 2 THÁNG

## 📋 TỔNG QUAN DỰ ÁN

**Tên dự án**: Movie Learning App - Ứng dụng xem phim học tiếng Anh  
**Thời gian**: 8 tuần (2 tháng)  
**Nền tảng**: Flutter (Web & Mobile)  
**Backend**: Firebase (Authentication, Firestore, Storage, Hosting)  
**Mục tiêu**: Xây dựng hệ thống xem phim trực tuyến với phụ đề song ngữ tích hợp tính năng học tiếng Anh

---

## 🎯 YÊU CẦU HỆ THỐNG

### Yêu cầu chức năng:

1. ✅ Đăng ký, đăng nhập, quản lý tài khoản
2. ✅ Xem phim với phụ đề song ngữ (Anh-Việt)
3. ✅ Tra từ điển trực tiếp từ phụ đề
4. ✅ Lưu từ vựng và quản lý danh sách từ cá nhân
5. ✅ Lặp lại câu thoại để luyện nghe
6. ✅ Bình luận và đánh giá phim
7. ✅ Gợi ý phim theo sở thích
8. ✅ Quản lý danh sách yêu thích và lịch sử xem
9. ✅ Admin panel quản lý phim và người dùng

### Yêu cầu phi chức năng:

- 🎨 Giao diện hiện đại, trực quan, responsive
- ⚡ Hiệu năng cao, tải nhanh
- 🔒 Bảo mật thông tin người dùng
- 📱 Hỗ trợ đa nền tảng (Web, Android, iOS)
- 🌐 Khả năng mở rộng cao

---

## 📅 KỀ HOẠCH CHI TIẾT 8 TUẦN

## TUẦN 1-2: PHÂN TÍCH & THIẾT KẾ HỆ THỐNG

### Tuần 1: Phân tích yêu cầu và thiết kế kiến trúc

**Công việc:**

- [ ] Phân tích chi tiết yêu cầu chức năng và phi chức năng
- [ ] Vẽ sơ đồ use case cho tất cả actors (User, Admin)
- [ ] Thiết kế kiến trúc hệ thống (Client-Server-Database)
- [ ] Lựa chọn công nghệ và thư viện cần sử dụng
- [ ] Tạo wireframe cho các màn hình chính

**Deliverables:**

- Document phân tích yêu cầu
- Sơ đồ use case
- Sơ đồ kiến trúc hệ thống
- Wireframe UI/UX

### Tuần 2: Thiết kế database và setup project

**Công việc:**

- [ ] Thiết kế database schema trên Firestore:
  - Users (uid, email, displayName, photoURL, preferences, createdAt)
  - Movies (id, title, description, genres, releaseYear, duration, videoUrl, thumbnailUrl, rating, viewCount)
  - Subtitles (movieId, language, content, timestamps)
  - Comments (id, movieId, userId, content, rating, createdAt)
  - Vocabulary (userId, word, meaning, pronunciation, example, movieId, timestamp, createdAt)
  - History (userId, movieId, watchedAt, progress, completed)
  - Watchlist (userId, movieId, addedAt)
- [ ] Thiết kế Security Rules cho Firestore
- [ ] Setup Firebase project (Authentication, Firestore, Storage)
- [ ] Cấu hình Flutter project với Firebase
- [ ] Tạo cấu trúc thư mục dự án theo Clean Architecture

**Deliverables:**

- Database schema document
- Firebase project configured
- Flutter project structure

---

## TUẦN 3-4: XÂY DỰNG AUTHENTICATION & UI CƠ BẢN

### Tuần 3: Authentication và User Management

**Công việc:**

- [ ] Tích hợp Firebase Authentication
- [ ] Implement màn hình đăng ký (email/password)
- [ ] Implement màn hình đăng nhập (email/password, Google Sign-In)
- [ ] Implement quên mật khẩu và reset password
- [ ] Implement màn hình profile và chỉnh sửa thông tin
- [ ] Tạo AuthProvider/AuthBloc để quản lý state
- [ ] Implement auto-login và session management

**Deliverables:**

- Authentication flow hoàn chỉnh
- User profile management

### Tuần 4: Xây dựng giao diện chính

**Công việc:**

- [ ] Tạo theme và design system (colors, typography, spacing)
- [ ] Implement Bottom Navigation Bar
- [ ] Màn hình Home:
  - Banner slider
  - Featured movies
  - Movies by genres
  - Continue watching section
- [ ] Màn hình Browse/Categories
- [ ] Màn hình Search với filter
- [ ] Màn hình Profile
- [ ] Màn hình Movie Detail
- [ ] Responsive layout cho web và mobile

**Deliverables:**

- Complete UI screens (non-functional)
- Responsive layouts

---

## TUẦN 5-6: VIDEO PLAYER & LEARNING FEATURES

### Tuần 5: Video Player với phụ đề song ngữ

**Công việc:**

- [ ] Tích hợp video player (video_player hoặc better_player)
- [ ] Implement hiển thị phụ đề song ngữ đồng bộ
- [ ] Tạo subtitle parser (SRT, VTT format)
- [ ] Implement controls: play/pause, seek, volume, fullscreen
- [ ] Hiển thị tiến độ xem và tự động lưu
- [ ] Upload video lên Firebase Storage
- [ ] Optimize video streaming

**Deliverables:**

- Working video player with bilingual subtitles
- Video upload functionality

### Tuần 6: Tra từ điển và quản lý từ vựng

**Công việc:**

- [ ] Tích hợp Dictionary API (Free Dictionary API hoặc Oxford API)
- [ ] Implement click-to-translate trên phụ đề
- [ ] Hiển thị popup với nghĩa, phiên âm, ví dụ
- [ ] Text-to-Speech cho phát âm từ
- [ ] Chức năng lưu từ vào danh sách cá nhân
- [ ] Màn hình quản lý từ vựng đã lưu
- [ ] Tính năng ôn tập từ vựng (flashcard style)
- [ ] Thống kê số từ đã học

**Deliverables:**

- Dictionary integration
- Vocabulary management system

---

## TUẦN 6-7: LEARNING TOOLS & SOCIAL FEATURES

### Tuần 6 (tiếp): Loop câu thoại

**Công việc:**

- [ ] Implement tính năng loop đoạn phụ đề
- [ ] Thêm controls: loop A-B, slow down speed (0.5x, 0.75x, 1x, 1.25x, 1.5x)
- [ ] Highlight câu đang phát trong phụ đề
- [ ] Click vào câu phụ đề để jump tới timestamp
- [ ] Lưu các đoạn loop yêu thích

**Deliverables:**

- Repeat/loop functionality
- Playback speed control

### Tuần 7: Bình luận, đánh giá và Watchlist

**Công việc:**

- [ ] Implement comment system với realtime updates
- [ ] Tính năng like/reply comments
- [ ] Đánh giá phim (1-5 sao)
- [ ] Hiển thị rating trung bình
- [ ] Thêm/xóa phim khỏi watchlist
- [ ] Màn hình Watchlist
- [ ] Màn hình Watch History
- [ ] Continue watching với tiến độ

**Deliverables:**

- Comment & rating system
- Watchlist & history features

---

## TUẦN 7-8: RECOMMENDATION & ADMIN PANEL

### Tuần 7 (tiếp): Hệ thống gợi ý phim

**Công việc:**

- [ ] Implement recommendation algorithm:
  - Based on watch history
  - Based on favorite genres
  - Based on ratings
  - Similar movies
- [ ] "Because you watched..." section
- [ ] "Top picks for you" section
- [ ] Trending movies
- [ ] Most popular movies

**Deliverables:**

- Movie recommendation system

### Tuần 8: Admin Panel

**Công việc:**

- [ ] Tạo role-based access control
- [ ] Admin dashboard:
  - Tổng quan thống kê (users, movies, comments)
  - Charts và analytics
- [ ] Quản lý phim:
  - Upload phim và phụ đề
  - CRUD operations
  - Bulk upload
- [ ] Quản lý người dùng:
  - View user list
  - Ban/unban users
  - View user activities
- [ ] Quản lý comments (delete inappropriate comments)

**Deliverables:**

- Complete admin panel

---

## TUẦN 8-9: TESTING & OPTIMIZATION

### Tuần 9: Testing và bug fixes

**Công việc:**

- [ ] Unit tests cho business logic
- [ ] Widget tests cho UI components
- [ ] Integration tests cho main flows
- [ ] Performance testing và optimization:
  - Lazy loading cho danh sách phim
  - Image caching
  - Video buffering optimization
- [ ] Security audit:
  - Review Firestore rules
  - Test authentication edge cases
  - Input validation
- [ ] Cross-platform testing (Web, Android, iOS)
- [ ] Bug fixing và refinement

**Deliverables:**

- Test coverage report
- Bug-free application

---

## TUẦN 10: DEPLOYMENT & FINALIZATION

### Tuần 10: Deploy và hoàn thiện

**Công việc:**

- [ ] Optimize build size
- [ ] Configure Firebase Hosting
- [ ] Deploy web app to Firebase Hosting
- [ ] Build Android APK/AAB
- [ ] Build iOS IPA (nếu có Mac)
- [ ] Setup analytics (Firebase Analytics)
- [ ] Setup crash reporting (Firebase Crashlytics)
- [ ] Viết tài liệu:
  - User guide
  - Technical documentation
  - API documentation
  - Deployment guide
- [ ] Tạo video demo
- [ ] Chuẩn bị presentation

**Deliverables:**

- Live production app
- Complete documentation
- Demo video

---

## 🛠️ CÔNG NGHỆ SỬ DỤNG

### Frontend:

- **Flutter** ^3.9.2
- **Provider/Bloc** - State management
- **GoRouter** - Navigation
- **cached_network_image** - Image caching
- **video_player/better_player** - Video playback
- **shimmer** - Loading skeleton

### Backend & Services:

- **Firebase Authentication** - User auth
- **Cloud Firestore** - Database
- **Firebase Storage** - File storage
- **Firebase Hosting** - Web hosting
- **Firebase Analytics** - Analytics
- **Firebase Crashlytics** - Crash reporting

### APIs:

- **Free Dictionary API** / **Oxford API** - Dictionary
- **TMDB API** (optional) - Movie metadata

### Development Tools:

- **VS Code** / **Android Studio** - IDE
- **Git** - Version control
- **Postman** - API testing
- **Firebase Console** - Backend management

---

## 📦 CẤU TRÚC THƯ MỤC DỰ ÁN

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_assets.dart
│   │   └── firebase_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   └── subtitle_parser.dart
│   ├── routes/
│   │   └── app_router.dart
│   └── errors/
│       └── exceptions.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── profile_screen.dart
│   │       └── widgets/
│   │           └── auth_form_field.dart
│   │
│   ├── movies/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── movie_model.dart
│   │   │   │   └── subtitle_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── movie_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── movie_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── movie.dart
│   │   │   │   └── subtitle.dart
│   │   │   ├── repositories/
│   │   │   │   └── movie_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_movies_usecase.dart
│   │   │       ├── get_movie_detail_usecase.dart
│   │   │       └── search_movies_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── movie_provider.dart
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── movie_detail_screen.dart
│   │       │   ├── browse_screen.dart
│   │       │   └── search_screen.dart
│   │       └── widgets/
│   │           ├── movie_card.dart
│   │           ├── movie_list.dart
│   │           └── genre_chip.dart
│   │
│   ├── player/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── player_provider.dart
│   │       ├── screens/
│   │       │   └── video_player_screen.dart
│   │       └── widgets/
│   │           ├── subtitle_widget.dart
│   │           ├── player_controls.dart
│   │           └── subtitle_selector.dart
│   │
│   ├── dictionary/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── word_definition_model.dart
│   │   │   └── datasources/
│   │   │       └── dictionary_api_datasource.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dictionary_provider.dart
│   │       └── widgets/
│   │           ├── word_popup.dart
│   │           └── pronunciation_button.dart
│   │
│   ├── vocabulary/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── vocabulary_provider.dart
│   │       ├── screens/
│   │       │   ├── vocabulary_list_screen.dart
│   │       │   └── flashcard_screen.dart
│   │       └── widgets/
│   │           └── vocabulary_card.dart
│   │
│   ├── comments/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── comment_provider.dart
│   │       └── widgets/
│   │           ├── comment_list.dart
│   │           ├── comment_item.dart
│   │           └── rating_widget.dart
│   │
│   ├── watchlist/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── watchlist_provider.dart
│   │       └── screens/
│   │           ├── watchlist_screen.dart
│   │           └── history_screen.dart
│   │
│   ├── recommendations/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── recommendation_provider.dart
│   │       └── widgets/
│   │           └── recommended_section.dart
│   │
│   └── admin/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── screens/
│           │   ├── admin_dashboard_screen.dart
│           │   ├── manage_movies_screen.dart
│           │   ├── manage_users_screen.dart
│           │   └── upload_movie_screen.dart
│           └── widgets/
│               ├── admin_stats_card.dart
│               └── user_table.dart
│
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_indicator.dart
    │   ├── error_widget.dart
    │   └── responsive_builder.dart
    └── services/
        ├── firebase_service.dart
        └── analytics_service.dart
```

---

## 📝 CHECKLIST TỔNG HỢP

### Setup & Configuration

- [ ] Firebase project setup
- [ ] Flutter project configuration
- [ ] Git repository initialization
- [ ] CI/CD pipeline (optional)

### Core Features

- [ ] Authentication system
- [ ] Movie browsing & search
- [ ] Video player with subtitles
- [ ] Dictionary integration
- [ ] Vocabulary management
- [ ] Loop/repeat functionality
- [ ] Comment & rating system
- [ ] Watchlist & history
- [ ] Recommendation system
- [ ] Admin panel

### Testing

- [ ] Unit tests (>60% coverage)
- [ ] Widget tests
- [ ] Integration tests
- [ ] Manual testing on multiple devices

### Documentation

- [ ] README.md
- [ ] API documentation
- [ ] User manual
- [ ] Technical documentation

### Deployment

- [ ] Web deployment (Firebase Hosting)
- [ ] Android APK/AAB
- [ ] iOS build (optional)

---

## 🎓 HỌC TẬP & TÀI LIỆU THAM KHẢO

### Flutter & Dart

- Flutter Documentation: https://flutter.dev/docs
- Dart Language Tour: https://dart.dev/guides/language/language-tour
- Flutter Widget Catalog: https://flutter.dev/docs/development/ui/widgets

### Firebase

- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire: https://firebase.flutter.dev/
- Firestore Security Rules: https://firebase.google.com/docs/firestore/security

### Clean Architecture

- Clean Architecture in Flutter: https://resocoder.com/flutter-clean-architecture/
- Flutter Bloc Pattern: https://bloclibrary.dev/

### APIs

- Free Dictionary API: https://dictionaryapi.dev/
- TMDB API: https://www.themoviedb.org/documentation/api

---

## ⚠️ RỦI RO & GIẢI PHÁP

| Rủi ro                       | Mức độ     | Giải pháp                                                         |
| ---------------------------- | ---------- | ----------------------------------------------------------------- |
| Độ phức tạp của video player | Cao        | Sử dụng package có sẵn (better_player), backup plan: video_player |
| Phụ đề không đồng bộ         | Trung bình | Test kỹ subtitle parser, chuẩn hóa timestamp format               |
| Firebase quota limit         | Trung bình | Optimize queries, implement pagination, caching                   |
| Dictionary API rate limit    | Thấp       | Implement caching, backup với offline dictionary                  |
| Cross-platform issues        | Trung bình | Test sớm trên nhiều platform, sử dụng responsive design           |
| Performance với video        | Cao        | Optimize video encoding, implement adaptive streaming             |

---

## 💡 GỢI Ý CẢI TIẾN SAU 2 THÁNG

1. **Machine Learning**:
   - Phân tích mức độ khó của phim dựa trên từ vựng
   - Gợi ý phim phù hợp với trình độ người học
2. **Gamification**:

   - Hệ thống điểm, level, achievement
   - Leaderboard
   - Daily challenges

3. **Social Features**:

   - Follow bạn bè
   - Share progress
   - Study groups

4. **Advanced Learning**:

   - Quiz từ vựng
   - Speaking practice với AI
   - Writing exercises

5. **Content**:
   - Series/TV shows
   - Podcast với transcript
   - Short clips cho người bận rộn

---

## 📧 LIÊN HỆ & HỖ TRỢ

Nếu có thắc mắc trong quá trình phát triển, có thể tham khảo:

- Flutter Community: https://flutter.dev/community
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Firebase Community: https://firebase.google.com/community

---

**Chúc bạn thành công với dự án! 🚀**

_Lưu ý: Plan này có thể điều chỉnh linh hoạt tùy theo tiến độ thực tế và khó khăn phát sinh._
