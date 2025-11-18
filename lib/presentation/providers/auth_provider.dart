import 'package:flutter/material.dart';
import '../../domain/entities/user.dart' as domain;
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  domain.User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  domain.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Load user from cache when app starts
  Future<void> loadUserFromCache() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authRepository.currentUser;
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(domain.User? user) {
    _user = user;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}
