#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

FLAVOR="prod"
ENV_FILE="env/${FLAVOR}.json"

VERSION_LINE=$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')
VERSION="${VERSION_LINE%%+*}"
echo "pubspec.yaml version: ${VERSION_LINE}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing ${ENV_FILE}." >&2
  echo "Fill .env then run: dart run tool/sync_env.dart ${FLAVOR}" >&2
  exit 1
fi

# --target-platform must match android/app ndk abiFilters (no x86_64).
# Otherwise Gradle fails: conflicting abiFilters vs splits.
flutter build apk \
  --release \
  --flavor "$FLAVOR" \
  --dart-define-from-file="$ENV_FILE" \
  --split-per-abi \
  --target-platform android-arm,android-arm64

ARM64="build/app/outputs/flutter-apk/app-arm64-v8a-${FLAVOR}-release.apk"
ARM32="build/app/outputs/flutter-apk/app-armeabi-v7a-${FLAVOR}-release.apk"

if [[ ! -f "$ARM64" ]]; then
  echo "Expected APK not found: $ARM64" >&2
  ls -lh build/app/outputs/flutter-apk/*.apk >&2 || true
  exit 1
fi

SIZE_BYTES=$(wc -c < "$ARM64" | tr -d ' ')
SHA256=$(sha256sum "$ARM64" | awk '{print $1}')
echo
echo "Built:"
echo "  $ARM64"
echo "  size:    ${SIZE_BYTES} bytes"
echo "  sha256:  ${SHA256}"
if [[ -f "$ARM32" ]]; then
  echo "  also:    $ARM32 (older 32-bit phones; do not upload unless needed)"
fi

echo
echo "Next steps:"
echo "  1. Install on a phone and confirm sign-in and sync work:"
echo "       adb install -r \"$ARM64\""
echo "  2. Export secrets in this shell only (never in the repo):"
echo "       export SUPABASE_URL=..."
echo "       export SUPABASE_SERVICE_ROLE_KEY=..."
echo "  3. ./scripts/upload_apk_supabase.sh"
echo "  4. Set VERSION, RELEASED, and APK_URL in download_site/config.js"
echo "  5. Commit and push download_site/ only (not the APK)."
echo
echo "This script does not commit or push."
echo "Bump the build number in pubspec.yaml (the part after +) so Android treats the install as an update."
