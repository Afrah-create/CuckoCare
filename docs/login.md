# Login & farm profile

- **Sign in / sign up** → `/home` (dashboard). Farm setup is never forced at login.
- **Incomplete farm profile**: banner on Home + **Settings → Farm profile** (`/home/farm-profile`). Required: name, district, village, phone; optional: alt phone, notes. Saves via RPC `save_farm_profile` (migration `0005_farm_profile_fields.sql`).
- **Demo session**: skips the banner.
