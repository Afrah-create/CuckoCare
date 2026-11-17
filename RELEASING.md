# Releasing CucoCare (APK download page)

Short guide for shipping a new Android build and updating the download page.

## Steps

1. **Bump the version** in `pubspec.yaml` (`version: x.y.z+build`).
   Raise the build number (the part after `+`) so Android treats it as an update.

2. **Build and place the APK**:
   ```bash
   ./scripts/publish_apk.sh
   ```
   Optional: `./scripts/publish_apk.sh --universal` for a single fat APK (larger; easier to hit GitHub’s 100 MB limit).

3. **Update the download page config** in `download_site/config.js`:
   - `VERSION` — e.g. `"1.0.1"`
   - `RELEASED` — e.g. `"17 Nov 2026"`

4. **Commit and push** (force-add the APK because `*.apk` is gitignored by default):
   ```bash
   git add -f apk/cucocare.apk download_site/config.js
   git commit -m "Release vX.Y.Z"
   git push
   ```

5. **Vercel** redeploys the download site automatically. The Download button still points at GitHub’s raw file URL, so users get the new APK from the repo after the push propagates.

## Deploy the download page

### Vercel (recommended)

1. Import this repository in Vercel.
2. Set **Root Directory** to `download_site`.
3. Set **Framework Preset** to **Other**.
4. Leave **Build Command** and **Output Directory** empty.
5. Deploy. Point your public download URL at this Vercel project.

### GitHub Pages (alternative)

GitHub Pages can only serve from the repo root or a `/docs` folder. This project keeps the site in `download_site/` so it does not collide with Flutter’s `web/` folder. To use Pages you would need to copy the contents of `download_site/` into `docs/` (and keep them in sync). Prefer Vercel to avoid that duplication. Do not add a Pages workflow unless you explicitly want one.

## Gotchas

- The **repo must be public** for anonymous APK downloads via the GitHub raw URL.
- Always **sign with the same keystore**, or Android will refuse the update over an existing install.
- Each committed APK stays in **git history forever**; the repo grows with every release.
- GitHub rejects files **over 100 MB**. Prefer `./scripts/publish_apk.sh` (split-per-ABI / arm64) over `--universal`.
- After a push, the **raw download URL can take a minute or two** to reflect the new file.
