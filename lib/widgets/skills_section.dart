import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/constants/portfolio_data.dart';
import 'package:portfolio_website/models/portfolio_models.dart';
import 'package:portfolio_website/widgets/robotics_showcase_section.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'EXPERTISE', title: 'Skills'),
          const SizedBox(height: 32),
          const GoldDivider(),
          const SizedBox(height: 48),

          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoCol = constraints.maxWidth > 700;
              return isTwoCol
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildSkillCard(PortfolioData.skills[0])),
                        const SizedBox(width: 20),
                        Expanded(child: _buildSkillCard(PortfolioData.skills[1])),
                      ],
                    )
                  : Column(
                      children: PortfolioData.skills
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildSkillCard(s),
                              ))
                          .toList(),
                    );
            },
          ),

          const SizedBox(height: 20),

          // Third card full-width
          if (PortfolioData.skills.length > 2)
            _buildSkillCard(PortfolioData.skills[2]),

          const SizedBox(height: 60),

          // About me callout block
          _AboutBlock(),
        ],
      ),
    );
  }

  Widget _buildSkillCard(SkillCategory category) {
    return _SkillCard(category: category);
  }
}

class _SkillCard extends StatefulWidget {
  final SkillCategory category;
  const _SkillCard({required this.category});

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? AppConstants.gold.withAlpha(160)
                : AppConstants.glassBorder,
            width: 1.5,
          ),
          color: AppConstants.bgGlass,
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppConstants.gold.withAlpha(40),
                    blurRadius: 24,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.category.icon,
                        style: TextStyle(
                          fontSize: 20,
                          color: AppConstants.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.category.name,
                        style: AppConstants.sectionHeadingStyle(18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.category.skills.map((skill) {
                      return _SkillChip(skill: skill);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatefulWidget {
  final String skill;
  const _SkillChip({required this.skill});

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _hovered
              ? AppConstants.gold.withAlpha(25)
              : AppConstants.bgDeep.withAlpha(180),
          border: Border.all(
            color: _hovered ? AppConstants.gold : AppConstants.glassBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          widget.skill,
          style: AppConstants.badgeStyle.copyWith(
            fontSize: 12,
            color: _hovered ? AppConstants.gold : AppConstants.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── About Me callout ─────────────────────────────────────────
class _AboutBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 28 : 48),
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.glassBorder, width: 1),
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF091420),
            AppConstants.bgCard,
          ],
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _aboutContent(isMobile),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _aboutContent(isMobile),
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: _courseworkBlock(),
                ),
              ],
            ),
    );
  }

  List<Widget> _aboutContent(bool isMobile) => [
        Text('ABOUT', style: AppConstants.labelStyle),
        const SizedBox(height: 12),
        Text(
          PortfolioData.education,
          style: AppConstants.sectionHeadingStyle(isMobile ? 18 : 22),
        ),
        const SizedBox(height: 16),
        Text(PortfolioData.about, style: AppConstants.bodyStyle),
        if (isMobile) ...[const SizedBox(height: 30), _courseworkBlock()],
      ];

  Widget _courseworkBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COURSEWORK', style: AppConstants.labelStyle),
        const SizedBox(height: 14),
        ...PortfolioData.coursework.map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppConstants.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(c, style: AppConstants.bodyStyle.copyWith(fontSize: 14)),
              ],
            ),
          );
        }),
      ],
    );
  }
}