import 'dart:math';
import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';

/// Deep Navy background with royal-blue mesh glows in corners and subtle animated orbs.
class NavyMeshBackground extends StatefulWidget {
  const NavyMeshBackground({super.key});

  @override
  State<NavyMeshBackground> createState() => _NavyMeshBackgroundState();
}

class _NavyMeshBackgroundState extends State<NavyMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base deep navy fill
        Container(color: AppConstants.bgDeep),

        // Top-left mesh glow — Royal Blue
        Positioned(
          top: -200,
          left: -200,
          child: Container(
            width: 700,
            height: 700,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x55163A8C), Color(0x001040A0)],
                radius: 0.6,
              ),
            ),
          ),
        ),

        // Bottom-right mesh glow — Deeper Blue
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 600,
            height: 600,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x440A2D70), Color(0x001040A0)],
                radius: 0.65,
              ),
            ),
          ),
        ),

        // Top-right subtle glow
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x221A4090), Colors.transparent],
                radius: 0.7,
              ),
            ),
          ),
        ),

        // Animated floating orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _MeshOrbPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class _MeshOrbPainter extends CustomPainter {
  final double t;
  _MeshOrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Very subtle floating specks — give depth
    final orbData = [
      (0.15, 0.25, 180.0, const Color(0x0A1A50D0)),
      (0.75, 0.15, 220.0, const Color(0x081030A0)),
      (0.35, 0.70, 160.0, const Color(0x0A0D40B0)),
      (0.85, 0.65, 200.0, const Color(0x061A3080)),
    ];

    for (final orb in orbData) {
      final dx = size.width * orb.$1 + sin((t + orb.$1) * 2 * pi) * 40;
      final dy = size.height * orb.$2 + cos((t + orb.$2) * 2 * pi) * 35;
      paint.color = orb.$4;
      canvas.drawCircle(Offset(dx, dy), orb.$3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshOrbPainter old) => old.t != t;
}
