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
      return _getUserFromFirestore(firebaseUser.uid);
    });
  }

  /// Lấy user hiện tại
  Future<User?> get currentUser async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _getUserFromFirestore(firebaseUser.uid);
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
      return _getUserFromFirestore(credential.user!.uid);
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

      try {
        return _getUserFromFirestore(credential.user!.uid);
      } catch (e) {
        // Tự động tạo user document nếu chưa có
        final user = User(
          id: credential.user!.uid,
          username: email.split('@')[0].toLowerCase(),
          email: email,
          displayName: credential.user!.displayName,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _createUserInFirestore(user);
        return user;
      }
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
      if (!await isUsernameAvailable(username)) {
        throw Exception('Username đã được sử dụng');
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw Exception('Đăng ký thất bại');

      if (displayName != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      final user = User(
        id: credential.user!.uid,
        username: username.toLowerCase(),
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _createUserInFirestore(user);
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e.toString().contains('Username')) rethrow;
      throw Exception('Đăng ký thất bại: $e');
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
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);

    // Cập nhật Firestore
    await _firestore.collection('users').doc(user.uid).update({
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  /// Lấy thông tin user từ Firestore
  Future<User> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Không tìm thấy user');
    return User.fromJson(doc.data()!);
  }

  /// Tạo user mới trong Firestore
  Future<void> _createUserInFirestore(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
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
