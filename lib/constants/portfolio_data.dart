import 'package:portfolio_website/models/portfolio_models.dart';

class PortfolioData {
  static const String name = 'Vishal Kumar';
  static const String subtitleLine1 = 'ECE Undergrad';
  static const String subtitleLine2 = 'Full-Stack Dev  ·  Robotics';
  static const String college = 'IIT (ISM) Dhanbad';
  static const String gpa = 'GPA: 6.73';
  static const String education = 'IIT (ISM) Dhanbad  ·  B.Tech ECE (2022–2026)';
  static const String about =
      'I\'m an Electronics & Communication Engineering undergraduate at IIT (ISM) Dhanbad '
      'with a deep passion for building things — be it real-time full-stack applications, '
      'analog audio circuits, or competition-winning combat bots. '
      'I thrive at the intersection of hardware and software.';

  static const List<String> badges = [
    'JEE Advanced AIR 1713',
    'Super-30 Alumnus',
    'Roborumble\'24 — 2nd Place',
    'Concetto\'24 — 3rd Place',
  ];

  static const List<Project> projects = [
    Project(
      title: 'JellyChat',
      subtitle: 'Real-time Messaging Platform',
      description:
          'Built a full-featured real-time messaging app with Flutter, Node.js, Supabase, and MySQL. '
          'Features include multi-persona emotional AI, persistent chat history, Google Auth, and GIF support.',
      technologies: ['Flutter', 'Node.js', 'Supabase', 'MySQL', 'AWS S3'],
      category: ProjectCategory.software,
      gradientStart: 0xFF1D3557,
      gradientEnd: 0xFF457B9D,
    ),
    Project(
      title: '3-Band Audio EQ',
      subtitle: 'Analog Signal Processing',
      description:
          'Designed and built a 3-band analog audio equalizer using OPAMP active filters. '
          'Implemented Butterworth filter topology for bass, mid, and treble frequency bands.',
      technologies: ['Analog Electronics', 'OPAMP', 'Butterworth Filters', 'PCB'],
      category: ProjectCategory.electronics,
      gradientStart: 0xFF2D1B69,
      gradientEnd: 0xFF6B4FBB,
    ),
    Project(
      title: 'Verilog HDL Designs',
      subtitle: 'Digital Circuit Engineering',
      description:
          'Implemented a suite of digital circuits in Verilog HDL including ALUs, finite state machines, '
          'and pipelined processors. Simulated and verified on FPGA.',
      technologies: ['Verilog HDL', 'Digital Design', 'FPGA', 'ModelSim'],
      category: ProjectCategory.electronics,
      gradientStart: 0xFF1A3A1A,
      gradientEnd: 0xFF2D6B2D,
    ),
    Project(
      title: 'RC Defensive Bot',
      subtitle: 'Roborumble\'24 — 2nd Place',
      description:
          'Engineered a remote-controlled defensive combat robot that secured 2nd place at Roborumble\'24. '
          'Custom chassis with layered armor and low-center-of-gravity design.',
      technologies: ['Robotics', 'Arduino', 'Sensors', 'Mechanical Design'],
      category: ProjectCategory.robotics,
      achievement: '🥈 2nd Place — Roborumble\'24',
      gradientStart: 0xFF3A1A00,
      gradientEnd: 0xFF8B4500,
    ),
    Project(
      title: 'Manual Armed Rover',
      subtitle: 'Concetto\'24 — 3rd Place',
      description:
          'Designed and built a manually controlled armed rover bot for Concetto\'24 tech fest, '
          'featuring servo-driven weapon systems and precision drive train.',
      technologies: ['Robotics', 'Servo Control', 'Mechanical Design', 'Control Systems'],
      category: ProjectCategory.robotics,
      achievement: '🥉 3rd Place — Concetto\'24',
      gradientStart: 0xFF2A1A3A,
      gradientEnd: 0xFF6A3AAA,
    ),
  ];

  static const List<SkillCategory> skills = [
    SkillCategory(
      name: 'Languages',
      icon: '{ }',
      skills: ['C', 'C++', 'Java', 'Dart', 'Python', 'Verilog HDL'],
    ),
    SkillCategory(
      name: 'Frameworks & Tools',
      icon: '⚙',
      skills: ['Flutter', 'Node.js', 'Express', 'MySQL', 'MongoDB', 'AWS S3', 'Git', 'Supabase'],
    ),
    SkillCategory(
      name: 'Electronics & Hardware',
      icon: '◈',
      skills: ['OPAMP Circuits', 'FPGA', 'Arduino', 'PCB Design', 'Signal Processing'],
    ),
  ];

  static const List<String> coursework = [
    'Data Structures & Algorithms',
    'Computer Networks',
    'Signals & Systems',
    'Digital Electronics',
    'Analog Circuits',
    'Control Systems',
  ];

  static const String linkedinUrl = 'https://linkedin.com/in/vishal-kumar';
  static const String githubUrl = 'https://github.com/vishal-IIT28';
  static const String emailUrl = 'mailto:vishal@example.com';
}