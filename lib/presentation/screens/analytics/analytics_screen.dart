import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_ai/core/theme/app_colors.dart';
import 'package:taskflow_ai/domain/entities/ai_insights.dart';
import 'package:taskflow_ai/domain/entities/ai_predictions.dart';
import 'package:taskflow_ai/domain/entities/analytics_data.dart';
import 'package:taskflow_ai/presentation/providers/ai_providers.dart';
import 'package:taskflow_ai/presentation/providers/analytics_providers.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_scaffold.dart';
import 'package:taskflow_ai/presentation/widgets/common/async_feedback.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final insightsAsync = ref.watch(aiInsightsProvider);
    final predictionsAsync = ref.watch(aiPredictionsProvider);

    return AppScaffold(
      title: 'Analytics',
      child: analyticsAsync.when(
        data: (analytics) => _AnalyticsContent(
          data: analytics,
          insightsAsync: insightsAsync,
          predictionsAsync: predictionsAsync,
        ),
        loading: () => const LoadingPane(label: 'Building analytics...'),
        error: (error, _) => ErrorPane(
          message: error.toString(),
          onRetry: () => ref.invalidate(analyticsProvider),
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({
    required this.data,
    required this.insightsAsync,
    required this.predictionsAsync,
  });

  final AnalyticsData data;
  final AsyncValue<AIInsights> insightsAsync;
  final AsyncValue<AIPredictions> predictionsAsync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 560;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: wide ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 118,
              ),
              itemBuilder: (context, index) {
                final metrics = [
                  _MetricCard(
                    label: 'Total tasks',
                    value: '${data.totalTasks}',
                    tone: AppColors.accent,
                  ),
                  _MetricCard(
                    label: 'Completed',
                    value: '${data.completedTasks}',
                    tone: AppColors.success,
                  ),
                  _MetricCard(
                    label: 'Active',
                    value: '${data.activeTasks}',
                    tone: AppColors.warning,
                  ),
                  _MetricCard(
                    label: 'Completion rate',
                    value: '${data.completionRate}%',
                    tone: AppColors.accentStrong,
                  ),
                ];
                return metrics[index];
              },
            );
          },
        ),
        const SizedBox(height: 20),
        _InsightStrip(data: data),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'AI insights',
          child: _AIInsightsSection(insightsAsync: insightsAsync),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'AI predictions',
          child: _AIPredictionsSection(predictionsAsync: predictionsAsync),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Last 7 days',
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.last7Days.length) {
                          return const SizedBox.shrink();
                        }
                        final label = DateFormat('E').format(data.last7Days[index].date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < data.last7Days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: data.last7Days[i].completed.toDouble(),
                          color: AppColors.success,
                          width: 10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        BarChartRodData(
                          toY: data.last7Days[i].active.toDouble(),
                          color: AppColors.warning,
                          width: 10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Top categories',
          child: Column(
            children: data.topCategories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 90, child: Text(category.name)),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: category.percentage / 100,
                              backgroundColor: AppColors.border,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${category.count}'),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Weekly heatmap',
          child: _Heatmap(heatmap: data.heatmap),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            ),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightStrip extends StatelessWidget {
  const _InsightStrip({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          runSpacing: 10,
          spacing: 10,
          children: [
            _MetaPill(label: 'Peak hour', value: '${data.peakProductivityHour}:00'),
            _MetaPill(label: 'Peak day', value: data.peakProductivityDay),
            _MetaPill(
              label: 'Avg completion',
              value: '${data.averageCompletionDays.toStringAsFixed(1)} d',
            ),
            _MetaPill(
              label: 'High priority',
              value: '${data.priorityDistribution['high'] ?? 0}',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _AIInsightsSection extends StatelessWidget {
  const _AIInsightsSection({required this.insightsAsync});

  final AsyncValue<AIInsights> insightsAsync;

  @override
  Widget build(BuildContext context) {
    return insightsAsync.when(
      data: (insights) => Column(
        children: [
          _AiBullet(title: 'Productivity', text: insights.productivity),
          _AiBullet(title: 'Best day', text: insights.bestDay),
          _AiBullet(title: 'Completion time', text: insights.completionTime),
          _AiBullet(title: 'Top category', text: insights.topCategory),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text(error.toString()),
    );
  }
}

class _AIPredictionsSection extends StatelessWidget {
  const _AIPredictionsSection({required this.predictionsAsync});

  final AsyncValue<AIPredictions> predictionsAsync;

  @override
  Widget build(BuildContext context) {
    return predictionsAsync.when(
      data: (predictions) => Column(
        children: [
          _AiBullet(title: 'Next week', text: predictions.nextWeekForecast),
          _AiBullet(title: 'Burnout risk', text: predictions.burnoutRisk),
          _AiBullet(title: 'Daily target', text: predictions.dailyRecommendation),
          _AiBullet(title: 'Execution speed', text: predictions.completionSpeed),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text(error.toString()),
    );
  }
}

class _AiBullet extends StatelessWidget {
  const _AiBullet({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.heatmap});

  final Map<int, Map<int, int>> heatmap;

  @override
  Widget build(BuildContext context) {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      children: [
        for (var row = 1; row <= 7; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(width: 36, child: Text(labels[row - 1])),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (var hour = 0; hour < 12; hour++)
                        _HeatCell(value: heatmap[row]?[hour] ?? 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (value == 0) {
      color = AppColors.border;
    } else if (value == 1) {
      color = AppColors.accent.withValues(alpha: 0.25);
    } else if (value <= 2) {
      color = AppColors.accent.withValues(alpha: 0.5);
    } else {
      color = AppColors.accent;
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
