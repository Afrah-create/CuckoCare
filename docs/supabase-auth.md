# Supabase Auth (hosted project)

CucoCare does **not** use Supabase’s built-in email confirmation links. Users sign up and continue in the app (farm onboarding next). A future Gmail/OTP flow may replace this.

## Disable email confirmation (required for hosted projects)

Dashboard → **Authentication** → **Providers** → **Email**:

- Turn **Confirm email** **OFF**
- Save

Without this, sign-up may not return a session and sign-in will fail until the user clicks a link.

Local CLI uses `supabase/config.toml` (`auth.email.enable_confirmations = false`).
