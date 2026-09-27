import 'package:flutter/material.dart';

import '../theme.dart';
import 'particle_field.dart';

/// Shown when the live site can't be reached. Ripples out from the icon
/// like a signal searching for a connection.
class OfflineView extends StatefulWidget {
  const OfflineView({super.key, required this.palette, required this.onRetry});

  final SitePalette palette;

  final VoidCallback onRetry;

  @override
  State<OfflineView> createState() => _OfflineViewState();
}

class _OfflineViewState extends State<OfflineView>
    with SingleTickerProviderStateMixin {
  SitePalette get _p => widget.palette;

  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _p.bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ParticleField(count: 40, palette: _p),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 140,
                    child: AnimatedBuilder(
                      animation: _ripple,
                      builder: (_, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          for (var i = 0; i < 3; i++) _ring((_ripple.value + i / 3) % 1),
                          Icon(Icons.wifi_off_rounded, size: 44, color: _p.accent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Can't reach the portfolio",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _p.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The app shows the live site, so it needs a connection.\nCheck your internet and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _p.text2, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _p.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double t) {
    return Container(
      width: 50 + 90 * t,
      height: 50 + 90 * t,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _p.accent.withValues(alpha: (1 - t) * .6), width: 1.5),
      ),
    );
  }
}
