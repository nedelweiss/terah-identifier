#!/usr/bin/env bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

KEYMAP_FILE="$PROJECT_ROOT/build/terah-compiled.xkb"

if [ ! -f "$KEYMAP_FILE" ]; then
    echo "Compiled keymap not found:"
    echo "$KEYMAP_FILE"
    echo
    echo "Run ./scripts/compile.sh first."
    exit 1
fi

if [ -z "$DISPLAY" ]; then
    echo "DISPLAY is not set."
    echo "This loader is intended for X11."
    exit 1
fi

xkbcomp "$KEYMAP_FILE" "$DISPLAY"

echo "Terah keymap loaded into $DISPLAY"