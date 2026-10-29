import 'package:flutter/material.dart';
import 'app_theme.dart';

class SoftUiSurface extends StatelessWidget {
  const SoftUiSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 24,
    this.color,
    this.pressed = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: AppTheme.softDecoration(
        context,
        radius: radius,
        color: color,
        pressed: pressed,
      ),
      child: child,
    );
  }
}
