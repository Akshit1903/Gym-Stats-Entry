import 'package:flutter/widgets.dart';
import 'package:gym_stats_entry_client/common/utils.dart';

class FieldModel {
  final String name;
  final String displayName;
  final String? samsungHealthDataKey;
  final String? healthConnectDataKey;
  final Function valueTransformer;
  final bool startsFromNewRow;
  final int maxLines;
  final TextInputType textInputType;
  bool moreTheMerrier;
  TextEditingController? controller;
  String? diffResponseValue;

  FieldModel({
    required this.name,
    required this.displayName,
    this.samsungHealthDataKey,
    this.healthConnectDataKey,
    this.valueTransformer = Utils.identity,
    this.startsFromNewRow = false,
    this.maxLines = 1,
    this.textInputType = TextInputType.number,
    this.moreTheMerrier = false,
  });

  void init() {
    controller = TextEditingController();
  }

  void dispose() {
    controller?.dispose();
  }
}
