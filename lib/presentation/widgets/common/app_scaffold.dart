import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_ai/app/router/route_names.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.currentRoute,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final String currentRoute;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final destinations = <({String route, IconData icon, String label})>[
      (route: RouteNames.dashboard, icon: Icons.dashboard_outlined, label: 'Dashboard'),
      (route: RouteNames.analytics, icon: Icons.analytics_outlined, label: 'Analytics'),
      (route: RouteNames.tools, icon: Icons.timer_outlined, label: 'Tools'),
      (route: RouteNames.profile, icon: Icons.person_outline, label: 'Profile'),
    ];
    final currentIndex = destinations.indexWhere((item) => item.route == currentRoute);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: child,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
        onDestinationSelected: (index) {
          final route = destinations[index].route;
          if (route != currentRoute) {
            context.go(route, extra: currentIndex < 0 ? 0 : currentIndex);
          }
        },
      ),
    );
  }
}
