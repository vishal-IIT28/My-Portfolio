import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/constants/portfolio_data.dart';
import 'package:portfolio_website/models/portfolio_models.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  ProjectCategory _selectedCategory = ProjectCategory.all;

  List<Project> get _filteredProjects {
    if (_selectedCategory == ProjectCategory.all) return PortfolioData.projects;
    return PortfolioData.projects.where((p) => p.category == _selectedCategory).toList();
  }

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
          // Section header
          _SectionHeader(label: 'FEATURED WORK', title: 'Projects'),
          const SizedBox(height: 40),

          // Gold divider
          const _GoldDivider(),
          const SizedBox(height: 40),

          // Filter pills
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ProjectCategory.values.map((cat) {
              final isActive = _selectedCategory == cat;
              return _FilterPill(
                label: cat.name.toUpperCase(),
                isActive: isActive,
                onTap: () => setState(() => _selectedCategory = cat),
              );
            }).toList(),
          ),

          const SizedBox(height: 50),

          // Project grid — vertically elongated cards
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  // Vertically elongated — taller cards like Simon Sparks
                  childAspectRatio: columns == 1 ? 1.3 : 0.85,
                ),
                itemCount: _filteredProjects.length,
                itemBuilder: (context, index) {
                  return _ProjectCard(
                    project: _filteredProjects[index],
                    index: index,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Project Card ─────────────────────────────────────────────
class _ProjectCard extends StatefulWidget {
  final Project project;
  final int index;
  const _ProjectCard({required this.project, required this.index});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _categoryColor {
    switch (widget.project.category) {
      case ProjectCategory.software:
        return AppConstants.coral;
      case ProjectCategory.electronics:
        return const Color(0xFF7B61FF);
      case ProjectCategory.robotics:
        return AppConstants.gold;
      default:
        return AppConstants.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered
                  ? AppConstants.gold.withAlpha(200)
                  : AppConstants.glassBorder,
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppConstants.gold.withAlpha(60),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Card gradient background derived from project
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(widget.project.gradientStart),
                        Color(widget.project.gradientEnd),
                        AppConstants.bgCard,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Hover overlay shimmer
                if (_hovered)
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.2,
                        colors: [
                          AppConstants.gold.withAlpha(20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _categoryColor.withAlpha(30),
                          border: Border.all(color: _categoryColor.withAlpha(120), width: 1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          widget.project.category.name.toUpperCase(),
                          style: AppConstants.labelStyle.copyWith(
                            color: _categoryColor,
                            fontSize: 10,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        widget.project.title,
                        style: AppConstants.sectionHeadingStyle(22).copyWith(
                          color: AppConstants.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        widget.project.subtitle,
                        style: AppConstants.labelStyle.copyWith(
                          color: AppConstants.gold.withAlpha(180),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Description
                      Expanded(
                        child: Text(
                          widget.project.description,
                          style: AppConstants.bodyStyle.copyWith(
                            fontSize: 14,
                            height: 1.7,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ),

                      // Achievement pill
                      if (widget.project.achievement != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppConstants.goldButtonGradient,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            widget.project.achievement!,
                            style: AppConstants.badgeStyle.copyWith(
                              color: AppConstants.bgDeep,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Tech chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.project.technologies.map((tech) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppConstants.bgDeep.withAlpha(160),
                              border: Border.all(
                                  color: AppConstants.glassBorder, width: 1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              tech,
                              style: AppConstants.badgeStyle.copyWith(
                                fontSize: 11,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Filter Pill ──────────────────────────────────────────────
class _FilterPill extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.isActive, required this.onTap});

  @override
  State<_FilterPill> createState() => _FilterPillState();
}

class _FilterPillState extends State<_FilterPill> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            gradient: widget.isActive ? AppConstants.goldButtonGradient : null,
            color: widget.isActive ? null : AppConstants.bgCard,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: widget.isActive || _hovered
                  ? AppConstants.gold
                  : AppConstants.glassBorder,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: AppConstants.badgeStyle.copyWith(
              color: widget.isActive
                  ? AppConstants.bgDeep
                  : (_hovered ? AppConstants.gold : AppConstants.textSecondary),
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable section header ─────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  const _SectionHeader({required this.label, required this.title});

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

// ─── Gold horizontal divider ─────────────────────────────────
class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 1, color: AppConstants.gold),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppConstants.gold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: AppConstants.glassBorder,
          ),
        ),
      ],
    );
  }
}