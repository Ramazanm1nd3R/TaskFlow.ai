class AIPredictions {
  const AIPredictions({
    required this.nextWeekForecast,
    required this.burnoutRisk,
    required this.dailyRecommendation,
    required this.completionSpeed,
  });

  final String nextWeekForecast;
  final String burnoutRisk;
  final String dailyRecommendation;
  final String completionSpeed;

  Map<String, dynamic> toJson() {
    return {
      'nextWeekForecast': nextWeekForecast,
      'burnoutRisk': burnoutRisk,
      'dailyRecommendation': dailyRecommendation,
      'completionSpeed': completionSpeed,
    };
  }

  factory AIPredictions.fromJson(Map<String, dynamic> json) {
    return AIPredictions(
      nextWeekForecast: json['nextWeekForecast'] as String? ?? '',
      burnoutRisk: json['burnoutRisk'] as String? ?? '',
      dailyRecommendation: json['dailyRecommendation'] as String? ?? '',
      completionSpeed: json['completionSpeed'] as String? ?? '',
    );
  }
}
