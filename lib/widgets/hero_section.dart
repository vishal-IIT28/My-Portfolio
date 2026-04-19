import 'dart:math';
import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/constants/portfolio_data.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _sphereController;
  late AnimationController _fadeController;
  late Animation<double> _sphereRotate;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _sphereController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _sphereRotate = Tween<double>(begin: 0, end: 2 * pi).animate(_sphereController);

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _sphereController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return SizedBox(
      width: double.infinity,
      height: isMobile ? null : size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative thin gold horizontal rule (top of hero)
          Positioned(
            top: isMobile ? 100 : 110,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: Container(
                  width: 80,
                  height: 1,
                  color: AppConstants.gold.withAlpha(120),
                ),
              ),
            ),
          ),

          // Main hero content
          Padding(
            padding: EdgeInsets.only(
              top: isMobile ? 120 : 0,
              bottom: isMobile ? 60 : 0,
              left: isMobile ? 24 : 60,
              right: isMobile ? 24 : 60,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label above name
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    'PORTFOLIO',
                    style: AppConstants.labelStyle,
                  ),
                ),
                const SizedBox(height: 18),

                // Name — large serif
                SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppConstants.nameGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        PortfolioData.name,
                        textAlign: TextAlign.center,
                        style: AppConstants.heroNameStyle(isMobile ? 42 : 72),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 3D Sphere orb
                FadeTransition(
                  opacity: _fadeIn,
                  child: AnimatedBuilder(
                    animation: _sphereRotate,
                    builder: (context, _) {
                      return _GlowOrb(
                        rotation: _sphereRotate.value,
                        size: isMobile ? 110 : 150,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Subtitle line
                SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Text(
                      'ECE Undergrad  ·  Full-Stack Dev  ·  Robotics',
                      textAlign: TextAlign.center,
                      style: AppConstants.bodyStyle.copyWith(
                        fontSize: isMobile ? 15 : 18,
                        color: AppConstants.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // College
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    PortfolioData.college,
                    style: AppConstants.labelStyle.copyWith(
                      color: AppConstants.gold.withAlpha(180),
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // CTA Buttons
                SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _GoldButton(
                          label: 'View Projects',
                          onTap: () {},
                        ),
                        _OutlineButton(
                          label: 'Contact Me',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Achievement badges
                FadeTransition(
                  opacity: _fadeIn,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: PortfolioData.badges.asMap().entries.map((e) {
                      return _HeroBadge(
                        text: e.value,
                        isGold: e.key == 0 || e.key == 2,
                        delay: e.key * 120,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Scroll indicator
          Positioned(
            bottom: 24,
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  Text('scroll', style: AppConstants.labelStyle.copyWith(fontSize: 10)),
                  const SizedBox(height: 6),
                  const _ScrollArrow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3D Glowing Orb ──────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final double rotation;
  final double size;
  const _GlowOrb({required this.rotation, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OrbPainter(rotation),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Outer glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
      ..color = const Color(0x55D4AF37);
    canvas.drawCircle(Offset(cx, cy), r * 0.85, glowPaint);

    // Base sphere gradient
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.3 + sin(t) * 0.2, -0.3 + cos(t) * 0.2),
        radius: 0.85,
        colors: const [
          Color(0xFF2A4A8A),
          Color(0xFF0D1F40),
          Color(0xFF060E1E),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r * 0.78, basePaint);

    // Gold shimmer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xAAD4AF37);
    canvas.drawCircle(Offset(cx, cy), r * 0.78, ringPaint);

    // Moving highlight
    final hlPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.4 + cos(t) * 0.3, -0.4 + sin(t) * 0.3),
        radius: 0.5,
        colors: const [Color(0x88E8D470), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r * 0.78, hlPaint);

    // Orbit ring
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(t * 0.4);
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0x55D4AF37);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 1.6, height: r * 0.4),
      orbitPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => old.t != t;
}

// ─── Buttons ─────────────────────────────────────────────────
class _GoldButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GoldButton({required this.label, required this.onTap});

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: _hovered
                ? const LinearGradient(
                    colors: [Color(0xFFE8C84A), Color(0xFFD4AF37)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppConstants.goldButtonGradient,
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppConstants.gold.withAlpha(100),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: AppConstants.badgeStyle.copyWith(
              color: AppConstants.bgDeep,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered
                ? AppConstants.gold.withAlpha(20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered ? AppConstants.gold : AppConstants.glassBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.label,
            style: AppConstants.badgeStyle.copyWith(
              color: _hovered ? AppConstants.gold : AppConstants.textSecondary,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Badge ──────────────────────────────────────────────
class _HeroBadge extends StatefulWidget {
  final String text;
  final bool isGold;
  final int delay;
  const _HeroBadge({required this.text, required this.isGold, required this.delay});

  @override
  State<_HeroBadge> createState() => _HeroBadgeState();
}

class _HeroBadgeState extends State<_HeroBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2400 + widget.delay),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -4, end: 4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isGold ? AppConstants.gold : AppConstants.coral;
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppConstants.bgGlass,
          border: Border.all(color: accent.withAlpha(160), width: 1),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: accent.withAlpha(40),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: AppConstants.badgeStyle.copyWith(
            color: accent,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ─── Scroll Arrow ───────────────────────────────────────────
class _ScrollArrow extends StatefulWidget {
  const _ScrollArrow();

  @override
  State<_ScrollArrow> createState() => _ScrollArrowState();
}

class _ScrollArrowState extends State<_ScrollArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: 8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _bounce.value),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppConstants.gold.withAlpha(160),
          size: 22,
        ),
      ),
    );
  }
}