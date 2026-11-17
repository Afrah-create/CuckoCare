#!/usr/bin/env bash
# Upload a built release APK to the public Supabase Storage bucket.
#
# Usage:
#   ./scripts/upload_apk_supabase.sh
#   ./scripts/upload_apk_supabase.sh --apk path/to.apk --version 1.0.1
#
# Reads SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY from the environment, or
# from the gitignored repo-root .env (same names). Never prints secrets.
# Does not run git. Do not use set -x.
set -euo pipefail

cd "$(dirname "$0")/.."

# Load KEY=VALUE pairs for selected keys. Strips surrounding quotes/whitespace.
load_dotenv_keys() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local line key val
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" == *=* ]] || continue
    key="${line%%=*}"
    val="${line#*=}"
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    case "$key" in
      SUPABASE_URL|SUPABASE_SERVICE_ROLE_KEY) ;;
      *) continue ;;
    esac
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    if [[ ${#val} -ge 2 && ( "$val" == \"*\" || "$val" == \'*\' ) ]]; then
      val="${val:1:${#val}-2}"
    fi
    printf -v "$key" '%s' "$val"
    export "$key"
  done < "$file"
}

load_dotenv_keys ".env"

APK="build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk"
VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apk)
      APK="${2:-}"
      shift 2
      ;;
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--apk <path>] [--version X]" >&2
      exit 1
      ;;
  esac
done

missing=()
if [[ -z "${SUPABASE_URL:-}" ]]; then
  missing+=("SUPABASE_URL")
fi
if [[ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  missing+=("SUPABASE_SERVICE_ROLE_KEY")
fi
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Missing ${missing[*]}." >&2
  echo "Add them to the gitignored .env, or export them in this shell." >&2
  exit 1
fi

# Trim again in case the caller exported quoted values.
SUPABASE_URL="${SUPABASE_URL#"${SUPABASE_URL%%[![:space:]]*}"}"
SUPABASE_URL="${SUPABASE_URL%"${SUPABASE_URL##*[![:space:]]}"}"
SUPABASE_URL="${SUPABASE_URL%/}"
if [[ ${#SUPABASE_URL} -ge 2 && ( "$SUPABASE_URL" == \"*\" || "$SUPABASE_URL" == \'*\' ) ]]; then
  SUPABASE_URL="${SUPABASE_URL:1:${#SUPABASE_URL}-2}"
fi
KEY="${SUPABASE_SERVICE_ROLE_KEY#"${SUPABASE_SERVICE_ROLE_KEY%%[![:space:]]*}"}"
KEY="${KEY%"${KEY##*[![:space:]]}"}"
if [[ ${#KEY} -ge 2 && ( "$KEY" == \"*\" || "$KEY" == \'*\' ) ]]; then
  KEY="${KEY:1:${#KEY}-2}"
fi
SUPABASE_SERVICE_ROLE_KEY="$KEY"
export SUPABASE_URL SUPABASE_SERVICE_ROLE_KEY

# Cheap JWT shape check (three segments). Do not print the token.
IFS='.' read -r _jwt_h _jwt_p _jwt_s _jwt_extra <<<"$SUPABASE_SERVICE_ROLE_KEY" || true
if [[ -z "${_jwt_h:-}" || -z "${_jwt_p:-}" || -z "${_jwt_s:-}" || -n "${_jwt_extra:-}" ]]; then
  echo "SUPABASE_SERVICE_ROLE_KEY is not a JWT (Invalid Compact JWS). Check .env quoting." >&2
  exit 1
fi
unset _jwt_h _jwt_p _jwt_s _jwt_extra KEY

if [[ -z "$VERSION" ]]; then
  VERSION_LINE=$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')
  VERSION="${VERSION_LINE%%+*}"
fi

if [[ ! -f "$APK" ]]; then
  echo "APK not found: $APK" >&2
  echo "Build first with ./scripts/publish_apk.sh" >&2
  exit 1
fi

SIZE_BYTES=$(wc -c < "$APK" | tr -d ' ')
if [[ "$SIZE_BYTES" -le $((5 * 1024 * 1024)) ]]; then
  echo "APK is too small (${SIZE_BYTES} bytes). Expected a real release build > 5 MB: $APK" >&2
  exit 1
fi

SHA256=$(sha256sum "$APK" | awk '{print $1}')
echo "Local APK: $APK"
echo "Size: ${SIZE_BYTES} bytes"
echo "SHA-256: ${SHA256}"

OBJECT="android/CucoCare-${VERSION}.apk"
UPLOAD_URL="${SUPABASE_URL}/storage/v1/object/app-releases/${OBJECT}"
PUBLIC_URL="${SUPABASE_URL}/storage/v1/object/public/app-releases/${OBJECT}"

echo "Uploading to app-releases/${OBJECT} ..."
http_code=$(
  curl --fail-with-body -o /tmp/cucocare-apk-upload-body.txt -w "%{http_code}" \
    --progress-bar \
    -X POST \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Content-Type: application/vnd.android.package-archive" \
    -H "x-upsert: true" \
    -H "cache-control: max-age=3600" \
    --data-binary @"$APK" \
    "$UPLOAD_URL"
) || {
  echo "Upload failed (HTTP ${http_code:-unknown}). Body saved to /tmp/cucocare-apk-upload-body.txt" >&2
  exit 1
}

echo "Upload HTTP ${http_code}"

headers=$(curl -sIL "$PUBLIC_URL")
echo "$headers"

status=$(printf '%s\n' "$headers" | awk 'BEGIN{IGNORECASE=1} /^HTTP\//{code=$2} END{print code}')
length=$(printf '%s\n' "$headers" | awk 'BEGIN{IGNORECASE=1} /^content-length:/{print $2}' | tr -d '\r' | tail -1)
ctype=$(printf '%s\n' "$headers" | awk 'BEGIN{IGNORECASE=1} /^content-type:/{sub("\r",""); $1=""; sub(/^ /,""); print}' | tail -1)

if [[ "$status" != "200" ]]; then
  echo "Public HEAD failed: expected HTTP 200, got ${status:-empty}" >&2
  exit 1
fi
if [[ "$length" != "$SIZE_BYTES" ]]; then
  echo "Public content-length mismatch: expected ${SIZE_BYTES}, got ${length:-empty}" >&2
  exit 1
fi
echo "Public content-type: ${ctype:-unknown}"

echo
echo "Public URL:"
echo "  ${PUBLIC_URL}"
echo
echo "Set these in download_site/config.js:"
echo "  APK_URL: \"${PUBLIC_URL}\""
echo "  VERSION: \"${VERSION}\""
