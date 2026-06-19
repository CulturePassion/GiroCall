#!/usr/bin/env node
import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const migrationsDir = resolve(__dirname, '../supabase/migrations');
const outPath = resolve(__dirname, '../supabase/combined_migrations.sql');

const files = readdirSync(migrationsDir)
  .filter((f) => f.endsWith('.sql') && f !== 'combined_migrations.sql')
  .sort();

const legacyPolicyCleanup = `
-- Drop legacy monolithic RLS policies (001) before migrations re-apply split policies (004+)
DROP POLICY IF EXISTS "Users can only access their own contacts" ON public.contacts;
DROP POLICY IF EXISTS "Users can only access their own call logs" ON public.call_logs;
DROP POLICY IF EXISTS "Users can only access their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can only access their own FCM tokens" ON public.fcm_tokens;
`.trim();

const parts = [
  '-- GiroCall combined migrations (safe to re-run)',
  `-- Generated: ${new Date().toISOString()}`,
  '-- Paste this entire file into Supabase SQL Editor and click Run.',
  '',
  '-- ── legacy_rls_cleanup (idempotent) ──',
  legacyPolicyCleanup,
  '',
];

for (const file of files) {
  parts.push(`-- ── ${file} ──`);
  parts.push(readFileSync(resolve(migrationsDir, file), 'utf8').trim());
  parts.push('');
}

const combined = parts.join('\n');
writeFileSync(outPath, combined, 'utf8');
console.log(`Wrote ${outPath} (${files.length} files)`);