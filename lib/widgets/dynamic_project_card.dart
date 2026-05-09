import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/models/dynamic_project.dart';

/// Jensen Omega style project card with alternating layout
/// - Left side: Image/Media, Right side: Text (or vice versa)
/// - Features: objective, tech stack, outcome
/// - Actions: GitHub link, Documentation (PDF)
class DynamicProjectCard extends StatefulWidget {
  final DynamicProject project;
  final bool imageLeft;
  final VoidCallback? onTap;

  const DynamicProjectCard({
    super.key,
    required this.project,
    this.imageLeft = true,
    this.onTap,
  });

  @override
  State<DynamicProjectCard> createState() => _DynamicProjectCardState();
}

class _DynamicProjectCardState extends State<DynamicProjectCard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _imageLoaded = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onImageLoaded() {
    setState(() => _imageLoaded = true);
    _fadeController.forward();
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // On mobile, always stack vertically
    if (isMobile) {
      return _buildMobileLayout();
    }

    // On desktop, use alternating left/right layout
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.imageLeft
            ? _buildDesktopLayout(isImageLeft: true)
            : _buildDesktopLayout(isImageLeft: false),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on top
          _buildProjectImage(isCompact: true),
          const SizedBox(height: 24),
          // Content below
          _buildProjectContent(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout({required bool isImageLeft}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isImageLeft
            ? [
                // Image on left
                Expanded(
                  flex: 45,
                  child: _buildProjectImage(isCompact: false),
                ),
                const SizedBox(width: 60),
                // Content on right
                Expanded(
                  flex: 55,
                  child: _buildProjectContent(),
                ),
              ]
            : [
                // Content on left
                Expanded(
                  flex: 55,
                  child: _buildProjectContent(),
                ),
                const SizedBox(width: 60),
                // Image on right
                Expanded(
                  flex: 45,
                  child: _buildProjectImage(isCompact: false),
                ),
              ],
      ),
    );
  }

  Widget _buildProjectImage({required bool isCompact}) {
    final height = isCompact ? 300.0 : 400.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.gold.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Loading shimmer
          if (!_imageLoaded)
            Shimmer.fromColors(
              baseColor: AppConstants.bgCard,
              highlightColor: AppConstants.navyLight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.bgCard,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          
          // Actual image
          if (widget.project.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FadeTransition(
                opacity: _fadeController,
                child: Image.network(
                  widget.project.imageUrl,
                  fit: BoxFit.cover,
                  frameBuilder: (ctx, child, frame, wasSyncLoaded) {
                    if (frame != null && !_imageLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _onImageLoaded(),
                      );
                    }
                    return child;
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppConstants.bgCard,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: AppConstants.gold.withValues(alpha: 0.5),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Image unavailable',
                            style: TextStyle(
                              color: AppConstants.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Code snippet overlay (if available)
          if (widget.project.codeSnippet != null &&
              widget.project.codeSnippet!.isNotEmpty)
            _buildCodeSnippetOverlay(),

          // Hover overlay
          if (_hovered)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCodeSnippetOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.project.codeLanguage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.project.codeLanguage!.toUpperCase(),
                  style: const TextStyle(
                    color: AppConstants.coral,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            Text(
              widget.project.codeSnippet!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontFamily: 'Courier New',
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title with achievement badge (if any)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.title,
                    style: AppConstants.sectionHeadingStyle(28),
                  ),
                  if (widget.project.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.project.subtitle,
                        style: TextStyle(
                          color: AppConstants.coral,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.project.achievement != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppConstants.coral, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.project.achievement!,
                  style: TextStyle(
                    color: AppConstants.coral,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // Objective (Problem Statement)
        if (widget.project.objective.isNotEmpty) ...[
          Text(
            'OBJECTIVE',
            style: TextStyle(
              color: AppConstants.gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.project.objective,
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Main Description
        Text(
          widget.project.description,
          style: TextStyle(
            color: AppConstants.textSecondary,
            fontSize: 13,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 16),

        // Outcome (Results)
        if (widget.project.outcome.isNotEmpty) ...[
          Text(
            'OUTCOME',
            style: TextStyle(
              color: AppConstants.gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.project.outcome,
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Tech Stack
        if (widget.project.techStack.isNotEmpty) ...[
          Text(
            'TECHNOLOGY STACK',
            style: TextStyle(
              color: AppConstants.gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.project.techStack
                .map((tech) => _buildTechBadge(tech))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Action Buttons
        Row(
          children: [
            if (widget.project.githubUrl != null &&
                widget.project.githubUrl!.isNotEmpty)
              _buildActionButton(
                label: 'VIEW CODE',
                icon: Icons.code,
                onTap: () => _launchUrl(widget.project.githubUrl),
              ),
            const SizedBox(width: 12),
            if (widget.project.pdfUrl != null &&
                widget.project.pdfUrl!.isNotEmpty)
              _buildActionButton(
                label: 'DOCUMENTATION',
                icon: Icons.description,
                isPrimary: false,
                onTap: () => _launchUrl(widget.project.pdfUrl),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechBadge(String tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppConstants.gold.withValues(alpha: 0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tech,
        style: TextStyle(
          color: AppConstants.gold,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isPrimary ? AppConstants.coral : AppConstants.gold,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(6),
            color: isPrimary
                ? AppConstants.coral.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppConstants.coral : AppConstants.gold,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? AppConstants.coral : AppConstants.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
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
