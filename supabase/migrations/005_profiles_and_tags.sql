-- Contact relationship tags + digital business card profiles (idempotent)

ALTER TABLE public.contacts
  ADD COLUMN IF NOT EXISTS tag text
  CHECK (tag IS NULL OR tag IN ('friends', 'family', 'work', 'business'));

CREATE INDEX IF NOT EXISTS idx_contacts_user_tag ON public.contacts(user_id, tag);

CREATE TABLE IF NOT EXISTS public.user_profiles (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  slug text UNIQUE NOT NULL,
  display_name text NOT NULL DEFAULT '',
  title text,
  company text,
  bio text,
  phone text,
  email text,
  website text,
  address_line1 text,
  address_line2 text,
  city text,
  state text,
  postal_code text,
  country text,
  avatar_url text,
  linkedin_url text,
  twitter_url text,
  instagram_url text,
  facebook_url text,
  tiktok_url text,
  youtube_url text,
  is_public boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profile_select_own" ON public.user_profiles;
DROP POLICY IF EXISTS "profile_insert_own" ON public.user_profiles;
DROP POLICY IF EXISTS "profile_update_own" ON public.user_profiles;
DROP POLICY IF EXISTS "profile_delete_own" ON public.user_profiles;
DROP POLICY IF EXISTS "profile_select_public" ON public.user_profiles;

CREATE POLICY "profile_select_own" ON public.user_profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "profile_insert_own" ON public.user_profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profile_update_own" ON public.user_profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profile_delete_own" ON public.user_profiles
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "profile_select_public" ON public.user_profiles
  FOR SELECT TO anon, authenticated
  USING (is_public = true);

CREATE OR REPLACE FUNCTION public.set_profile_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER trg_user_profiles_updated_at
BEFORE UPDATE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_profile_updated_at();

CREATE OR REPLACE FUNCTION public.create_default_user_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  base_slug text;
  final_slug text;
  suffix int := 0;
  display text;
BEGIN
  base_slug := lower(
    regexp_replace(
      split_part(coalesce(new.email, new.id::text), '@', 1),
      '[^a-z0-9]',
      '-',
      'g'
    )
  );
  IF base_slug = '' OR length(base_slug) < 3 THEN
    base_slug := 'user';
  END IF;
  final_slug := base_slug;
  WHILE EXISTS (SELECT 1 FROM public.user_profiles WHERE slug = final_slug) LOOP
    suffix := suffix + 1;
    final_slug := base_slug || '-' || suffix;
  END LOOP;

  display := coalesce(
    new.raw_user_meta_data->>'display_name',
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'GiroCall User'
  );

  INSERT INTO public.user_profiles (user_id, slug, display_name, email, is_public)
  VALUES (new.id, final_slug, display, new.email, false)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN new;
END;
$$;

DROP TRIGGER IF EXISTS trg_create_default_user_profile ON auth.users;
CREATE TRIGGER trg_create_default_user_profile
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.create_default_user_profile();

GRANT SELECT ON public.user_profiles TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.user_profiles TO authenticated;