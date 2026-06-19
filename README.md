# GiroCall

**Spin the Giro. Make the Call. Stay Connected.**

GiroCall is a cross-platform relationship maintenance app built with Flutter and Supabase. It helps you reconnect with people you care about through a delightful spinning wheel that picks who to call next.

## Features

- Secure authentication with Supabase Auth
- Import device contacts or add them manually
- Animated spinning wheel with smart weighting
- One-tap calling with native dialer integration
- Call logging and star ratings
- Status tab with overdue call suggestions
- Stats, streaks, and progress charts
- Daily reminder notifications
- Dark theme (system / light / dark)
- Profile hub with digital business card
- Settings and account management

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.44+ (Dart 3.2+) — iOS, Android, Web PWA |
| Backend | Supabase (Auth, PostgreSQL, Storage, Edge Functions) |
| State | Riverpod 3 |
| Navigation | GoRouter 17 |
| Charts | fl_chart |

## Getting Started

```bash
cp .env.example .env          # add Supabase URL + anon key
make setup-db                 # apply migrations
make install
make run                      # Chrome
make run-ios
make run-android
```

## App Navigation

| Tab | Route | Purpose |
|-----|-------|---------|
| **Giro** (center) | `/` | Spin the wheel |
| People | `/contacts` | Contact list and import |
| Status | `/status` | Presence + overdue suggestions |
| Stats | `/stats` | Streaks and charts |
| You | `/profile` | Account hub |

## Recent Updates (v2.1)
- Premium frosted glassmorphism, entrance animations, spacing & dark mode polish focused on Profile + Digital Card
- Full brand palette refresh (#1EB05B vibrant green + 5 supporting colors)
- See CHANGELOG.md for details

Public digital cards: `/card/:slug` (no auth required)

## Build & Deploy

```bash
make build-apk
make build-ios
make build-web                # → build/web/ for static hosting
make deploy-all               # Supabase migrations + edge functions
```

## Quality

```bash
make analyze
make test
make format
```

## Project Structure

```
lib/
├── app/            # Bootstrap, main shell (Giro-centered nav)
├── core/
│   ├── design/     # Colors, theme, spacing, tokens, microcopy
│   └── theme/      # Light/dark/system mode
├── features/       # auth, contacts, wheel, call_log, status, stats, profile, settings, notifications
├── shared/         # Models and reusable widgets
├── main.dart
└── router.dart
```

See `AGENTS.md` for the full specification.  
See `docs/DEPLOYMENT.md` for Supabase and hosting setup.

## License

Copyright © 2026 GiroCall. All rights reserved.# GiroCall
