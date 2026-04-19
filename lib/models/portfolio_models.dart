enum ProjectCategory { all, software, electronics, robotics }

class Project {
  final String title;
  final String subtitle;
  final String description;
  final List<String> technologies;
  final ProjectCategory category;
  final String? achievement;
  final int gradientStart;
  final int gradientEnd;

  const Project({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.technologies,
    required this.category,
    this.achievement,
    this.gradientStart = 0xFF0D2140,
    this.gradientEnd = 0xFF1A4080,
  });
}

class SkillCategory {
  final String name;
  final String icon;
  final List<String> skills;

  const SkillCategory({
    required this.name,
    required this.icon,
    required this.skills,
  });
}