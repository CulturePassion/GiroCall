-- Initial GiroCall schema with RLS policies.
-- Safe to re-run: uses IF NOT EXISTS / DROP IF EXISTS where needed.

create extension if not exists "uuid-ossp";

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  phone text not null,
  photo_url text,
  notes text,
  target_frequency_days integer default 30 not null,
  last_called_at timestamptz,
  relationship_score integer check (relationship_score between 1 and 5),
  created_at timestamptz default now() not null,
  unique (user_id, phone)
);

create table if not exists public.call_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  contact_id uuid references public.contacts(id) on delete cascade not null,
  called_at timestamptz not null default now(),
  duration_seconds integer,
  call_rating integer check (call_rating between 1 and 5),
  notes text,
  created_at timestamptz default now() not null
);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  daily_reminder_time time,
  daily_call_goal integer default 2 not null,
  created_at timestamptz default now() not null
);

create table if not exists public.fcm_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  token text not null,
  platform text not null default 'unknown',
  created_at timestamptz default now() not null,
  unique (user_id, token)
);

alter table public.contacts enable row level security;
alter table public.call_logs enable row level security;
alter table public.user_settings enable row level security;
alter table public.fcm_tokens enable row level security;

drop policy if exists "Users can only access their own contacts" on public.contacts;
create policy "Users can only access their own contacts"
  on public.contacts
  for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "Users can only access their own call logs" on public.call_logs;
create policy "Users can only access their own call logs"
  on public.call_logs
  for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "Users can only access their own settings" on public.user_settings;
create policy "Users can only access their own settings"
  on public.user_settings
  for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "Users can only access their own FCM tokens" on public.fcm_tokens;
create policy "Users can only access their own FCM tokens"
  on public.fcm_tokens
  for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create index if not exists idx_contacts_user_id on public.contacts(user_id);
create index if not exists idx_contacts_last_called on public.contacts(user_id, last_called_at);
create index if not exists idx_call_logs_user_id on public.call_logs(user_id);
create index if not exists idx_call_logs_called_at on public.call_logs(user_id, called_at desc);

create or replace function public.update_contact_last_called()
returns trigger as $$
begin
  update public.contacts
  set last_called_at = new.called_at
  where id = new.contact_id;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_update_contact_last_called on public.call_logs;
create trigger trg_update_contact_last_called
after insert on public.call_logs
for each row
execute function public.update_contact_last_called();

create or replace function public.create_default_user_settings()
returns trigger as $$
begin
  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_create_default_user_settings on auth.users;
create trigger trg_create_default_user_settings
after insert on auth.users
for each row
execute function public.create_default_user_settings();