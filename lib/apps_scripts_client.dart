import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/utils.dart';
import 'package:http/http.dart' as http;

import 'package:gym_stats_entry_client/settings/settings_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppsScriptsClient {
  final GoogleSignInAccount? _user;
  AppsScriptsClient(this._user);

  Future<String?> _getAccessToken(
    GoogleSignInAccount? googleSignInAccount,
  ) async {
    if (googleSignInAccount == null) {
      return null;
    }
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    return googleSignInAuthentication.accessToken;
  }

  Future<dynamic> callAppsScript(
    final String functionName,
    final List<dynamic> parameters,
    BuildContext context,
    String? successMessage,
    String? errorMessage,
  ) async {
    try {
      final apiUrl = await SettingsService().getApiUrl();
      final Uri uri = Uri.parse(apiUrl);
      final authorization = await _getAccessToken(_user);
      var headers = {
        if (authorization != null) 'Authorization': "Bearer $authorization",
        'Content-Type': 'application/json',
      };
      var body = json.encode({
        "function": functionName,
        "parameters": parameters,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (context.mounted) {
          Map<String, dynamic> responseJson = jsonDecode(response.body);
          assert(responseJson["done"] as bool);
          String result = responseJson["response"]["result"].toString();
          if (successMessage != null) {
            Utils.showSnackBar(successMessage, Colors.green, context);
          }
          return result;
        }
      } else {
        if (context.mounted && errorMessage != null) {
          Utils.showSnackBar(
            '$errorMessage Status: ${response.statusCode.toString()}  Message: ${(response.reasonPhrase ?? "")}',
            Colors.red,
            context,
          );
        }
      }
    } catch (e) {
      if (context.mounted && errorMessage != null) {
        Utils.showSnackBar("Error: ${e.toString()}", Colors.red, context);
      }
    }
  }
}
