import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Drifting coloured particles — the native twin of the site's
/// particle canvas. Loops forever; cheap enough for a background.
class ParticleField extends StatefulWidget {
  const ParticleField({super.key, this.count = 70, this.palette = SitePalette.dark});

  final int count;
  final SitePalette palette;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  late final List<_Particle> _particles = List.generate(
    widget.count,
    (i) => _Particle.random(math.Random(i * 7919)),
  );

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ParticlePainter(_particles, _clock, widget.palette),
      ),
    );
  }
}

class _Particle {
  _Particle.random(math.Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        vx = (r.nextDouble() - .5) * .6,
        vy = (r.nextDouble() - .5) * .6,
        radius = r.nextDouble() * 1.8 + .6,
        colorIndex = r.nextInt(3),
        phase = r.nextDouble() * math.pi * 2;

  final double x, y, vx, vy, radius, phase;
  final int colorIndex;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.clock, this.palette)
      : super(repaint: clock);

  final List<_Particle> particles;
  final Animation<double> clock;
  final SitePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    final colors = [palette.accent, palette.accent2, palette.accent3];
    final paint = Paint();
    for (final p in particles) {
      final dx = (p.x + p.vx * t) % 1.0;
      final dy = (p.y + p.vy * t) % 1.0;
      final twinkle = .45 + .35 * math.sin(p.phase + t * math.pi * 16);
      paint.color = colors[p.colorIndex].withValues(alpha: twinkle);
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.palette != palette;
}
