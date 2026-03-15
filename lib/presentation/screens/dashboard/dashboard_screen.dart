import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/core/theme/app_colors.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/presentation/providers/auth_providers.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_card.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_scaffold.dart';
import 'package:taskflow_ai/presentation/widgets/common/async_feedback.dart';
import 'package:taskflow_ai/presentation/widgets/common/section_title.dart';
import 'package:taskflow_ai/presentation/widgets/common/task_tile.dart';
import 'package:taskflow_ai/presentation/widgets/dashboard/task_composer_sheet.dart';
import 'package:taskflow_ai/presentation/widgets/dashboard/task_editor_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tasksState = ref.watch(tasksControllerProvider);
    final user = authState.session?.user;

    return AppScaffold(
      title: 'TaskFlow AI',
      currentRoute: RouteNames.dashboard,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text('Demo', style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ],
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const TaskComposerSheet(),
                );
              },
              label: const Text('New'),
              icon: const Icon(Icons.add),
            ),
      child: user == null
          ? const LoadingPane(label: 'Checking session...')
          : tasksState.when(
              data: (tasks) =>
                  _DashboardContent(userName: user.firstName, tasks: tasks),
              loading: () => const LoadingPane(label: 'Loading tasks...'),
              error: (error, _) => ErrorPane(
                message: error.toString(),
                onRetry: () =>
                    ref.read(tasksControllerProvider.notifier).refresh(),
              ),
            ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.userName, required this.tasks});

  final String userName;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final completed = tasks.where((task) => task.isCompleted).length;
    final active = tasks.length - completed;
    final today = active > 0 ? active : tasks.length;
    final search = ref.watch(taskSearchProvider);
    final filter = ref.watch(taskFilterProvider);
    final category = ref.watch(taskCategoryProvider);
    final categories = <String>{
      'all',
      ...tasks.map((task) => task.category).where((value) => value.isNotEmpty),
    }.toList()..sort();
    final visibleTasks = tasks.where((task) {
      final matchesSearch =
          search.isEmpty ||
          task.title.toLowerCase().contains(search.toLowerCase());
      final matchesFilter = switch (filter) {
        TaskListFilter.all => true,
        TaskListFilter.active => !task.isCompleted,
        TaskListFilter.completed => task.isCompleted,
      };
      final matchesCategory = category == 'all' || task.category == category;
      return matchesSearch && matchesFilter && matchesCategory;
    }).toList();

    return ListView(
      children: [
        Text(
          'Good morning',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium,
        ).animate().fadeIn(duration: 240.ms),
        const SizedBox(height: 6),
        Text(
          userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.displaySmall,
        ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.06),
        const SizedBox(height: 8),
        Text(
          'You have $today tasks in motion today.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyLarge,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            children: [
              const SectionTitle(
                title: 'Overview',
                subtitle: 'Calm, minimal daily snapshot',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'Today', value: '$today'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Done', value: '$completed'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Open', value: '$active'),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.03),
        const SizedBox(height: 18),
        AppCard(
          child: _FilterBar(
            categories: categories,
            selectedFilter: filter,
            selectedCategory: category,
          ),
        ).animate().fadeIn(duration: 340.ms),
        const SizedBox(height: 18),
        SectionTitle(
          title: 'Tasks',
          subtitle: visibleTasks.isEmpty
              ? 'No tasks match the current view'
              : '${visibleTasks.length} items in this view',
        ),
        const SizedBox(height: 12),
        if (visibleTasks.isEmpty)
          AppCard(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 160),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Text(
                    'No tasks match current filters.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          )
        else
          for (final task in visibleTasks)
            TaskTile(
              task: task,
              onToggle: () => ref
                  .read(tasksControllerProvider.notifier)
                  .toggleStatus(task.id),
              onEdit: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TaskEditorSheet(initialTask: task),
                );
              },
              onDelete: () => ref
                  .read(tasksControllerProvider.notifier)
                  .deleteTask(task.id),
            ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({
    required this.categories,
    required this.selectedFilter,
    required this.selectedCategory,
  });

  final List<String> categories;
  final TaskListFilter selectedFilter;
  final String selectedCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            onChanged: (value) =>
                ref.read(taskSearchProvider.notifier).state = value,
            decoration: const InputDecoration(
              hintText: 'Search tasks',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<TaskListFilter>(
                segments: const [
                  ButtonSegment(value: TaskListFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: TaskListFilter.active,
                    label: Text('Active'),
                  ),
                  ButtonSegment(
                    value: TaskListFilter.completed,
                    label: Text('Done'),
                  ),
                ],
                selected: {selectedFilter},
                onSelectionChanged: (selection) {
                  ref.read(taskFilterProvider.notifier).state = selection.first;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          items: categories
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item == 'all' ? 'All categories' : item),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(taskCategoryProvider.notifier).state = value;
            }
          },
          decoration: const InputDecoration(labelText: 'Category'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: textTheme.titleLarge),
          ),
        ],
      ),
    );
  }
}
