import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/constants/portfolio_data.dart';
import 'package:portfolio_website/widgets/cyber_background.dart';
import 'package:portfolio_website/widgets/hero_section.dart';
import 'package:portfolio_website/widgets/projects_section.dart';
import 'package:portfolio_website/widgets/skills_section.dart';
import 'package:portfolio_website/widgets/robotics_showcase_section.dart';
import 'package:portfolio_website/widgets/experience_education_section.dart';
import 'package:portfolio_website/widgets/footer_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vishal Kumar — Portfolio',
      theme: AppConstants.darkTheme,
      home: const PortfolioHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final ScrollController _scrollController = ScrollController();

  // Section keys for scroll-to navigation
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();

  // Nav becomes frosted-glass after scrolling past hero
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final didScroll = _scrollController.offset > 80;
      if (didScroll != _scrolled) setState(() => _scrolled = didScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDeep,
      body: Stack(
        children: [
          // ── Fixed background
          const Positioned.fill(child: NavyMeshBackground()),

          // ── Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Space for floating nav
                const SizedBox(height: 0),

                HeroSection(key: _heroKey),

                // Gold divider between sections
                _SectionDivider(),

                ProjectsSection(key: _projectsKey),

                // Widescreen robotics showcase
                const RoboticsShowcaseSection(),

                _SectionDivider(),

                SkillsSection(key: _skillsKey),

                _SectionDivider(),

                ExperienceEducationSection(key: _experienceKey),

                _SectionDivider(),

                const FooterSection(),
              ],
            ),
          ),

          // ── Floating Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _FloatingNavBar(
              scrolled: _scrolled,
              isMobile: MediaQuery.of(context).size.width < 700,
              onHome: () => _scrollToSection(_heroKey),
              onProjects: () => _scrollToSection(_projectsKey),
              onSkills: () => _scrollToSection(_skillsKey),
              onExperience: () => _scrollToSection(_experienceKey),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Divider ─────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 700 ? 24 : 60,
      ),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: AppConstants.glassBorder)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppConstants.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: AppConstants.glassBorder)),
        ],
      ),
    );
  }
}

// ─── Floating Nav Bar ────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final bool scrolled;
  final bool isMobile;
  final VoidCallback onHome;
  final VoidCallback onProjects;
  final VoidCallback onSkills;
  final VoidCallback onExperience;

  const _FloatingNavBar({
    required this.scrolled,
    required this.isMobile,
    required this.onHome,
    required this.onProjects,
    required this.onSkills,
    required this.onExperience,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: scrolled
            ? AppConstants.bgDeep.withAlpha(180)
            : Colors.transparent,
        border: scrolled
            ? const Border(
                bottom: BorderSide(color: AppConstants.glassBorder, width: 1),
              )
            : null,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: scrolled
              ? ImageFilter.blur(sigmaX: 18, sigmaY: 18)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: isMobile ? 20 : 60,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo / Monogram
                  GestureDetector(
                    onTap: onHome,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppConstants.gold, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (rect) =>
                                  AppConstants.nameGradient.createShader(rect),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'VK',
                                style: AppConstants.sectionHeadingStyle(13).copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 10),
                          Text(
                            PortfolioData.name,
                            style: AppConstants.navStyle.copyWith(
                              color: AppConstants.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Nav links or hamburger
                  if (isMobile)
                    _MobileMenu(
                      onHome: onHome,
                      onProjects: onProjects,
                      onSkills: onSkills,
                      onExperience: onExperience,
                    )
                  else
                    Row(
                      children: [
                        _NavLink(label: 'Home', onTap: onHome),
                        _NavLink(label: 'Projects', onTap: onProjects),
                        _NavLink(label: 'Skills', onTap: onSkills),
                        _NavLink(label: 'Experience', onTap: onExperience),
                      ],
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

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppConstants.navStyle.copyWith(
                  color: _hovered ? AppConstants.gold : AppConstants.textSecondary,
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 1.5,
                width: _hovered ? 20 : 0,
                color: AppConstants.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onProjects;
  final VoidCallback onSkills;
  final VoidCallback onExperience;

  const _MobileMenu({
    required this.onHome,
    required this.onProjects,
    required this.onSkills,
    required this.onExperience,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppConstants.bgGlass,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppConstants.glassBorder),
      ),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.glassBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.menu, color: AppConstants.textPrimary, size: 18),
      ),
      onSelected: (value) {
        switch (value) {
          case 'home': onHome(); break;
          case 'projects': onProjects(); break;
          case 'skills': onSkills(); break;
          case 'experience': onExperience(); break;
        }
      },
      itemBuilder: (_) => [
        _menuItem('home', 'Home', Icons.home_outlined),
        _menuItem('projects', 'Projects', Icons.work_outline_rounded),
        _menuItem('skills', 'Skills', Icons.code_rounded),
        _menuItem('experience', 'Education', Icons.school_outlined),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppConstants.gold),
          const SizedBox(width: 10),
          Text(label, style: AppConstants.navStyle),
        ],
      ),
    );
  }
}
