import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
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
      currentRoute: RouteNames.analytics,
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
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Analytics',
            subtitle:
                'A quieter view of your momentum, consistency, and focus.',
          ).animate().fadeIn(duration: 220.ms),
          const SizedBox(height: 24),
          _StatsCardsGrid(data: data).animate().fadeIn(duration: 260.ms),
          const SizedBox(height: 24),
          const _SectionHeader(
            title: 'Activity Heatmap',
            subtitle: 'Last 7 days',
          ),
          const SizedBox(height: 12),
          _HeatmapCard(heatmap: data.heatmap),
          const SizedBox(height: 24),
          const _SectionHeader(
            title: 'Productivity Trend',
            subtitle: 'Completed vs active tasks over the week',
          ),
          const SizedBox(height: 12),
          _TrendChartCard(data: data),
          const SizedBox(height: 24),
          _SummaryStrip(data: data),
          const SizedBox(height: 24),
          const _SectionHeader(
            title: 'AI Insights',
            subtitle: 'Powered by GPT-4',
          ),
          const SizedBox(height: 12),
          _AIInsightsGrid(insightsAsync: insightsAsync),
          const SizedBox(height: 24),
          const _SectionHeader(
            title: 'AI Predictions',
            subtitle: 'Forward-looking suggestions',
          ),
          const SizedBox(height: 12),
          _AIPredictionsGrid(predictionsAsync: predictionsAsync),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Distribution'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    _TopCategoriesCard(data: data),
                    const SizedBox(height: 16),
                    _PriorityDistributionCard(data: data),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TopCategoriesCard(data: data)),
                  const SizedBox(width: 16),
                  Expanded(child: _PriorityDistributionCard(data: data)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatsCardsGrid extends StatelessWidget {
  const _StatsCardsGrid({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCardData(
        icon: Icons.task_outlined,
        label: 'Total Tasks',
        value: '${data.totalTasks}',
        color: const Color(0xFF3B82F6),
      ),
      _StatCardData(
        icon: Icons.bolt_outlined,
        label: 'Active',
        value: '${data.activeTasks}',
        color: const Color(0xFFF59E0B),
      ),
      _StatCardData(
        icon: Icons.check_circle_outline,
        label: 'Completed',
        value: '${data.completedTasks}',
        color: const Color(0xFF10B981),
      ),
      _StatCardData(
        icon: Icons.trending_up_outlined,
        label: 'Completion',
        value: '${data.completionRate}%',
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final stat in stats)
              SizedBox(
                width: cardWidth,
                child: _StatCard(data: stat),
              ),
          ],
        );
      },
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.heatmap});

  final Map<int, Map<int, int>> heatmap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly intensity',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            const _HeatmapLegend(),
            const SizedBox(height: 16),
            Expanded(child: _Heatmap(heatmap: heatmap)),
          ],
        ),
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 260,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 2,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 28),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.last7Days.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Text(
                        DateFormat('E').format(data.last7Days[index].date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
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
                      color: const Color(0xFF10B981),
                      width: 10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    BarChartRodData(
                      toY: data.last7Days[i].active.toDouble(),
                      color: const Color(0xFF3B82F6),
                      width: 10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Peak hour', '${data.peakProductivityHour}:00'),
      ('Peak day', data.peakProductivityDay),
      ('Avg completion', '${data.averageCompletionDays.toStringAsFixed(1)} d'),
      ('High priority', '${data.priorityDistribution['high'] ?? 0}'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final item in items) _Pill(label: item.$1, value: item.$2),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                style: textTheme.bodySmall,
                children: [
                  TextSpan(text: '$label: '),
                  TextSpan(
                    text: value,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCardsWrap extends StatelessWidget {
  const _AnalyticsCardsWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final cardWidth = isCompact
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final child in children)
                SizedBox(width: cardWidth, child: child),
            ],
          ),
        );
      },
    );
  }
}

class _AIInsightsGrid extends StatelessWidget {
  const _AIInsightsGrid({required this.insightsAsync});

  final AsyncValue<AIInsights> insightsAsync;

