# Login flow

- Cold start: `/splash` reads local `AuthSnapshot` (Drift).
- No snapshot → `/login` (Supabase email/password; needs network once).
- Snapshot present → `/home` (works offline).
- Dev flavor: **Demo mode** writes a local snapshot without Supabase.

`LoginScreen` clears keyboard focus when the app goes to background.
