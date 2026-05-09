import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';

/// Full-width "widescreen" section inspired by Simon Sparks' project showcase panels.
/// Features a high-contrast dark panel with gold-accented CTA for Robotics wins.
class RoboticsShowcaseSection extends StatefulWidget {
  const RoboticsShowcaseSection({super.key});

  @override
  State<RoboticsShowcaseSection> createState() => _RoboticsShowcaseSectionState();
}

class _RoboticsShowcaseSectionState extends State<RoboticsShowcaseSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: isMobile ? 0 : 0),
      child: Stack(
        children: [
          // Dark base panel
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF03080F),
                  Color(0xFF060B14),
                  Color(0xFF0A1020),
                ],
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 50 : 80,
              horizontal: isMobile ? 24 : 80,
            ),
            child: isMobile
                ? _buildContent(isMobile)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _buildContent(isMobile)),
                      const SizedBox(width: 60),
                      Expanded(flex: 4, child: _buildRobotPanel()),
                    ],
                  ),
          ),

          // Gold left border accent
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => Container(
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppConstants.gold.withAlpha((200 * _glow.value).round()),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ROBOTICS', style: AppConstants.labelStyle),
        const SizedBox(height: 14),
        Text(
          'Competition\nWins',
          style: AppConstants.sectionHeadingStyle(isMobile ? 38 : 52).copyWith(
            color: AppConstants.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Competed in back-to-back robotics competitions, engineering combat bots from scratch with custom chassis, sensor arrays, and drive systems. Earned podium finishes at Roborumble\'24 and Concetto\'24.',
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 15,
            height: 1.75,
          ),
        ),
        const SizedBox(height: 36),

        // Achievement badges
        Row(
          children: [
            _AchievBadge(
              rank: '2nd',
              event: 'Roborumble\'24',
              color: AppConstants.gold,
            ),
            const SizedBox(width: 16),
            _AchievBadge(
              rank: '3rd',
              event: 'Concetto\'24',
              color: AppConstants.coral,
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Gold CTA
        _GoldBorderedButton(
          label: 'View Bot Projects',
          onTap: () {},
        ),

        if (isMobile) ...[
          const SizedBox(height: 40),
          _buildRobotPanel(),
        ],
      ],
    );
  }

  Widget _buildRobotPanel() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        height: 320,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppConstants.gold.withAlpha((120 * _glow.value).round()),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gradient stand-in (no real image — placeholder that looks premium)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A1828),
                      Color(0xFF030810),
                    ],
                  ),
                ),
              ),

              // Robot icon representation
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppConstants.gold, width: 2),
                        gradient: const RadialGradient(
                          colors: [Color(0xFF1A3060), Color(0xFF050C18)],
                        ),
                      ),
                      child: const Icon(
                        Icons.precision_manufacturing_rounded,
                        color: AppConstants.gold,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'RC DEFENSIVE BOT',
                      style: AppConstants.labelStyle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Roborumble\'24  ·  2nd Place',
                      style: AppConstants.bodyStyle.copyWith(
                        fontSize: 13,
                        color: AppConstants.gold.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),

              // Corner glows
              Positioned(
                top: -20, left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppConstants.gold.withAlpha((40 * _glow.value).round()),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievBadge extends StatelessWidget {
  final String rank;
  final String event;
  final Color color;
  const _AchievBadge({required this.rank, required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(160), width: 1.5),
        borderRadius: BorderRadius.circular(4),
        color: color.withAlpha(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            rank,
            style: AppConstants.sectionHeadingStyle(26).copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            event,
            style: AppConstants.badgeStyle.copyWith(
              color: AppConstants.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldBorderedButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GoldBorderedButton({required this.label, required this.onTap});

  @override
  State<_GoldBorderedButton> createState() => _GoldBorderedButtonState();
}

class _GoldBorderedButtonState extends State<_GoldBorderedButton> {
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
            gradient: _hovered ? AppConstants.goldButtonGradient : null,
            border: Border.all(color: AppConstants.gold, width: 1.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppConstants.gold.withAlpha(80),
                      blurRadius: 20,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppConstants.badgeStyle.copyWith(
                  color: _hovered ? AppConstants.bgDeep : AppConstants.gold,
                  fontSize: 13,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: _hovered ? AppConstants.bgDeep : AppConstants.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Expose reusable widgets for other sections
class SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  const SectionHeader({super.key, required this.label, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppConstants.labelStyle),
        const SizedBox(height: 10),
        Text(
          title,
          style: AppConstants.sectionHeadingStyle(
            MediaQuery.of(context).size.width < 700 ? 30 : 40,
          ),
        ),
      ],
    );
  }
}

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 1, color: AppConstants.gold),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppConstants.gold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: AppConstants.glassBorder),
        ),
      ],
    );
  }
}
