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

const parts = [
  '-- GiroCall combined migrations (safe to re-run)',
  `-- Generated: ${new Date().toISOString()}`,
  '-- Paste this entire file into Supabase SQL Editor and click Run.',
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