# AGENTS.md — GiroCall (Single Source of Truth)

**Project Name:** GiroCall  
**Tagline:** "Spin the Giro. Make the Call. Stay Connected."  
**Domain:** GiroCall.com  
**Status:** v2.0 — Flutter-only rebuild (design system + app layer consolidated)

This file is the **single source of truth** for all AI coding agents and human developers working on GiroCall. Read this file completely before making any changes.

---

## 1. Project Overview

GiroCall is a cross-platform relationship maintenance app centered around a fun **spinning wheel** ("Giro") that helps users reconnect with contacts they haven’t called in a while.

### Core User Flow
1. Import contacts (name + phone number primary)
2. Spin the Giro (beautiful animated wheel with smart weighting)
3. Tap to call (opens native dialer)
4. Log the call + rate it (1-5 stars) + optional notes
5. View smart "Call Again" recommendations
6. Receive daily push notifications to spin and call 2 people

### Key Features (MVP)
- Contact import (device contacts + manual add)
- Animated spinning wheel with weighted selection
- Call logging + rating system
- Recommendation engine (based on time since last call + user-defined frequency)
- Daily reminders + streak tracking
- Cross-device sync
- Stats (streaks, total calls, people reconnected, charts)
- Dark theme (system / light / dark) with local persistence
- Profile hub, digital business card, settings, and account management

**Target Platforms:** iOS, Android, Web (PWA via Flutter)

---

## 2. Technology Stack (Use This Exactly)

- **Framework:** Flutter (Dart) — single codebase for iOS, Android, and Web
- **Backend:** Supabase (PostgreSQL + Auth + Storage + Realtime + Edge Functions)
- **State Management:** Riverpod (preferred) or Bloc
- **Navigation:** GoRouter
- **Key Packages (approved):**
  - `flutter_contacts` + `permission_handler`
  - `url_launcher` (for `tel:` links)
  - `flutter_local_notifications` + Supabase + FCM for reminders
  - `fl_chart` for stats
  - `shared_preferences` for theme mode persistence
  - `share_plus` + `qr_flutter` for digital business cards
  - CustomPainter for the spin animation
- **Design System:** Custom brand (see Brand section below)
- **CI/CD:** GitHub Actions (recommended)

**Do not** introduce new major frameworks without updating this file first.

---

## 3. Project Structure (Follow This)

```
GiroCall/
├── lib/
│   ├── app/                     # Bootstrap, shell (centered Giro nav)
│   ├── core/
│   │   ├── design/              # colors, theme, spacing, tokens, microcopy
│   │   ├── theme/               # ThemeMode provider (light/dark/system)
│   │   ├── sync/                # Cross-device refresh
│   │   └── utils/               # Weighting, vCard, platform helpers
│   ├── features/
│   │   ├── auth/
│   │   ├── contacts/            # Import, list, edit, frequency settings
│   │   ├── wheel/               # Spin animation + selection logic
│   │   ├── call_log/            # Call logging and rating
│   │   ├── status/              # Presence + overdue call suggestions
│   │   ├── stats/               # Streaks, history, charts
│   │   ├── profile/             # Profile hub + digital business card
│   │   ├── settings/            # App settings + account management
│   │   └── notifications/       # Reminder scheduling + FCM tokens
│   ├── shared/                  # Reusable widgets, models, extensions
│   ├── main.dart
│   └── router.dart
├── assets/
│   ├── images/                  # Logo, illustrations
│   └── fonts/                   # Inter or system fonts
├── supabase/
│   ├── migrations/              # SQL schema files
│   └── functions/               # Edge Functions (daily reminders)
├── test/
├── integration_test/
├── docs/                        # Deployment and architecture docs
├── Makefile
├── pubspec.yaml
├── AGENTS.md                    # ← This file (keep updated)
└── README.md
```

**Naming Convention:** `snake_case` for files/folders, `PascalCase` for classes/widgets, `camelCase` for variables/methods.

---

## 4. Brand & Design System (Strictly Follow)

**App Name:** GiroCall  
**Tagline:** "Spin the Giro. Make the Call. Stay Connected."

**Primary Colors (use exact hex in code):**
- Primary Teal: `#0D9488`
- Accent Coral: `#F97316` (CTAs, highlights)
- Secondary Blue: `#3B82F6`

**Light theme:**
- Background: `#F8FAFC`
- Surface: `#FFFFFF`
- Text Primary: `#1E293B`
- Text Secondary: `#64748B`

**Dark theme:**
- Background: `#0F172A`
- Surface: `#1E293B`
- Text Primary: `#F1F5F9`
- Text Secondary: `#94A3B8`

Use `AppTheme.light` / `AppTheme.dark` and `Theme.of(context)` — never hardcode light-only colors in widgets.

**Typography:** Inter (or system sans-serif). Use generous line height.

