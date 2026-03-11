import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/presentation/providers/auth_providers.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_scaffold.dart';
import 'package:taskflow_ai/presentation/widgets/common/async_feedback.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tasksAsync = ref.watch(tasksControllerProvider);
    final user = authState.session?.user;

    return AppScaffold(
      title: 'Profile',
      currentRoute: RouteNames.profile,
      child: user == null
          ? const LoadingPane(label: 'Loading profile...')
          : tasksAsync.when(
              data: (tasks) => _ProfileContent(user: user, tasks: tasks),
              loading: () => const LoadingPane(label: 'Loading profile...'),
              error: (error, _) => ErrorPane(
                message: error.toString(),
                onRetry: () => ref.read(tasksControllerProvider.notifier).refresh(),
              ),
            ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    required this.tasks,
  });

  final dynamic user;
  final List<dynamic> tasks;

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed = tasks.where((task) => task.isCompleted).length;
    final active = total - completed;
    final focusHours = ((completed * 35) / 60).ceil();

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(user.firstName.substring(0, 1)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      const Chip(label: Text('Demo account')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _ProfileStat(label: 'Tasks', value: '$total')),
            const SizedBox(width: 12),
            Expanded(child: _ProfileStat(label: 'Done', value: '$completed')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ProfileStat(label: 'Active', value: '$active')),
            const SizedBox(width: 12),
            Expanded(child: _ProfileStat(label: 'Focus hours', value: '$focusHours')),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About demo profile', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  'This screen is now fed by the same demo session and task state as the rest of the app. Next step can expand it with editable settings, achievements and activity history.',
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

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

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
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
