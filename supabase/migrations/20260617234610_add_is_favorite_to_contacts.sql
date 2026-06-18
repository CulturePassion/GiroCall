-- Safe to re-run
ALTER TABLE public.contacts
  ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN NOT NULL DEFAULT FALSE;