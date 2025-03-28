import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool animate;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.8),
              ],
            ),
          ),
          child: child,
        ),
      ),
    )
        .animate(
          target: animate ? 1 : 0,
          effects: [
            FadeEffect(duration: 400.ms),
            ScaleEffect(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 400.ms,
            ),
          ],
        );
  }
} 