#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dart run tool/sync_env.dart dev
flutter run --flavor dev --dart-define-from-file=env/dev.json "$@"
