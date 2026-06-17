#!/usr/bin/env node
/**
 * Apply GiroCall SQL migrations (001–007) to a remote Supabase project.
 *
 * Option A (recommended): add DATABASE_URL to .env, then run `make setup-db`
 * Option B: add SUPABASE_ACCESS_TOKEN to .env, then run `node scripts/apply_migrations.mjs`
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
      'Add it to .env, then run: node scripts/apply_migrations.mjs',
  );
  process.exit(1);
}

const files = readdirSync(migrationsDir)
  .filter((name) => name.endsWith('.sql'))
  .sort();

if (files.length === 0) {
  console.error(`No migration files found in ${migrationsDir}`);
  process.exit(1);
}

const endpoint = `https://api.supabase.com/v1/projects/${projectRef}/database/query`;

for (const file of files) {
  const sql = readFileSync(resolve(migrationsDir, file), 'utf8');
  console.log(`→ Applying ${file}...`);

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
    console.error(`Migration failed on ${file} (${response.status}): ${body}`);
    process.exit(1);
  }

  console.log(`✓ ${file}`);
}

console.log(`All ${files.length} migrations applied successfully.`);