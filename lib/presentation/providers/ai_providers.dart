import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/data/datasources/local/ai_cache_local_datasource.dart';
import 'package:taskflow_ai/data/repositories/ai_cache_repository_impl.dart';
import 'package:taskflow_ai/data/repositories/ai_repository_impl.dart';
import 'package:taskflow_ai/domain/repositories/ai_cache_repository.dart';
import 'package:taskflow_ai/domain/repositories/ai_repository.dart';
import 'package:taskflow_ai/domain/usecases/ai/generate_insights_usecase.dart';
import 'package:taskflow_ai/domain/usecases/ai/generate_predictions_usecase.dart';
import 'package:taskflow_ai/presentation/providers/analytics_providers.dart';

final aiCacheLocalDataSourceProvider = Provider<AICacheLocalDataSource>(
  (ref) => const AICacheLocalDataSource(),
);

final aiRepositoryProvider = Provider<AIRepository>(
  (ref) => const AIRepositoryImpl(),
);

final aiCacheRepositoryProvider = Provider<AICacheRepository>(
  (ref) => AICacheRepositoryImpl(ref.watch(aiCacheLocalDataSourceProvider)),
);

final generateInsightsUseCaseProvider = Provider<GenerateInsightsUseCase>(
  (ref) => GenerateInsightsUseCase(
    ref.watch(aiRepositoryProvider),
    ref.watch(aiCacheRepositoryProvider),
  ),
);

final generatePredictionsUseCaseProvider = Provider<GeneratePredictionsUseCase>(
  (ref) => GeneratePredictionsUseCase(
    ref.watch(aiRepositoryProvider),
    ref.watch(aiCacheRepositoryProvider),
  ),
);

final aiInsightsProvider = FutureProvider((ref) async {
  final analytics = await ref.watch(analyticsProvider.future);
  return ref.watch(generateInsightsUseCaseProvider).call(analytics);
});

final aiPredictionsProvider = FutureProvider((ref) async {
  final analytics = await ref.watch(analyticsProvider.future);
  return ref.watch(generatePredictionsUseCaseProvider).call(analytics);
});
