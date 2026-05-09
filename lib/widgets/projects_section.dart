import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/constants/portfolio_data.dart';
import 'package:portfolio_website/models/dynamic_project.dart';
import 'package:portfolio_website/services/database_service.dart';
import 'package:portfolio_website/widgets/dynamic_project_card.dart';

// ─── Static fallback data (shown when Supabase is offline / no credentials) ──
List<DynamicProject> _staticFallbackProjects() {
  return PortfolioData.projects.asMap().entries.map((entry) {
    final i = entry.key;
    final p = entry.value;
    return DynamicProject(
      id: 'static_$i',
      title: p.title,
      subtitle: p.subtitle,
      description: p.description,
      objective: _objectiveFor(p.title),
      outcome: _outcomeFor(p.title),
      techStack: List<String>.from(p.technologies),
      imageUrl: '',
      pdfUrl: p.title.contains('EQ') ? 'placeholder' : null,
      githubUrl: PortfolioData.githubUrl,
      category: p.category.name,
      achievement: p.achievement,
      createdAt: DateTime.now(),
      codeSnippet: _snippetFor(p.title),
      codeLanguage: _langFor(p.title),
    );
  }).toList();
}

String _objectiveFor(String title) {
  switch (title) {
    case 'JellyChat':
      return 'Build a production-grade real-time messaging platform that replaces '
          'sterile chat UIs with multi-persona emotional AI—enabling users to hold '
          'natural, context-aware conversations with distinct AI personalities.';
    case '3-Band Audio EQ':
      return 'Design and fabricate a hardware 3-band audio equalizer using OPAMP '
          'active filters, demonstrating mastery of analog signal processing for '
          'professional-grade audio manipulation.';
    case 'Verilog HDL Designs':
      return 'Implement and verify a suite of digital circuits—from combinational '
          'ALUs to pipelined processors—entirely in Verilog HDL, targeting real FPGA '
          'synthesis and timing closure.';
    case 'RC Defensive Bot':
      return 'Engineer a combat-ready remote-controlled robot optimized for defensive '
          'strategy at Roborumble\'24, minimizing mechanical failure under sustained '
          'impact while maximizing opponent contact area.';
    case 'Manual Armed Rover':
      return 'Build a manually controlled armed rover capable of precision weapon '
          'deployment for Concetto\'24, featuring servo-driven actuators and a robust '
          'drive train under competition constraints.';
    default:
      return '';
  }
}

String _outcomeFor(String title) {
  switch (title) {
    case 'JellyChat':
      return '🚀 Deployed full-stack messaging platform with <100 ms real-time latency. '
          'Supports 6 AI personas, multilingual input, persistent chat history, '
          'Google OAuth, and an animated GIF picker.';
    case '3-Band Audio EQ':
      return '🎵 Successfully fabricated and verified PCB. Bass/mid/treble bands '
          'achieved flat passband response within ±1.5 dB. Presented circuit '
          'diagrams as part of ECE lab coursework at IIT (ISM) Dhanbad.';
    case 'Verilog HDL Designs':
      return '✅ All designs synthesized on Xilinx FPGA with zero critical warnings. '
          'Pipelined processor achieved 4-stage execution with correct hazard '
          'forwarding, verified on ModelSim testbenches.';
    case 'RC Defensive Bot':
      return '🥈 Secured 2nd Place at Roborumble\'24. Chassis withstood 15+ direct '
          'hits without structural failure. Layered armor design eliminated opponent '
          'flipper access to undercarriage.';
    case 'Manual Armed Rover':
      return '🥉 Won 3rd Place at Concetto\'24. Servo weapon system delivered precise '
          'targeting. Drive train maintained full mobility throughout all match rounds.';
    default:
      return '';
  }
}

String? _snippetFor(String title) {
  if (title == 'JellyChat') {
    return "// Real-time message stream\nsupabase.from('messages')\n  .stream(primaryKey: ['id'])\n  .listen((data) => _updateUI(data));";
  }
  if (title == 'Verilog HDL Designs') {
    return "// 4-stage pipelined ALU\nalways @(posedge clk) begin\n  EX_MEM <= {alu_result, rd};\nend";
  }
  return null;
}

String? _langFor(String title) {
  if (title == 'JellyChat') return 'Dart';
  if (title == 'Verilog HDL Designs') return 'Verilog';
  return null;
}

