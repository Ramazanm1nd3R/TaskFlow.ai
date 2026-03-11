import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow_ai/core/constants/hive_boxes.dart';

class AICacheLocalDataSource {
  const AICacheLocalDataSource();

  Future<Map<String, dynamic>?> getInsights(String key) async {
    final box = Hive.box<String>(HiveBoxes.aiInsights);
    final raw = box.get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveInsights(String key, Map<String, dynamic> payload) async {
    final box = Hive.box<String>(HiveBoxes.aiInsights);
    await box.put(key, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> getPredictions(String key) async {
    final box = Hive.box<String>(HiveBoxes.aiPredictions);
    final raw = box.get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> savePredictions(String key, Map<String, dynamic> payload) async {
    final box = Hive.box<String>(HiveBoxes.aiPredictions);
    await box.put(key, jsonEncode(payload));
  }
}
