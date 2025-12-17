# YÊU CẦU KỸ THUẬT CHI TIẾT

## 🎯 MỤC TIÊU DỰ ÁN

Xây dựng ứng dụng xem phim trực tuyến với phụ đề song ngữ, tích hợp các tính năng học tiếng Anh, hỗ trợ đa nền tảng (Web, Android, iOS).

---

## 📋 YÊU CẦU CHỨC NĂNG

### 1. Quản lý người dùng

#### 1.1 Authentication

- ✅ Đăng ký tài khoản mới (email/password)
- ✅ Đăng nhập (email/password, Google Sign-In)
- ✅ Quên mật khẩu và reset password
- ✅ Đăng xuất
- ✅ Tự động đăng nhập (Remember me)
- ✅ Email verification

#### 1.2 Profile Management

- ✅ Xem và chỉnh sửa thông tin cá nhân
- ✅ Đổi mật khẩu
- ✅ Upload/change avatar
- ✅ Cài đặt preferences (thể loại yêu thích, trình độ, ngôn ngữ phụ đề)
- ✅ Xem thống kê học tập
- ✅ Xóa tài khoản

---

### 2. Quản lý phim

#### 2.1 Hiển thị danh sách phim

- ✅ Trang chủ với sections:
  - Featured movies
  - Continue watching
  - Popular movies
  - New releases
  - Movies by genres
- ✅ Browse by categories/genres
- ✅ Search phim (theo tên, diễn viên, đạo diễn, năm)
- ✅ Filter phim (thể loại, năm phát hành, độ khó)
- ✅ Sort phim (rating, views, newest)
- ✅ Pagination/infinite scroll

#### 2.2 Chi tiết phim

- ✅ Hiển thị đầy đủ thông tin:
  - Title, description, plot
  - Director, cast
  - Genres, release year, duration
  - Thumbnail, poster
  - Average rating, view count
- ✅ Play button
- ✅ Add to watchlist
- ✅ Rating & reviews section
- ✅ Similar movies section
- ✅ Trailer (nếu có)

---

### 3. Video Player

#### 3.1 Player Controls

- ✅ Play/Pause
- ✅ Seek bar với preview thumbnails
- ✅ Volume control
- ✅ Playback speed (0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x)
- ✅ Fullscreen mode
- ✅ Picture-in-Picture (PiP)
- ✅ Auto-play next episode/movie
- ✅ Skip intro/outro (optional)

#### 3.2 Subtitle Features

- ✅ Hiển thị phụ đề song ngữ (English + Vietnamese)
- ✅ Toggle subtitle visibility
- ✅ Chọn ngôn ngữ phụ đề (EN only, VI only, Both)
- ✅ Adjust subtitle position
- ✅ Adjust subtitle font size
- ✅ Subtitle style customization
- ✅ Click vào câu phụ đề để jump đến timestamp

#### 3.3 Learning Features trong Player

- ✅ Click vào từ trong phụ đề để tra nghĩa
- ✅ Loop/repeat đoạn phụ đề đang phát
- ✅ Mark A-B loop points
- ✅ Slow down playback cho dễ nghe
- ✅ Hide English/Vietnamese subtitle để luyện tập
- ✅ Bookmark câu phụ đề hay

#### 3.4 Progress Tracking

- ✅ Tự động lưu tiến độ xem
- ✅ Resume từ vị trí đã xem
- ✅ Mark completed khi xem hết

---

### 4. Tính năng học tiếng Anh

#### 4.1 Dictionary Integration

- ✅ Tra từ điển trực tiếp từ phụ đề
- ✅ Hiển thị:
  - Nghĩa tiếng Việt
  - Phiên âm IPA
  - Part of speech
  - Example sentences
  - Synonyms
- ✅ Text-to-Speech cho pronunciation
- ✅ Multiple definitions cho từ đa nghĩa
- ✅ Save word to vocabulary list

#### 4.2 Vocabulary Management

- ✅ Lưu từ vựng kèm context (câu trong phim)
- ✅ Danh sách từ đã lưu
- ✅ Filter/search trong vocabulary list
- ✅ Sort by date added, alphabetically
- ✅ Mastery levels (New, Learning, Mastered)
- ✅ Spaced repetition reminders
- ✅ Export vocabulary to CSV/Excel

#### 4.3 Practice Features

- ✅ Flashcard mode
- ✅ Quiz từ vựng
- ✅ Statistics:
  - Total words learned
  - Words by mastery level
  - Learning streak
  - Progress charts
- ✅ Review due words

#### 4.4 Loop/Repeat Feature

- ✅ Loop một câu thoại nhiều lần
- ✅ Set number of loops
- ✅ Adjust playback speed
- ✅ Auto-pause between loops
- ✅ Save favorite loops

---

### 5. Social Features

#### 5.1 Comments & Reviews

- ✅ Comment trên phim
- ✅ Rate phim (1-5 stars)
- ✅ Like/dislike comments
- ✅ Reply to comments
- ✅ Edit/delete own comments
- ✅ Report inappropriate comments
- ✅ Sort comments (newest, most liked, top rated)

#### 5.2 User Interactions

