# 🚀 Dynamic Portfolio Implementation Guide

This guide shows how to use the new dynamic Supabase integration and Jensen Omega project cards in your portfolio.

## Files Overview

### New Core Files Created
```
lib/
├── services/
│   └── database_service.dart        # Supabase singleton (fetch/manage data)
├── models/
│   └── dynamic_project.dart         # Dynamic project model from Supabase
└── widgets/
    └── dynamic_project_card.dart    # Jensen Omega layout card
    
.env.example                         # Environment variables template
SUPABASE_SETUP.md                   # Complete Supabase setup guide
```

### Updated Files
```
lib/
├── main.dart                        # Now initializes Supabase from .env
└── pubspec.yaml                     # Added flutter_dotenv, supabase_flutter
```

---

## Phase 1: Local Development Setup

### Step 1: Install Dependencies

```bash
# Get all new packages
flutter pub get

# Verify flutter_dotenv is added to pubspec.yaml
# Verify .env is in flutter: assets: section
```

### Step 2: Create Local .env File

```bash
# Copy template
cp .env.example .env

# Edit .env with your Supabase credentials
# DO NOT commit this file!
```

### Step 3: Verify .gitignore

```bash
# Ensure .gitignore has .env
cat .gitignore | grep ".env"

# Should output: .env
```

---

## Phase 2: Supabase Database Setup

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create new project named `portfolio-vishal`
3. Wait for initialization
4. Copy Project URL and Anon Key to `.env`

### Step 2: Create Tables

Go to Supabase Dashboard → SQL Editor → New Query → Paste this:

```sql
-- ========================================
-- Create Projects Table
-- ========================================
CREATE TABLE projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT DEFAULT '',
  description TEXT NOT NULL,
  objective TEXT DEFAULT '',
  outcome TEXT DEFAULT '',
  tech_stack TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  image_url TEXT DEFAULT '',
  pdf_url TEXT,
  github_url TEXT,
  category TEXT NOT NULL,
  achievement TEXT,
  code_snippet TEXT,
  code_language TEXT,
  created_at TIMESTAMP DEFAULT now() NOT NULL,
  updated_at TIMESTAMP DEFAULT now() NOT NULL
);

-- Index for faster queries
CREATE INDEX idx_projects_category ON projects(category);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);

-- Enable public read access (Row Level Security)
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users"
ON projects FOR SELECT
USING (true);

-- ========================================
-- Create Storage Buckets
-- ========================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('project-images', 'project-images', true);

INSERT INTO storage.buckets (id, name, public)
VALUES ('project-pdfs', 'project-pdfs', true);
```

### Step 3: Add Sample Project Data

```sql
INSERT INTO projects (title, subtitle, description, objective, outcome, tech_stack, image_url, github_url, category) VALUES
(
  'JellyChat',
  'Real-time Messaging Platform',
  'Built a full-featured real-time messaging app with Flutter, Node.js, Supabase, and MySQL. Features include multi-persona emotional AI, persistent chat history, Google Auth, and GIF support.',
  'Create a real-time messaging platform with emotional AI integration',
  'Successfully launched with 1000+ users, 50+ daily active conversations',
  ARRAY['Flutter', 'Node.js', 'Supabase', 'MySQL', 'AWS S3'],
  'https://your-bucket.supabase.co/storage/v1/object/public/project-images/jellychat.jpg',
  'https://github.com/vishal-IIT28/jellychat',
  'software'
);
```

---

## Phase 3: Implement Dynamic Projects Section

### Option A: Replace Static ProjectsSection (Recommended)

Create a new file `lib/widgets/dynamic_projects_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:portfolio_website/models/dynamic_project.dart';
import 'package:portfolio_website/services/database_service.dart';
import 'package:portfolio_website/widgets/dynamic_project_card.dart';
import 'package:portfolio_website/constants/app_constants.dart';

class DynamicProjectsSection extends StatefulWidget {
  const DynamicProjectsSection({super.key});

  @override
  State<DynamicProjectsSection> createState() => _DynamicProjectsSectionState();
}

class _DynamicProjectsSectionState extends State<DynamicProjectsSection> {
  late Future<List<DynamicProject>> _projectsFuture;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    _projectsFuture = _fetchProjects();
  }

  Future<List<DynamicProject>> _fetchProjects() async {
    try {
      final supabaseService = SupabaseService();
      final projectsData = await supabaseService.fetchProjects();
      
      return projectsData
          .map((data) => DynamicProject.fromSupabase(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      return [];
    }
  }

  List<DynamicProject> _filterProjects(List<DynamicProject> projects) {
    if (_selectedCategory == 'all') return projects;
    return projects.where((p) => p.category == _selectedCategory).toList();
  }

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
          // Header
          Text(
            'FEATURED WORK',
            style: TextStyle(
              color: AppConstants.gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Projects',
            style: AppConstants.sectionHeadingStyle(36),
          ),
          const SizedBox(height: 40),

          // Projects list
          FutureBuilder<List<DynamicProject>>(
            future: _projectsFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppConstants.coral,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading projects...',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Error loading projects: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final projects = snapshot.data ?? [];
              final filtered = _filterProjects(projects);

              // Render projects
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filters
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['all', 'software', 'electronics', 'robotics']
                        .map((cat) => _buildFilterChip(cat))
                        .toList(),
                  ),
                  const SizedBox(height: 50),

                  // Project cards with alternating layout
                  ...List.generate(
                    filtered.length,
                    (index) => DynamicProjectCard(
                      key: ValueKey(filtered[index].id),
                      project: filtered[index],
                      imageLeft: index % 2 == 0, // Alternate layout
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    final isActive = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? AppConstants.coral : AppConstants.gold,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isActive ? AppConstants.coral.withOpacity(0.1) : Colors.transparent,
        ),
        child: Text(
          category.toUpperCase(),
          style: TextStyle(
            color: isActive ? AppConstants.coral : AppConstants.gold,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
```

