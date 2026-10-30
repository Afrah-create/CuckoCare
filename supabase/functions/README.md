# Edge Functions

Secrets are read from `Deno.env` at runtime. **Never commit values.**

| Variable | Used by | Purpose |
|----------|---------|---------|
| `MAKYPAY_API_KEY` | `makypay-checkout` | Provider API auth |
| `MAKYPAY_WEBHOOK_SECRET` | `makypay-webhook` | Webhook signature verification |
| `MAKYREACH_API_KEY` | `makyreach-send` | SMS provider auth |
| `SMTP_HOST` | `email-otp` | Mail server (Gmail: `smtp.gmail.com`) |
| `SMTP_PORT` | `email-otp` | `587` (STARTTLS) or `465` (SSL) |
| `SMTP_USER` | `email-otp` | SMTP username |
| `SMTP_PASSWORD` | `email-otp` | App password, not the Gmail login password |
| `SMTP_FROM` | `email-otp` | From address |
| `SMTP_FROM_NAME` | `email-otp` | From display name |
| `OTP_PEPPER` | `email-otp` | Optional extra secret for hashing codes |

`email-otp` is called from the signed-out app with the anon key. It sends a 6-digit code and verifies it.