- ✅ View user profiles
- ✅ Follow/unfollow users (optional)
- ✅ Share movie links

---

### 6. Watchlist & History

#### 6.1 Watchlist

- ✅ Add/remove movies from watchlist
- ✅ View watchlist
- ✅ Quick add button từ movie card
- ✅ Notifications cho phim mới trong watchlist

#### 6.2 Watch History

- ✅ Lịch sử xem phim
- ✅ Continue watching section
- ✅ Progress percentage cho từng phim
- ✅ Clear history
- ✅ Delete individual items

---

### 7. Recommendation System

#### 7.1 Personalized Recommendations

- ✅ Based on watch history
- ✅ Based on favorite genres
- ✅ Based on ratings
- ✅ Similar movies
- ✅ "Because you watched..." section
- ✅ "Top picks for you"

#### 7.2 Trending & Popular

- ✅ Trending movies (most viewed this week)
- ✅ Most popular all-time
- ✅ Top rated movies
- ✅ New releases

---

### 8. Admin Panel

#### 8.1 Dashboard

- ✅ Statistics overview:
  - Total users, active users
  - Total movies, views
  - Comments, ratings
- ✅ Charts & analytics
- ✅ Recent activities

#### 8.2 Movie Management

- ✅ Upload new movie
- ✅ Edit movie information
- ✅ Delete movie
- ✅ Upload subtitles (SRT format)
- ✅ Set featured movies
- ✅ Publish/unpublish movies
- ✅ Bulk upload (CSV import)

#### 8.3 User Management

- ✅ View user list
- ✅ Search users
- ✅ View user details & activity
- ✅ Ban/unban users
- ✅ Promote to admin

#### 8.4 Content Moderation

- ✅ Review reported comments
- ✅ Delete inappropriate content
- ✅ View moderation logs

---

## 🎨 YÊU CẦU PHI CHỨC NĂNG

### 1. UI/UX Requirements

#### 1.1 Design Principles

- ✅ Modern, clean interface
- ✅ Intuitive navigation
- ✅ Consistent design language
- ✅ Dark mode support
- ✅ Accessibility (WCAG 2.1 AA)

#### 1.2 Responsive Design

- ✅ Mobile-first approach
- ✅ Tablet optimization
- ✅ Desktop optimization
- ✅ Adaptive layouts
- ✅ Touch-friendly controls

#### 1.3 Color Scheme

