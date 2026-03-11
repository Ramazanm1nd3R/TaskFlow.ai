class DailyTaskSnapshot {
  const DailyTaskSnapshot({
    required this.date,
    required this.completed,
    required this.active,
  });

  final DateTime date;
  final int completed;
  final int active;
}

class CategoryStat {
  const CategoryStat({
    required this.name,
    required this.count,
    required this.percentage,
  });

  final String name;
  final int count;
  final double percentage;
}

class AnalyticsData {
  const AnalyticsData({
    required this.totalTasks,
    required this.activeTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.topCategories,
    required this.priorityDistribution,
    required this.last7Days,
    required this.heatmap,
    required this.peakProductivityHour,
    required this.peakProductivityDay,
    required this.averageCompletionDays,
  });

  final int totalTasks;
  final int activeTasks;
  final int completedTasks;
  final int completionRate;
  final List<CategoryStat> topCategories;
  final Map<String, int> priorityDistribution;
  final List<DailyTaskSnapshot> last7Days;
  final Map<int, Map<int, int>> heatmap;
  final int peakProductivityHour;
  final String peakProductivityDay;
  final double averageCompletionDays;
}
