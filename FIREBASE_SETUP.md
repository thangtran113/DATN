# 🚀 HƯỚNG DẪN SETUP FIREBASE - BƯỚC ĐẦU TIÊN

## Bạn đang ở bước nào?

✅ **HOÀN THÀNH**: Cài đặt Flutter dependencies (flutter pub get)  
🔄 **ĐANG LÀM**: Setup Firebase project

---

## 📋 BƯỚC 1: TẠO FIREBASE PROJECT

### 1.1. Truy cập Firebase Console

1. Mở trình duyệt và vào: https://console.firebase.google.com/
2. Đăng nhập với tài khoản Google của bạn

### 1.2. Tạo project mới

1. Click nút **"Add project"** hoặc **"Create a project"**
2. Nhập tên project: `movie-learning-app-dev`
3. Click **"Continue"**
4. **Google Analytics**: Tắt (có thể bật sau) - Bỏ check "Enable Google Analytics"
5. Click **"Create project"**
6. Đợi khoảng 30 giây để Firebase tạo project
7. Click **"Continue"** khi hoàn thành

🎉 **Xong!** Bạn đã có Firebase project.

---

## 📋 BƯỚC 2: CÀI ĐẶT FIREBASE CLI

### 2.1. Cài đặt Node.js (nếu chưa có)

- Tải tại: https://nodejs.org/ (chọn phiên bản LTS)
- Sau khi cài xong, mở terminal mới

### 2.2. Cài đặt Firebase Tools

Mở terminal và chạy:

```bash
npm install -g firebase-tools
```

**Verify cài đặt:**

```bash
firebase --version
```

### 2.3. Đăng nhập Firebase

```bash
firebase login
```

Trình duyệt sẽ mở, chọn tài khoản Google và cho phép quyền truy cập.

---

## 📋 BƯỚC 3: CÀI ĐẶT FLUTTERFIRE CLI

### 3.1. Cài đặt FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 3.2. Thêm vào PATH (nếu cần)

**Windows:**

- FlutterFire CLI được cài tại: `%USERPROFILE%\AppData\Local\Pub\Cache\bin`
- Thêm path này vào Environment Variables nếu command không chạy

**Mac/Linux:**

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

**Verify:**

```bash
flutterfire --version
```

---

## 📋 BƯỚC 4: CÁU HÌNH FIREBASE CHO FLUTTER

### 4.1. Chạy FlutterFire Configure

Trong terminal, tại thư mục project:

```bash
cd c:\Users\hotra\OneDrive\Desktop\DATN\movie_learning_app
flutterfire configure
```

### 4.2. Trả lời các câu hỏi:

**Select a Firebase project:**

- Chọn `movie-learning-app-dev` (project vừa tạo)

**Which platforms should your configuration support?**

- Chọn: `android`, `ios`, `web` (dùng space để chọn, enter để confirm)

**What package name do you want to use?**

- Nhập: `com.example.movie_learning_app`
- Hoặc nhấn Enter để dùng default

### 4.3. Files được tạo:

✅ `lib/firebase_options.dart` - Firebase configuration  
✅ `android/app/google-services.json` - Android config  
✅ `ios/Runner/GoogleService-Info.plist` - iOS config  
✅ `.firebaserc` - Firebase project mapping

---

## 📋 BƯỚC 5: ENABLE FIREBASE SERVICES

### 5.1. Authentication

1. Trong Firebase Console, vào sidebar → **"Build"** → **"Authentication"**
2. Click **"Get started"**
3. Trong tab **"Sign-in method"**:

   **Email/Password:**

   - Click **"Email/Password"**
   - Toggle **"Enable"**
   - Click **"Save"**

   **Google Sign-In:**

   - Click **"Google"**
   - Toggle **"Enable"**
   - Nhập email support: `your.email@example.com`
   - Click **"Save"**

### 5.2. Firestore Database

1. Vào sidebar → **"Build"** → **"Firestore Database"**
2. Click **"Create database"**
3. Chọn **"Start in production mode"** (sẽ config rules sau)
4. **Location**: Chọn `asia-southeast1 (Singapore)` (gần Việt Nam nhất)
5. Click **"Enable"**
6. Đợi vài phút để Firestore được tạo

