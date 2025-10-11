import 'package:flutter/material.dart';

class Utils {
  Utils._();

  static const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

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
        final monthIndex = months.indexOf(month);
        if (monthIndex != -1) {
          final year = DateTime.now().year;
          return DateTime(year, monthIndex + 1, day);
        }
      }
    }
    return DateTime.now();
  }

  static String formatDate(DateTime date) {
    return '${months[date.month - 1]} ${date.day}';
  }
}
