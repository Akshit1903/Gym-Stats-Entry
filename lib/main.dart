import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_stats_entry_client/auth.dart';
import 'package:gym_stats_entry_client/sign_in_view.dart';
import 'package:gym_stats_entry_client/workout_form_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData.dark(), home: const AppWrapper());
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final AuthService _authService = AuthService();
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthStateChanged);
    _authService.silentSignIn().then((_) {
      if (mounted) {
        setState(() {
          _currentUser = _authService.currentUser;
        });
      }
    });
    _currentUser = _authService.currentUser;
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    setState(() {
      _currentUser = _authService.currentUser;
    });
  }

  void _onSignedIn(GoogleSignInAccount? user) {
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return WorkoutFormPage(
        user: _currentUser!,
        onSignOut: () {
          setState(() {
            _currentUser = null;
          });
        },
      );
    } else {
      return SignInView(authService: _authService, onSignedIn: _onSignedIn);
    }
  }
}
