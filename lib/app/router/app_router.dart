import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/presentation/providers/auth_providers.dart';
import 'package:taskflow_ai/presentation/screens/analytics/analytics_screen.dart';
import 'package:taskflow_ai/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:taskflow_ai/presentation/screens/profile/profile_screen.dart';
import 'package:taskflow_ai/presentation/screens/tools/tools_screen.dart';

const _tabOrder = <String, int>{
  RouteNames.dashboard: 0,
  RouteNames.analytics: 1,
  RouteNames.tools: 2,
  RouteNames.profile: 3,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RouteNames.dashboard,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == RouteNames.splash ||
          location == RouteNames.login ||
          location == RouteNames.register ||
          location == RouteNames.verification) {
        return RouteNames.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) => _buildTabPage(
          state: state,
          route: RouteNames.dashboard,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        pageBuilder: (context, state) => _buildTabPage(
          state: state,
          route: RouteNames.dashboard,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.analytics,
        pageBuilder: (context, state) => _buildTabPage(
          state: state,
          route: RouteNames.analytics,
          child: const AnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.tools,
        pageBuilder: (context, state) => _buildTabPage(
          state: state,
          route: RouteNames.tools,
          child: const ToolsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.profile,
        pageBuilder: (context, state) => _buildTabPage(
          state: state,
          route: RouteNames.profile,
          child: const ProfileScreen(),
        ),
      ),
    ],
  );
});

CustomTransitionPage<void> _buildTabPage({
  required GoRouterState state,
  required String route,
  required Widget child,
}) {
  final newIndex = _tabOrder[route] ?? 0;
  final oldIndex = state.extra is int ? state.extra as int : newIndex;
  final direction = newIndex > oldIndex
      ? 1.0
      : newIndex < oldIndex
          ? -1.0
          : 0.0;

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: Offset(direction, 0),
        end: Offset.zero,
      ).animate(curve);
      final fade = Tween<double>(begin: 0.92, end: 1).animate(curve);

      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}
