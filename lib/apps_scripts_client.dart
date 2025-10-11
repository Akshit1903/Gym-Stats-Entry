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
    String successMessage,
    Function postSuccessCallback,
    String errorMessage,
  ) async {
    try {
      final apiUrl = await SettingsService().getApiUrl();
      if (apiUrl.isEmpty) {
        throw Exception('API URL not configured. Please set it in Settings.');
      }
      final authorization = await _getAccessToken(_user);
      final Uri uri = Uri.parse(await SettingsService().getApiUrl());
      var headers = {
        if (authorization != null) 'Authorization': "Bearer $authorization",
        'Content-Type': 'application/json',
      };
      var body = json.encode({
        "function": functionName,
        "parameters": parameters,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          await postSuccessCallback();
          String result = jsonDecode(
            response.body,
          )["response"]["result"].toString();
          Utils.showSnackBar(successMessage, Colors.green, context);
          return result;
        }
      } else {
        if (context.mounted) {
          Utils.showSnackBar(
            '$errorMessage Status: ${response.statusCode.toString()}  Message: ${(response.reasonPhrase ?? "")}',
            Colors.red,
            context,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Utils.showSnackBar("Error: ${e.toString()}", Colors.red, context);
      }
    }
  }
}
