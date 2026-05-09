# Project: Vishal Kumar Dynamic Portfolio (Jensen Omega UI)
**Target Stack:** Flutter Web + Supabase (Backend) + Vercel (Hosting)

## 🏗️ Architecture Map (Dynamic)
- `lib/main.dart`: Entry point with Supabase Initialization.
- `lib/services/database_service.dart`: Handles fetching projects, skills, and circuit diagrams from Supabase.
- `lib/widgets/`:
    - `hero_section.dart`: Intro text + Profile Image (Asset).
    - `nav_bar.dart`: Logo (Circular Photo Asset) + Dynamic Nav Links.
    - `project_card.dart`: Fetches Image/PDF URL and Code Snippets from Database.
    - `admin_panel/`: (Hidden Route) A simple form to add new projects/PDFs.

## 🎨 Global Theme (Jensen Omega)
- **Primary:** #0F172A (Deep Charcoal)
- **Accent:** #FF6B6B (Coral Orange)[cite: 2]
- **Font:** Serif (Headings) / Sans-Serif (Body)[cite: 2]

## 🛠️ Data Strategy (Always Free)
1. **Database:** Supabase PostgreSQL (500MB Free) for project descriptions, JEE rank, and Super-30 data.
2. **Storage:** Supabase Storage (1GB Free) for PDFs, Circuit Diagrams, and Project Screenshots.
3. **Auth:** Supabase Auth (Free) for the Admin Panel login.
4. **Hosting:** Vercel (Free tier) with SSL enabled.