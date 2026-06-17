# Daily Reminder Edge Function

Sends daily push notifications to users who have reminders enabled at the current UTC time.

## Deploy

```bash
supabase functions deploy daily-reminder
```

## Invoke manually

```bash
curl -L -X POST 'https://your-project.supabase.co/functions/v1/daily-reminder' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

## Schedule

Create a cron job in Supabase to call this function every minute:

```sql
select cron.schedule(
  'daily-reminder',
  '* * * * *',
  $$
  select
    net.http_post(
      url:='https://your-project.supabase.co/functions/v1/daily-reminder',
      headers:='{"Authorization": "Bearer SERVICE_ROLE_KEY", "Content-Type": "application/json"}'::jsonb
    ) as request_id;
  $$
);
```

> Note: This function does not include names or phone numbers in notification payloads, in line with GiroCall's privacy rules.
