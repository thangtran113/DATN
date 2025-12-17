# HƯỚNG DẪN BẮT ĐẦU - TUẦN 1

## 🎯 Mục tiêu Tuần 1

1. ✅ Phân tích yêu cầu chi tiết
2. ✅ Thiết kế kiến trúc hệ thống
3. ✅ Setup project cơ bản
4. ⏳ Cấu hình Firebase

## 📋 Checklist

### Ngày 1-2: Phân tích yêu cầu

- [x] Đọc và phân tích tài liệu yêu cầu
- [x] Vẽ sơ đồ use case
- [ ] Xác định actors: User, Admin
- [ ] List ra tất cả use cases
- [ ] Prioritize features (Must-have, Should-have, Nice-to-have)

### Ngày 3-4: Thiết kế hệ thống

- [x] Thiết kế kiến trúc tổng thể (3-layer: Presentation, Domain, Data)
- [x] Thiết kế database schema (Firestore collections)
- [x] Thiết kế API integration points
- [ ] Vẽ sơ đồ luồng dữ liệu
- [ ] Thiết kế wireframe cho các màn hình chính

### Ngày 5-6: Setup Project

- [x] Tạo Flutter project
- [x] Cấu trúc thư mục theo Clean Architecture
- [x] Thêm dependencies vào pubspec.yaml
- [x] Tạo constants files (colors, strings, etc.)
- [x] Tạo theme file
- [x] Tạo utility files
- [ ] Setup linting rules

### Ngày 7: Cấu hình Firebase

- [ ] Tạo Firebase project
- [ ] Thêm Firebase vào Flutter app (Android, iOS, Web)
- [ ] Enable Authentication (Email/Password, Google)
- [ ] Tạo Firestore Database
- [ ] Setup Storage
- [ ] Setup Hosting
- [ ] Configure Security Rules

---

## 🔧 Các bước thực hiện chi tiết

### BƯỚC 1: Cài đặt dependencies

Chạy lệnh sau trong terminal:

```bash
cd c:\Users\hotra\OneDrive\Desktop\DATN\movie_learning_app
flutter pub get
```

**Expected Output:**

```
Running "flutter pub get" in movie_learning_app...
Resolving dependencies...
+ cached_network_image 3.3.1
+ chewie 1.7.5
+ cloud_firestore 4.14.0
...
Got dependencies!
```

**Troubleshooting:**

- Nếu gặp lỗi version conflict, check `pubspec.yaml`
- Đảm bảo Flutter version >= 3.9.2 bằng lệnh `flutter --version`
- Chạy `flutter clean` rồi `flutter pub get` lại

---

### BƯỚC 2: Setup Firebase Project

#### 2.1. Tạo Firebase Project

1. Truy cập: https://console.firebase.google.com/
2. Click "Add project"
3. Nhập tên: `movie-learning-app-dev` (cho development)
4. Disable Google Analytics (có thể enable sau)
5. Click "Create project"

#### 2.2. Cài đặt Firebase CLI

**Windows:**

```bash
npm install -g firebase-tools
```

**Mac/Linux:**

```bash
curl -sL https://firebase.tools | bash
```

**Login:**

```bash
firebase login
```

#### 2.3. Cấu hình FlutterFire CLI

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

Chọn:

- Project: `movie-learning-app-dev`
- Platforms: Android, iOS, Web
- Package name: `com.example.movie_learning_app`

**Files được tạo:**

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

#### 2.4. Enable Firebase Services

**Authentication:**

1. Vào Firebase Console → Authentication
2. Click "Get started"
3. Enable "Email/Password"
4. Enable "Google"

**Firestore Database:**

1. Vào Firebase Console → Firestore Database
2. Click "Create database"
3. Chọn "Start in production mode"
4. Location: asia-southeast1 (Singapore)

**Storage:**

1. Vào Firebase Console → Storage
2. Click "Get started"
3. Chọn "Start in production mode"
4. Location: asia-southeast1

