import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _signIn = GoogleSignIn(scopes: <String>['email']);

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  Future<GoogleSignInAccount?> signIn() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    _isSigningIn = true;
    notifyListeners();
    _currentUser = await _signIn.signIn();
    _isSigningIn = false;
    notifyListeners();
    return _currentUser;
  }

  Future<void> signOut() async {
    await _signIn.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
