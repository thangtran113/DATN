import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// Repository for admin user management
class AdminUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all users (paginated)
  Stream<List<User>> getAllUsersStream({int limit = 20}) {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => User.fromJson(doc.data())).toList(),
        );
  }

  /// Get all users (one-time)
  Future<List<User>> getAllUsers({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Search users by username or email
  Future<List<User>> searchUsers(String query) async {
    try {
      // Search by username
      final usernameSnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      // Search by email
      final emailSnapshot = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      final users = <String, User>{};
      for (final doc in [...usernameSnapshot.docs, ...emailSnapshot.docs]) {
        final user = User.fromJson(doc.data());
        users[user.id] = user;
      }

      return users.values.toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Ban a user
  Future<void> banUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to ban user: $e');
    }
  }

  /// Unban a user
  Future<void> unbanUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBanned': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unban user: $e');
    }
  }

  /// Promote user to admin
  Future<void> promoteToAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to promote user: $e');
    }
  }

  /// Demote admin to regular user
  Future<void> demoteFromAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to demote user: $e');
    }
  }

  /// Delete a user and all their data
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // Clean up user's data
      // Delete comments
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete ratings
      final ratingsSnapshot = await _firestore
          .collection('movie_ratings')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in ratingsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete watchlist
      final watchlistSnapshot = await _firestore
          .collection('watchlist')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in watchlistSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete watch history
      final historySnapshot = await _firestore
          .collection('watch_history')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in historySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final totalUsers = snapshot.docs.length;

      int adminCount = 0;
      int bannedCount = 0;
      int activeUsers = 0;

      final now = DateTime.now();
      final last30Days = now.subtract(const Duration(days: 30));

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final user = User.fromJson(data);
          if (user.isAdmin) adminCount++;
          if (user.isBanned) bannedCount++;
          if (user.lastLoginAt != null &&
              user.lastLoginAt!.isAfter(last30Days)) {
            activeUsers++;
          }
        } catch (e) {
          // Skip invalid user documents
          continue;
        }
      }

      return {
        'totalUsers': totalUsers,
        'adminCount': adminCount,
        'bannedCount': bannedCount,
        'activeUsers': activeUsers,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return User.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Update user info
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
