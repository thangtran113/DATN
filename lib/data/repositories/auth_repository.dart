import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// Repository xử lý xác thực người dùng
class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy stream trạng thái đăng nhập của user
  Stream<User?> get userStream {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final user = await _getUserFromFirestore(firebaseUser.uid);

        // Nếu tài khoản bị cấm, tự động đăng xuất
        if (user.isBanned) {
          await _firebaseAuth.signOut();
          return null;
        }

        return user;
      } catch (e) {
        // Nếu không lấy được user từ Firestore, đăng xuất
        await _firebaseAuth.signOut();
        return null;
      }
    });
  }

  /// Lấy user hiện tại
  Future<User?> get currentUser async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final user = await _getUserFromFirestore(firebaseUser.uid);

      // Nếu tài khoản bị banned, tự động đăng xuất
      if (user.isBanned) {
        await _firebaseAuth.signOut();
        return null;
      }

      return user;
    } catch (e) {
      // Nếu không lấy được user từ Firestore, đăng xuất
      await _firebaseAuth.signOut();
      return null;
    }
  }

  /// Kiểm tra username có khả dụng không
  Future<bool> isUsernameAvailable(String username) async {
    final docs = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return docs.docs.isEmpty;
  }

  /// Lấy email từ username
  Future<String?> _getEmailFromUsername(String username) async {
    final docs = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    if (docs.docs.isEmpty) return null;
    return docs.docs.first.data()['email'] as String?;
  }

  /// Đăng nhập bằng username và password
  Future<User> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      final email = await _getEmailFromUsername(username);
      if (email == null) throw Exception('Username not found');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw Exception('Đăng nhập thất bại');

      await _updateLastLoginTime(credential.user!.uid);
      final user = await _getUserFromFirestore(credential.user!.uid);

      // Kiểm tra tài khoản có bị banned không
      if (user.isBanned) {
        await _firebaseAuth.signOut();
        throw Exception(
          'Tài khoản của bạn đã bị cấm. Vui lòng liên hệ quản trị viên.',
        );
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng nhập bằng email và password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw Exception('Đăng nhập thất bại');

      await _updateLastLoginTime(credential.user!.uid);

      User user;
      try {
        user = await _getUserFromFirestore(credential.user!.uid);
      } catch (e) {
        // Tự động tạo tài liệu người dùng nếu chưa có
        user = User(
          id: credential.user!.uid,
          username: email.split('@')[0].toLowerCase(),
          email: email,
          displayName: credential.user!.displayName,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _createUserInFirestore(user);
      }

      // Kiểm tra tài khoản có bị banned không
      if (user.isBanned) {
        await _firebaseAuth.signOut();
        throw Exception('Tài khoản của bạn đã bị khóa');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Đăng ký tài khoản mới
  Future<User> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      print('🔵 Bắt đầu đăng ký...');
      print('  Tên người dùng: $username');
      print('  Email: $email');

      if (!await isUsernameAvailable(username)) {
        print('❌ Tên người dùng đã được sử dụng');
        throw Exception('Username đã được sử dụng');
      }

      print('✅ Tên người dùng có sẵn');
      print('🔵 Đang tạo người dùng Firebase Auth...');

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Người dùng Firebase Auth đã tạo: ${credential.user?.uid}');

      if (credential.user == null) {
        print('❌ Người dùng thông tin xác thực là null');
        throw Exception('Đăng ký thất bại');
      }

      if (displayName != null) {
        print('🔵 Đang cập nhật tên hiển thị...');
        await credential.user!.updateDisplayName(username);
        print('✅ Tên hiển thị đã cập nhật');
      }

      final user = User(
        id: credential.user!.uid,
        username: username.toLowerCase(),
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      print('🔵 Đang tạo người dùng trong Firestore...');
      print('  Dữ liệu người dùng: ${user.toJson()}');

      // SỬA LỐI QUAN TRỌNG: Đăng nhập lại để đảm bảo mã xác thực được gắn vào yêu cầu Firestore
      // createUserWithEmailAndPassword trên Web không tự động gắn mã thông báo
      print('🔵 Đang đăng nhập để gắn mã xác thực...');
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Đã đăng nhập, mã xác thực đã gắn');

      // Trì hoãn nhỏ để đảm bảo mã thông báo được truyền đi
      await Future.delayed(const Duration(milliseconds: 300));

      await _createUserInFirestore(user);
      print('✅ Người dùng đã tạo trong Firestore');

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Ngoại lệ chung: $e');
      if (e.toString().contains('Username')) rethrow;
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  /// Đăng nhập bằng Google (dùng Firebase signInWithPopup)
  Future<User> signInWithGoogle() async {
    try {
      // Tạo GoogleAuthProvider
      final googleProvider = firebase_auth.GoogleAuthProvider();

      // Thêm phạm vi
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Đặt tham số tùy chỉnh
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      // Đăng nhập bằng popup - Cảnh báo CORS không sao, đăng nhập vẫn hoạt động
      final userCredential = await _firebaseAuth.signInWithPopup(
        googleProvider,
      );

      if (userCredential.user == null) {
        throw Exception('Đăng nhập thất bại');
      }

      // Kiểm tra người dùng có tồn tại trong Firestore không
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      User user;
      if (!userDoc.exists) {
        // Tạo người dùng mới trong Firestore
        user = User(
          id: userCredential.user!.uid,
          username: userCredential.user!.email!.split('@')[0].toLowerCase(),
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _createUserInFirestore(user);
      } else {
        // Cập nhật thời gian đăng nhập cuối
        await _updateLastLoginTime(userCredential.user!.uid);
        user = await _getUserFromFirestore(userCredential.user!.uid);
      }

      // Kiểm tra tài khoản có bị banned không
      if (user.isBanned) {
        await _firebaseAuth.signOut();
        throw Exception('Tài khoản của bạn đã bị khóa');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user') {
        throw Exception('Đăng nhập bị hủy');
      } else if (e.code == 'popup-blocked') {
        throw Exception('Popup bị chặn bởi trình duyệt');
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi đăng nhập Google: $e');
    }
  }

  /// Đăng nhập ẩn danh (khách vãng lai)
  Future<User> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();

      if (userCredential.user == null) {
        throw Exception('Đăng nhập thất bại');
      }

      // Tạo hồ sơ người dùng cho khách vãng lai
      final anonymousUser = User(
        id: userCredential.user!.uid,
        username: 'guest_${userCredential.user!.uid.substring(0, 8)}',
        email: null,
        displayName: 'Khách vãng lai',
        photoUrl: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isAnonymous: true,
      );

      // Tạo tài liệu người dùng trong Firestore (tùy chọn - để theo dõi)
      try {
        await _createUserInFirestore(anonymousUser);
      } catch (e) {
        // Bỏ qua lỗi nếu không tạo được tài liệu
        print('Cảnh báo: Không thể tạo tài liệu người dùng ẩn danh: $e');
      }

      // Tài khoản ẩn danh không thể bị cấm (isBanned mặc định là false)

      return anonymousUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi đăng nhập khách: $e');
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Cập nhật thông tin user
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);

      // Cập nhật Firestore
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
    } catch (e) {
      throw Exception('Cập nhật thông tin thất bại: $e');
    }
  }

  /// Đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      // Xác thực lại người dùng với mật khẩu hiện tại
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Đổi mật khẩu
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu hiện tại không đúng');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu mới quá yếu');
      } else {
        throw Exception(_handleAuthException(e));
      }
    } catch (e) {
      throw Exception('Đổi mật khẩu thất bại: $e');
    }
  }

  /// Xóa tài khoản người dùng
  Future<void> deleteAccount({String? currentPassword}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      // Kiểm tra loại đăng nhập và xác thực lại nếu cần
      final providerData = user.providerData;
      if (providerData.isNotEmpty) {
        final providerId = providerData.first.providerId;

        // Nếu là Email/Mật khẩu, cần xác thực lại
        if (providerId == 'password') {
          if (currentPassword == null || currentPassword.isEmpty) {
            throw Exception('Vui lòng nhập mật khẩu để xác nhận');
          }
          final credential = firebase_auth.EmailAuthProvider.credential(
            email: user.email!,
            password: currentPassword,
          );
          await user.reauthenticateWithCredential(credential);
        }
        // Nếu là Đăng nhập Google, không cần xác thực lại với mật khẩu
      }

      // Xóa tất cả dữ liệu liên quan của người dùng
      final batch = _firestore.batch();

      // Xóa tài liệu người dùng
      batch.delete(_firestore.collection('users').doc(user.uid));

      // Xóa saved_words
      final savedWordsQuery = await _firestore
          .collection('saved_words')
          .where('userId', isEqualTo: user.uid)
          .get();
      for (final doc in savedWordsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Xóa danh sách xem
      final watchlistQuery = await _firestore
          .collection('watchlist')
          .where('userId', isEqualTo: user.uid)
          .get();
      for (final doc in watchlistQuery.docs) {
        batch.delete(doc.reference);
      }

      // Cam kết xóa hàng loạt
      await batch.commit();

      // Cập nhật bình luận: Không xóa, chỉ thay đổi userName và xóa userAvatar
      final commentsQuery = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: user.uid)
          .get();

      final commentBatch = _firestore.batch();
      for (final doc in commentsQuery.docs) {
        commentBatch.update(doc.reference, {
          'userName': 'Người dùng đã xóa tài khoản',
          'userAvatar': null,
        });
      }
      await commentBatch.commit();

      // Xóa tài khoản Firebase Auth (phải làm cuối cùng)
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không đúng');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Vui lòng đăng nhập lại để xóa tài khoản');
      } else {
        throw Exception(_handleAuthException(e));
      }
    } catch (e) {
      throw Exception('Xóa tài khoản thất bại: $e');
    }
  }

  /// Lấy thông tin user từ Firestore
  Future<User> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Không tìm thấy user');
    return User.fromJson(doc.data()!);
  }

  /// Tạo user mới trong Firestore
  Future<void> _createUserInFirestore(User user) async {
    try {
      print('🔵 Đang tạo tài liệu người dùng trong Firestore...');
      print('  Bộ sưu tập: users');
      print('  ID tài liệu: ${user.id}');
      print('  Dữ liệu: ${user.toJson()}');

      // Chỉ cần đặt tài liệu - quy tắc xác thực sẽ xác minh mã thông báo
      await _firestore.collection('users').doc(user.id).set(user.toJson());

      print('✅ Tài liệu người dùng đã tạo thành công');
    } catch (e) {
      print('❌ Lỗi _createUserInFirestore: $e');
      rethrow;
    }
  }

  /// Cập nhật thời gian đăng nhập cuối
  Future<void> _updateLastLoginTime(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': DateTime.now().toIso8601String(),
    });
  }

  /// Xử lý lỗi Firebase Auth
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với username này';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'operation-not-allowed':
        return 'Thao tác không được phép';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      default:
        return 'Lỗi: ${e.message}';
    }
  }
}
