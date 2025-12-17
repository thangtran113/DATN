# ✅ CHECKLIST TUẦN 1 - QUICK REFERENCE

## 🎯 Mục tiêu: Setup Project & Firebase

### ✅ HOÀN THÀNH

- [x] Tạo Flutter project structure
- [x] Thêm dependencies vào pubspec.yaml
- [x] Cài đặt packages (flutter pub get)
- [x] Tạo constants files (colors, strings, constants)
- [x] Tạo theme file (dark theme)
- [x] Tạo utility files (validators, date formatter)
- [x] Update main.dart với splash screen
- [x] Tạo tài liệu hướng dẫn

### 🔄 ĐANG LÀM

- [ ] Chạy app lần đầu (flutter run)
- [ ] Tạo Firebase project
- [ ] Setup Firebase CLI

### ⏳ SẮP LÀM

- [ ] Configure FlutterFire
- [ ] Enable Firebase services
- [ ] Deploy security rules
- [ ] Test Firebase connection

---

## 📝 CÁC BƯỚC TIẾP THEO

### 1. Test App (ĐANG LÀM)

```bash
flutter run -d chrome
```

**Kỳ vọng:** App mở trên Chrome với splash screen hiển thị hướng dẫn setup Firebase

### 2. Tạo Firebase Project

1. Vào: https://console.firebase.google.com/
2. Click "Add project"
3. Tên: `movie-learning-app-dev`
4. Tắt Google Analytics
5. Click "Create project"

### 3. Cài Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 4. Cài FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 5. Configure Firebase

```bash
flutterfire configure
```

- Chọn project: `movie-learning-app-dev`
- Platforms: android, ios, web
- Package: `com.example.movie_learning_app`

### 6. Enable Firebase Services

**Authentication:**

- Firebase Console → Authentication → Get started
- Enable Email/Password
- Enable Google Sign-In

**Firestore:**

- Firestore Database → Create database
- Production mode
- Location: asia-southeast1

**Storage:**

- Storage → Get started
- Production mode
- Location: asia-southeast1

### 7. Deploy Security Rules

Tạo `firestore.rules` và `storage.rules` (xem FIREBASE_SETUP.md)

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### 8. Update main.dart

Uncomment Firebase initialization:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 9. Test lại App

```bash
flutter run -d chrome
```

---

## 📚 TÀI LIỆU THAM KHẢO

- **FIREBASE_SETUP.md** - Hướng dẫn chi tiết từng bước setup Firebase
- **WEEK1_GUIDE.md** - Kế hoạch chi tiết tuần 1
- **DEVELOPMENT_PLAN.md** - Kế hoạch tổng thể 2 tháng
- **DATABASE_DESIGN.md** - Thiết kế database Firestore
- **TECHNICAL_REQUIREMENTS.md** - Yêu cầu kỹ thuật

---

## ⏰ TIMELINE DỰ KIẾN

**Hôm nay (Ngày 1):**

- ✅ Setup project (XONG)
- 🔄 Test app (ĐANG LÀM)
- ⏳ Tạo Firebase project (30 phút)
- ⏳ Cài Firebase CLI (15 phút)
- ⏳ Configure FlutterFire (15 phút)

**Ngày mai (Ngày 2):**

- Enable Firebase services (30 phút)
- Deploy security rules (15 phút)
- Test Firebase connection (30 phút)
- Tạo test data trong Firestore (30 phút)

**Ngày 3-4:**

- Thiết kế wireframe UI
- Vẽ sơ đồ use case
- Finalize database schema

**Ngày 5-7:**

- Học về Firebase Authentication
- Học về Firestore queries
- Học về Flutter state management (Provider)

---

## 🎯 KẾT QUẢ MONG ĐỢI CUỐI TUẦN 1

✅ App chạy được trên Chrome/Android/iOS  
✅ Firebase project đã setup đầy đủ  
✅ Firebase integrated vào Flutter app  
✅ Firestore và Storage có basic rules  
✅ Hiểu rõ cấu trúc project và database  
✅ Sẵn sàng bắt đầu code Authentication (Tuần 2)

---

## 💡 TIPS

1. **Làm từng bước một**, không vội vàng
2. **Test sau mỗi bước** để phát hiện lỗi sớm
3. **Đọc error messages** cẩn thận
4. **Google search** khi gặp lỗi (thường có người gặp rồi)
5. **Commit code thường xuyên** với Git

---

## 🐛 COMMON ISSUES

| Lỗi                           | Giải pháp                              |
| ----------------------------- | -------------------------------------- |
| Dependencies conflict         | `flutter pub upgrade --major-versions` |
| Firebase not initialized      | Check `firebase_options.dart` exists   |
| FlutterFire command not found | Add pub cache to PATH                  |
| Build failed on Android       | Check minSdkVersion >= 21              |
| Chrome not launching          | `flutter devices` để check             |

---

## 📞 HỖ TRỢ

Nếu gặp khó khăn:

1. Check error trong terminal
2. Search trên Stack Overflow
3. Đọc Firebase docs
4. Ask ChatGPT/Claude với error log

---

## 🚀 READY FOR TUẦN 2?

Sau khi hoàn thành checklist này, bạn sẽ:

- Implement Login screen
- Implement Register screen
- Setup GoRouter navigation
- Create reusable widgets

**Let's go! 💪**
