import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/constants/portfolio_data.dart';
import 'package:portfolio_website/widgets/robotics_showcase_section.dart';

class ExperienceEducationSection extends StatelessWidget {
  const ExperienceEducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'BACKGROUND', title: 'Education'),
          const SizedBox(height: 32),
          const GoldDivider(),
          const SizedBox(height: 48),

          // Education card
          _EduCard(),
        ],
      ),
    );
  }
}

class _EduCard extends StatefulWidget {
  @override
  State<_EduCard> createState() => _EduCardState();
}

class _EduCardState extends State<_EduCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? AppConstants.gold.withAlpha(180)
                : AppConstants.glassBorder,
            width: 1.5,
          ),
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
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A1828),
                    AppConstants.bgCard,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(36),
              child: LayoutBuilder(builder: (context, constraints) {
                final isTwoCol = constraints.maxWidth > 600;
                return isTwoCol
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _eduDetails()),
                          const SizedBox(width: 40),
                          Expanded(flex: 2, child: _statsColumn()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _eduDetails(),
                          const SizedBox(height: 30),
                          _statsColumn(),
                        ],
                      );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _eduDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Institution
        Row(
          children: [
            const Icon(Icons.school_rounded, color: AppConstants.gold, size: 20),
            const SizedBox(width: 10),
            Text(
              'IIT (ISM) Dhanbad',
              style: AppConstants.sectionHeadingStyle(22),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'B.Tech — Electronics & Communication Engineering',
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 15,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '2022 – 2026',
          style: AppConstants.labelStyle.copyWith(
            color: AppConstants.gold.withAlpha(160),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 24),

        // GPA stat
        Row(
          children: [
            _StatBox(label: 'GPA', value: '6.73'),
            const SizedBox(width: 16),
            _StatBox(label: 'JEE AIR', value: '1713'),
          ],
        ),

        const SizedBox(height: 28),
        Text('COURSEWORK', style: AppConstants.labelStyle),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: PortfolioData.coursework.map((c) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppConstants.bgDeep.withAlpha(180),
                border: Border.all(color: AppConstants.glassBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                c,
                style: AppConstants.badgeStyle.copyWith(
                  fontSize: 12,
                  color: AppConstants.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _statsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACHIEVEMENTS', style: AppConstants.labelStyle),
        const SizedBox(height: 16),
        ...PortfolioData.badges.map((b) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppConstants.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b,
                    style: AppConstants.bodyStyle.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.gold.withAlpha(120)),
        borderRadius: BorderRadius.circular(4),
        color: AppConstants.gold.withAlpha(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppConstants.sectionHeadingStyle(24).copyWith(
              color: AppConstants.gold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppConstants.labelStyle.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}