### Option B: Keep Both Versions

If you want to keep the static version for reference while testing dynamic:

```dart
// In main.dart or your routing logic
// Show dynamic section instead of static one

// OLD (remove):
// ProjectsSection(key: _projectsKey),

// NEW (add):
// DynamicProjectsSection(key: _projectsKey),
```

---

## Phase 4: Using the Components

### 1. Fetch Projects Directly

```dart
import 'package:portfolio_website/services/database_service.dart';
import 'package:portfolio_website/models/dynamic_project.dart';

// Anywhere in your widget
final supabase = SupabaseService();

// Fetch all projects
final projects = await supabase.fetchProjects();
final dynamicProjects = projects
    .map((data) => DynamicProject.fromSupabase(data))
    .toList();

// Fetch by category
final softwareProjects = await supabase.fetchProjectsByCategory('software');
```

### 2. Display Single Project Card

```dart
import 'package:portfolio_website/widgets/dynamic_project_card.dart';

DynamicProjectCard(
  project: myProject,
  imageLeft: true,
  onTap: () => print('Project tapped!'),
)
```

### 3. Open External Links

The card automatically handles:
- GitHub links → opens in new tab
- PDF documentation → opens PDF viewer
- Shimmer loading while images load

---

## Phase 5: Deployment to Vercel

### Step 1: Push to GitHub

```bash
git add .
git commit -m "feat: Add dynamic Supabase integration and Jensen Omega design"
git push origin main
```

### Step 2: Connect to Vercel

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import GitHub repository `My-Portfolio`
3. Set up build configuration

### Step 3: Add Environment Variables in Vercel

Vercel Dashboard → Project Settings → Environment Variables

| Variable | Value |
|----------|-------|
| `SUPABASE_URL` | `https://your-project.supabase.co` |
| `SUPABASE_ANON_KEY` | `eyJ...` |
| `APP_ENV` | `production` |

### Step 4: Deploy

```bash
# Trigger deploy from Vercel dashboard
# or push to main branch
git push origin main
```

Vercel will automatically build and deploy. Monitor at [vercel.com/dashboard](https://vercel.com/dashboard)

---

## Troubleshooting

### Issue: "Failed to initialize Supabase"

**Check:**
1. `.env` file exists in project root
2. `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct
3. Supabase project is running (check Dashboard → Status)
4. Run `flutter clean && flutter pub get`

### Issue: "Projects table not found"

**Check:**
1. SQL table was created in Supabase
2. Table name matches query: `projects`
3. Run: `SELECT * FROM projects;` in Supabase SQL Editor

### Issue: "Images not loading"

**Check:**
1. Storage bucket is public
2. Image URLs are correct in database
3. URLs start with `https://`
4. Check browser console for CORS errors

### Issue: "Build fails on Vercel"

**Check:**
1. Environment variables set in Vercel
2. `.env` NOT in git repo (should be in .gitignore)
3. Build command: `flutter build web`
4. Check Vercel build logs for specific error

---

## Next Steps

1. ✅ Add your projects to Supabase database
2. ✅ Update project images in storage bucket
3. ✅ Create PDF documentation (circuit diagrams, etc.)
4. ✅ Implement admin panel for editing projects
5. ✅ Set up GitHub Actions for CI/CD
6. ✅ Monitor Supabase usage and optimize queries

---

## Support Resources

- [Supabase Docs](https://supabase.com/docs)
- [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv)
- [Supabase Flutter SDK](https://pub.dev/packages/supabase_flutter)
- [Vercel Docs](https://vercel.com/docs)
- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)
