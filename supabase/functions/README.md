# Edge Functions (MakyPay / MakyReach)

Secrets are read from `Deno.env` at runtime. **Never commit values.**

| Variable | Used by | Purpose |
|----------|---------|---------|
| `MAKYPAY_API_KEY` | `makypay-checkout` | Provider API auth |
| `MAKYPAY_WEBHOOK_SECRET` | `makypay-webhook` | Webhook signature verification |
| `MAKYREACH_API_KEY` | `makyreach-send` | SMS provider auth |

Client apps call these functions with the user's Supabase JWT only.
