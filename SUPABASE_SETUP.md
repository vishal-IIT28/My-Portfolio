# 🔐 Supabase Security & Environment Setup Guide

## Table of Contents
1. [Local Development Setup](#local-development-setup)
2. [Environment Variables (.env)](#environment-variables)
3. [Git Security (.gitignore)](#git-security)
4. [Deployment to Vercel](#deployment-to-vercel)
5. [Supabase Database Schema](#supabase-database-schema)
6. [Security Best Practices](#security-best-practices)

---  

## Local Development Setup

### 1. Create a Supabase Account & Project

1. Go to [supabase.com](https://supabase.com) and sign up
2. Create a new project:
   - Name: `portfolio-vishal`
   - Region: Choose closest to your location
   - Database Password: Use a strong password (save it somewhere safe)
3. Wait for the project to initialize (2-3 minutes)

### 2. Create `.env` File (Local Only)

```bash
# In your project root, create a .env file (NOT committed to git)
cp .env.example .env
```

Edit `.env` with your credentials:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
APP_ENV=development
```

**Where to get these values:**
- Go to Supabase Dashboard → Project Settings → API
- Copy the "Project URL" → `SUPABASE_URL`
- Copy the "anon [public]" key → `SUPABASE_ANON_KEY`

### 3. Update `pubspec.yaml`

Add flutter_dotenv to load environment variables:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
  supabase_flutter: ^2.5.0
```

Update `flutter:` section:
```yaml
flutter:
  uses-material-design: true
  assets:
    - .env  # Add this line
```

Run: `flutter pub get`

---

## Environment Variables

### Understanding `.env` vs `Secrets`

**Public (`.env`, safe in version control):**
- `SUPABASE_URL` - Project URL (publicly visible anyway)
- `SUPABASE_ANON_KEY` - Anon key (designed for public use, limited permissions)
- `APP_ENV` - Environment name

**Secret (`.env.local` or deployment environment variables, NEVER in git):**
- `SUPABASE_ADMIN_KEY` - Full database access (only for backend servers)
- Database passwords
- API keys for other services

### File Structure

```
portfolio_website/
├── .env              ← YOUR LOCAL SECRETS (Never commit!)
├── .env.example      ← Template (COMMIT THIS)
├── .gitignore        ← Should include .env
└── lib/
    ├── main.dart     ← Initialize Supabase
    └── services/
        └── database_service.dart
```

---

## Git Security

### ✅ Update `.gitignore`

Ensure your `.gitignore` has:

```bash
# Environment variables - CRITICAL
.env
.env.local
.env.*.local

# Flutter/Dart
build/
.dart_tool/
.flutter-plugins
.packages

# IDE
.vscode/
.idea/
*.iml
*.swp

# OS
.DS_Store
Thumbs.db

# Firebase/Supabase keys
google-services.json
ServiceAccountKey.json
```

### Verify Before Committing

```bash
# Check if .env is tracked (should output nothing if properly ignored)
git status .env

# Remove .env from git history if accidentally added
git rm --cached .env
git commit -m "Remove .env from tracking"
```

---

## Deployment to Vercel

### Prerequisites
- Vercel account (free at [vercel.com](https://vercel.com))
- GitHub repository set up

### Step 1: Connect GitHub to Vercel

1. Go to [vercel.com/new](https://vercel.com/new)
2. Select "Import Git Repository"
3. Search for `My-Portfolio` repository
4. Click "Import"

### Step 2: Configure Environment Variables in Vercel

1. In Vercel Project Settings → Environment Variables
2. Add each variable:

| Name | Value | Environments |
|------|-------|--------------|
| `SUPABASE_URL` | `https://your-project-id.supabase.co` | Production |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` | Production |
| `APP_ENV` | `production` | Production |

**Screenshot Guide:**
```
Settings → Environment Variables
┌─────────────────────────────────────┐
│ Name: SUPABASE_URL                  │
│ Value: https://project.supabase.co  │
│ Environment: Production             │
│ [Add Environment Variable]          │
└─────────────────────────────────────┘
```

### Step 3: Set Build Configuration

In Vercel, ensure build settings:
- **Framework:** Flutter Web
- **Build Command:** `flutter build web`
- **Output Directory:** `build/web`
- **Install Command:** `flutter pub get`

### Step 4: Deploy

1. Push to GitHub main branch
2. Vercel automatically deploys
3. Monitor build progress in Vercel Dashboard

---

## Supabase Database Schema

### Create Tables in Supabase

Go to Supabase Dashboard → SQL Editor → New Query

#### 1. Projects Table

```sql
-- Create projects table
CREATE TABLE projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT NOT NULL,
  objective TEXT,
  outcome TEXT,
  tech_stack TEXT[] NOT NULL,
  image_url TEXT,
  pdf_url TEXT,
  github_url TEXT,
  category TEXT NOT NULL,
  achievement TEXT,
  code_snippet TEXT,
  code_language TEXT,
  created_at TIMESTAMP DEFAULT now() NOT NULL,
  updated_at TIMESTAMP DEFAULT now() NOT NULL
);

-- Create index for faster queries
CREATE INDEX idx_projects_category ON projects(category);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);

-- Enable Row Level Security (RLS) for public read-only access
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Create policy: Anyone can read projects
CREATE POLICY "Enable read access for all users"
ON projects FOR SELECT
USING (true);
```

#### 2. Skills Table

```sql
CREATE TABLE skills (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  skill_name TEXT NOT NULL,
  category TEXT NOT NULL,
  proficiency_level TEXT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_skills_category ON skills(category);

ALTER TABLE skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users"
ON skills FOR SELECT
USING (true);
```

#### 3. Authentication for Admin Panel

```sql
-- Create admin_users table to track who can edit
CREATE TABLE admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  auth_id UUID NOT NULL REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'admin',
  created_at TIMESTAMP DEFAULT now()
);

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Only admins can insert/update/delete projects
CREATE POLICY "Admins can modify projects"
ON projects FOR INSERT
WITH CHECK (
  auth.uid() IN (SELECT auth_id FROM admin_users)
);

CREATE POLICY "Admins can update projects"
ON projects FOR UPDATE
USING (
  auth.uid() IN (SELECT auth_id FROM admin_users)
);

CREATE POLICY "Admins can delete projects"
ON projects FOR DELETE
USING (
  auth.uid() IN (SELECT auth_id FROM admin_users)
);
```

### Create Storage Buckets

Go to Supabase Dashboard → Storage → New Bucket

1. Create bucket: `project-images`
   - Make Public ✓
2. Create bucket: `project-pdfs`
   - Make Public ✓ (or Private if you want signed URLs)

---

## Security Best Practices

### ✅ Do's

- ✅ Use `.env.example` as a template (commit this)
- ✅ Keep `.env` in `.gitignore` (don't commit)
- ✅ Rotate ANON_KEY periodically in Supabase
- ✅ Use Supabase Row Level Security (RLS) for database access control
- ✅ Store ADMIN_KEY only on backend servers (Node.js, Vercel serverless)
- ✅ Enable Supabase Authentication for admin panel
- ✅ Monitor API usage in Supabase Dashboard

### ❌ Don'ts

- ❌ Don't hardcode credentials in source code
- ❌ Don't commit `.env` files
- ❌ Don't expose ADMIN_KEY in Flutter frontend
- ❌ Don't use the same database password everywhere
- ❌ Don't share Supabase credentials over chat/email
- ❌ Don't make private storage buckets publicly readable

### Checking for Exposed Credentials

```bash
# Search git history for secrets
git log --all --oneline --decorate --graph

# Use git-secrets to prevent commits
brew install git-secrets  # macOS/Linux
git secrets --install
git secrets --register-aws
```

---

## Troubleshooting

### Issue: "Failed to initialize Supabase"

**Solution:**
- Verify `SUPABASE_URL` format: `https://xxx.supabase.co`
- Check `SUPABASE_ANON_KEY` length (should be 200+ characters)
- Ensure `.env` file exists in project root
- Check `flutter: assets: - .env` in pubspec.yaml

### Issue: "No database connection"

**Solution:**
- Verify Supabase project is running (Dashboard → Status)
- Check RLS policies allow public SELECT
- Verify table exists (go to SQL Editor and run `SELECT * FROM projects;`)

### Issue: "Image fails to load"

**Solution:**
- Verify storage bucket is public
- Check image URL is accessible from browser
- Ensure Supabase Storage CORS is configured

### Issue: "Vercel build fails with .env"

**Solution:**
- DO NOT add `.env` to Vercel environment settings
- Use Vercel Dashboard → Settings → Environment Variables instead
- Ensure variable names match in `dotenv.load()` in Flutter

---

## Environment Setup Checklist

- [ ] Supabase project created
- [ ] `.env` file created (locally, not committed)
- [ ] `.gitignore` includes `.env`
- [ ] Supabase tables created (SQL scripts)
- [ ] Storage buckets created (`project-images`, `project-pdfs`)
- [ ] `flutter_dotenv` added to pubspec.yaml
- [ ] `.env` added to flutter: assets in pubspec.yaml
- [ ] Vercel project connected to GitHub
- [ ] Environment variables added to Vercel dashboard
- [ ] First project added to Supabase database
- [ ] Test deployment to Vercel
- [ ] Verify no .env file in git history: `git log --all --full-history -- .env`

---

## Questions?

For more info:
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Security](https://supabase.com/docs/guides/auth#security)
- [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv)
- [Vercel Environment Variables](https://vercel.com/docs/concepts/projects/environment-variables)
