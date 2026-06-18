#!/usr/bin/env node
/**
 * Apply GiroCall SQL migrations to remote Supabase (skips already-applied).
 *
 * Prefers: make setup-db  (uses DATABASE_URL, token, or CLI)
 * Direct:  node scripts/apply_migrations.mjs
 */

import { readFileSync, readdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadEnvFile } from './load_env.mjs';

loadEnvFile();

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRef = process.env.SUPABASE_PROJECT_REF ?? 'gtvpsukmmjhszpopulfe';
const migrationsDir = resolve(__dirname, '../supabase/migrations');

const token = process.env.SUPABASE_ACCESS_TOKEN;
if (!token) {
  console.error(
    'Missing SUPABASE_ACCESS_TOKEN.\n' +
      'Create one at https://supabase.com/dashboard/account/tokens\n' +
      'Add it to .env, then run: make setup-db',
  );
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

async function getAppliedVersions() {
  try {
    const rows = await query(
      `SELECT version FROM supabase_migrations.schema_migrations ORDER BY version;`,
    );
    return new Set(rows.map((row) => row.version));
  } catch {
    return new Set();
  }
}

async function recordMigration(version) {
  await query(
    `INSERT INTO supabase_migrations.schema_migrations (version)
     VALUES ('${version.replace(/'/g, "''")}')
     ON CONFLICT (version) DO NOTHING;`,
  );
}

const files = readdirSync(migrationsDir)
  .filter((name) => name.endsWith('.sql'))
  .sort();

if (files.length === 0) {
  console.error(`No migration files found in ${migrationsDir}`);
  process.exit(1);
}

const applied = await getAppliedVersions();
let ran = 0;
let skipped = 0;

for (const file of files) {
  const version = file.replace(/\.sql$/, '');

  if (applied.has(version)) {
    console.log(`⊘ Skipping ${file} (already applied)`);
    skipped += 1;
    continue;
  }

  const sql = readFileSync(resolve(migrationsDir, file), 'utf8');
  console.log(`→ Applying ${file}...`);

  try {
    await query(sql);
    await recordMigration(version);
    console.log(`✓ ${file}`);
    ran += 1;
  } catch (error) {
    console.error(`Migration failed on ${file}: ${error.message}`);
    process.exit(1);
  }
}

console.log(
  `Done. Applied ${ran}, skipped ${skipped}, total ${files.length} migration file(s).`,
);