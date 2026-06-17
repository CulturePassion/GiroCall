# GiroCall Deployment Guide

## 1. Supabase Setup

1. Create a Supabase project.
2. Go to **Project Settings > API** and copy the URL and anon key.
3. Run all SQL migrations in `supabase/migrations/` (in order) via the SQL Editor or CLI:

```bash
supabase login
supabase link --project-ref your-project-ref
supabase db push
# or from the project root:
make setup-db
```

Migration files (run in order):

| File | Purpose |
|------|---------|
| `001_initial_schema.sql` | Core tables, RLS, account deletion |
| `002_security_hardening.sql` | Auth trigger hardening |
| `003_reminder_timezone.sql` | Timezone offset for reminders |
| `004_rls_policy_split.sql` | Granular RLS policies |
| `005_profiles_and_tags.sql` | User profiles, digital cards, contact tags |

## 2. Edge Function (daily reminders)

The `daily-reminder` function is deployed to Supabase. Set these **Edge Function secrets** in the dashboard:

| Secret | Purpose |
|--------|---------|
| `FCM_SERVER_KEY` | Firebase Cloud Messaging server key (mobile push) |
| `CRON_SECRET` | Random string used to authenticate cron invocations |

**Schedule the function** in [Supabase Dashboard → Edge Functions → daily-reminder → Schedules](https://supabase.com/dashboard/project/gtvpsukmmjhszpopulfe/functions):

- Cron: `* * * * *` (every minute)
- HTTP header: `Authorization: Bearer <your-CRON_SECRET>`

Or redeploy manually:

```bash
supabase functions deploy daily-reminder --no-verify-jwt
supabase secrets set FCM_SERVER_KEY=your-fcm-key CRON_SECRET=your-random-secret
```

## 3. Flutter Build

### Android

```bash
flutter build apk --release
```

### iOS

Minimum deployment target: **iOS 15.0** (required by Firebase 4.x).

If the app crashes on launch with `SwiftFlutterContactsPlugin`, stale CocoaPods
symlinks are usually the cause. Refresh the iOS build:

```bash
make clean-ios
flutter run -d ios --dart-define-from-file=.env
```

```bash
flutter build ios --release
```

### Web PWA

```bash
flutter build web --release
```

## 4. Environment Variables

Copy `.env.example` to `.env` and fill in your credentials. The Makefile and VS Code launch configs load them automatically:

```bash
cp .env.example .env
make run
```

Or pass defines manually:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Optional: `APP_BASE_URL` for public digital card links (defaults to `https://girocall.com`).

For CI/CD, add these as secrets.

## 5. Push Notifications (Mobile)

1. Create a Firebase project and add Android + iOS apps for `com.girocall.app`.
2. Run `flutterfire configure` (or manually add `google-services.json` and `GoogleService-Info.plist`).
3. Set `FCM_SERVER_KEY` in Supabase Edge Function secrets.
4. Build and run on a device — the app registers FCM tokens in `public.fcm_tokens` on sign-in.
5. Enable daily reminders in the app (saves local time + timezone offset).

## 6. CI/CD

GitHub Actions workflow is in `.github/workflows/flutter.yml`.
