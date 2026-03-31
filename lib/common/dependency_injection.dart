import 'package:get_it/get_it.dart';
import 'package:gym_stats_entry_client/clients/gym_stats_apps_scripts_client.dart';
import 'package:gym_stats_entry_client/clients/home_server_client.dart';
import 'package:gym_stats_entry_client/common/auth_config.dart';
import 'package:gym_stats_entry_client/services/auth_service.dart';

final GetIt getIt = GetIt.instance;

void setUpLocators() {
  // Clients
  getIt.registerLazySingleton<HomeServerClient>(() => HomeServerClient());
  getIt.registerLazySingleton<GymStatsAppsScriptsClient>(
    () => GymStatsAppsScriptsClient(),
  );
  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(AuthConfig.getSignInClient()),
  );
  // _getIt.registerLazySingleton<SamsungHealth>(() => SamsungHealth());
}
