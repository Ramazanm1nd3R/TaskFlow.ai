import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/core/theme/app_colors.dart';
import 'package:taskflow_ai/presentation/providers/auth_providers.dart';
import 'package:taskflow_ai/presentation/providers/task_providers.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_card.dart';
import 'package:taskflow_ai/presentation/widgets/common/app_scaffold.dart';
import 'package:taskflow_ai/presentation/widgets/common/async_feedback.dart';
import 'package:taskflow_ai/presentation/widgets/common/section_title.dart';

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
                onRetry: () =>
                    ref.read(tasksControllerProvider.notifier).refresh(),
              ),
            ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user, required this.tasks});

  final dynamic user;
  final List<dynamic> tasks;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = tasks.length;
    final completed = tasks.where((task) => task.isCompleted).length;
    final active = total - completed;
    final focusHours = ((completed * 35) / 60).ceil();

    return ListView(
      children: [
        const SectionTitle(
          title: 'Profile',
          subtitle: 'Apple Settings inspired account summary.',
        ).animate().fadeIn(duration: 240.ms),
        const SizedBox(height: 16),
        AppCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.cardMuted,
                child: Text(
                  user.firstName.substring(0, 1),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    const Chip(label: Text('Demo account')),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ProfileStat(label: 'Tasks', value: '$total'),
            _ProfileStat(label: 'Done', value: '$completed'),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ProfileStat(label: 'Active', value: '$active'),
            _ProfileStat(label: 'Focus hours', value: '$focusHours'),
          ],
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Settings',
                subtitle: 'Notion-simple, Apple-clean',
              ),
              const SizedBox(height: 8),
              _SettingTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'Prepared for light and dark theme support',
              ),
              _SettingTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Pomodoro and digest preferences will live here',
              ),
              _SettingTile(
                icon: Icons.auto_awesome_outlined,
                title: 'AI Insights',
                subtitle: 'OpenAI powered recommendations and wheel analysis',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'About',
                subtitle: 'Current workspace state',
              ),
              const SizedBox(height: 8),
              Text(
                'This screen keeps the existing state model intact and only reshapes the experience into a more native iOS settings layout.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ],
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
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 160,
      child: AppCard(
        padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.cardMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
    );
  }
}
