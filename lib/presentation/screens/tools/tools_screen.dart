import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/core/theme/app_colors.dart';
import 'package:taskflow_ai/domain/entities/life_wheel.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/presentation/providers/life_wheel_providers.dart';
import 'package:taskflow_ai/presentation/providers/pomodoro_provider.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_card.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_scaffold.dart';
import 'package:taskflow_ai/presentation/widgets/common/async_feedback.dart';
import 'package:taskflow_ai/presentation/widgets/common/section_title.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksControllerProvider);

    return AppScaffold(
      title: 'Tools',
      currentRoute: RouteNames.tools,
      child: tasksAsync.when(
        data: (tasks) => _ToolsContent(tasks: tasks),
        loading: () => const LoadingPane(label: 'Loading tools...'),
        error: (error, _) => ErrorPane(
          message: error.toString(),
          onRetry: () => ref.read(tasksControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _ToolsContent extends StatelessWidget {
  const _ToolsContent({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completedToday = tasks.where((task) {
      final now = DateTime.now();
      return task.isCompleted &&
          task.updatedAt.year == now.year &&
          task.updatedAt.month == now.month &&
          task.updatedAt.day == now.day;
    }).length;
    final activeTasks = tasks.where((task) => !task.isCompleted).length;
    final focusMinutes = (completedToday * 35).clamp(25, 240);

    return ListView(
      children: [
        const SectionTitle(
          title: 'Tools',
          subtitle:
              'Focus rituals and reflective planning in one calm workspace.',
        ).animate().fadeIn(duration: 240.ms),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Pomodoro',
                subtitle: 'Apple-clean timer, local state, no extra friction.',
              ),
              const SizedBox(height: 20),
              const _PomodoroPanel(),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ToolStat(label: 'Focus block', value: '25 min'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolStat(
                      label: 'Today focus',
                      value: '$focusMinutes min',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03),
        const SizedBox(height: 20),
        const _LifeWheelPanel(),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Daily snapshot',
                subtitle: 'A quiet operational view for the day.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ToolStat(
                      label: 'Completed today',
                      value: '$completedToday',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolStat(
                      label: 'Active now',
                      value: '$activeTasks',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  value: 0.62,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Demo progress score: 62%. This area can later host Pomodoro history and life-wheel shortcuts.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 340.ms),
      ],
    );
  }
}

class _LifeWheelPanel extends ConsumerWidget {
  const _LifeWheelPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(lifeWheelProvider);
    final trigger = ref.watch(lifeWheelAnalysisTriggerProvider);
    final analysisAsync = trigger == 0
        ? null
        : ref.watch(lifeWheelAnalysisProvider);

    return Card(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Life Wheel',
              subtitle:
                  'Notion-like sliders with a reflective AI analysis on demand.',
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wheelSize = min(constraints.maxWidth, 320.0);
                return Center(
                  child: SizedBox(
                    width: wheelSize,
                    height: wheelSize,
                    child: CustomPaint(
                      painter: _LifeWheelPainter(categories: categories),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _AddCategoryRow(
              count: categories.length,
              onAdd: (label) {
                final added = ref
                    .read(lifeWheelProvider.notifier)
                    .addCategory(label);
                final messenger = ScaffoldMessenger.of(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      added
                          ? 'Category added'
                          : categories.length >= 10
                          ? 'Maximum is 10 categories'
                          : 'Category already exists or is invalid',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            for (final category in categories)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            category.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            category.score.toStringAsFixed(1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        if (category.isCustom) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Remove category',
                            onPressed: () {
                              final removed = ref
                                  .read(lifeWheelProvider.notifier)
                                  .removeCategory(category.key);
                              if (!removed) return;
                              final messenger = ScaffoldMessenger.of(context);
                              messenger.hideCurrentSnackBar();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Category removed'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.close),
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: category.score,
                            min: 1,
                            max: 10,
                            divisions: 18,
                            activeColor: category.color,
                            onChanged: (value) => ref
                                .read(lifeWheelProvider.notifier)
                                .updateScore(category.key, value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    ref.read(lifeWheelAnalysisTriggerProvider.notifier).state++;
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Analyze wheel'),
                ),
                Text(
                  '${categories.length}/10 categories',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (analysisAsync == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Adjust the wheel and tap "Analyze wheel" when you want AI feedback.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            if (analysisAsync != null)
              analysisAsync.when(
                data: (analysis) => Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 260),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AI analysis',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _LifeWheelInsight(
                          label: 'Summary',
                          value: analysis.summary,
                        ),
                        _LifeWheelInsight(
                          label: 'Focus area',
                          value: analysis.focusArea,
                        ),
                        _LifeWheelInsight(
                          label: 'Encouragement',
                          value: analysis.encouragement,
                        ),
                        _LifeWheelInsight(
                          label: 'Next step',
                          value: analysis.nextStep,
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) => Text(error.toString()),
              ),
          ],
        ),
      ),
    );
  }
}

class _PomodoroPanel extends ConsumerWidget {
  const _PomodoroPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(pomodoroProvider);
    final controller = ref.read(pomodoroProvider.notifier);

    String modeLabel(PomodoroMode mode) {
      switch (mode) {
        case PomodoroMode.focus:
          return 'Focus';
        case PomodoroMode.shortBreak:
          return 'Short';
        case PomodoroMode.longBreak:
          return 'Long';
      }
    }

    return Column(
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: CustomPaint(
            painter: _PomodoroPainter(progress: timer.progress),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        timer.formattedTime,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    modeLabel(timer.mode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in PomodoroMode.values)
              ChoiceChip(
                label: Text(modeLabel(mode)),
                selected: timer.mode == mode,
                onSelected: (_) => controller.switchMode(mode),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: controller.toggle,
              icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(timer.isRunning ? 'Pause' : 'Start'),
            ),
            OutlinedButton.icon(
              onPressed: controller.reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Completed focus sessions: ${timer.completedFocusSessions}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PomodoroPainter extends CustomPainter {
  const _PomodoroPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final basePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F6CBD), Color(0xFF22C55E)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2831 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PomodoroPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _LifeWheelPainter extends CustomPainter {
  const _LifeWheelPainter({required this.categories});

  final List<LifeWheelCategory> categories;

  @override
  void paint(Canvas canvas, Size size) {
    if (categories.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;
    final segmentAngle = 6.2831 / categories.length;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), gridPaint);
    }

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final startAngle = -1.5708 + segmentAngle * i;
      final sweepAngle = segmentAngle;
      final segmentRadius = radius * (category.score / 10);

      final fillPaint = Paint()
        ..color = category.color.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: segmentRadius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);

      final labelAngle = startAngle + sweepAngle / 2;
      final labelOffset = Offset(
        center.dx + (radius + 24) * cos(labelAngle),
        center.dy + (radius + 24) * sin(labelAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: category.label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 72);

      textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - textPainter.width / 2,
          labelOffset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LifeWheelPainter oldDelegate) {
    return oldDelegate.categories != categories;
  }
}

class _AddCategoryRow extends StatefulWidget {
  const _AddCategoryRow({required this.count, required this.onAdd});

  final int count;
  final ValueChanged<String> onAdd;

  @override
  State<_AddCategoryRow> createState() => _AddCategoryRowState();
}

class _AddCategoryRowState extends State<_AddCategoryRow> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMax = widget.count >= 10;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            enabled: !isMax,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Add custom category',
              hintText: isMax ? 'Maximum reached' : 'Example: Spirituality',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: isMax
                  ? null
                  : () {
                      final value = _controller.text.trim();
                      widget.onAdd(value);
                      _controller.clear();
                    },
              child: const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeWheelInsight extends StatelessWidget {
  const _LifeWheelInsight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ToolStat extends StatelessWidget {
  const _ToolStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardMuted
            : AppColors.cardMuted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: textTheme.titleLarge),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
