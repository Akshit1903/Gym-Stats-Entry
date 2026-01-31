import 'package:gym_stats_entry_client/apps_scripts_client.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';

class SettingsService {
  SettingsService._();

  static Future<String> getAppsScriptURL() async {
    try {
      String appsScriptURL = await Utils.getPrefsStringValue(
        Utils.APPS_SCRIPT_URL_KEY,
      );
      if (appsScriptURL.isNotEmpty) {
        return appsScriptURL;
      }
      setAppsScriptURL();
      return await Utils.getPrefsStringValue(Utils.APPS_SCRIPT_URL_KEY);
    } catch (e) {
      throw Exception('Failed to get Apps Script URL: ${e.toString()}');
    }
  }

  static Future<bool> setAppsScriptURL() async {
    try {
      final stateConfigURL = await getStateConfigURL();
      if (stateConfigURL.isEmpty) {
        return false;
      }
      final appsScriptURL = await AppsScriptsClient.instance
          .getAppsScriptClientUrl(null);
      return await Utils.setPrefsStringValue(
        Utils.APPS_SCRIPT_URL_KEY,
        appsScriptURL ?? "",
      );
    } catch (e) {
      return false;
    }
  }

  // Get the stored Config State URL
  static Future<String> getStateConfigURL() async {
    try {
      return await Utils.getPrefsStringValue(Utils.STATE_CONFIG_URL_KEY);
    } catch (e) {
      throw Exception(
        'State Config URL not configured. Please set it in Settings.',
      );
    }
  }

  // Set the State Config URL
  static Future<bool> setStateConfigURL(String url) async {
    try {
      bool stateConfigURLSetStatus = await Utils.setPrefsStringValue(
        Utils.STATE_CONFIG_URL_KEY,
        url,
      );
      setAppsScriptURL();
      return stateConfigURLSetStatus;
    } catch (e) {
      return false;
    }
  }
}
