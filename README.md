# GiroCall

**Spin the Giro. Make the Call. Stay Connected.**

GiroCall is a cross-platform relationship maintenance app built with Flutter and Supabase. It helps you reconnect with people you care about through a delightful spinning wheel that picks who to call next.

## Features

- Secure authentication with Supabase Auth
- Import device contacts or add them manually
- Animated spinning wheel with smart weighting
- One-tap calling with native dialer integration
- Call logging and star ratings
- Smart "Call Again" recommendations
- Stats, streaks, and progress charts
- Daily reminder notifications
- Dark theme (system / light / dark)
- Profile hub with digital business card
- Settings and account management

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.44+ (Dart 3.2+) |
| Backend | Supabase (Auth, PostgreSQL, Realtime, Edge Functions) |
| State | Riverpod 3 |
| Navigation | GoRouter 17 |
| Charts | fl_chart |
| Theme persistence | shared_preferences |

## Getting Started

### Prerequisites

- Flutter SDK (stable channel, 3.22+)
- A Supabase project

### Setup

1. Copy environment template and add credentials:

```bash
cp .env.example .env
```

2. Run all SQL migrations in `supabase/migrations/` against your Supabase project (in order), or:

```bash
make setup-db
```

3. Install dependencies:

```bash
make install
```

4. Run the app:

```bash
make run          # Web (Chrome)
make run-ios      # iOS simulator
make run-android  # Android emulator
```

Credentials are loaded from `.env` via `--dart-define-from-file`.

## App Navigation

| Tab / Screen | Route | Purpose |
|--------------|-------|---------|
| Giro | `/` | Spin the wheel |
| People | `/contacts` | Contact list and import |
| Suggest | `/recommendations` | Overdue call suggestions |
| Stats | `/stats` | Streaks and charts |
| Profile | `/profile` | Account hub |
| My Card | `/profile/card` | Digital business card |
| Settings | `/settings` | Theme and preferences |
| Account | `/settings/account` | Sign out, delete data |
| Reminders | `/settings/notifications` | Daily nudges |

## Build Commands

```bash
make build-apk    # Android release APK
make build-ios    # iOS release
make build-web    # Web PWA
```

## Quality

```bash
make format       # Format Dart code
make analyze      # Static analysis
make test         # Unit and widget tests
make test-integration
```

## Project Structure

```
lib/
├── core/           # Theme, config, utils, Supabase bootstrap
│   └── theme/      # Dark/light theme mode provider
├── features/
│   ├── auth/
│   ├── contacts/
│   ├── wheel/
│   ├── call_log/
│   ├── recommendations/
│   ├── stats/
│   ├── profile/    # Profile hub + digital card
│   ├── settings/   # Settings + account screens
│   └── notifications/
├── shared/         # Reusable widgets and models
├── main.dart
└── router.dart
```

See `AGENTS.md` for the full project specification and development guidelines.  
See `docs/DEPLOYMENT.md` for Supabase, Edge Functions, and push notification setup.

## License

Copyright © 2026 GiroCall. All rights reserved.# GiroCall
