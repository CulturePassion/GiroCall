-- Security hardening and account deletion support.

create or replace function public.update_contact_last_called()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.contacts
  set last_called_at = new.called_at
  where id = new.contact_id;
  return new;
end;
$$;

create or replace function public.create_default_user_settings()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

revoke execute on function public.update_contact_last_called() from public, anon, authenticated;
revoke execute on function public.create_default_user_settings() from public, anon, authenticated;

create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_account() from public;
revoke execute on function public.delete_account() from anon;
grant execute on function public.delete_account() to authenticated;