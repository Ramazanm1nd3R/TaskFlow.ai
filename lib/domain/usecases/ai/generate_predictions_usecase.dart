import 'package:taskflow_ai/core/utils/hash_utils.dart';
import 'package:taskflow_ai/domain/entities/ai_predictions.dart';
import 'package:taskflow_ai/domain/entities/analytics_data.dart';
import 'package:taskflow_ai/domain/repositories/ai_cache_repository.dart';
import 'package:taskflow_ai/domain/repositories/ai_repository.dart';

class GeneratePredictionsUseCase {
  const GeneratePredictionsUseCase(this._repository, this._cacheRepository);

  final AIRepository _repository;
  final AICacheRepository _cacheRepository;

  Future<AIPredictions> call(AnalyticsData analytics) async {
    final key = stableHash({
      'type': 'predictions',
      'total': analytics.totalTasks,
      'active': analytics.activeTasks,
      'completed': analytics.completedTasks,
      'completionRate': analytics.completionRate,
      'last7': [
        for (final day in analytics.last7Days)
          {
            'date': day.date.toIso8601String(),
            'completed': day.completed,
            'active': day.active,
          }
      ],
    });

    final cached = await _cacheRepository.getPredictions(key);
    if (cached != null) {
      return AIPredictions.fromJson(cached);
    }

    final predictions = await _repository.generatePredictions(analytics);
    await _cacheRepository.savePredictions(key, predictions.toJson());
    return predictions;
  }
}
