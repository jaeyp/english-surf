#!/bin/bash
# =============================================================================
# build.sh — Conditional TTS Asset Bundling
# =============================================================================
# Reads TTS_ENGINE from .env and modifies pubspec.yaml to include only the
# selected engine's assets before building. Restores pubspec.yaml after build.
#
# Usage:
#   ./scripts/build.sh [flutter build arguments...]
#
# Examples:
#   ./scripts/build.sh ios --release
#   ./scripts/build.sh apk --release
#   ./scripts/build.sh run
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
PUBSPEC="$PROJECT_DIR/pubspec.yaml"
PUBSPEC_BACKUP="$PROJECT_DIR/pubspec.yaml.bak"

# --- Read TTS_ENGINE from .env ---
TTS_ENGINE="supertonic2"
if [[ -f "$ENV_FILE" ]]; then
  value=$(grep -E "^TTS_ENGINE=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '[:space:]' | tr -d "'\"")
  if [[ -n "$value" ]]; then
    TTS_ENGINE="$value"
  fi
fi

echo "==> TTS Engine: $TTS_ENGINE"

# --- Validate engine name ---
VALID_ENGINES=("supertonic2" "qwen3")
if [[ ! " ${VALID_ENGINES[*]} " =~ " ${TTS_ENGINE} " ]]; then
  echo "ERROR: Unknown TTS_ENGINE='$TTS_ENGINE'. Valid options: ${VALID_ENGINES[*]}"
  exit 1
fi

# --- Determine which asset line to REMOVE ---
if [[ "$TTS_ENGINE" == "supertonic2" ]]; then
  EXCLUDE_LINE="assets/tts/qwen3/"
else
  EXCLUDE_LINE="assets/tts/supertonic2/"
fi

# --- Backup pubspec.yaml ---
cp "$PUBSPEC" "$PUBSPEC_BACKUP"

cleanup() {
  echo "==> Restoring pubspec.yaml"
  mv "$PUBSPEC_BACKUP" "$PUBSPEC"
}
trap cleanup EXIT

# --- Remove the excluded asset line ---
echo "==> Excluding assets: $EXCLUDE_LINE"
sed -i '' "/$EXCLUDE_LINE/d" "$PUBSPEC"

# --- Run flutter command ---
FLUTTER_CMD="${1:-run}"
shift 2>/dev/null || true

echo "==> Running: flutter $FLUTTER_CMD $*"
cd "$PROJECT_DIR"
flutter "$FLUTTER_CMD" "$@"

echo "==> Build complete with TTS_ENGINE=$TTS_ENGINE"
