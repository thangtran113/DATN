import 'package:flutter/material.dart';
import '../../domain/entities/user.dart' as domain;

class AuthProvider extends ChangeNotifier {
  domain.User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  domain.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void setUser(domain.User? user) {
    _user = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
