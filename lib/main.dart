import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_stats_entry_client/apps_scripts_client.dart';
import 'package:gym_stats_entry_client/auth.dart';
import 'package:gym_stats_entry_client/sign_in_view.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';
import 'package:gym_stats_entry_client/workout/workout_form_page.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "updateGymDays":
        final appsScriptsClient = AppsScriptsClient(null);
        String noOfGymDays = await appsScriptsClient.getNumberOfGymDays();
        await Utils.updateNoOfGymDaysHomeWidget(noOfGymDays);
    }
    return true;
  });
}

Future<void> initWorkManager() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  // 🔁 Regular periodic task (runs every 2 hours)
  await Workmanager().registerPeriodicTask(
    "gymWidgetTask",
    "updateGymDays",
    frequency: const Duration(hours: 2),
    initialDelay: const Duration(minutes: 1),
  );

  // ⚡ Immediate one-off debug task (runs after 10 seconds)
  await Workmanager().registerOneOffTask(
    "debugGymWidgetTask",
    "updateGymDays",
    initialDelay: const Duration(seconds: 10),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWorkManager();
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
        initWorkManager();
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