### 5.3. Storage

1. Vào sidebar → **"Build"** → **"Storage"**
2. Click **"Get started"**
3. Chọn **"Start in production mode"**
4. **Location**: `asia-southeast1`
5. Click **"Done"**

### 5.4. Hosting (cho Web)

1. Vào sidebar → **"Build"** → **"Hosting"**
2. Click **"Get started"**
3. Follow instructions (hoặc skip, sẽ config sau)

---

## 📋 BƯỚC 6: TẠO FIRESTORE SECURITY RULES

### 6.1. Tạo file firestore.rules

Tại thư mục root của project, tạo file `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isAdmin() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Movies collection
    match /movies/{movieId} {
      allow read: if true;  // Public read
      allow write: if isAdmin();
    }

    // Comments collection
    match /comments/{commentId} {
      allow read: if true;
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(resource.data.userId) || isAdmin();
    }

    // Vocabulary collection
    match /vocabulary/{vocabId} {
      allow read, write: if isOwner(resource.data.userId);
    }

    // History collection
    match /history/{historyId} {
      allow read, write: if isOwner(resource.data.userId);
    }

    // Watchlist collection
    match /watchlist/{watchlistId} {
      allow read, write: if isOwner(resource.data.userId);
    }

    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 6.2. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### 6.3. Tạo file storage.rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Movies - anyone can read, only admin can write
    match /movies/{movieId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null &&
                     firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    // User avatars
    match /users/{userId}/avatar.jpg {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### 6.4. Deploy Storage Rules

```bash
firebase deploy --only storage:rules
```

---

## 📋 BƯỚC 7: UPDATE MAIN.DART

### 7.1. Uncomment Firebase initialization

Mở `lib/main.dart` và uncomment:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncomment 3 dòng này:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

---

## 📋 BƯỚC 8: TEST APP

### 8.1. Run app

```bash
flutter run -d chrome
```

hoặc

```bash
flutter run
```

### 8.2. Kiểm tra

✅ App chạy không lỗi  
✅ Không có error về Firebase  
✅ Console log hiển thị "Firebase initialized"

---

## 🎉 HOÀN THÀNH!

Nếu tất cả chạy OK, bạn đã hoàn thành setup cơ bản!

### ✅ Checklist cuối:

- [x] Flutter dependencies installed
- [ ] Firebase project created
- [ ] Firebase CLI installed
- [ ] FlutterFire configured
- [ ] Authentication enabled
- [ ] Firestore created
- [ ] Storage enabled
- [ ] Security rules deployed
- [ ] App runs without errors

---

## 🐛 Troubleshooting

### Lỗi: "Firebase not initialized"

**Giải pháp:**

1. Check `firebase_options.dart` đã tồn tại
2. Check đã uncomment `Firebase.initializeApp()`
3. Chạy `flutter clean && flutter pub get`

### Lỗi: "flutterfire: command not found"

**Giải pháp:**

1. Thêm pub cache vào PATH
2. Restart terminal
3. Chạy lại: `dart pub global activate flutterfire_cli`

### Lỗi: "google-services.json not found"

**Giải pháp:**

1. Chạy lại: `flutterfire configure`
2. Check file tồn tại trong `android/app/`

### Lỗi khi deploy rules

**Giải pháp:**

1. Check `firebase login` đã thành công
2. Check `firebase use movie-learning-app-dev`
3. Check syntax của rules file

---

## 📞 Cần trợ giúp?

- Firebase Docs: https://firebase.google.com/docs
- FlutterFire Docs: https://firebase.flutter.dev/
- Stack Overflow: [firebase] [flutter] tags

---

## 🚀 BƯỚC TIẾP THEO (Tuần 2-3)

Sau khi hoàn thành setup Firebase, bạn sẽ:

1. **Implement Authentication Screens**

   - Login screen
   - Register screen
   - Forgot password screen

2. **Setup Navigation**

   - GoRouter configuration
   - Route definitions

3. **Create Base UI Components**
   - Custom buttons
   - Text fields
   - Loading widgets

👉 Xem chi tiết trong `WEEK2_GUIDE.md` (sẽ tạo sau)

---

**Happy Coding! 🎬**
