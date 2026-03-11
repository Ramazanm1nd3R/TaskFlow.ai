class AIInsights {
  const AIInsights({
    required this.productivity,
    required this.bestDay,
    required this.completionTime,
    required this.topCategory,
  });

  final String productivity;
  final String bestDay;
  final String completionTime;
  final String topCategory;

  Map<String, dynamic> toJson() {
    return {
      'productivity': productivity,
      'bestDay': bestDay,
      'completionTime': completionTime,
      'topCategory': topCategory,
    };
  }

  factory AIInsights.fromJson(Map<String, dynamic> json) {
    return AIInsights(
      productivity: json['productivity'] as String? ?? '',
      bestDay: json['bestDay'] as String? ?? '',
      completionTime: json['completionTime'] as String? ?? '',
      topCategory: json['topCategory'] as String? ?? '',
    );
  }
}
