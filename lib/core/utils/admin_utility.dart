import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility script để set admin cho user
///
/// Cách sử dụng:
/// 1. Lấy userId từ Firebase Console (users collection)
/// 2. Gọi setUserAsAdmin(userId) trong code
/// 3. Run app một lần để execute
///
/// QUAN TRỌNG: Xóa hoặc comment code này sau khi dùng xong!
class AdminUtility {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Set user thành admin
  static Future<void> setUserAsAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Successfully set user $userId as admin');
    } catch (e) {
      print('❌ Error setting admin: $e');
    }
  }

  /// Remove admin role
  static Future<void> removeAdminRole(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Successfully removed admin role from user $userId');
    } catch (e) {
      print('❌ Error removing admin: $e');
    }
  }

  /// Check if user is admin
  static Future<bool> isUserAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;
      return doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      print('❌ Error checking admin: $e');
      return false;
    }
  }

  /// List all admin users
  static Future<List<Map<String, dynamic>>> listAllAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('❌ Error listing admins: $e');
      return [];
    }
  }
}
