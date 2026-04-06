import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_stats_entry_client/common/background_service.dart';
import 'package:gym_stats_entry_client/common/dependency_injection.dart';
import 'package:gym_stats_entry_client/providers/auth_provider.dart';
import 'package:gym_stats_entry_client/services/auth_service.dart';
import 'package:gym_stats_entry_client/sign_in_view.dart';
import 'package:gym_stats_entry_client/workout/workout_form_page.dart';
import 'package:provider/provider.dart';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initWorkManager();
  setUpLocators();
}

void main() async {
  await initApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(theme: ThemeData.dark(), home: const AppWrapper()),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final AuthService _authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    return FutureBuilder(
      future: _authService.silentSignIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        final isSignedIn = authProvider.isAuthenticated;
        return isSignedIn ? WorkoutFormPage() : SignInView();
      },
    );
  }
}