**Hosting:**

1. Vào Firebase Console → Hosting
2. Click "Get started"
3. Follow instructions

---

### BƯỚC 3: Cấu hình Security Rules

#### Firestore Rules (`firestore.rules`)

Tạo file `firestore.rules` trong root project:

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
      allow read: if true;
      allow write: if isAdmin();
    }

    // Default deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Deploy rules:

```bash
firebase deploy --only firestore:rules
```

#### Storage Rules (`storage.rules`)

Tạo file `storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Movies can be read by anyone
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

Deploy rules:

```bash
firebase deploy --only storage:rules
```

---

### BƯỚC 4: Initialize Firebase trong App

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Movie Learning App\nFirebase Initialized!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
```

---

### BƯỚC 5: Test Firebase Connection

Tạo file test: `lib/test_firebase.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebaseScreen extends StatelessWidget {
  const TestFirebaseScreen({super.key});

  Future<void> testFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Test write
    await firestore.collection('test').doc('test1').set({
      'message': 'Hello Firebase!',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Test read
    final doc = await firestore.collection('test').doc('test1').get();
    print('Firestore data: ${doc.data()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Firebase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: testFirestore,
              child: const Text('Test Firestore'),
            ),
            const SizedBox(height: 20),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Logged in as: ${snapshot.data!.email}');
                }
                return const Text('Not logged in');
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

Run app và test:

```bash
flutter run -d chrome
```

---

## 📝 Deliverables Tuần 1

Sau khi hoàn thành tuần 1, bạn cần có:

1. ✅ **Document phân tích yêu cầu**

   - Use case diagram
   - Feature list với priority
   - User stories

2. ✅ **Thiết kế hệ thống**

   - Sơ đồ kiến trúc (3-layer)
   - Database schema (Firestore collections)
   - Wireframes (10+ màn hình chính)

3. ✅ **Flutter project hoàn chỉnh**

   - Cấu trúc thư mục đúng chuẩn
   - Dependencies đã cài đặt
   - Theme & constants setup

4. ✅ **Firebase project cấu hình xong**
   - Authentication enabled
   - Firestore database created
   - Storage setup
   - Security rules deployed
   - Firebase connected successfully

---

## 🚀 Bước tiếp theo (Tuần 2)

Sau khi hoàn thành setup, tuần 2 sẽ bắt đầu implement:

1. **Authentication screens**

   - Login screen
   - Register screen
   - Forgot password

2. **Navigation setup**

   - GoRouter configuration
   - Bottom navigation bar

3. **Basic UI components**
   - Custom buttons
   - Text fields
   - Loading indicators

---

## ❓ FAQ & Troubleshooting

### Q: Flutter pub get failed với version conflict?

**A:** Chạy `flutter pub upgrade --major-versions` để upgrade tất cả packages.

### Q: Firebase initialization failed?

**A:**

1. Check `firebase_options.dart` đã được tạo chưa
2. Check `google-services.json` (Android) và `GoogleService-Info.plist` (iOS) đã được thêm chưa
3. Chạy `flutterfire configure` lại

### Q: Firestore rules deployment failed?

**A:**

1. Check Firebase CLI đã login chưa: `firebase login`
2. Check project đã được set: `firebase use movie-learning-app-dev`
3. Check syntax của rules file

### Q: Build failed trên Android?

**A:**

1. Check `minSdkVersion` trong `android/app/build.gradle` >= 21
2. Check `multiDexEnabled true` đã được thêm chưa
3. Clean build: `flutter clean && flutter pub get`

---

## 📞 Support

Nếu gặp khó khăn, check:

1. Flutter documentation: https://docs.flutter.dev
2. Firebase documentation: https://firebase.google.com/docs
3. Stack Overflow với tag [flutter] [firebase]

---

**Good luck với tuần 1! 🚀**
