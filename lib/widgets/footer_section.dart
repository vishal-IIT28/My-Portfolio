import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/constants/portfolio_data.dart';
import 'package:portfolio_website/widgets/robotics_showcase_section.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatefulWidget {
  const FooterSection({super.key});

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) return;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Column(
      children: [
        // Gold horizontal divider before footer
        Container(height: 1, color: AppConstants.glassBorder),

        // CTA Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 80,
            horizontal: isMobile ? 24 : 80,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF04080F),
                Color(0xFF060C18),
              ],
            ),
          ),
          child: Column(
            children: [
              Text('GET IN TOUCH', style: AppConstants.labelStyle),
              const SizedBox(height: 16),
              Text(
                'Let\'s Build\nSomething Together',
                textAlign: TextAlign.center,
                style: AppConstants.sectionHeadingStyle(isMobile ? 32 : 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Open for internships, collaborations, and interesting projects.',
                textAlign: TextAlign.center,
                style: AppConstants.bodyStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 40),

              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _FooterCTA(
                    label: 'LinkedIn',
                    icon: Icons.business_center_rounded,
                    isGold: true,
                    onTap: () => _launchUrl(PortfolioData.linkedinUrl),
                  ),
                  _FooterCTA(
                    label: 'GitHub',
                    icon: Icons.code_rounded,
                    isGold: false,
                    onTap: () => _launchUrl(PortfolioData.githubUrl),
                  ),
                  _FooterCTA(
                    label: 'Email Me',
                    icon: Icons.mail_outline_rounded,
                    isGold: false,
                    onTap: () => _launchUrl(PortfolioData.emailUrl),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bottom bar
        Container(
          height: 1,
          color: AppConstants.glassBorder,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: isMobile ? 24 : 80,
          ),
          color: AppConstants.bgDeep,
          child: isMobile
              ? Column(
                  children: [
                    _navLinks(),
                    const SizedBox(height: 12),
                    _copyright(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _copyright(),
                    _navLinks(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _copyright() {
    return Text(
      '© 2025 Vishal Kumar. All rights reserved.',
      style: AppConstants.bodyStyle.copyWith(
        fontSize: 12,
        color: AppConstants.textMuted,
      ),
    );
  }

  Widget _navLinks() {
    final links = ['Home', 'Projects', 'Skills', 'Contact'];
    return Wrap(
      spacing: 20,
      children: links.map((l) {
        return Text(
          l,
          style: AppConstants.navStyle.copyWith(
            fontSize: 12,
            color: AppConstants.textMuted,
          ),
        );
      }).toList(),
    );
  }
}

class _FooterCTA extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isGold;
  final VoidCallback onTap;
  const _FooterCTA({
    required this.label,
    required this.icon,
    required this.isGold,
    required this.onTap,
  });

  @override
  State<_FooterCTA> createState() => _FooterCTAState();
}

class _FooterCTAState extends State<_FooterCTA> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isGold ? AppConstants.gold : AppConstants.coral;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: _hovered && widget.isGold
                ? AppConstants.goldButtonGradient
                : _hovered
                    ? AppConstants.coralButtonGradient
                    : null,
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered
                ? [BoxShadow(color: color.withAlpha(80), blurRadius: 18)]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _hovered ? AppConstants.bgDeep : color,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: AppConstants.badgeStyle.copyWith(
                  color: _hovered ? AppConstants.bgDeep : color,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
