import 'package:flutter/services.dart';
import "../utils/constants.dart";

class SamsungHealth {
  static const MethodChannel _channel = MethodChannel(Constants.packageName);

  static Future<Map<String, String>?>
  getBodyCompositionAndExerciseData() async {
    try {
      final result = await _channel.invokeMethod(
        'getBodyCompositionAndExerciseData',
      );
      return Map<String, String>.from(result);
    } on PlatformException catch (e) {
      print("Error fetching body composition: ${e.message}");
      return null;
    }
  }
}
