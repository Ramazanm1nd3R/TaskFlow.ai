import 'package:taskflow_ai/domain/entities/ai_insights.dart';
import 'package:taskflow_ai/domain/entities/ai_predictions.dart';
import 'package:taskflow_ai/domain/entities/analytics_data.dart';
import 'package:taskflow_ai/domain/entities/life_wheel.dart';

abstract class AIRepository {
  Future<AIInsights> generateInsights(AnalyticsData analytics);
  Future<AIPredictions> generatePredictions(AnalyticsData analytics);
  Future<LifeWheelAnalysis> generateLifeWheelAnalysis(
    List<LifeWheelCategory> categories,
  );
}
