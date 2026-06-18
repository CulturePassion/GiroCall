#!/usr/bin/env bash
# Build Flutter web PWA for hosting.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example to .env first."
  exit 1
fi

echo "→ Building Flutter web (release)..."
flutter build web --release --dart-define-from-file=.env

echo ""
echo "✓ Build complete."
echo ""
echo "Deploy artifact: $ROOT/build/web/"
echo ""
echo "Recommended hosts: Vercel, Netlify, Firebase Hosting, Cloudflare Pages"
echo "Upload the contents of build/web/ to your static host."
echo ""
echo "Supabase Auth → add your production URL to:"
echo "  Dashboard → Authentication → URL Configuration → Redirect URLs"