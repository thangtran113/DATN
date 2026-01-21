# 🎬 CineChill - Ứng Dụng Học Tiếng Anh Qua Phim

## 📋 Giới Thiệu

**CineChill** là ứng dụng xem phim kết hợp học tiếng Anh, cho phép người dùng:

- Xem phim với **phụ đề song ngữ** (Anh - Việt)
- **Tra từ điển** trực tiếp khi xem phim
- **Lưu từ vựng** và ôn tập bằng Flashcard, Quiz
- Theo dõi **tiến độ học tập**

---

## 🚀 Tính Năng Chính

### 👤 Người Dùng (User)

| Tính năng                  | Mô tả                                  |
| -------------------------- | -------------------------------------- |
| 🔐 **Đăng ký / Đăng nhập** | Email/Password, Google Sign-In         |
| 🎬 **Xem phim**            | Stream video với phụ đề song ngữ       |
| 📖 **Tra từ điển**         | Click vào từ trong phụ đề để tra nghĩa |
| 💾 **Lưu từ vựng**         | Lưu từ mới vào danh sách cá nhân       |
| 🎴 **Flashcard**           | Ôn tập từ vựng bằng thẻ ghi nhớ        |
| 📝 **Quiz**                | Kiểm tra từ vựng đã học                |
| ❤️ **Yêu thích**           | Thêm phim vào danh sách yêu thích      |
| 💬 **Bình luận**           | Bình luận và tương tác dưới mỗi phim   |
| 📊 **Thống kê**            | Xem tiến độ học tập cá nhân            |

### 🛡️ Quản Trị Viên (Admin)

| Tính năng                 | Mô tả                       |
| ------------------------- | --------------------------- |
| 🎬 **Quản lý phim**       | Thêm, sửa, xóa phim         |
| 👥 **Quản lý người dùng** | Xem, ban/unban user         |
| 📊 **Dashboard**          | Thống kê tổng quan hệ thống |

---

## 🛠️ Công Nghệ Sử Dụng

| Công nghệ            | Mục đích                      |
| -------------------- | ----------------------------- |
| **Flutter 3.x**      | Framework phát triển ứng dụng |
| **Dart**             | Ngôn ngữ lập trình            |
| **Firebase Auth**    | Xác thực người dùng           |
| **Cloud Firestore**  | Cơ sở dữ liệu NoSQL           |
| **Firebase Storage** | Lưu trữ video, phụ đề         |
| **Provider**         | Quản lý state                 |
| **GoRouter**         | Điều hướng                    |
| **Video Player**     | Phát video                    |

---

## 📁 Cấu Trúc Thư Mục

```
lib/
├── core/                    # Cấu hình chung
│   ├── constants/           # Màu sắc, chuỗi, kích thước
│   ├── theme/               # Theme ứng dụng
│   ├── routes/              # Định nghĩa routes
│   └── utils/               # Validators
│
├── data/                    # Tầng dữ liệu
│   ├── repositories/        # Giao tiếp Firebase
│   │   ├── auth_repository.dart
│   │   ├── movie_repository.dart
│   │   ├── comment_repository.dart
│   │   ├── subtitle_repository.dart
│   │   └── vocabulary_repository.dart
│   └── services/            # API bên ngoài
│       ├── dictionary_service.dart
│       └── tmdb_service.dart
│
├── domain/                  # Tầng nghiệp vụ
│   └── entities/            # Các đối tượng
│       ├── user.dart
│       ├── movie.dart
│       ├── subtitle.dart
│       ├── comment.dart
│       └── saved_word.dart
│
├── presentation/            # Tầng giao diện
│   ├── providers/           # Quản lý state
│   ├── screens/             # Các màn hình
│   │   ├── auth/            # Đăng nhập, đăng ký
│   │   ├── movie/           # Danh sách, chi tiết phim
│   │   ├── player/          # Trình phát video
│   │   ├── vocabulary/      # Từ vựng, flashcard, quiz
│   │   ├── profile/         # Trang cá nhân
│   │   └── admin/           # Trang quản trị
│   └── widgets/             # Components tái sử dụng
│
├── utils/                   # Tiện ích
│   └── srt_parser.dart      # Parse file phụ đề
│
├── firebase_options.dart    # Cấu hình Firebase
└── main.dart                # Entry point
```

### Các Bước Cài Đặt

#### 1. Clone Project

```bash
git clone https://github.com/thangtran113/DATN
cd CineChill
```

#### 2. Cài Đặt Dependencies

```bash
flutter pub get
```

#### 3. Chạy Ứng Dụng

```bash
# Chạy trên Chrome (Web)
flutter run -d chrome

# Hoặc chạy trên thiết bị khác
flutter run
```

## 🗄️ Cấu Trúc Database (Firestore)

### Collections

```
firestore/
├── users/                 # Thông tin người dùng
│   └── {userId}/
│       ├── id
│       ├── username
│       ├── email
│       ├── displayName
│       ├── isAdmin
│       ├── isBanned
│       └── createdAt
│
├── movies/                # Thông tin phim
│   └── {movieId}/
│       ├── id
│       ├── title
│       ├── description
│       ├── videoUrl
│       ├── posterUrl
│       ├── subtitles: { en: "url", vi: "url" }
│       ├── genres
│       ├── duration
│       └── year
│
├── comments/              # Bình luận
│   └── {commentId}/
│       ├── userId
│       ├── userName
│       ├── movieId
│       ├── text
│       ├── likedBy
│       └── createdAt
│
└── vocabulary/            # Từ vựng đã lưu
    └── {wordId}/
        ├── userId
        ├── word
        ├── definition
        ├── movieId
        └── savedAt
```
