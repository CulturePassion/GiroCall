-- Store the user's UTC offset so server-side reminders fire at the right local time.

alter table public.user_settings
  add column if not exists timezone_offset_minutes integer default 0 not null;