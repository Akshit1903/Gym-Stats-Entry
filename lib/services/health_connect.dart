import 'package:flutter/material.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';
import 'package:gym_stats_entry_client/workout/fields/field_model.dart';
import 'package:gym_stats_entry_client/workout/fields/fields.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthConnect {
  static final _health = Health();
  static const List<HealthDataType> _dietaryTypes = [HealthDataType.NUTRITION];

  static Future<void> init() async {
    await _health.configure();
    await Permission.activityRecognition.request();
    await Permission.location.request();
    await _health.requestAuthorization(
      _dietaryTypes,
      permissions: _dietaryTypes.map((e) => HealthDataAccess.READ).toList(),
    );
  }

  static Future<List<HealthDataPoint>> _fetchDietaryData() async {
    await init();
    if (!(await _health.isHealthConnectAvailable())) {
      return [];
    }
    bool? granted = await _health.hasPermissions(_dietaryTypes);
    if (!(granted ?? false)) {
      return [];
    }
    var now = DateTime.now();
    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
      types: _dietaryTypes,
      startTime: now.subtract(Duration(days: 1)),
      endTime: now,
    );
    return healthData;
  }

  static Future<void> setNutritionData(BuildContext? context) async {
    List<HealthDataPoint> healthData = await _fetchDietaryData();
    for (HealthDataPoint dataPoint in healthData) {
      Map<String, dynamic> valueMap = dataPoint.value.toJson();
      for (FieldModel field in NUTRITION_FIELDS) {
        if (field.controller == null || field.healthConnectDataKey == null) {
          if (context != null && context.mounted) {
            Utils.showSnackBar(
              "Error: Field controller or data key is null for ${field.name}",
              Colors.red,
              context,
            );
          }
          return;
        }
        if (field.controller?.text.isEmpty ?? false) {
          field.controller?.text = "0";
        }
        double currentValue =
            (Utils.parseDouble(field.controller?.text) ?? 0.0) +
            valueMap[field.healthConnectDataKey];
        field.controller?.text = currentValue.toString();
      }
    }
    if (healthData.isNotEmpty) {
      for (FieldModel field in NUTRITION_FIELDS) {
        field.controller?.text = field
            .valueTransformer(field.controller?.text)
            .toString();
      }
    }
  }
}
