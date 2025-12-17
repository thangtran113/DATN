# Hướng dẫn Đăng nhập bằng Username

## Tổng quan thay đổi

Hệ thống authentication đã được cập nhật từ đăng nhập bằng email sang đăng nhập bằng **username**.

## Các thay đổi chính

### 1. User Entity (`lib/domain/entities/user.dart`)

- **Thêm field mới**: `username` (bắt buộc)
- Username được lưu ở dạng chữ thường (`toLowerCase()`)
- Format username: chỉ chứa chữ cái, số và dấu gạch dưới (\_)

```dart
class User {
  final String id;
  final String username;  // ← MỚI
  final String email;
  // ... các field khác
}
```

### 2. Auth Repository (`lib/data/repositories/auth_repository.dart`)

#### Phương thức mới:

- **`isUsernameAvailable(String username)`**: Kiểm tra username có khả dụng không
- **`signInWithUsername({username, password})`**: Đăng nhập bằng username
- **`_getEmailFromUsername(String username)`**: Lấy email từ username

#### Phương thức cập nhật:

- **`registerWithEmailAndPassword()`**: Bây giờ yêu cầu tham số `username`
- Tự động sinh username từ email cho Google Sign In (phần trước @)
- Kiểm tra username trùng lặp khi đăng ký

### 3. Login Screen (`lib/presentation/screens/auth/login_screen.dart`)

#### Thay đổi:

- ~~Email field~~ → **Username field**
- Validator: kiểm tra username tối thiểu 3 ký tự
- Icon: `person_outline` thay vì `email_outlined`
- Label: "Username" thay vì "Email"

```dart
// Trước
_emailController
signInWithEmailAndPassword(email: ...)

// Sau
_usernameController
signInWithUsername(username: ...)
```

### 4. Register Screen (`lib/presentation/screens/auth/register_screen.dart`)

#### Thêm:

- **Username field** mới (giữa Name và Email)
- Real-time validation username
- Kiểm tra username đã tồn tại khi user rời khỏi field
- Icon check màu xanh khi username hợp lệ

#### Validation rules:

- Tối thiểu 3 ký tự
- Chỉ chứa: chữ cái (a-z, A-Z), số (0-9), dấu gạch dưới (\_)
- Không trùng lặp trong database

```dart
RegExp(r'^[a-zA-Z0-9_]+$')
```

## Firestore Database Structure

### Users Collection

```json
{
  "id": "firebase_uid",
  "username": "john_doe", // ← MỚI (lowercase)
  "email": "john@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "lastLoginAt": "2024-01-20T15:45:00.000Z",
  "favoriteMovieIds": [],
  "watchlistIds": [],
  "preferences": {}
}
```

### Cần tạo index mới (quan trọng!)

Để tìm kiếm username nhanh, cần tạo composite index trong Firestore:

1. Vào Firebase Console → Firestore Database → Indexes
2. Tạo index mới:
   - **Collection**: `users`
   - **Field**: `username` (Ascending)
   - **Query scope**: Collection

## Luồng đăng nhập mới

### Register Flow:

1. User nhập: Name, **Username**, Email, Password
2. Khi rời khỏi username field → kiểm tra trùng lặp
3. Submit form → validate tất cả
4. Kiểm tra username available
5. Tạo tài khoản Firebase Auth (dùng email)
6. Lưu username vào Firestore (lowercase)
7. Redirect về Login

### Login Flow:

1. User nhập: **Username**, Password
2. Submit → Tìm email từ username trong Firestore
3. Dùng email để authenticate với Firebase Auth
4. Update lastLoginAt
5. Load user data → Redirect về Home

### Google Sign In Flow:

1. User chọn Google account
2. Tự động tạo username từ email (phần trước @)
3. Ví dụ: `john.doe@gmail.com` → username: `john.doe`
4. Lưu vào Firestore với username auto-generated

## Lưu ý quan trọng

### ⚠️ Dữ liệu cũ (User đã tồn tại)

Các user đã đăng ký trước khi có username field sẽ KHÔNG có username. Cần migration script:

```dart
// Script migration (chạy một lần)
Future<void> migrateExistingUsers() async {
  final users = await FirebaseFirestore.instance.collection('users').get();

  for (var doc in users.docs) {
    if (!doc.data().containsKey('username')) {
      // Tạo username từ email
      final email = doc.data()['email'] as String;
      final username = email.split('@')[0].toLowerCase();

      // Update document
      await doc.reference.update({'username': username});
    }
  }
}
```

### ✅ Testing

Để test hệ thống mới:

1. **Đăng ký tài khoản mới**: Test username validation
2. **Đăng nhập bằng username**: Kiểm tra lookup hoạt động
3. **Username trùng lặp**: Thử đăng ký username đã tồn tại
4. **Google Sign In**: Kiểm tra auto-generate username

### 🔒 Security

- Username được lưu lowercase để tránh trùng lặp (john_doe = John_Doe)
- Firebase Auth vẫn dùng email để authentication (an toàn)
- Password vẫn được mã hóa bởi Firebase Auth

## Tương thích ngược

Hệ thống vẫn giữ method `signInWithEmailAndPassword()` để tương thích ngược. Nhưng:

- Login UI chỉ hiển thị username field
- User cũ cần migration để có username

## Các bước tiếp theo

1. ✅ Migration script cho user cũ (nếu có)
2. ✅ Test toàn bộ luồng register/login
3. ✅ Tạo Firestore index cho username
4. ⏳ Cập nhật profile screen để hiển thị username
5. ⏳ Cho phép user đổi username (optional)

---

## Code Examples

### Đăng ký user mới:

```dart
await authRepo.registerWithEmailAndPassword(
  username: 'john_doe',        // ← MỚI
  email: 'john@example.com',
  password: 'secure123',
  displayName: 'John Doe',
);
```

### Đăng nhập:

```dart
await authRepo.signInWithUsername(
  username: 'john_doe',        // ← Username thay vì email
  password: 'secure123',
);
```

### Kiểm tra username:

```dart
final isAvailable = await authRepo.isUsernameAvailable('new_username');
if (isAvailable) {
  // Username khả dụng
} else {
  // Username đã tồn tại
}
```
