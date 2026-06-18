#!/usr/bin/env bash
# Push Edge Function secrets from .env to Supabase.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Missing .env"
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

if [[ -z "${CRON_SECRET:-}" ]]; then
  echo "Missing CRON_SECRET in .env"
  exit 1
fi

ARGS=(CRON_SECRET="$CRON_SECRET")
if [[ -n "${FCM_SERVER_KEY:-}" ]]; then
  ARGS+=(FCM_SERVER_KEY="$FCM_SERVER_KEY")
fi

echo "→ Setting Edge Function secrets..."
supabase secrets set "${ARGS[@]}"

echo "✓ Secrets updated. Schedule daily-reminder in Dashboard → Edge Functions → Schedules."
echo "  Cron: * * * * *"
echo "  Header: Authorization: Bearer <CRON_SECRET>"