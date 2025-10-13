import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:gym_stats_entry_client/utils/constants.dart';

class Utils {
  Utils._();

  static void showSnackBar(
    String message,
    Color? backgroundColor,
    BuildContext context,
  ) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  static DateTime parseFormattedDate(String formattedDate) {
    final parts = formattedDate.split(' ');
    if (parts.length == 2) {
      final month = parts[0];
      final day = int.tryParse(parts[1]);
      if (day != null) {
        final monthIndex = Constants.months.indexOf(month);
        if (monthIndex != -1) {
          final year = DateTime.now().year;
          return DateTime(year, monthIndex + 1, day);
        }
      }
    }
    return DateTime.now();
  }

  static String formatDate(DateTime date) {
    return '${Constants.months[date.month - 1]} ${date.day}';
  }

  // Home Widget related methods

  static Future<void> updateNoOfGymDaysHomeWidget(String noOfGymDays) async {
    await HomeWidget.saveWidgetData<String>('no_of_gym_days', noOfGymDays);
    await HomeWidget.saveWidgetData<String>(
      'no_of_gym_days_time',
      DateTime.now().toString(),
    );
    await HomeWidget.updateWidget(androidName: "GymDaysWidget");
  }

  static Future<void> updateGraphImageHomeWidget(
    String title,
    Widget chartCard,
  ) async {
    String imagePath = await HomeWidget.renderFlutterWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(600, 400),
            devicePixelRatio: 3.0,
            platformBrightness: Brightness.dark, // helps some widgets
          ),
          child: Theme(
            data: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              cardColor: Colors.black,
              canvasColor: Colors.black,
              colorScheme: const ColorScheme.dark(),
            ),
            child: Material(color: Colors.black, child: chartCard),
          ),
        ),
      ),
      key: title,
      logicalSize: const Size(600, 400),
      pixelRatio: 6 / 2,
    );
    await HomeWidget.saveWidgetData<String>(title, imagePath);
    await HomeWidget.updateWidget(name: 'BodyWeight');
  }
}
