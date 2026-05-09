/// Project model for dynamic data from Supabase
/// Fields: title, description, tech_stack (list), image_url, pdf_url, github_url,
/// objective, outcome, category
class DynamicProject {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String objective; // "What problem does this solve?"
  final String outcome;   // "What was achieved?"
  final List<String> techStack;
  final String imageUrl;
  final String? pdfUrl;      // For circuit diagrams, technical docs
  final String? githubUrl;
  final String category;     // 'software', 'electronics', 'robotics'
  final String? achievement; // e.g., "🥈 2nd Place — Roborumble'24"
  final DateTime createdAt;
  final String? codeSnippet; // Optional code snippet for display
  final String? codeLanguage; // e.g., 'dart', 'python', 'verilog'

  DynamicProject({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.objective,
    required this.outcome,
    required this.techStack,
    required this.imageUrl,
    this.pdfUrl,
    this.githubUrl,
    required this.category,
    this.achievement,
    required this.createdAt,
    this.codeSnippet,
    this.codeLanguage,
  });

  /// Create DynamicProject from Supabase response (Map)
  factory DynamicProject.fromSupabase(Map<String, dynamic> data) {
    return DynamicProject(
      id: data['id'] as String,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String? ?? '',
      description: data['description'] as String,
      objective: data['objective'] as String? ?? '',
      outcome: data['outcome'] as String? ?? '',
      techStack: List<String>.from(
        (data['tech_stack'] as List?)?.cast<String>() ?? [],
      ),
      imageUrl: data['image_url'] as String? ?? '',
      pdfUrl: data['pdf_url'] as String?,
      githubUrl: data['github_url'] as String?,
      category: data['category'] as String? ?? 'software',
      achievement: data['achievement'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      codeSnippet: data['code_snippet'] as String?,
      codeLanguage: data['code_language'] as String?,
    );
  }

  /// Convert to Map for Supabase insert/update
  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'objective': objective,
      'outcome': outcome,
      'tech_stack': techStack,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'github_url': githubUrl,
      'category': category,
      'achievement': achievement,
      'code_snippet': codeSnippet,
      'code_language': codeLanguage,
    };
  }

  /// Create a copy with some fields replaced
  DynamicProject copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? objective,
    String? outcome,
    List<String>? techStack,
    String? imageUrl,
    String? pdfUrl,
    String? githubUrl,
    String? category,
    String? achievement,
    DateTime? createdAt,
    String? codeSnippet,
    String? codeLanguage,
  }) {
    return DynamicProject(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      outcome: outcome ?? this.outcome,
      techStack: techStack ?? this.techStack,
      imageUrl: imageUrl ?? this.imageUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      category: category ?? this.category,
      achievement: achievement ?? this.achievement,
      createdAt: createdAt ?? this.createdAt,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      codeLanguage: codeLanguage ?? this.codeLanguage,
    );
  }
}
