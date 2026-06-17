import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

interface UserRow {
  user_id: string;
  daily_reminder_time: string | null;
  daily_call_goal: number;
  timezone_offset_minutes: number | null;
}

interface ContactRow {
  user_id: string;
  target_frequency_days: number;
  last_called_at: string | null;
}

interface FcmTokenRow {
  user_id: string;
  token: string;
  platform: string;
}

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const fcmServerKey = Deno.env.get('FCM_SERVER_KEY');
const cronSecret = Deno.env.get('CRON_SECRET');

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

function localTimeFromUtc(date: Date, offsetMinutes: number): string {
  const totalMinutes =
    date.getUTCHours() * 60 + date.getUTCMinutes() + offsetMinutes;
  const normalized = ((totalMinutes % 1440) + 1440) % 1440;
  const hour = Math.floor(normalized / 60);
  const minute = normalized % 60;
  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}:00`;
}

function normalizeStoredTime(value: string): string {
  const parts = value.split(':');
  if (parts.length < 2) return value;
  return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}:00`;
}

async function sendFcm(token: string): Promise<void> {
  if (!fcmServerKey) return;

  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      Authorization: `key=${fcmServerKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: token,
      notification: {
        title: "Who's it going to be today?",
        body: 'Spin the Giro and reconnect with someone.',
      },
      data: {
        type: 'daily_reminder',
      },
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`FCM ${response.status}: ${body}`);
  }
}

Deno.serve(async (req) => {
  try {
    if (cronSecret) {
      const auth = req.headers.get('Authorization');
      if (auth !== `Bearer ${cronSecret}`) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          status: 401,
          headers: { 'Content-Type': 'application/json' },
        });
      }
    }

    const now = new Date();

    const { data: users, error: userError } = await supabase
      .from('user_settings')
      .select(
        'user_id, daily_reminder_time, daily_call_goal, timezone_offset_minutes',
      )
      .not('daily_reminder_time', 'is', null);

    if (userError) throw userError;
    if (!users || users.length === 0) {
      return new Response(
        JSON.stringify({ message: 'No users with reminders configured.' }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 },
      );
    }

    const dueUsers = (users as UserRow[]).filter((user) => {
      const offset = user.timezone_offset_minutes ?? 0;
      const localTime = localTimeFromUtc(now, offset);
      const reminderTime = normalizeStoredTime(user.daily_reminder_time!);
      return localTime === reminderTime;
    });

    if (dueUsers.length === 0) {
      return new Response(
        JSON.stringify({ message: 'No users due for reminders this minute.' }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 },
      );
    }

    const results: string[] = [];

    for (const user of dueUsers) {
      const { data: tokens, error: tokenError } = await supabase
        .from('fcm_tokens')
        .select('user_id, token, platform')
        .eq('user_id', user.user_id);

      if (tokenError || !tokens || tokens.length === 0) {
        results.push(`user:${user.user_id} no_tokens`);
        continue;
      }

      for (const t of tokens as FcmTokenRow[]) {
        try {
          await sendFcm(t.token);
          results.push(`user:${user.user_id} sent:${t.platform}`);
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          results.push(`user:${user.user_id} fcm_error:${message}`);
        }
      }
    }

    return new Response(
      JSON.stringify({ due: dueUsers.length, processed: results.length, results }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 },
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ error: message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});