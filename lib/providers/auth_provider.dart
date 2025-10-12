import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_stats_entry_client/apps_scripts_client.dart';

class AuthProvider extends ChangeNotifier {
  static const SCOPES = [
    "https://www.googleapis.com/auth/script.projects",
    "https://www.googleapis.com/auth/spreadsheets",
    'https://www.googleapis.com/auth/drive.file',
  ];
  final GoogleSignIn _signIn = GoogleSignIn(scopes: SCOPES);

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  AuthProvider() {
    silentSignIn();
    _signIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      _currentUser = account;
      AppsScriptsClient.instance.setUser(account);
      notifyListeners();
    });
  }

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

  Future<void> silentSignIn() async {
    _currentUser = await _signIn.signInSilently();
  }

  Future<bool> isSignedIn() async {
    return await _signIn.isSignedIn();
  }
}
