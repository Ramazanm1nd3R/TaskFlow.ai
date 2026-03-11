import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow_ai/app/app.dart';
import 'package:taskflow_ai/core/constants/hive_boxes.dart';
import 'package:taskflow_ai/core/env/app_config.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    await Hive.initFlutter();
    await Hive.openBox<String>(HiveBoxes.aiInsights);
    await Hive.openBox<String>(HiveBoxes.aiPredictions);
    await Hive.openBox<String>(HiveBoxes.aiLifeWheel);
    if (AppConfig.openAiKey.isNotEmpty) {
      OpenAI.apiKey = AppConfig.openAiKey;
      OpenAI.showLogs = false;
    }
  }
}

class TaskFlowAppBootstrap extends StatelessWidget {
  const TaskFlowAppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskFlowApp();
  }
}
