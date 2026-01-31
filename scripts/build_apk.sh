#!/usr/bin/env bash
set -euo pipefail

MODE_ARGS=(--release)
POSTHOG_KEY=""
POSTHOG_HOST=""
POSTHOG_DEBUG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug)
      MODE_ARGS=(--debug)
      shift
      ;;
    --release)
      MODE_ARGS=(--release)
      shift
      ;;
    --posthog-key)
      POSTHOG_KEY="${2:-}"
      shift 2
      ;;
    --posthog-host)
      POSTHOG_HOST="${2:-}"
      shift 2
      ;;
    --posthog-debug)
      POSTHOG_DEBUG="true"
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      echo "Usage: $(basename "$0") [--debug|--release] [--posthog-key <key>] [--posthog-host <host>] [--posthog-debug]"
      exit 1
      ;;
  esac
done

DART_DEFINES=()

if [[ -n "${POSTHOG_KEY}" ]]; then
  DART_DEFINES+=("--dart-define=POSTHOG_API_KEY=${POSTHOG_KEY}")
elif [[ -n "${POSTHOG_API_KEY:-}" ]]; then
  DART_DEFINES+=("--dart-define=POSTHOG_API_KEY=${POSTHOG_API_KEY}")
fi

if [[ -n "${POSTHOG_HOST}" ]]; then
  DART_DEFINES+=("--dart-define=POSTHOG_HOST=${POSTHOG_HOST}")
elif [[ -n "${POSTHOG_HOST:-}" ]]; then
  DART_DEFINES+=("--dart-define=POSTHOG_HOST=${POSTHOG_HOST}")
fi

if [[ -n "${POSTHOG_DEBUG}" ]]; then
  DART_DEFINES+=("--dart-define=POSTHOG_ALLOW_DEBUG=true")
elif [[ -n "${POSTHOG_ALLOW_DEBUG:-}" ]]; then
  DART_DEFINES+=("--dart-define=POSTHOG_ALLOW_DEBUG=${POSTHOG_ALLOW_DEBUG}")
fi

flutter clean
flutter pub get

flutter build apk "${MODE_ARGS[@]}" ${DART_DEFINES[@]+"${DART_DEFINES[@]}"}

echo "APK output:"
ls -1 build/app/outputs/flutter-apk || true
