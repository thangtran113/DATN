# Migration Script - Thêm Username cho User Cũ

## Vấn đề

User đã tồn tại (như `admin@gmail.com` - UID: `zwkJ3wAWT7dQBaS4ZSEwjtv0v8P2`) không có field `username`.

## Cách khắc phục

### Option 1: Sử dụng Firebase Console (Nhanh nhất)

1. Vào Firebase Console: https://console.firebase.google.com/project/cinechill-dev/firestore
2. Vào collection `users`
3. Tìm document với UID: `zwkJ3wAWT7dQBaS4ZSEwjtv0v8P2`
4. Click "Edit" (icon bút chì)
5. Thêm field mới:
   - **Field name**: `username`
   - **Type**: string
   - **Value**: `admin` (hoặc username bạn muốn)
6. Save

### Option 2: Chạy script migration trong code

Tạo file `lib/scripts/migrate_users.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> migrateUsersWithUsername() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('🔄 Starting user migration...');

  // Get all users
  final usersSnapshot = await firestore.collection('users').get();

  int migrated = 0;
  int skipped = 0;

  for (var doc in usersSnapshot.docs) {
    final data = doc.data();

    // Check if username exists
    if (data.containsKey('username')) {
      print('⏭️  Skipping ${doc.id} - already has username');
      skipped++;
      continue;
    }

    // Generate username from email
    final email = data['email'] as String;
    final username = email.split('@')[0].toLowerCase();

    // Update document
    await doc.reference.update({'username': username});

    print('✅ Migrated ${doc.id} - added username: $username');
    migrated++;
  }

  print('');
  print('📊 Migration completed:');
  print('   - Migrated: $migrated users');
  print('   - Skipped: $skipped users');
}

void main() async {
  await migrateUsersWithUsername();
}
```

Chạy script:

```bash
dart run lib/scripts/migrate_users.dart
```

### Option 3: Update thủ công qua REST API

Dùng Firebase REST API để update:

```bash
# Get your Firebase Web API Key từ Firebase Console
# Thay YOUR_WEB_API_KEY và YOUR_ID_TOKEN

curl -X PATCH \
  'https://firestore.googleapis.com/v1/projects/cinechill-dev/databases/(default)/documents/users/zwkJ3wAWT7dQBaS4ZSEwjtv0v8P2?updateMask.fieldPaths=username' \
  -H 'Authorization: Bearer YOUR_ID_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "fields": {
      "username": {
        "stringValue": "admin"
      }
    }
  }'
```

## Recommendation

**👉 Dùng Firebase Console (Option 1)** - Nhanh và đơn giản nhất!

Chỉ cần:

1. Mở Firebase Console
2. Vào Firestore → users → zwkJ3wAWT7dQBaS4ZSEwjtv0v8P2
3. Thêm field `username` = `admin`
4. Save
5. Refresh app và đăng nhập lại

## Sau khi migration

Test lại:

1. ✅ Đăng nhập bằng username: `admin`
2. ✅ Đăng ký user mới với username
3. ✅ Kiểm tra username trùng lặp

---

**Lưu ý**: Nếu có nhiều user cũ, nên dùng Option 2 (script) để tự động hóa.
