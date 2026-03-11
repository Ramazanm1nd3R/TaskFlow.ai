import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow_ai/app/app.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    await Hive.initFlutter();
  }
}

class TaskFlowAppBootstrap extends StatelessWidget {
  const TaskFlowAppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskFlowApp();
  }
}
