-- Split RLS policies for clearer security boundaries (idempotent)
-- Drops legacy monolithic policies from 001 before creating split policies.

-- contacts: separate SELECT/INSERT/UPDATE/DELETE
DROP POLICY IF EXISTS "Users can only access their own contacts" ON public.contacts;
DROP POLICY IF EXISTS "Users manage own contacts" ON public.contacts;
DROP POLICY IF EXISTS "contacts_select_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_insert_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_update_own" ON public.contacts;
DROP POLICY IF EXISTS "contacts_delete_own" ON public.contacts;

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

-- call_logs: separate policies
DROP POLICY IF EXISTS "Users can only access their own call logs" ON public.call_logs;
DROP POLICY IF EXISTS "Users manage own call logs" ON public.call_logs;
DROP POLICY IF EXISTS "call_logs_select_own" ON public.call_logs;
DROP POLICY IF EXISTS "call_logs_insert_own" ON public.call_logs;
DROP POLICY IF EXISTS "call_logs_update_own" ON public.call_logs;
DROP POLICY IF EXISTS "call_logs_delete_own" ON public.call_logs;

CREATE POLICY "call_logs_select_own" ON public.call_logs
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "call_logs_insert_own" ON public.call_logs
  FOR INSERT TO authenticated
  WITH CHECK (
    (SELECT auth.uid()) = user_id
    AND EXISTS (
      SELECT 1 FROM public.contacts c
      WHERE c.id = contact_id AND c.user_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "call_logs_update_own" ON public.call_logs
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK (
    (SELECT auth.uid()) = user_id
    AND EXISTS (
      SELECT 1 FROM public.contacts c
      WHERE c.id = contact_id AND c.user_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "call_logs_delete_own" ON public.call_logs
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- user_settings
DROP POLICY IF EXISTS "Users can only access their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users manage own settings" ON public.user_settings;
DROP POLICY IF EXISTS "user_settings_select_own" ON public.user_settings;
DROP POLICY IF EXISTS "user_settings_insert_own" ON public.user_settings;
DROP POLICY IF EXISTS "user_settings_update_own" ON public.user_settings;

CREATE POLICY "user_settings_select_own" ON public.user_settings
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "user_settings_insert_own" ON public.user_settings
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "user_settings_update_own" ON public.user_settings
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

-- fcm_tokens
DROP POLICY IF EXISTS "Users can only access their own FCM tokens" ON public.fcm_tokens;
DROP POLICY IF EXISTS "Users manage own fcm tokens" ON public.fcm_tokens;
DROP POLICY IF EXISTS "fcm_tokens_select_own" ON public.fcm_tokens;
DROP POLICY IF EXISTS "fcm_tokens_insert_own" ON public.fcm_tokens;
DROP POLICY IF EXISTS "fcm_tokens_update_own" ON public.fcm_tokens;
DROP POLICY IF EXISTS "fcm_tokens_delete_own" ON public.fcm_tokens;

CREATE POLICY "fcm_tokens_select_own" ON public.fcm_tokens
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "fcm_tokens_insert_own" ON public.fcm_tokens
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "fcm_tokens_update_own" ON public.fcm_tokens
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "fcm_tokens_delete_own" ON public.fcm_tokens
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);