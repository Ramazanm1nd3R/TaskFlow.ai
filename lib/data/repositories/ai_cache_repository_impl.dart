import 'package:taskflow_ai/data/datasources/local/ai_cache_local_datasource.dart';
import 'package:taskflow_ai/domain/repositories/ai_cache_repository.dart';

class AICacheRepositoryImpl implements AICacheRepository {
  const AICacheRepositoryImpl(this._local);

  final AICacheLocalDataSource _local;

  @override
  Future<Map<String, dynamic>?> getInsights(String key) => _local.getInsights(key);

  @override
  Future<Map<String, dynamic>?> getPredictions(String key) =>
      _local.getPredictions(key);

  @override
  Future<Map<String, dynamic>?> getLifeWheel(String key) => _local.getLifeWheel(key);

  @override
  Future<void> saveInsights(String key, Map<String, dynamic> payload) =>
      _local.saveInsights(key, payload);

  @override
  Future<void> savePredictions(String key, Map<String, dynamic> payload) =>
      _local.savePredictions(key, payload);

  @override
  Future<void> saveLifeWheel(String key, Map<String, dynamic> payload) =>
      _local.saveLifeWheel(key, payload);
}
