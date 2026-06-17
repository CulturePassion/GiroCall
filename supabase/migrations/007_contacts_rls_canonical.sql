-- Canonical RLS for public.contacts (idempotent, fixes duplicate legacy policies)
--
-- GiroCall intent:
--   • Ownership column: user_id (uuid → auth.users)
--   • Access model: single-tenant — each user sees only their own rows
--   • Operations: SELECT, INSERT, UPDATE, DELETE
--   • Client: Flutter app via Supabase Data API (publishable/anon key + signed-in user)
--   • anon: no direct table access

ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;

-- Remove every known legacy / duplicate policy name
DROP POLICY IF EXISTS "Users can only access their own contacts" ON public.contacts;
DROP POLICY IF EXISTS "Users manage own contacts" ON public.contacts;
DROP POLICY IF EXISTS "Users can only insert their own contacts" ON public.contacts;
DROP POLICY IF EXISTS "Users can only update their own contacts" ON public.contacts;
DROP POLICY IF EXISTS "Users can only delete their own contacts" ON public.contacts;
DROP POLICY IF EXISTS "contacts_select_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_insert_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_update_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_delete_own" ON public.contacts;

-- API role grants (authenticated only; RLS still enforces row ownership)
REVOKE ALL ON public.contacts FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.contacts TO authenticated;

CREATE POLICY "contacts_select_own" ON public.contacts
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "contacts_insert_own" ON public.contacts
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "contacts_update_own" ON public.contacts
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "contacts_delete_own" ON public.contacts
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);