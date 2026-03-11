import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/presentation/providers/pomodoro_provider.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_scaffold.dart';
import 'package:taskflow_ai/presentation/widgets/common/async_feedback.dart';

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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pomodoro', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  'A local focus timer for the demo workspace. The state is fully interactive now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                const _PomodoroPanel(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _ToolStat(label: 'Focus block', value: '25 min')),
                    const SizedBox(width: 12),
                    Expanded(child: _ToolStat(label: 'Today focus', value: '$focusMinutes min')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily snapshot', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _ToolStat(label: 'Completed today', value: '$completedToday')),
                    const SizedBox(width: 12),
                    Expanded(child: _ToolStat(label: 'Active now', value: '$activeTasks')),
                  ],
                ),
                const SizedBox(height: 12),
                const LinearProgressIndicator(value: 0.62, minHeight: 10),
                const SizedBox(height: 10),
                Text(
                  'Demo progress score: 62%. This area can later host Pomodoro history and life-wheel shortcuts.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
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
                  Text(
                    timer.formattedTime,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(modeLabel(timer.mode)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: controller.toggle,
              icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(timer.isRunning ? 'Pause' : 'Start'),
            ),
            const SizedBox(width: 12),
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

class _ToolStat extends StatelessWidget {
  const _ToolStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
