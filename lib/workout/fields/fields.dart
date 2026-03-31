import 'package:flutter/cupertino.dart';
import 'package:gym_stats_entry_client/common/utils.dart';
import 'package:gym_stats_entry_client/workout/fields/field_model.dart';

List<FieldModel> BODY_MEASUREMENT_FIELDS = [
  FieldModel(
    name: 'BodyWeight',
    displayName: 'Body Weight (kg)',
    samsungHealthDataKey: 'weight',
    valueTransformer: Utils.parseDouble,
    startsFromNewRow: true,
  ),
  FieldModel(
    name: 'SkeletalMass',
    displayName: 'Skeletal Muscle Mass (kg)',
    samsungHealthDataKey: 'skeletal_muscle_mass',
    valueTransformer: Utils.parseDouble,
    moreTheMerrier: true,
  ),
  FieldModel(
    name: 'FatMass',
    displayName: 'Fat Mass (kg)',
    samsungHealthDataKey: 'body_fat_mass',
    valueTransformer: Utils.parseDouble,
    startsFromNewRow: true,
  ),
  FieldModel(
    name: 'BodyWater',
    displayName: 'Body Water (kg)',
    samsungHealthDataKey: 'total_body_water',
    valueTransformer: Utils.parseDouble,
  ),
  FieldModel(
    name: 'FatPercent',
    displayName: 'Fat Percentage (%)',
    samsungHealthDataKey: 'body_fat',
    valueTransformer: Utils.parseDouble,
    startsFromNewRow: true,
  ),
  FieldModel(
    name: 'BMR',
    displayName: 'Basal Metabolic Rate (kcal)',
    samsungHealthDataKey: 'basal_metabolic_rate',
    valueTransformer: Utils.parseDouble,
  ),
];
List<FieldModel> EXERCISE_FIELDS = [
  FieldModel(
    name: 'Energy',
    displayName: 'Calories Burned (kcal)',
    samsungHealthDataKey: 'calories',
    valueTransformer: Utils.parseInt,
    startsFromNewRow: true,
  ),
  FieldModel(
    name: 'AvgHeartRate',
    displayName: 'Average Heart Rate (bpm)',
    samsungHealthDataKey: 'meanHeartRate',
    valueTransformer: Utils.parseInt,
    startsFromNewRow: true,
  ),
  FieldModel(
    name: 'MaxHeartRate',
    displayName: 'Max Heart Rate (bpm)',
    samsungHealthDataKey: 'maxHeartRate',
    valueTransformer: Utils.parseInt,
  ),
  FieldModel(
    name: "Notes",
    displayName: "Notes",
    maxLines: 3,
    startsFromNewRow: true,
    textInputType: TextInputType.multiline,
  ),
];

List<FieldModel> NUTRITION_FIELDS = [
  FieldModel(
    name: 'Calories',
    displayName: 'Calories (kcal)',
    healthConnectDataKey: "calories",
    valueTransformer: Utils.parseInt,
    startsFromNewRow: true,
  ),
  FieldModel(
    name: 'Protein',
    displayName: 'Protein (g)',
    healthConnectDataKey: "protein",
    valueTransformer: Utils.parseInt,
    moreTheMerrier: true,
  ),
  FieldModel(
    name: 'Carbohydrates',
    displayName: 'Carbohydrates (g)',
    healthConnectDataKey: "carbs",
    valueTransformer: Utils.parseInt,
    startsFromNewRow: true,
  ),
  FieldModel(
    name: 'Fats',
    displayName: 'Fats (g)',
    healthConnectDataKey: "fat",
    valueTransformer: Utils.parseInt,
  ),
];
