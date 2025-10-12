import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';
import 'package:http/http.dart' as http;

import 'package:gym_stats_entry_client/settings/settings_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppsScriptsClient {
  static final AppsScriptsClient instance = AppsScriptsClient._();
  AppsScriptsClient._();

  GoogleSignInAccount? _user;

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

  Future<String?> _callAppsScript(
    final String functionName,
    final List<dynamic> parameters,
    BuildContext? context,
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
      "No. of gym days fetched successfully.",
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
      'Workout entry added successfully!',
      "Failed to add workout entry.",
    );
  }
}
