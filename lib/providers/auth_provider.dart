import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gym_stats_entry_client/common/dependency_injection.dart';
import 'package:gym_stats_entry_client/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isSigningIn = false;
  bool _isAuthenticated = false;

  AuthProvider() : _authService = getIt<AuthService>() {
    _authService.onUserChanged.listen((account) {
      _isAuthenticated = account != null;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isSigningIn => _isSigningIn;

  Future<void> signIn() async {
    _setIsSigningIn(true);
    try {
      await _authService.signIn();
    } finally {
      _setIsSigningIn(false);
    }
  }

  Future<void> signOut() async {
    _setIsSigningIn(true);
    try {
      await _authService.signOut();
    } finally {
      _setIsSigningIn(false);
    }
  }

  void _setIsSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners();
  }
}
