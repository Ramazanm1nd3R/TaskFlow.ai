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
            subtitle: 'A quieter view of your momentum, consistency, and focus.',
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
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
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
    return _SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly intensity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
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
              getDrawingHorizontalLine: (_) => const FlLine(
                color: Color(0xFFE2E8F0),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('E').format(data.last7Days[index].date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
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
          _InsightCardData('🎯', 'Productivity', insights.productivity, const Color(0xFF3B82F6)),
          _InsightCardData('📅', 'Best Day', insights.bestDay, const Color(0xFF10B981)),
          _InsightCardData('⏱️', 'Avg Time', insights.completionTime, const Color(0xFFF59E0B)),
          _InsightCardData('🏆', 'Top Category', insights.topCategory, const Color(0xFFEC4899)),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: cardWidth,
                    child: _AIInsightCard(data: card),
                  ),
              ],
            );
          },
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
          _InsightCardData('📈', 'Next Week', predictions.nextWeekForecast, const Color(0xFF3B82F6)),
          _InsightCardData('🧠', 'Burnout Risk', predictions.burnoutRisk, const Color(0xFFEF4444)),
          _InsightCardData('📌', 'Daily Target', predictions.dailyRecommendation, const Color(0xFF10B981)),
          _InsightCardData('⚡', 'Speed', predictions.completionSpeed, const Color(0xFF8B5CF6)),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: cardWidth,
                    child: _AIInsightCard(data: card),
                  ),
              ],
            );
          },
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
              Text(data.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: Color(0xFF1E293B),
            ),
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
                  SizedBox(
                    width: 88,
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
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
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${category.count}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
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
    final items = [
      ('High', data.priorityDistribution['high'] ?? 0, const Color(0xFFEF4444)),
      ('Medium', data.priorityDistribution['medium'] ?? 0, const Color(0xFFF59E0B)),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Text(
                      '${item.$2}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
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
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text(
          'Less',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        SizedBox(width: 8),
        _HeatCell(value: 0),
        SizedBox(width: 4),
        _HeatCell(value: 1),
        SizedBox(width: 4),
        _HeatCell(value: 2),
        SizedBox(width: 4),
        _HeatCell(value: 3),
        SizedBox(width: 8),
        Text(
          'More',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
              width: 36,
              child: Text(
                labels[index],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
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
                        SizedBox(
                          width: cellWidth,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _HeatCell(value: heatmap[row]?[hour] ?? 0),
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
