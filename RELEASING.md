# Releasing CucoCare (APK + download page)

Ship a new Android build, host it in Supabase Storage, and update the download page.

## First-time setup (once)

1. Open the Supabase SQL editor.
2. Run `scripts/supabase_bucket_setup.sql`.
   That creates the public bucket `app-releases`. Public reads are allowed; uploads use the **service-role key** from your laptop, not from the app.

## Each release

1. **Bump `version:` in `pubspec.yaml`** (`x.y.z+build`).
   Raise the number after `+` so Android treats the file as an update.

2. **Build with the correct flags** (prod flavor + dart-defines + phone ABIs only):
   ```bash
   ./scripts/publish_apk.sh
   ```
   Output: `build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk`

3. **Install on a real phone over USB** and confirm **sign-in and sync** work **before** uploading:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk
   ```

4. **Export secrets in this shell only** (never a file in the repo):
   ```bash
   export SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co"
   export SUPABASE_SERVICE_ROLE_KEY="..."
   ```

5. **Upload:**
   ```bash
   ./scripts/upload_apk_supabase.sh
   ```
   It prints the public URL and the `APK_URL` / `VERSION` lines for the next step.

6. **Edit `download_site/config.js`:** set `VERSION`, `RELEASED`, and `APK_URL`.
   Then commit and push **`download_site/` only** (not the APK, not `.env`).

7. Open the download page on a phone, tap Download, and install over the old version.

## Gotchas

- Always **sign with the same keystore**, or Android refuses the update. Today release builds still use the **debug** keystore until you add a real `key.properties`.
- The **service-role key is full access**. It never goes in the repo, the APK, `config.js`, or screenshots.
- Check the **Supabase free-plan per-file limit** in Dashboard → Storage settings.
- Old versions stay in the bucket (`android/CucoCare-<VERSION>.apk`). Delete unused objects from the dashboard if you want.
- The Flutter app needs `SUPABASE_URL` and `SUPABASE_ANON_KEY` at **compile time** (`--dart-define-from-file=env/prod.json`). A release APK built without that file will install and then fail on launch.