**Logo:** Circular spinning wheel with diverse avatars + central phone icon + "GiroCall" wordmark (see generated assets in `/assets`).

**Tone of Voice:** Warm, encouraging, lightly playful, respectful. Never guilt-tripping.

**Example microcopy:**
- "Who’s it going to be today?"
- "Great call! How did it feel?"
- "You’ve reconnected with 12 people this month — nice work."

---

## 5. Data Models (Supabase Schema)

**Core Tables (create via migrations):**

```sql
-- users (handled by Supabase Auth)

CREATE TABLE contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  phone text NOT NULL,
  photo_url text,
  notes text,
  target_frequency_days integer DEFAULT 30,
  last_called_at timestamptz,
  relationship_score integer,           -- 1-5 optional
  created_at timestamptz DEFAULT now()
);

CREATE TABLE call_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  contact_id uuid REFERENCES contacts(id) ON DELETE CASCADE,
  called_at timestamptz NOT NULL DEFAULT now(),
  duration_seconds integer,
  call_rating integer CHECK (call_rating BETWEEN 1 AND 5),
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE user_settings (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  daily_reminder_time time,
  daily_call_goal integer DEFAULT 2,
  created_at timestamptz DEFAULT now()
);
```

**Important Rules:**

- Every query must respect Row Level Security (RLS)
- Users can only access their own data
- Contact import must ask for explicit permission

---

## 6. Build, Run & Test Commands

```bash
# Install
flutter pub get

# Run
flutter run                    # default device
flutter run -d chrome          # Web
flutter run -d ios             # iOS simulator
flutter run -d android         # Android emulator

# Build
flutter build apk --release
flutter build ios --release
flutter build web --release

# Quality
flutter analyze
dart format .
flutter test
flutter test integration_test/
```

Before any PR or handoff: Run `flutter analyze` and `flutter test` — they must pass cleanly.

---

## 7. Development Guidelines for AI Agents

- Always read this AGENTS.md first before starting any task.
- Work in vertical slices: Complete one full user flow (e.g. spin → call → rate → see updated recommendation) before starting another.
- Prioritize delightful UX — especially the wheel animation and positive feedback after logging a call.
- Privacy-first: Request minimal permissions. Explain clearly why contact access is needed.
- Use Riverpod for state. Keep widgets small and focused.
- Write tests alongside features (unit for logic, widget for UI, integration for flows).
- Update this AGENTS.md and README.md whenever you make architectural decisions or add major features.
- Keep the natural language in comments and documentation clear and concise (matching this file).

---

## 8. Security & Privacy (Non-Negotiable)

- Supabase RLS policies are mandatory on all tables.
- Never log or expose phone numbers unnecessarily.
- Push notification payloads must not contain contact names or numbers.
- Provide easy "Delete my account and all data" flow.
- Follow GDPR/CCPA principles from day one.
- Any change to auth, contacts, or call logging must be reviewed against this section.

---

## 9. Current Status & Next Steps (as of 2026-06-18)

- **v2.0 ground-up UI rebuild** — consolidated `lib/core/design/`, `lib/app/` bootstrap + shell
- Flutter-only (Next.js `site/` removed); web = Flutter PWA via `build/web/`
- Brand, Supabase backend, wheel, contacts, status, stats, profile, settings intact
- 24 tests passing, `flutter analyze` clean

**Next recommended steps:**

1. End-to-end testing on iOS and Android devices
2. Firebase / FCM production setup for push reminders
3. App Store / Play Store deployment
4. Contact photo sync and richer wheel avatars

---

## 10. How to Update This File

When you make significant changes (new features, architecture decisions, new packages, etc.), update the relevant sections above and add a short note at the bottom with the date.

Example:  
`Updated wheel selection algorithm section — 2026-06-20`

---

This file is the single source of truth.  
Any AI agent or developer working on GiroCall must follow the guidelines here.

Last updated: 2026-06-18

## Updates

- Full Flutter project scaffold completed — 2026-06-17
- Edge Function for daily reminders, FCM skeleton, Makefile, deployment docs, and additional tests added — 2026-06-17
- Dark theme, Profile/Settings/Account UI, mobile UX polish, dependency upgrades (Riverpod 3, GoRouter 17, Firebase 4.x) — 2026-06-17
- Launcher icons generated for Android, iOS, and Web (PWA) using `flutter_launcher_icons`; pre-existing lint issues resolved so `flutter analyze` passes cleanly — 2026-06-17
- App now runs on Android emulator; fixed `LoginScreen` negative `BoxConstraints` bug and moved `ref.listen` into `build()` in `main.dart`; cleaned up duplicate Android `build.gradle.kts`/`settings.gradle.kts` files and aligned NDK version — 2026-06-17
- v2.0 ground-up UI rebuild: `lib/core/design/`, `lib/app/`, removed Next.js site, merged recommendations into status — 2026-06-18

GiroCall — Helping people stay connected, one spin at a time.