  @override
  Widget build(BuildContext context) {
    return insightsAsync.when(
      data: (insights) {
        final cards = [
          _InsightCardData(
            '🎯',
            'Productivity',
            insights.productivity,
            const Color(0xFF3B82F6),
          ),
          _InsightCardData(
            '📅',
            'Best Day',
            insights.bestDay,
            const Color(0xFF10B981),
          ),
          _InsightCardData(
            '⏱️',
            'Avg Time',
            insights.completionTime,
            const Color(0xFFF59E0B),
          ),
          _InsightCardData(
            '🏆',
            'Top Category',
            insights.topCategory,
            const Color(0xFFEC4899),
          ),
        ];

        return _AnalyticsCardsWrap(
          children: [for (final card in cards) _AIInsightCard(data: card)],
        );
      },
      loading: () => const _LoadingSurface(),
      error: (error, _) => _ErrorSurface(message: error.toString()),
    );
  }
}

class _AIPredictionsGrid extends StatelessWidget {
  const _AIPredictionsGrid({required this.predictionsAsync});

  final AsyncValue<AIPredictions> predictionsAsync;

  @override
  Widget build(BuildContext context) {
    return predictionsAsync.when(
      data: (predictions) {
        final cards = [
          _InsightCardData(
            '📈',
            'Next Week',
            predictions.nextWeekForecast,
            const Color(0xFF3B82F6),
          ),
          _InsightCardData(
            '🧠',
            'Burnout Risk',
            predictions.burnoutRisk,
            const Color(0xFFEF4444),
          ),
          _InsightCardData(
            '📌',
            'Daily Target',
            predictions.dailyRecommendation,
            const Color(0xFF10B981),
          ),
          _InsightCardData(
            '⚡',
            'Speed',
            predictions.completionSpeed,
            const Color(0xFF8B5CF6),
          ),
        ];

        return _AnalyticsCardsWrap(
          children: [for (final card in cards) _AIInsightCard(data: card)],
        );
      },
      loading: () => const _LoadingSurface(),
      error: (error, _) => _ErrorSurface(message: error.toString()),
    );
  }
}

class _InsightCardData {
  const _InsightCardData(this.icon, this.title, this.content, this.color);

  final String icon;
  final String title;
  final String content;
  final Color color;
}

class _AIInsightCard extends StatelessWidget {
  const _AIInsightCard({required this.data});

  final _InsightCardData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  data.icon,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TopCategoriesCard extends StatelessWidget {
  const _TopCategoriesCard({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Categories',
            subtitle: 'Where the work clusters',
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.topCategories.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = data.topCategories[index];
              return Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: category.percentage / 100,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${category.count}',
                          textAlign: TextAlign.right,
                          style: textTheme.titleSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PriorityDistributionCard extends StatelessWidget {
  const _PriorityDistributionCard({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = [
      ('High', data.priorityDistribution['high'] ?? 0, const Color(0xFFEF4444)),
      (
        'Medium',
        data.priorityDistribution['medium'] ?? 0,
        const Color(0xFFF59E0B),
      ),
      ('Low', data.priorityDistribution['low'] ?? 0, const Color(0xFF10B981)),
    ];

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Priority',
            subtitle: 'Current spread of urgency',
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.$3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text('${item.$2}', style: textTheme.titleSmall),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _LoadingSurface extends StatelessWidget {
  const _LoadingSurface();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class _ErrorSurface extends StatelessWidget {
  const _ErrorSurface({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Text(
        message,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Less',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const _HeatCell(value: 0),
        const SizedBox(width: 4),
        const _HeatCell(value: 1),
        const SizedBox(width: 4),
        const _HeatCell(value: 2),
        const SizedBox(width: 4),
        const _HeatCell(value: 3),
        const SizedBox(width: 8),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'More',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.heatmap});

  final Map<int, Map<int, int>> heatmap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: labels.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = index + 1;
        return Row(
          children: [
            SizedBox(
              width: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cellWidth = math.max(10.0, (width - 44) / 12);
                  return Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (var hour = 0; hour < 12; hour++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: cellWidth,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _HeatCell(value: heatmap[row]?[hour] ?? 0),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
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
      color = const Color(0xFFE2E8F0);
    } else if (value == 1) {
      color = const Color(0xFFBFDBFE);
    } else if (value <= 2) {
      color = const Color(0xFF60A5FA);
    } else {
      color = const Color(0xFF3B82F6);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
