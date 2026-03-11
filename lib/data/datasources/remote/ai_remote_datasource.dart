import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:taskflow_ai/domain/entities/ai_insights.dart';
import 'package:taskflow_ai/domain/entities/ai_predictions.dart';
import 'package:taskflow_ai/domain/entities/analytics_data.dart';
import 'package:taskflow_ai/domain/entities/life_wheel.dart';

class AIRemoteDataSource {
  const AIRemoteDataSource();

  Future<AIInsights> generateInsights(AnalyticsData analytics) async {
    final completion = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      responseFormat: const {'type': 'json_object'},
      temperature: 0.7,
      maxTokens: 400,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'Ты аналитик продуктивности. Верни только JSON с ключами productivity, bestDay, completionTime, topCategory.',
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              _buildInsightsPrompt(analytics),
            ),
          ],
        ),
      ],
    );

    final raw = _extractText(completion);
    return AIInsights.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<AIPredictions> generatePredictions(AnalyticsData analytics) async {
    final completion = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      responseFormat: const {'type': 'json_object'},
      temperature: 0.7,
      maxTokens: 500,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'Ты AI-прогнозист продуктивности. Верни только JSON с ключами nextWeekForecast, burnoutRisk, dailyRecommendation, completionSpeed.',
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              _buildPredictionsPrompt(analytics),
            ),
          ],
        ),
      ],
    );

    final raw = _extractText(completion);
    return AIPredictions.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<LifeWheelAnalysis> generateLifeWheelAnalysis(
    List<LifeWheelCategory> categories,
  ) async {
    final completion = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      responseFormat: const {'type': 'json_object'},
      temperature: 0.7,
      maxTokens: 450,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'Ты коуч по life wheel. Верни только JSON с ключами summary, focusArea, encouragement, nextStep.',
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              _buildLifeWheelPrompt(categories),
            ),
          ],
        ),
      ],
    );

    final raw = _extractText(completion);
    return LifeWheelAnalysis.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  String _extractText(OpenAIChatCompletionModel completion) {
    final content = completion.choices.first.message.content;
    if (content == null || content.isEmpty) {
      throw const FormatException('Empty OpenAI response');
    }
    return content
        .map((item) => item.text ?? '')
        .join()
        .trim();
  }

  String _buildInsightsPrompt(AnalyticsData analytics) {
    final topCategory = analytics.topCategories.isEmpty
        ? 'none'
        : analytics.topCategories.first.name;
    return '''
Данные пользователя:
- Total tasks: ${analytics.totalTasks}
- Active tasks: ${analytics.activeTasks}
- Completed tasks: ${analytics.completedTasks}
- Completion rate: ${analytics.completionRate}%
- Peak productivity hour: ${analytics.peakProductivityHour}
- Peak productivity day: ${analytics.peakProductivityDay}
- Average completion days: ${analytics.averageCompletionDays.toStringAsFixed(1)}
- Top category: $topCategory

Нужны короткие практичные инсайты на русском.
''';
  }

  String _buildPredictionsPrompt(AnalyticsData analytics) {
    final dailyTrend = analytics.last7Days
        .map((day) =>
            '${day.date.toIso8601String().split('T').first}: completed ${day.completed}, active ${day.active}')
        .join('\n');

    return '''
Построй прогноз по данным:
- Total tasks: ${analytics.totalTasks}
- Active tasks: ${analytics.activeTasks}
- Completed tasks: ${analytics.completedTasks}
- Completion rate: ${analytics.completionRate}%

Trend:
$dailyTrend

Ответ нужен по-русски, в JSON.
''';
  }

  String _buildLifeWheelPrompt(List<LifeWheelCategory> categories) {
    final payload = categories
        .map((category) => '- ${category.label}: ${category.score.toStringAsFixed(1)}/10')
        .join('\n');

    return '''
Проанализируй life wheel пользователя.

$payload

Нужны:
- краткое summary
- слабая зона focusArea
- короткое encouragement
- один конкретный nextStep

Ответ по-русски и строго JSON.
''';
  }
}
