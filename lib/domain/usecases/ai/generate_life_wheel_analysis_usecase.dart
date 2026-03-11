import 'package:taskflow_ai/core/utils/hash_utils.dart';
import 'package:taskflow_ai/domain/entities/life_wheel.dart';
import 'package:taskflow_ai/domain/repositories/ai_cache_repository.dart';
import 'package:taskflow_ai/domain/repositories/ai_repository.dart';

class GenerateLifeWheelAnalysisUseCase {
  const GenerateLifeWheelAnalysisUseCase(
    this._repository,
    this._cacheRepository,
  );

  final AIRepository _repository;
  final AICacheRepository _cacheRepository;

  Future<LifeWheelAnalysis> call(List<LifeWheelCategory> categories) async {
    final key = stableHash({
      'type': 'life-wheel',
      'categories': [
        for (final category in categories)
          {
            'key': category.key,
            'score': category.score,
          }
      ],
    });

    final cached = await _cacheRepository.getLifeWheel(key);
    if (cached != null) {
      return LifeWheelAnalysis.fromJson(cached);
    }

    final analysis = await _repository.generateLifeWheelAnalysis(categories);
    await _cacheRepository.saveLifeWheel(key, analysis.toJson());
    return analysis;
  }
}
