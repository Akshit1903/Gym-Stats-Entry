import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/auth.dart';
import 'package:gym_stats_entry_client/sign_in_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: SignInView(authService: AuthService()),
    );
  }
}
