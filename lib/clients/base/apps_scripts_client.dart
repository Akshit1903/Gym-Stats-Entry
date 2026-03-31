import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/clients/home_server_client.dart';
import 'package:gym_stats_entry_client/common/dependency_injection.dart';
import 'package:gym_stats_entry_client/common/utils.dart';
import 'package:gym_stats_entry_client/models/apps_script_type.dart';
import 'package:gym_stats_entry_client/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AppsScriptsClient {
  final AppsScriptType _appsScriptType;

  final AuthService _authService;
  final HomeServerClient _homeServerClient = getIt<HomeServerClient>();

  AppsScriptsClient(this._appsScriptType) : _authService = getIt<AuthService>();

  Future<String?> callAppsScript(
    final String functionName,
    final List<dynamic> parameters,
    BuildContext? context,
    String? successMessage,
    String? errorMessage,
  ) async {
    try {
      final host = await _homeServerClient.getHostName(_appsScriptType);
      final Uri uri = Uri.parse(host);
      final accessToken = await _authService.getAccessToken();
      var headers = {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      };
      var body = json.encode({
        "function": functionName,
        "parameters": parameters,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(response.body);
        if (responseJson["error"] != null &&
            responseJson["error"]["details"] != null) {
          String errorDetails = responseJson["error"]["details"].toString();
          Utils.showSnackBar('Error: $errorDetails', Colors.red, context);
          return null;
        }
        assert(responseJson["done"] as bool);
        String result = responseJson["response"]["result"].toString();
        if (context != null && context.mounted && successMessage != null) {
          Utils.showSnackBar(successMessage, Colors.green, context);
        }
        return result;
      } else {
        if (context != null && context.mounted && errorMessage != null) {
          Utils.showSnackBar(
            '$errorMessage Status: ${response.statusCode.toString()}  Message: ${(response.reasonPhrase ?? "")}',
            Colors.red,
            context,
          );
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        Utils.showSnackBar("Error: ${e.toString()}", Colors.red, context);
      }
    }
    return null;
  }
}