// ─── Projects Section ────────────────────────────────────────────────────────
class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  late Future<List<DynamicProject>> _projectsFuture;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _projectsFuture = _loadProjects();
  }

  Future<List<DynamicProject>> _loadProjects() async {
    final service = SupabaseService();
    if (service.isInitialized) {
      final dynamic_ = await service.fetchDynamicProjects();
      if (dynamic_.isNotEmpty) return dynamic_;
    }
    // Graceful fallback to static portfolio data
    return _staticFallbackProjects();
  }

  List<DynamicProject> _filtered(List<DynamicProject> all) {
    if (_selectedCategory == 'all') return all;
    return all.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──────────────────────────────────
          _SectionHeader(label: 'FEATURED WORK', title: 'Projects'),
          const SizedBox(height: 40),
          const _GoldDivider(),
          const SizedBox(height: 40),

          // ── Filter Tabs ─────────────────────────────────────
          _CategoryTabs(
            selected: _selectedCategory,
            onSelect: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 60),

          // ── Dynamic Content ─────────────────────────────────
          FutureBuilder<List<DynamicProject>>(
            future: _projectsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _ShimmerLoader(isMobile: isMobile);
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  onRetry: () => setState(() {
                    _projectsFuture = _loadProjects();
                  }),
                );
              }

              final projects = _filtered(snapshot.data ?? []);

              if (projects.isEmpty) {
                return _EmptyState(category: _selectedCategory);
              }

              // Jensen Omega alternating layout
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Column(
                  key: ValueKey(_selectedCategory),
                  children: projects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final project = entry.value;
                    return DynamicProjectCard(
                      project: project,
                      imageLeft: index.isEven, // ← alternating layout
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Category Tabs ────────────────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryTabs({required this.selected, required this.onSelect});

  static const _categories = [
    ('all', 'ALL'),
    ('software', 'SOFTWARE'),
    ('electronics', 'ELECTRONICS'),
    ('robotics', 'ROBOTICS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((cat) {
        final isActive = selected == cat.$1;
        return _FilterPill(
          label: cat.$2,
          isActive: isActive,
          onTap: () => onSelect(cat.$1),
        );
      }).toList(),
    );
  }
}

// ─── Shimmer Skeleton Loading ─────────────────────────────────────────────────
class _ShimmerLoader extends StatelessWidget {
  final bool isMobile;
  const _ShimmerLoader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Shimmer.fromColors(
            baseColor: AppConstants.bgCard,
            highlightColor: AppConstants.navyLight,
            period: const Duration(milliseconds: 1400),
            child: isMobile
                ? _mobileShimmerItem()
                : _desktopShimmerItem(index),
          ),
        );
      }),
    );
  }

  Widget _desktopShimmerItem(int index) {
    final leftFirst = index.isEven;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: leftFirst
          ? [
              _shimmerBox(flex: 45, height: 380),
              const SizedBox(width: 60),
              _shimmerContent(flex: 55),
            ]
          : [
              _shimmerContent(flex: 55),
              const SizedBox(width: 60),
              _shimmerBox(flex: 45, height: 380),
            ],
    );
  }

  Widget _mobileShimmerItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerRect(width: double.infinity, height: 200),
        const SizedBox(height: 24),
        _shimmerRect(width: double.infinity, height: 16),
        const SizedBox(height: 8),
        _shimmerRect(width: 200, height: 12),
        const SizedBox(height: 16),
        _shimmerRect(width: double.infinity, height: 80),
      ],
    );
  }

  Widget _shimmerBox({required int flex, required double height}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppConstants.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _shimmerContent({required int flex}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerRect(width: 280, height: 28),
          const SizedBox(height: 12),
          _shimmerRect(width: 160, height: 14),
          const SizedBox(height: 20),
          _shimmerRect(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          _shimmerRect(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          _shimmerRect(width: 280, height: 12),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              4,
              (_) => _shimmerRect(width: 70, height: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerRect({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppConstants.bgCard,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppConstants.coral.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not reach Supabase',
              style: AppConstants.sectionHeadingStyle(18).copyWith(
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing static fallback data. Check .env credentials.',
              style: AppConstants.bodyStyle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppConstants.gold),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'RETRY',
                  style: AppConstants.labelStyle.copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          'No $category projects yet.',
          style: AppConstants.bodyStyle.copyWith(
            color: AppConstants.textMuted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Pill ──────────────────────────────────────────────────────────────
class _FilterPill extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterPill(
      {required this.label, required this.isActive, required this.onTap});

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
      cursor: SystemMouseCursors.click,
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

// ─── Section Header ───────────────────────────────────────────────────────────
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

// ─── Gold Divider ─────────────────────────────────────────────────────────────
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