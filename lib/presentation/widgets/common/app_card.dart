import 'package:flutter/material.dart';
import 'package:taskflow_ai/core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkDivider
              : AppColors.divider,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D101828),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
  }
}
