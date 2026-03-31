import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_stats_entry_client/common/dependency_injection.dart';
import 'package:gym_stats_entry_client/models/apps_script_type.dart';
import 'package:gym_stats_entry_client/services/auth_service.dart';
import 'package:http/http.dart' as http;

class HomeServerClient {
  final AuthService _authService;
  HomeServerClient()
    : _host = dotenv.get('HOME_SERVER_HOST'),
      _authService = getIt<AuthService>();

  final String _host;

  Uri _getUri(String endpoint) {
    return Uri.https(_host, endpoint);
  }

  Future<Map<String, String>> _getRequestHeaders() async {
    final accessToken = await _authService.getAccessToken();
    final idToken = await _authService.getIDToken();
    return {
      'Authorization': "Bearer $idToken",
      'X-ACCESS-TOKEN': accessToken,
      'Content-Type': 'application/json',
    };
  }

  Future<String> getHostName(AppsScriptType appsScriptType) async {
    try {
      final Uri uri = _getUri("/hosts/host/${appsScriptType.sheetName}");
      var headers = await _getRequestHeaders();
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        // {"host":"https://script.googleapis.com/v1/scripts/...","appsScriptType":"GymStats"}
        Map<String, dynamic> responseJson = jsonDecode(response.body);
        final String? host = responseJson["host"];
        if (host == null || host.isEmpty) {
          throw Exception("Host is null or empty");
        }
        return host;
      } else {
        throw Exception(
          'Failed to get host name. Status: ${response.statusCode}, Message: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception("Error getting host name: ${e.toString()}");
    }
  }
}
