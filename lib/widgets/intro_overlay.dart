import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config.dart';
import '../theme.dart';
import 'particle_field.dart';

/// Native launch sequence: particles, the "PT" mark popping in, the tech
/// stack orbiting it, then the name typed out. The website loads behind
/// this, so it hides network time instead of adding to it.
class IntroOverlay extends StatefulWidget {
  const IntroOverlay({super.key, required this.palette, required this.onFinished});

  /// The last-used theme, so the intro matches what the site will open in.
  final SitePalette palette;

  /// Fires once the animation has played through.
  final VoidCallback onFinished;

  @override
  State<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends State<IntroOverlay>
    with TickerProviderStateMixin {
  SitePalette get _p => widget.palette;
  static const _name = 'Parth Tank';

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinished();
    })
    ..forward();

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  Animation<double> _phase(double begin, double end, [Curve curve = Curves.easeOut]) =>
      CurvedAnimation(parent: _intro, curve: Interval(begin, end, curve: curve));

  late final _logo = _phase(0, .35, Curves.elasticOut);
  late final _orbit = _phase(.25, .6);
  late final _typing = _phase(.45, .8, Curves.linear);
  late final _tagline = _phase(.75, .95);

  @override
  void dispose() {
    _intro.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _p.bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ParticleField(count: 80, palette: _p),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildOrbit(),
                      ScaleTransition(scale: _logo, child: _buildMark()),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedBuilder(
                  animation: _typing,
                  builder: (_, _) {
                    final n = (_name.length * _typing.value).round();
                    return Text.rich(
                      TextSpan(children: [
                        TextSpan(text: _name.substring(0, n)),
                        TextSpan(
                          text: n < _name.length ? '▍' : '',
                          style: TextStyle(color: _p.accent2),
                        ),
                      ]),
                      style: TextStyle(
                        color: _p.text,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.8,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _tagline,
                  child: Text(
                    '// SOFTWARE DEVELOPER · JAIPUR, IN',
                    style: TextStyle(
                      color: _p.accent3,
                      fontSize: 11,
                      letterSpacing: 2.2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMark() {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: _p.brandGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: _p.accent.withValues(alpha: .55), blurRadius: 40),
        ],
      ),
      child: const Text(
        'PT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildOrbit() {
    return FadeTransition(
      opacity: _orbit,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, _) {
          const radius = 112.0;
          final base = _spin.value * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _p.accent.withValues(alpha: .25)),
                ),
              ),
              for (var i = 0; i < introStack.length; i++)
                Transform.translate(
                  offset: Offset.fromDirection(
                    base + i * 2 * math.pi / introStack.length,
                    radius,
                  ),
                  child: _pill(introStack[i], i),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _pill(String label, int i) {
    final tint = [_p.accent, _p.accent3, _p.accent2][i % 3];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _p.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: tint.withValues(alpha: .5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: tint, fontSize: 10, fontFamily: 'monospace'),
      ),
    );
  }
}
