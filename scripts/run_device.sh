#!/usr/bin/env bash
set -euo pipefail

MODE_ARGS=(--debug)
POSTHOG_KEY=""
POSTHOG_HOST=""
POSTHOG_DEBUG=""
DEVICE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug)
      MODE_ARGS=(--debug --verbose)
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
      DEVICE_ID="$1"
      shift
      ;;
  esac
done

if [[ -z "${DEVICE_ID}" ]]; then
  echo "Usage: $(basename "$0") [--debug|--release] [--posthog-key <key>] [--posthog-host <host>] [--posthog-debug] <device-id>"
  echo "Tip: flutter devices"
  exit 1
fi

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

if [[ -d "ios" ]]; then
  pushd ios >/dev/null
  pod install
  popd >/dev/null
fi

flutter run -d "${DEVICE_ID}" "${MODE_ARGS[@]}" ${DART_DEFINES[@]+"${DART_DEFINES[@]}"}

# RELEASE APK -  flutter build apk --release
