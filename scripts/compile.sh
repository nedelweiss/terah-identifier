#!/usr/bin/env bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

KEYBOARD_DIR="$PROJECT_ROOT/keyboard"
KEYMAP_FILE="$KEYBOARD_DIR/keymap/terah.xkb"
BUILD_DIR="$PROJECT_ROOT/build"
OUTPUT_FILE="$BUILD_DIR/terah-compiled.xkb"

mkdir -p "$BUILD_DIR"

xkbcli compile-keymap \
  --from-xkb \
  --include "$KEYBOARD_DIR" \
  --include-defaults \
  < "$KEYMAP_FILE" \
  > "$OUTPUT_FILE"

echo "Compiled:"
echo "$OUTPUT_FILE"
