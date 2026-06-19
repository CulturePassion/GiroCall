/**
 * Validates Supabase personal access tokens for Management API scripts.
 * These are NOT the same as SUPABASE_ANON_KEY (JWT) or service role keys.
 */

const PLACEHOLDER_TOKENS = new Set([
  'sbp_your_personal_access_token',
  'sbp_...',
  'sbp_your_token',
]);

/** @returns {string} */
export function getAccessToken() {
  return (process.env.SUPABASE_ACCESS_TOKEN ?? '').trim();
}

/**
 * @param {string} token
 * @returns {{ ok: true } | { ok: false, reason: string, message: string }}
 */
export function validateAccessToken(token) {
  if (!token) {
    return {
      ok: false,
      reason: 'missing',
      message:
        'Missing SUPABASE_ACCESS_TOKEN.\n' +
        'Create one at https://supabase.com/dashboard/account/tokens\n' +
        'Add to .env: SUPABASE_ACCESS_TOKEN=sbp_...\n' +
        'Or set DATABASE_URL, or run: supabase login',
    };
  }

  const lower = token.toLowerCase();
  if (PLACEHOLDER_TOKENS.has(lower) || lower.includes('your_personal')) {
    return {
      ok: false,
      reason: 'placeholder',
      message:
        'SUPABASE_ACCESS_TOKEN is still the .env.example placeholder.\n' +
        'Create a real token at https://supabase.com/dashboard/account/tokens\n' +
        'Then set SUPABASE_ACCESS_TOKEN=sbp_... in .env (not SUPABASE_ANON_KEY).',
    };
  }

  if (token.startsWith('eyJ')) {
    return {
      ok: false,
      reason: 'jwt',
      message:
        'SUPABASE_ACCESS_TOKEN looks like SUPABASE_ANON_KEY (a JWT).\n' +
        'Use a personal access token (sbp_...) from:\n' +
        'https://supabase.com/dashboard/account/tokens',
    };
  }

  if (!token.startsWith('sbp_') || token.length < 40) {
    return {
      ok: false,
      reason: 'format',
      message:
        'SUPABASE_ACCESS_TOKEN must be a Supabase personal access token (sbp_..., usually 40+ chars).\n' +
        'Create one at https://supabase.com/dashboard/account/tokens',
    };
  }

  return { ok: true };
}

/**
 * @param {number} status
 * @param {string} body
 */
export function formatManagementApiError(status, body) {
  if (status === 401) {
    return (
      'Supabase API rejected the token (401 JWT could not be decoded).\n' +
      'Your SUPABASE_ACCESS_TOKEN is invalid or expired.\n' +
      'Fix: https://supabase.com/dashboard/account/tokens → Generate new token\n' +
      '     Add SUPABASE_ACCESS_TOKEN=sbp_... to .env\n' +
      'Alternatives: DATABASE_URL in .env, or `supabase login` then `make setup-db`'
    );
  }
  return `${status}: ${body}`;
}