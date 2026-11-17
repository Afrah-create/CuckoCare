#!/usr/bin/env bash
# Usage:
#   ./scripts/publish_apk.sh              # split-per-ABI; copies arm64-v8a release APK
#   ./scripts/publish_apk.sh --universal  # universal APK (app-release.apk)
#
# Builds a release APK and copies it to apk/cucocare.apk. Does NOT commit or push.
set -euo pipefail

cd "$(dirname "$0")/.."

UNIVERSAL=0
if [[ "${1:-}" == "--universal" ]]; then
  UNIVERSAL=1
elif [[ -n "${1:-}" ]]; then
  echo "Unknown option: $1" >&2
  echo "Usage: $0 [--universal]" >&2
  exit 1
fi

VERSION_LINE=$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')
echo "pubspec.yaml version: ${VERSION_LINE}"

if [[ "$UNIVERSAL" -eq 1 ]]; then
  flutter build apk --release
  SRC="build/app/outputs/flutter-apk/app-release.apk"
else
  flutter build apk --release --split-per-abi
  SRC="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
fi

mkdir -p apk
cp -f "$SRC" apk/cucocare.apk

SIZE_BYTES=$(wc -c < apk/cucocare.apk | tr -d ' ')
SIZE_MB=$(python3 -c "print(f'{${SIZE_BYTES}/(1024*1024):.1f}')")
echo "Copied $SRC -> apk/cucocare.apk (${SIZE_MB} MB)"

if (( SIZE_BYTES > 90 * 1024 * 1024 )); then
  echo "WARNING: APK is over 90 MB. GitHub rejects files over 100 MB." >&2
  echo "Prefer the default split-per-abi build (omit --universal)." >&2
fi

echo
echo "Next steps:"
echo "  1. Edit VERSION and RELEASED in download_site/config.js"
echo "  2. git add -f apk/cucocare.apk download_site/config.js && git commit -m \"Release v${VERSION_LINE%%+*}\" && git push"
echo
echo "This script does not commit or push."
