#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PROJECT_REF="${SUPABASE_PROJECT_REF:-gtvpsukmmjhszpopulfe}"
SQL_URL="https://supabase.com/dashboard/project/${PROJECT_REF}/sql/new"

# Load .env
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# Allow one-off: make setup-db TOKEN=sbp_...
if [[ -n "${TOKEN:-}" ]]; then
  export SUPABASE_ACCESS_TOKEN="$TOKEN"
fi

run_via_database_url() {
  echo "→ Pushing migrations via DATABASE_URL..."
  npx supabase db push --db-url "$DATABASE_URL"
}

run_via_access_token() {
  echo "→ Applying migrations via Supabase API..."
  node scripts/apply_migrations.mjs
}

run_via_cli() {
  echo "→ Linking project ${PROJECT_REF}..."
  supabase link --project-ref "$PROJECT_REF" --yes >/dev/null 2>&1 || true
  echo "→ Pushing migrations via Supabase CLI..."
  supabase db push
}

run_paste_flow() {
  node scripts/combine_migrations.mjs
  echo ""
  echo "No database credential found. Use one of these:"
  echo ""
  echo "  1) One-liner with access token:"
  echo "     make setup-db TOKEN=sbp_your_token"
  echo ""
  echo "  2) Add to .env (permanent):"
  echo "     SUPABASE_ACCESS_TOKEN=sbp_..."
  echo "     # or DATABASE_URL=postgresql://..."
  echo ""
  echo "  3) Paste SQL manually (combined file ready):"
  echo "     ${SQL_URL}"
  echo "     File: supabase/combined_migrations.sql"
  echo ""

  if [[ -f supabase/combined_migrations.sql ]]; then
    if command -v pbcopy >/dev/null 2>&1; then
      pbcopy < supabase/combined_migrations.sql
      echo "✓ Combined SQL copied to clipboard."
    fi
    if command -v open >/dev/null 2>&1; then
      open "$SQL_URL"
      echo "✓ Opened Supabase SQL Editor in your browser."
      echo "  Paste (⌘V) and click Run."
    fi
  fi

  return 1
}

if [[ -n "${DATABASE_URL:-}" ]]; then
  run_via_database_url
  exit 0
fi

if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  run_via_access_token
  exit 0
fi

if supabase projects list >/dev/null 2>&1; then
  run_via_cli
  exit 0
fi

run_paste_flow