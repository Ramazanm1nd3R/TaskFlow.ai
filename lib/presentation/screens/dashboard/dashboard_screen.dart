import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/core/theme/app_colors.dart';
import 'package:taskflow_ai/domain/entities/task.dart';
import 'package:taskflow_ai/presentation/providers/auth_providers.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_scaffold.dart';
import 'package:taskflow_ai/presentation/widgets/common/async_feedback.dart';
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
      actions: [
        IconButton(
          onPressed: () => context.push(RouteNames.analytics),
          icon: const Icon(Icons.analytics_outlined),
          tooltip: 'Analytics',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              'Demo Mode',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
              label: const Text('New task'),
              icon: const Icon(Icons.add),
            ),
      child: user == null
          ? const LoadingPane(label: 'Checking session...')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F3FF), Color(0xFFF5F9FF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, ${user.firstName}', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        'App starts directly with a local demo account and seeded dashboard data.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: tasksState.when(
                    data: (tasks) => _DashboardContent(tasks: tasks),
                    loading: () => const LoadingPane(label: 'Loading tasks...'),
                    error: (error, _) => ErrorPane(
                      message: error.toString(),
                      onRetry: () => ref.read(tasksControllerProvider.notifier).refresh(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final active = tasks.length - completed;
    final search = ref.watch(taskSearchProvider);
    final filter = ref.watch(taskFilterProvider);
    final category = ref.watch(taskCategoryProvider);
    final categories = <String>{
      'all',
      ...tasks.map((task) => task.category).where((value) => value.isNotEmpty),
    }.toList()
      ..sort();
    final visibleTasks = tasks.where((task) {
      final matchesSearch = search.isEmpty ||
          task.title.toLowerCase().contains(search.toLowerCase());
      final matchesFilter = switch (filter) {
        TaskListFilter.all => true,
        TaskListFilter.active => !task.isCompleted,
        TaskListFilter.completed => task.isCompleted,
      };
      final matchesCategory = category == 'all' || task.category == category;
      return matchesSearch && matchesFilter && matchesCategory;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(child: _StatCard(label: 'Total', value: '${tasks.length}')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Active', value: '$active')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Done', value: '$completed')),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: _FilterBar(
            categories: categories,
            selectedFilter: filter,
            selectedCategory: category,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        if (visibleTasks.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No tasks match current filters.')),
          )
        else
          SliverList.builder(
            itemCount: visibleTasks.length,
            itemBuilder: (context, index) {
              final task = visibleTasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.title,
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 6),
                                Text('${task.category} • ${task.priority.name}'),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(task.status.name),
                            backgroundColor: task.isCompleted
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.warning.withValues(alpha: 0.12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => ref
                                .read(tasksControllerProvider.notifier)
                                .toggleStatus(task.id),
                            icon: Icon(task.isCompleted
                                ? Icons.radio_button_unchecked
                                : Icons.check_circle_outline),
                            label: Text(task.isCompleted ? 'Reopen' : 'Complete'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => TaskEditorSheet(initialTask: task),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => ref
                                .read(tasksControllerProvider.notifier)
                                .deleteTask(task.id),
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
      children: [
        TextField(
          onChanged: (value) => ref.read(taskSearchProvider.notifier).state = value,
          decoration: const InputDecoration(
            hintText: 'Search tasks',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<TaskListFilter>(
                segments: const [
                  ButtonSegment(value: TaskListFilter.all, label: Text('All')),
                  ButtonSegment(value: TaskListFilter.active, label: Text('Active')),
                  ButtonSegment(value: TaskListFilter.completed, label: Text('Done')),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
