-- Rich contact fields (iPhone/Android parity) + WhatsApp-style presence status

ALTER TABLE public.contacts
  ADD COLUMN IF NOT EXISTS first_name text,
  ADD COLUMN IF NOT EXISTS last_name text,
  ADD COLUMN IF NOT EXISTS email text,
  ADD COLUMN IF NOT EXISTS company text,
  ADD COLUMN IF NOT EXISTS job_title text,
  ADD COLUMN IF NOT EXISTS birthday date,
  ADD COLUMN IF NOT EXISTS secondary_phone text,
  ADD COLUMN IF NOT EXISTS website text,
  ADD COLUMN IF NOT EXISTS address_line1 text,
  ADD COLUMN IF NOT EXISTS address_line2 text,
  ADD COLUMN IF NOT EXISTS city text,
  ADD COLUMN IF NOT EXISTS state text,
  ADD COLUMN IF NOT EXISTS postal_code text,
  ADD COLUMN IF NOT EXISTS country text,
  ADD COLUMN IF NOT EXISTS device_native_id text,
  ADD COLUMN IF NOT EXISTS sync_to_device boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS last_device_sync_at timestamptz;

CREATE INDEX IF NOT EXISTS idx_contacts_device_native_id
  ON public.contacts(user_id, device_native_id)
  WHERE device_native_id IS NOT NULL;

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS presence_type text
    CHECK (presence_type IS NULL OR presence_type IN ('available', 'meeting', 'custom')),
  ADD COLUMN IF NOT EXISTS presence_message text,
  ADD COLUMN IF NOT EXISTS presence_updated_at timestamptz;

CREATE TABLE IF NOT EXISTS public.user_status_stories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  text_content text NOT NULL,
  status_type text NOT NULL DEFAULT 'custom'
    CHECK (status_type IN ('available', 'meeting', 'custom')),
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_status_stories_user_expires
  ON public.user_status_stories(user_id, expires_at DESC);

CREATE INDEX IF NOT EXISTS idx_status_stories_expires
  ON public.user_status_stories(expires_at DESC);

ALTER TABLE public.user_status_stories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "status_stories_select_active" ON public.user_status_stories;
DROP POLICY IF EXISTS "status_stories_insert_own" ON public.user_status_stories;
DROP POLICY IF EXISTS "status_stories_delete_own" ON public.user_status_stories;

CREATE POLICY "status_stories_select_active" ON public.user_status_stories
  FOR SELECT TO authenticated
  USING (expires_at > now());

CREATE POLICY "status_stories_insert_own" ON public.user_status_stories
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "status_stories_delete_own" ON public.user_status_stories
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

GRANT SELECT, INSERT, DELETE ON public.user_status_stories TO authenticated;