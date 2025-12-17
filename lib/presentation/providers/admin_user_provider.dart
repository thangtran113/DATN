import 'package:flutter/foundation.dart';
import '../../data/repositories/admin_user_repository.dart';
import '../../domain/entities/user.dart';

/// Provider for admin user management
class AdminUserProvider with ChangeNotifier {
  final AdminUserRepository _repository = AdminUserRepository();

  List<User> _users = [];
  Map<String, dynamic>? _statistics;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<User> get users => _users;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all users
  Future<void> loadUsers({int limit = 20}) async {
    _isLoading = true;
    _error = null;

    try {
      _users = await _repository.getAllUsers(limit: limit);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách người dùng: $e';
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await loadUsers();
      return;
    }

    _isLoading = true;
    _error = null;

    try {
      _users = await _repository.searchUsers(query);
      _error = null;
    } catch (e) {
      _error = 'Không thể tìm kiếm: $e';
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ban user
  Future<bool> banUser(String userId) async {
    try {
      await _repository.banUser(userId);
      await loadUsers(); // Refresh
      return true;
    } catch (e) {
      _error = 'Không thể cấm người dùng: $e';
      notifyListeners();
      return false;
    }
  }

  /// Unban user
  Future<bool> unbanUser(String userId) async {
    try {
      await _repository.unbanUser(userId);
      await loadUsers(); // Refresh
      return true;
    } catch (e) {
      _error = 'Không thể bỏ cấm người dùng: $e';
      notifyListeners();
      return false;
    }
  }

  /// Promote to admin
  Future<bool> promoteToAdmin(String userId) async {
    try {
      await _repository.promoteToAdmin(userId);
      await loadUsers(); // Refresh
      return true;
    } catch (e) {
      _error = 'Không thể thăng cấp: $e';
      notifyListeners();
      return false;
    }
  }

  /// Demote from admin
  Future<bool> demoteFromAdmin(String userId) async {
    try {
      await _repository.demoteFromAdmin(userId);
      await loadUsers(); // Refresh
      return true;
    } catch (e) {
      _error = 'Không thể hạ cấp: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _repository.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Không thể xóa người dùng: $e';
      notifyListeners();
      return false;
    }
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _repository.getUserStatistics();
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải thống kê: $e';
      notifyListeners();
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      return await _repository.getUserById(userId);
    } catch (e) {
      _error = 'Không thể tải thông tin người dùng: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update user
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _repository.updateUser(userId, data);
      await loadUsers(); // Refresh
      return true;
    } catch (e) {
      _error = 'Không thể cập nhật người dùng: $e';
      notifyListeners();
      return false;
    }
  }

  /// Watch users stream (for real-time updates)
  Stream<List<User>> watchUsersStream({int limit = 20}) {
    return _repository.getAllUsersStream(limit: limit);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
