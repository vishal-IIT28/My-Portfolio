# 🎯 Quick Start Reference

**Estimated Setup Time:** 30 minutes for complete integration

---

## 1️⃣ Environment Setup (5 minutes)

```bash
# Create .env file from template
cp .env.example .env

# Edit with your Supabase credentials
# SUPABASE_URL=https://xxx.supabase.co
# SUPABASE_ANON_KEY=eyJ...
```

**Verify .gitignore has:**
```
.env
.env.local
```

---

## 2️⃣ Install & Run (3 minutes)

```bash
flutter pub get
flutter run
```

Check console for: `✅ Supabase initialized successfully`

---

## 3️⃣ Create Supabase Project (10 minutes)

1. Go to [supabase.com](https://supabase.com) → New Project
2. Save Project URL & Anon Key → Add to `.env`
3. Go to SQL Editor → Paste schema from [SUPABASE_SETUP.md](SUPABASE_SETUP.md#supabase-database-schema)
4. Run SQL to create `projects` table

---

## 4️⃣ Add First Project (5 minutes)

In Supabase Dashboard → Table Editor → `projects` table:

| Field | Value | Example |
|-------|-------|---------|
| title | Project name | `JellyChat` |
| subtitle | Short tagline | `Real-time Messaging` |
| description | Full description | `Built with Flutter...` |
| objective | Problem solved | `Create real-time messaging...` |
| outcome | Results achieved | `Launched with 1000+ users` |
| tech_stack | ARRAY | `['Flutter', 'Node.js', 'Supabase']` |
| image_url | HTTPS URL | `https://...` |
| category | one of: software\|electronics\|robotics | `software` |
| github_url | GitHub repo URL | `https://github.com/...` |
| pdf_url | Documentation PDF URL | `https://...` (optional) |

---

## 5️⃣ Integrate into Your App

### Option A: Replace ProjectsSection (Recommended)

In `lib/main.dart`:

```dart
// OLD:
// ProjectsSection(key: _projectsKey),

// NEW (import & use):
import 'package:portfolio_website/widgets/dynamic_projects_section.dart';

DynamicProjectsSection(key: _projectsKey),
```

Create file: `lib/widgets/dynamic_projects_section.dart` (code in IMPLEMENTATION_GUIDE.md)

### Option B: Use Individual Cards

```dart
import 'package:portfolio_website/widgets/dynamic_project_card.dart';

DynamicProjectCard(
  project: dynamicProject,
  imageLeft: true,
)
```

---

## 6️⃣ Deploy to Vercel (5 minutes)

1. Push to GitHub: `git push origin main`
2. Go to [vercel.com/new](https://vercel.com/new) → Import repository
3. Add Environment Variables:
   - `SUPABASE_URL` = `https://xxx.supabase.co`
   - `SUPABASE_ANON_KEY` = `eyJ...`
4. Deploy!

Vercel will automatically build and deploy on every push to `main`.

---

## 📋 Project Structure

```
lib/
├── main.dart (← Initialize Supabase here)
├── services/
│   └── database_service.dart (← Singleton for Supabase)
├── models/
│   └── dynamic_project.dart (← Project model)
└── widgets/
    ├── dynamic_project_card.dart (← Card UI)
    └── dynamic_projects_section.dart (← Full section)

.env (← Local secrets, NOT in git)
.env.example (← Template, IN git)
SUPABASE_SETUP.md (← Complete security guide)
IMPLEMENTATION_GUIDE.md (← Detailed integration)
```

---

## 🔑 Key Files Explained

| File | Purpose |
|------|---------|
| `database_service.dart` | Singleton that connects to Supabase, fetches projects |
| `dynamic_project.dart` | Model that represents a project from database |
| `dynamic_project_card.dart` | Jensen Omega card UI (alternating image/text) |
| `.env.example` | Template showing required variables |
| `SUPABASE_SETUP.md` | Complete security & database setup |
| `IMPLEMENTATION_GUIDE.md` | Step-by-step integration guide |

---

## ✨ Jensen Omega Features

✅ **Alternating Layout:** Image left on odd projects, right on even  
✅ **Objective/Outcome:** Case study format (Problem → Solution → Results)  
✅ **Tech Stack Display:** Styled badges for technologies used  
✅ **Code Snippets:** Optional code overlay on images  
✅ **Documentation Links:** PDF button for circuit diagrams/technical docs  
✅ **GitHub Integration:** Direct links to source code  
✅ **Loading States:** Shimmer effect while images load  
✅ **Responsive:** Mobile-optimized stack layout  
✅ **Hover Effects:** Desktop hover state with gradient overlay  

---

## 🔒 Security Checklist

- [ ] `.env` created locally
- [ ] `.env` in `.gitignore`
- [ ] `.env.example` IN repository
- [ ] `flutter_dotenv` in `pubspec.yaml`
- [ ] `.env` added to `flutter: assets:`
- [ ] Supabase RLS policies configured (allow public SELECT)
- [ ] Vercel environment variables set
- [ ] No hardcoded credentials in code
- [ ] Verify with: `git log --all --full-history -- .env` (should be empty)

---

## 🐛 Common Issues

| Error | Solution |
|-------|----------|
| "Supabase not initialized" | Check `.env` file exists and has correct URL/key |
| "Projects table not found" | Run SQL schema in Supabase SQL Editor |
| "Images not loading" | Verify storage bucket is public |
| "Build fails on Vercel" | Environment variables set in Vercel dashboard? |
| ".env accidentally committed" | `git rm --cached .env` then `git commit` |

---

## 📚 Documentation

For detailed information, see:
- **Security & Environment:** [SUPABASE_SETUP.md](SUPABASE_SETUP.md)
- **Integration Steps:** [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
- **API Reference:** Code comments in `database_service.dart`

---

## 🚀 Ready to Build?

1. Start with Step 1 in SUPABASE_SETUP.md
2. Follow the Quick Start above
3. Refer to IMPLEMENTATION_GUIDE.md for detailed code
4. Deploy to Vercel and monitor

**Questions?** Check the Troubleshooting section in SUPABASE_SETUP.md or IMPLEMENTATION_GUIDE.md

**Next Level:** Implement admin panel for editing projects without SQL knowledge!
