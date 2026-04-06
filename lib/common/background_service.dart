import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_stats_entry_client/clients/gym_stats_apps_scripts_client.dart';
import 'package:gym_stats_entry_client/common/dependency_injection.dart';
import 'package:gym_stats_entry_client/common/utils.dart';
import 'package:gym_stats_entry_client/services/auth_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    setUpLocators();
    await dotenv.load(fileName: ".env");
    await getIt<AuthService>().silentSignIn();
    switch (task) {
      case "updateGymDays":
        final GymStatsAppsScriptsClient gymStatsAppsScriptsClient =
            getIt<GymStatsAppsScriptsClient>();
        String noOfGymDays = await gymStatsAppsScriptsClient
            .getNumberOfGymDays();
        if (int.tryParse(noOfGymDays) != null) {
          await Utils.updateNoOfGymDaysHomeWidget(noOfGymDays);
        }
    }
    return true;
  });
}

Future<void> initWorkManager() async {
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    "gymWidgetTask",
    "updateGymDays",
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
  // ⚡ Immediate one-off debug task (runs after 10 seconds)
  // await Workmanager().registerOneOffTask(
  //   "debugGymWidgetTask",
  //   "updateGymDays",
  //   initialDelay: const Duration(seconds: 5),
  // );
}
