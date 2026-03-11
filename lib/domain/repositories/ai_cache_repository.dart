abstract class AICacheRepository {
  Future<Map<String, dynamic>?> getInsights(String key);
  Future<void> saveInsights(String key, Map<String, dynamic> payload);
  Future<Map<String, dynamic>?> getPredictions(String key);
  Future<void> savePredictions(String key, Map<String, dynamic> payload);
}
