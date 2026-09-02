#!/usr/bin/env bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

XKB_ROOT="/usr/share/X11/xkb"
SYMBOLS_TARGET="$XKB_ROOT/symbols/terah"
TYPES_TARGET="$XKB_ROOT/types/terah"

SYMBOLS_BACKUP="$SYMBOLS_TARGET.bak"
TYPES_BACKUP="$TYPES_TARGET.bak"
RULES_XML="$XKB_ROOT/rules/evdev.xml"

if [[ $EUID -ne 0 ]]; then
    echo "Please run with sudo."
    exit 1
fi


echo
echo "Removing Terah XKB files..."

if [ -f "$SYMBOLS_TARGET" ]; then
    rm "$SYMBOLS_TARGET"
    echo "Removed:"
    echo "  $SYMBOLS_TARGET"
else
    echo "Symbols file not installed:"
    echo "  $SYMBOLS_TARGET"
fi

if [ -f "$TYPES_TARGET" ]; then
    rm "$TYPES_TARGET"
    echo "Removed:"
    echo "  $TYPES_TARGET"
else
    echo "Types file not installed:"
    echo "  $TYPES_TARGET"
fi


# Remove backups created for Terah files
if [ -f "$SYMBOLS_BACKUP" ]; then
    rm "$SYMBOLS_BACKUP"
fi

if [ -f "$TYPES_BACKUP" ]; then
    rm "$TYPES_BACKUP"
fi


echo
echo "Removing Terah layout registration..."

python3 - "$RULES_XML" <<'PY'
import sys
import xml.etree.ElementTree as ET

xml_path = sys.argv[1]

tree = ET.parse(xml_path)
root = tree.getroot()

layout_list = root.find("layoutList")

if layout_list is None:
    raise RuntimeError("layoutList not found in evdev.xml")

removed = False

for layout in list(layout_list.findall("layout")):
    config_item = layout.find("configItem")

    if config_item is None:
        continue

    name = config_item.find("name")

    if name is not None and name.text == "terah":
        layout_list.remove(layout)
        removed = True

if removed:
    ET.indent(tree, space="  ")

    tree.write(
        xml_path,
        encoding="UTF-8",
        xml_declaration=True
    )

    print("Terah registration removed.")
else:
    print("Terah registration was not present.")
PY

echo
echo "Done."
echo
echo "Terah has been uninstalled."