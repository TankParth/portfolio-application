import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Floating "PT" mark with a slow breathing glow — the entry point to the
/// quick-actions sheet.
class PtOrb extends StatefulWidget {
  const PtOrb({super.key, required this.palette, required this.onTap});

  final SitePalette palette;
  final VoidCallback onTap;

  @override
  State<PtOrb> createState() => _PtOrbState();
}

class _PtOrbState extends State<PtOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Semantics(
      button: true,
      label: 'Quick actions',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _breath,
          builder: (_, child) => Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: p.brandGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: p.accent.withValues(alpha: .35 + .25 * _breath.value),
                  blurRadius: 16 + 14 * _breath.value,
                ),
              ],
            ),
            child: child,
          ),
          child: const Center(
            child: Text(
              'PT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
