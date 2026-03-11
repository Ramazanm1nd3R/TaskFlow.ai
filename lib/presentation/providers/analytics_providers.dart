import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_ai/domain/entities/analytics_data.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final tasks = await ref.watch(tasksControllerProvider.future);
  return _buildAnalytics(tasks);
});

AnalyticsData _buildAnalytics(List<Task> tasks) {
  final totalTasks = tasks.length;
  final completedTasks = tasks.where((task) => task.isCompleted).length;
  final activeTasks = totalTasks - completedTasks;
  final completionRate =
      totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();

  final categoryCounts = <String, int>{};
  final priorityCounts = <String, int>{
    'high': 0,
    'medium': 0,
    'low': 0,
  };
  final heatmap = <int, Map<int, int>>{
    for (var day = 1; day <= 7; day++) day: <int, int>{},
  };
  final dayCounts = <int, int>{for (var day = 1; day <= 7; day++) day: 0};
  final hourCounts = <int, int>{for (var hour = 0; hour < 24; hour++) hour: 0};

  for (final task in tasks) {
    categoryCounts.update(task.category, (value) => value + 1, ifAbsent: () => 1);
    priorityCounts.update(task.priority.name, (value) => value + 1);

    final weekday = task.createdAt.weekday;
    final hour = task.createdAt.hour;
    heatmap[weekday]!.update(hour, (value) => value + 1, ifAbsent: () => 1);
    dayCounts.update(weekday, (value) => value + 1);
    hourCounts.update(hour, (value) => value + 1);
  }

  final topCategories = categoryCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final last7Days = List.generate(7, (index) {
    final date = DateTime.now().subtract(Duration(days: 6 - index));
    final bucket = tasks.where((task) {
      final taskDate = DateTime(task.updatedAt.year, task.updatedAt.month, task.updatedAt.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return taskDate == targetDate;
    }).toList();

    return DailyTaskSnapshot(
      date: date,
      completed: bucket.where((task) => task.isCompleted).length,
      active: bucket.where((task) => !task.isCompleted).length,
    );
  });

  double averageCompletionDays = 0;
  final completed = tasks.where((task) => task.isCompleted).toList();
  if (completed.isNotEmpty) {
    final totalDays = completed
        .map((task) => task.updatedAt.difference(task.createdAt).inHours / 24)
        .reduce((a, b) => a + b);
    averageCompletionDays = totalDays / completed.length;
  }

  final peakHour = hourCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  final peakDay = dayCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  return AnalyticsData(
    totalTasks: totalTasks,
    activeTasks: activeTasks,
    completedTasks: completedTasks,
    completionRate: completionRate,
    topCategories: topCategories
        .take(4)
        .map(
          (entry) => CategoryStat(
            name: entry.key,
            count: entry.value,
            percentage: totalTasks == 0 ? 0 : (entry.value / totalTasks) * 100,
          ),
        )
        .toList(),
    priorityDistribution: priorityCounts,
    last7Days: last7Days,
    heatmap: heatmap,
    peakProductivityHour: peakHour,
    peakProductivityDay: DateFormat('EEE').format(
      DateTime(2026, 3, 8).add(Duration(days: peakDay - 1)),
    ),
    averageCompletionDays: averageCompletionDays,
  );
}
