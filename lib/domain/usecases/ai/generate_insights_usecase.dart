import 'package:taskflow_ai/core/utils/hash_utils.dart';
import 'package:taskflow_ai/domain/entities/ai_insights.dart';
import 'package:taskflow_ai/domain/entities/analytics_data.dart';
import 'package:taskflow_ai/domain/repositories/ai_cache_repository.dart';
import 'package:taskflow_ai/domain/repositories/ai_repository.dart';

class GenerateInsightsUseCase {
  const GenerateInsightsUseCase(this._repository, this._cacheRepository);

  final AIRepository _repository;
  final AICacheRepository _cacheRepository;

  Future<AIInsights> call(AnalyticsData analytics) async {
    final key = stableHash({
      'type': 'insights',
      'total': analytics.totalTasks,
      'active': analytics.activeTasks,
      'completed': analytics.completedTasks,
      'completionRate': analytics.completionRate,
      'peakHour': analytics.peakProductivityHour,
      'peakDay': analytics.peakProductivityDay,
      'categories': [
        for (final category in analytics.topCategories)
          {'name': category.name, 'count': category.count}
      ],
    });

    final cached = await _cacheRepository.getInsights(key);
    if (cached != null) {
      return AIInsights.fromJson(cached);
    }

    final insights = await _repository.generateInsights(analytics);
    await _cacheRepository.saveInsights(key, insights.toJson());
    return insights;
  }
}
