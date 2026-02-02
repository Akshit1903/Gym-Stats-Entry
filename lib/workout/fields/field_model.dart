import 'package:flutter/widgets.dart';
import 'package:gym_stats_entry_client/utils/utils.dart';

class FieldModel {
  final String name;
  final String displayName;
  final String? samsungHealthDataKey;
  final Function valueTransformer;
  final bool startsFromNewRow;
  final int maxLines;
  final TextInputType textInputType;
  TextEditingController? controller;

  FieldModel({
    required this.name,
    required this.displayName,
    this.samsungHealthDataKey,
    this.valueTransformer = Utils.identity,
    this.startsFromNewRow = false,
    this.maxLines = 1,
    this.textInputType = TextInputType.number,
  });

  void init() {
    controller = TextEditingController();
  }

  void dispose() {
    controller?.dispose();
  }
}
