# wallet-pass — GiroCall Edge Function

Generates Apple Wallet (`.pkpass`) or Google Wallet pass data for a user's public digital business card.

**Project:** `gtvpsukmmjhszpopulfe`

## Deploy

```bash
make deploy-edge
# or:
supabase functions deploy wallet-pass
```

## Called from Flutter

Not via `functions.invoke` — opened as an HTTP GET URL:

```
https://gtvpsukmmjhszpopulfe.supabase.co/functions/v1/wallet-pass?slug=USER_SLUG&platform=apple
```

See `lib/features/profile/services/wallet_service.dart` and `lib/core/utils/card_url.dart`.