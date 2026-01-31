import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';
import 'package:http/http.dart' as http;

import 'package:gym_stats_entry_client/settings/settings_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppsScriptsClient {
  static final AppsScriptsClient instance = AppsScriptsClient._();
  GoogleSignInAccount? _user;

  AppsScriptsClient._() {
    SettingsService.setAppsScriptURL();
  }

  Future<String?> _getAccessToken(
    GoogleSignInAccount? googleSignInAccount,
  ) async {
    if (googleSignInAccount == null) {
      return null;
    }
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    return googleSignInAuthentication.accessToken;
  }

  void setUser(GoogleSignInAccount? user) {
    _user = user;
  }

  Future<String?> _getStateConfigVar(
    String functionName,
    String stateVarId, [
    BuildContext? context,
    String errorMessagePrefix = "",
  ]) async {
    try {
      String stateConfigUrl = await SettingsService.getStateConfigURL();
      final Uri uri = Uri.parse(stateConfigUrl);

      var headers = {
        'Authorization': 'Bearer ${await _getAccessToken(_user)}',
        'Content-Type': 'application/json',
      };
      var body = json.encode({
        "function": functionName,
        "parameters": [stateVarId],
      });

      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode != 200) {
        throw Exception(
          'Status: ${response.statusCode.toString()}  Message: ${(response.reasonPhrase ?? "")}',
        );
      }
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse["response"]["result"];
    } catch (e) {
      if (context != null && context.mounted) {
        Utils.showSnackBar("$errorMessagePrefix $e", Colors.red, context);
      }
      return null;
    }
  }

  Future<String?> getAppsScriptClientUrl(BuildContext? context) async {
    return _getStateConfigVar(
      "getAppsScriptClientUrl",
      Utils.APP_NAME,
      context,
      "Error getting apps script URL:",
    );
  }

  Future<String?> _callAppsScript(
    final String functionName,
    final List<dynamic> parameters,
    BuildContext? context,
    String? successMessage,
    String? errorMessage,
  ) async {
    try {
      final appsScriptURL = await SettingsService.getAppsScriptURL();
      final Uri uri = Uri.parse(appsScriptURL);
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
        Map<String, dynamic> responseJson = jsonDecode(response.body);
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

  Future<String> getNumberOfGymDays([BuildContext? context]) async {
    final String? noOfGymDays = await _callAppsScript(
      "getNumberOfDaysIWentToGymInLast7Days",
      [],
      context,
      null,
      "Failed to fetch no. of gym days.",
    );
    return noOfGymDays ?? "-";
  }

  Future<String> getWorkoutData([BuildContext? context]) async {
    return await _callAppsScript(
          "getAllBodyCompositionEntries",
          [],
          context,
          null,
          "Error fetching graphs data",
        ) ??
        "";
  }

  Future<void> submitBodyCompositionEntry(
    Map<String, dynamic> workoutData, [
    BuildContext? context,
  ]) async {
    await _callAppsScript(
      "addBodyCompositionEntry",
      [workoutData],
      context,
      null,
      "Failed to add workout entry.",
    );
  }

  Future<String> getNextWorkoutType([BuildContext? context]) async {
    return await _callAppsScript(
          "getNextWorkoutType",
          [],
          context,
          null,
          "Failed to fetch next workout type",
        ) ??
        "";
  }
}
