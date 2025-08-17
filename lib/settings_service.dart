import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _apiUrlKey = 'api_url';

  // Get the stored API URL
  Future<String> getApiUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiUrlKey) ?? '';
    } catch (e) {
      // Return empty string if there's an error
      return '';
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

  // Check if API URL is configured
  Future<bool> isApiUrlConfigured() async {
    final url = await getApiUrl();
    return url.isNotEmpty;
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