import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taskflow_ai/core/constants/api_constants.dart';

abstract final class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? ApiConstants.defaultBaseUrl;

  static String get openAiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
}
