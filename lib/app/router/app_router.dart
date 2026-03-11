import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_ai/app/router/route_names.dart';
import 'package:taskflow_ai/presentation/providers/auth_providers.dart';
import 'package:taskflow_ai/presentation/screens/analytics/analytics_screen.dart';
import 'package:taskflow_ai/presentation/screens/dashboard/dashboard_screen.dart';

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
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});
