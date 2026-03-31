import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/clients/base/apps_scripts_client.dart';
import 'package:gym_stats_entry_client/models/apps_script_type.dart';

class GymStatsAppsScriptsClient extends AppsScriptsClient {
  GymStatsAppsScriptsClient() : super(AppsScriptType.gymStats);

  Future<String> getNumberOfGymDays([BuildContext? context]) async {
    final String? noOfGymDays = await callAppsScript(
      "getNumberOfDaysIWentToGymInLast7Days",
      [],
      context,
      null,
      "Failed to fetch no. of gym days.",
    );
    return noOfGymDays ?? "-";
  }

  Future<String> getWorkoutData([BuildContext? context]) async {
    return await callAppsScript(
          "getAllBodyCompositionEntries",
          [],
          context,
          null,
          "Error fetching graphs data",
        ) ??
        "";
  }

  Future<void> submitWorkoutLog(
    Map<String, dynamic> workoutData, [
    BuildContext? context,
  ]) async {
    await callAppsScript(
      "addWorkoutLog",
      [workoutData],
      context,
      null,
      "Failed to add workout entry.",
    );
  }

  Future<String?> submitCutLog(
    Map<String, dynamic> cutData, [
    BuildContext? context,
  ]) async {
    return await callAppsScript(
      "addCutLog",
      [cutData],
      context,
      null,
      "Failed to add cut entry.",
    );
  }

  Future<String> getNextWorkoutType([BuildContext? context]) async {
    return await callAppsScript(
          "getNextWorkoutType",
          [],
          context,
          null,
          "Failed to fetch next workout type",
        ) ??
        "";
  }
}
