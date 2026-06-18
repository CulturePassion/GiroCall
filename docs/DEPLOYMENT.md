# GiroCall Deployment Guide

Project ref: `gtvpsukmmjhszpopulfe`

GiroCall is **Flutter-only** — web deploys as a PWA from `build/web/`.

## Quick start

```bash
cp .env.example .env
make deploy-all               # migrations + edge functions + secrets + verify
make deploy-hosting           # build Flutter web PWA
```

## 1. Supabase

### Credentials

| Variable | Where to get it |
|----------|-----------------|
| `SUPABASE_URL` | Dashboard → Project Settings → API |
| `SUPABASE_ANON_KEY` | Same page (publishable anon key) |
| `SUPABASE_ACCESS_TOKEN` | [Account tokens](https://supabase.com/dashboard/account/tokens) |

### Migrations & verify

```bash
make setup-db
make verify-supabase          # 15 health checks
```

### Auth redirect URLs

**Dashboard → Authentication → URL Configuration:**

- Site URL: `https://girocall.com`
- Redirect URLs: `http://localhost:62792`, `https://girocall.com`, `https://www.girocall.com`

### Edge functions

```bash
make deploy-edge-all
make deploy-secrets
```

Schedule `daily-reminder`: cron `* * * * *`, header `Authorization: Bearer <CRON_SECRET>`.

## 2. Flutter builds

```bash
make build-apk
make build-ios
make build-web                # output: build/web/
```

## 3. Web hosting

Upload `build/web/` to Vercel, Netlify, Firebase Hosting, or Cloudflare Pages.

Add your production URL to Supabase Auth redirect URLs.

## 4. Environment variables

```bash
cp .env.example .env
```

Required: `SUPABASE_URL`, `SUPABASE_ANON_KEY`  
Deploy: `SUPABASE_ACCESS_TOKEN`, `CRON_SECRET`, `FCM_SERVER_KEY`  
Optional: `APP_BASE_URL` (defaults to `https://girocall.com`)

## Makefile reference

| Target | Action |
|--------|--------|
| `make setup-db` | Apply pending SQL migrations |
| `make deploy-edge-all` | Deploy edge functions |
| `make deploy-secrets` | Push secrets from `.env` |
| `make verify-supabase` | Run health checks |
| `make deploy-all` | Full Supabase stack |
| `make deploy-hosting` | Build Flutter web PWA |