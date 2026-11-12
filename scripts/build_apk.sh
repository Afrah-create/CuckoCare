#!/usr/bin/env bash
# Release APKs under GitHub's 100MB file limit (split per ABI, no x86_64).
set -euo pipefail
cd "$(dirname "$0")/.."

FLAVOR="${1:-prod}"
ENV_FILE="env/${FLAVOR}.json"

if [[ ! -f "$ENV_FILE" ]]; then
  dart run tool/sync_env.dart "$FLAVOR"
fi

flutter build apk \
  --release \
  --flavor "$FLAVOR" \
  --dart-define-from-file="$ENV_FILE" \
  --split-per-abi

echo
echo "APKs (must each be under 100MB):"
ls -lh build/app/outputs/flutter-apk/*.apk
python3 - <<'PY'
from pathlib import Path
limit = 100 * 1024 * 1024
ok = True
for p in sorted(Path("build/app/outputs/flutter-apk").glob("*.apk")):
    size = p.stat().st_size
    mb = size / (1024 * 1024)
    flag = "OK" if size < limit else "TOO LARGE"
    if size >= limit:
        ok = False
    print(f"  {flag:10} {mb:6.1f} MB  {p.name}")
raise SystemExit(0 if ok else 1)
PY