- Primary: Netflix-inspired red/dark theme
- Background: Dark (#121212, #1E1E1E)
- Text: White (#FFFFFF), Gray (#B3B3B3)
- Accent: Red (#E50914), Blue (#0071EB)

#### 1.4 Typography

- Font family: Roboto, Inter, or Montserrat
- Heading sizes: 24px, 20px, 18px, 16px
- Body text: 14px, 16px
- Subtitle text: 12px

---

### 2. Performance Requirements

#### 2.1 Speed

- ✅ Page load time < 3 seconds
- ✅ Video buffering < 2 seconds
- ✅ Smooth 60fps animations
- ✅ API response time < 500ms

#### 2.2 Optimization

- ✅ Image lazy loading
- ✅ Video adaptive streaming
- ✅ Code splitting
- ✅ Bundle size optimization
- ✅ Caching strategy

#### 2.3 Scalability

- ✅ Handle 1000+ concurrent users
- ✅ Support 100+ movies library
- ✅ Efficient database queries
- ✅ CDN for video delivery

---

### 3. Security Requirements

#### 3.1 Authentication & Authorization

- ✅ Secure password hashing
- ✅ JWT tokens (Firebase handles this)
- ✅ Role-based access control (User, Admin)
- ✅ Session management
- ✅ CSRF protection

#### 3.2 Data Security

- ✅ Firestore Security Rules
- ✅ Input validation & sanitization
- ✅ XSS protection
- ✅ SQL injection prevention (not applicable for Firestore)
- ✅ Secure file upload

#### 3.3 Privacy

- ✅ GDPR compliance (data export, deletion)
- ✅ Cookie consent
- ✅ Privacy policy
- ✅ Terms of service

---

### 4. Compatibility Requirements

#### 4.1 Browsers (Web)

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

#### 4.2 Mobile Platforms

- ✅ Android 7.0+ (API 24+)
- ✅ iOS 12.0+

#### 4.3 Screen Sizes

- Mobile: 320px - 767px
- Tablet: 768px - 1023px
- Desktop: 1024px+

---

### 5. Reliability Requirements

#### 5.1 Availability

- ✅ 99% uptime
- ✅ Graceful degradation
- ✅ Error handling & fallbacks
- ✅ Offline support (basic features)

#### 5.2 Error Handling

- ✅ User-friendly error messages
- ✅ Retry mechanisms
- ✅ Error logging (Firebase Crashlytics)
- ✅ Network error handling

#### 5.3 Data Integrity

- ✅ Transaction support
- ✅ Data validation
- ✅ Backup strategy
- ✅ Version control

---

### 6. Maintainability Requirements

#### 6.1 Code Quality

- ✅ Clean Architecture pattern
- ✅ SOLID principles
- ✅ Code comments & documentation
- ✅ Consistent naming conventions
- ✅ Linting (flutter_lints)

#### 6.2 Testing

- ✅ Unit tests (60%+ coverage)
- ✅ Widget tests
- ✅ Integration tests
- ✅ E2E tests
- ✅ Manual testing checklist

#### 6.3 Documentation

- ✅ README.md
- ✅ API documentation
- ✅ Code documentation
- ✅ User manual
- ✅ Deployment guide

---

## 🛠️ CÔNG NGHỆ & THƯ VIỆN

### Core Framework

```yaml
dependencies:
  flutter: ^3.9.2
  dart: ^3.9.2
```

### State Management

```yaml
provider: ^6.1.1 # Hoặc
flutter_bloc: ^8.1.3 # Hoặc
riverpod: ^2.4.9 # Chọn 1 trong 3
```

### Firebase Integration

```yaml
firebase_core: ^2.24.2
firebase_auth: ^4.16.0
cloud_firestore: ^4.14.0
firebase_storage: ^11.6.0
firebase_analytics: ^10.8.0
firebase_crashlytics: ^3.4.9
```

### UI/UX

```yaml
google_fonts: ^6.1.0
flutter_svg: ^2.0.9
cached_network_image: ^3.3.1
shimmer: ^3.0.0
flutter_rating_bar: ^4.0.1
lottie: ^3.0.0 # Animations
animations: ^2.0.11
```

### Video Player

```yaml
video_player: ^2.8.2
chewie: ^1.7.5 # Video player UI
better_player: ^0.0.83 # Alternative
wakelock: ^0.6.2 # Keep screen on
```

### Navigation

```yaml
go_router: ^13.0.1
```

### Networking & APIs

```yaml
http: ^1.2.0
dio: ^5.4.0 # Alternative to http
```

### Local Storage

```yaml
shared_preferences: ^2.2.2
hive: ^2.2.3
hive_flutter: ^1.1.0
```

### Utilities

```yaml
intl: ^0.19.0 # Internationalization & date formatting
timeago: ^3.6.0 # Time formatting
url_launcher: ^6.2.4 # Open URLs
share_plus: ^7.2.1 # Share functionality
image_picker: ^1.0.7 # Pick images
file_picker: ^6.1.1 # Pick files
path_provider: ^2.1.2 # Get paths
permission_handler: ^11.2.0
```

### Text-to-Speech

```yaml
flutter_tts: ^4.0.2
```

### Analytics & Monitoring

```yaml
firebase_analytics: ^10.8.0
firebase_crashlytics: ^3.4.9
```

### Development Tools

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.8
  mockito: ^5.4.4 # Mocking for tests
  integration_test:
    sdk: flutter
```

---

## 📱 PLATFORM-SPECIFIC CONFIGURATION

### Android (android/app/build.gradle)

```gradle
android {
    compileSdkVersion 34
    minSdkVersion 24
    targetSdkVersion 34

    defaultConfig {
        multiDexEnabled true
    }
}
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>NSCameraUsageDescription</key>
<string>Upload profile picture</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Select profile picture</string>
```

### Web (web/index.html)

```html
<!-- Firebase SDK -->
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>
```

---

## 🔌 EXTERNAL APIs

### 1. Dictionary API

**Option 1: Free Dictionary API**

- URL: https://dictionaryapi.dev/
- Free, no API key required
- Rate limit: ~450 requests/day per IP

**Option 2: Oxford Dictionary API**

- URL: https://developer.oxforddictionaries.com/
- Requires API key
- Free tier: 3000 requests/month

### 2. TMDB API (Optional - for movie metadata)

- URL: https://www.themoviedb.org/documentation/api
- Free API key
- Rate limit: 40 requests/10 seconds

---

## 📊 PERFORMANCE METRICS

### Target Metrics

- First Contentful Paint: < 1.8s
- Speed Index: < 3.4s
- Time to Interactive: < 3.8s
- Total Blocking Time: < 200ms
- Lighthouse Score: > 90

---

## 🚀 DEPLOYMENT

### Web Deployment

```bash
flutter build web --release
firebase deploy --only hosting
```

### Android Deployment

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS Deployment

```bash
flutter build ios --release
```

---

## 📝 TESTING REQUIREMENTS

### Test Coverage Goals

- Unit Tests: 70%+
- Widget Tests: 60%+
- Integration Tests: Main user flows

### Testing Checklist

- [ ] User registration & login
- [ ] Video playback & subtitle sync
- [ ] Dictionary lookup & vocabulary save
- [ ] Comment & rating
- [ ] Watchlist & history
- [ ] Admin CRUD operations
- [ ] Responsive layouts
- [ ] Performance under load

---

## 🔐 FIREBASE CONFIGURATION

### Firebase Projects

- Development: movie-learning-dev
- Production: movie-learning-prod

### Firebase Services

- ✅ Authentication (Email, Google)
- ✅ Firestore Database
- ✅ Storage (videos, images)
- ✅ Hosting (web app)
- ✅ Analytics
- ✅ Crashlytics
- ✅ Cloud Functions (optional)

---

**Tài liệu này là reference chính cho development. Update khi có thay đổi yêu cầu.**
