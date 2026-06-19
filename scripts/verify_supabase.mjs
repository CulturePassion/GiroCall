#!/usr/bin/env node
/**
 * Full Supabase health check — schema, storage, edge functions, and core columns.
 */

import { loadEnvFile } from './load_env.mjs';
import {
  formatManagementApiError,
  getAccessToken,
  validateAccessToken,
} from './supabase_token.mjs';

loadEnvFile();

const projectRef = process.env.SUPABASE_PROJECT_REF ?? 'gtvpsukmmjhszpopulfe';
const supabaseUrl = (
  process.env.SUPABASE_URL ?? `https://${projectRef}.supabase.co`
).replace(/\/+$/, '');

let token = getAccessToken();
let tokenCheck = validateAccessToken(token);
if (!tokenCheck.ok && process.platform === 'darwin') {
  try {
    const { execSync } = await import('node:child_process');
    const keychainToken = execSync(
      'security find-generic-password -s "Supabase CLI" -w 2>/dev/null',
      { encoding: 'utf8' },
    ).trim();
    const keychainCheck = validateAccessToken(keychainToken);
    if (keychainCheck.ok) token = keychainToken;
  } catch {
    // fall through
  }
}
tokenCheck = validateAccessToken(token);
if (!tokenCheck.ok) {
  console.error(tokenCheck.message);
  process.exit(1);
}

const endpoint = `https://api.supabase.com/v1/projects/${projectRef}/database/query`;

async function query(sql) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ query: sql }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(formatManagementApiError(response.status, body));
  }

  return response.json();
}

const checks = [
  {
    name: 'contacts table',
    sql: `SELECT to_regclass('public.contacts') AS exists;`,
    validate: (rows) => rows[0]?.exists === 'contacts',
  },
  {
    name: 'contacts.is_favorite column',
    sql: `SELECT column_name FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'contacts'
          AND column_name = 'is_favorite';`,
    validate: (rows) => rows.length === 1,
  },
  {
    name: 'call_logs table',
    sql: `SELECT to_regclass('public.call_logs') AS exists;`,
    validate: (rows) => rows[0]?.exists === 'call_logs',
  },
  {
    name: 'user_settings table',
    sql: `SELECT to_regclass('public.user_settings') AS exists;`,
    validate: (rows) => rows[0]?.exists === 'user_settings',
  },
  {
    name: 'user_profiles table',
    sql: `SELECT to_regclass('public.user_profiles') AS exists;`,
    validate: (rows) => rows[0]?.exists === 'user_profiles',
  },
  {
    name: 'fcm_tokens table',
    sql: `SELECT to_regclass('public.fcm_tokens') AS exists;`,
    validate: (rows) => rows[0]?.exists === 'fcm_tokens',
  },
  {
    name: 'contacts RLS enabled',
    sql: `SELECT relrowsecurity FROM pg_class
          WHERE relname = 'contacts' AND relnamespace = 'public'::regnamespace;`,
    validate: (rows) => rows[0]?.relrowsecurity === true,
  },
  {
    name: 'avatars storage bucket',
    sql: `SELECT id, public FROM storage.buckets WHERE id = 'avatars';`,
    validate: (rows) => rows.length === 1 && rows[0].public === true,
  },
  {
    name: 'avatar storage policies',
    sql: `SELECT count(*)::int AS count FROM pg_policies
          WHERE schemaname = 'storage' AND tablename = 'objects'
          AND policyname LIKE 'avatars_%';`,
    validate: (rows) => rows[0]?.count >= 4,
  },
  {
    name: 'profile avatar_url column',
    sql: `SELECT column_name FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'user_profiles'
          AND column_name = 'avatar_url';`,
    validate: (rows) => rows.length === 1,
  },
  {
    name: 'migrations tracked',
    sql: `SELECT count(*)::int AS count FROM supabase_migrations.schema_migrations;`,
    validate: (rows) => (rows[0]?.count ?? 0) >= 9,
  },
  {
    name: 'contacts.tag column',
    sql: `SELECT column_name FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'contacts'
          AND column_name = 'tag';`,
    validate: (rows) => rows.length === 1,
  },
  {
    name: 'delete_account function',
    sql: `SELECT proname FROM pg_proc
          WHERE proname = 'delete_account' AND pronamespace = 'public'::regnamespace;`,
    validate: (rows) => rows.length === 1,
  },
];

const edgeChecks = [
  {
    name: 'wallet-pass edge function',
    url: `${supabaseUrl}/functions/v1/wallet-pass`,
    validate: async (response) => {
      const body = await response.text();
      // Public endpoint: missing slug → 400; misconfigured JWT → 401.
      if (response.status === 400 && body.includes('slug')) return true;
      if (response.status === 401) {
        throw new Error('deploy with: supabase functions deploy wallet-pass --no-verify-jwt');
      }
      return false;
    },
  },
  {
    name: 'daily-reminder edge function',
    url: `${supabaseUrl}/functions/v1/daily-reminder`,
    validate: async (response) => {
      // 401 = deployed with CRON_SECRET; 200 = deployed without secret guard.
      return response.status === 401 || response.status === 200;
    },
  },
];

console.log(`→ GiroCall Supabase health check (${projectRef})...\n`);

let failed = 0;

for (const check of checks) {
  try {
    const rows = await query(check.sql);
    if (check.validate(rows)) {
      console.log(`✓ ${check.name}`);
    } else {
      console.error(`✗ ${check.name}`);
      failed += 1;
    }
  } catch (error) {
    console.error(`✗ ${check.name}: ${error.message}`);
    failed += 1;
  }
}

for (const check of edgeChecks) {
  try {
    const response = await fetch(check.url, { method: 'POST' });
    if (await check.validate(response)) {
      console.log(`✓ ${check.name}`);
    } else {
      console.error(`✗ ${check.name} (HTTP ${response.status})`);
      failed += 1;
    }
  } catch (error) {
    console.error(`✗ ${check.name}: ${error.message}`);
    failed += 1;
  }
}

if (failed > 0) {
  console.error(`\n${failed} check(s) failed. Run: make deploy-supabase`);
  process.exit(1);
}

console.log('\nAll Supabase health checks passed.');