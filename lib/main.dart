import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_stats_entry_client/apps_scripts_client.dart';
import 'package:gym_stats_entry_client/providers/auth_provider.dart';
import 'package:gym_stats_entry_client/sign_in_view.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';
import 'package:gym_stats_entry_client/workout/workout_form_page.dart';
import 'package:workmanager/workmanager.dart';
import 'package:google_sign_in/google_sign_in.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "updateGymDays":
        final GoogleSignIn signIn = GoogleSignIn(scopes: AuthProvider.SCOPES);
        final GoogleSignInAccount? user = await signIn.signInSilently();
        AppsScriptsClient.instance.setUser(user);
        final appsScriptsClient = AppsScriptsClient.instance;
        String noOfGymDays = await appsScriptsClient.getNumberOfGymDays();
        await Utils.updateNoOfGymDaysHomeWidget(noOfGymDays);
    }
    return true;
  });
}

Future<void> initWorkManager() async {
  await Workmanager().initialize(callbackDispatcher);
  // 🔁 Regular periodic task (runs every 2 hours)
  await Workmanager().registerPeriodicTask(
    "gymWidgetTask",
    "updateGymDays",
    frequency: const Duration(hours: 2),
    initialDelay: const Duration(minutes: 1),
  );

  // ⚡ Immediate one-off debug task (runs after 10 seconds)
  // await Workmanager().registerOneOffTask(
  //   "debugGymWidgetTask",
  //   "updateGymDays",
  //   initialDelay: const Duration(seconds: 10),
  // );
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
  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return FutureBuilder(
      future: authProvider.isSignedIn(),
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
        final isSignedIn = snapshot.data ?? false;
        return isSignedIn ? WorkoutFormPage() : SignInView();
      },
    );
  }
}
