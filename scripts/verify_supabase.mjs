#!/usr/bin/env node
/**
 * Verify remote Supabase deployment (schema + storage).
 */

import { loadEnvFile } from './load_env.mjs';

loadEnvFile();

const projectRef = process.env.SUPABASE_PROJECT_REF ?? 'gtvpsukmmjhszpopulfe';
const token = process.env.SUPABASE_ACCESS_TOKEN;

if (!token) {
  console.error('Missing SUPABASE_ACCESS_TOKEN in .env');
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
    throw new Error(`${response.status}: ${body}`);
  }

  return response.json();
}

const checks = [
  {
    name: 'user_profiles table',
    sql: `SELECT to_regclass('public.user_profiles') AS exists;`,
    validate: (rows) => rows[0]?.exists === 'user_profiles',
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
];

console.log(`→ Verifying Supabase project ${projectRef}...`);

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

if (failed > 0) {
  console.error(`\n${failed} check(s) failed.`);
  process.exit(1);
}

console.log('\nAll Supabase checks passed.');