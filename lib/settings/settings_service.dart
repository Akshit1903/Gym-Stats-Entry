import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _apiUrlKey = 'api_url';

  // Get the stored API URL
  Future<String> getApiUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiUrlKey) ?? '';
    } catch (e) {
      throw Exception('API URL not configured. Please set it in Settings.');
    }
  }

  // Set the API URL
  Future<bool> setApiUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_apiUrlKey, url);
    } catch (e) {
      return false;
    }
  }

  // Clear the stored API URL
  Future<bool> clearApiUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_apiUrlKey);
    } catch (e) {
      return false;
    }
  }
}
