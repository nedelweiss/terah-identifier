#!/usr/bin/env bash

set -e

########################################
# Project paths
########################################

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SYMBOLS_SOURCE="$PROJECT_ROOT/keyboard/symbols/terah"
TYPES_SOURCE="$PROJECT_ROOT/keyboard/types/terah"

########################################
# System paths
########################################

XKB_ROOT="/usr/share/X11/xkb"

SYMBOLS_TARGET="$XKB_ROOT/symbols/terah"
TYPES_TARGET="$XKB_ROOT/types/terah"

RULES_XML="$XKB_ROOT/rules/evdev.xml"
RULES_XML_BACKUP="$XKB_ROOT/rules/evdev.xml.terah.bak"

########################################
# Check sudo
########################################

if [[ $EUID -ne 0 ]]; then
    echo "Please run with sudo."
    exit 1
fi

########################################
# Check source files
########################################

if [ ! -f "$SYMBOLS_SOURCE" ]; then
    echo "Symbols source file not found:"
    echo "  $SYMBOLS_SOURCE"
    exit 1
fi

if [ ! -f "$TYPES_SOURCE" ]; then
    echo "Types source file not found:"
    echo "  $TYPES_SOURCE"
    exit 1
fi

########################################
# Backup
########################################

echo
echo "Creating backups..."

if [ -f "$SYMBOLS_TARGET" ]; then
    cp "$SYMBOLS_TARGET" "$SYMBOLS_TARGET.bak"
fi

if [ -f "$TYPES_TARGET" ]; then
    cp "$TYPES_TARGET" "$TYPES_TARGET.bak"
fi

if [ ! -f "$RULES_XML_BACKUP" ]; then
    cp "$RULES_XML" "$RULES_XML_BACKUP"
fi

########################################
# Install XKB files
########################################

echo
echo "Installing Terah XKB files..."

cp "$SYMBOLS_SOURCE" "$SYMBOLS_TARGET"
cp "$TYPES_SOURCE" "$TYPES_TARGET"

########################################
# Register layout in evdev.xml
########################################

echo
echo "Registering Terah layout..."

python3 - "$RULES_XML" <<'PY'
import sys
import xml.etree.ElementTree as ET

xml_path = sys.argv[1]

tree = ET.parse(xml_path)
root = tree.getroot()

layout_list = root.find("layoutList")

if layout_list is None:
    raise RuntimeError("layoutList not found in evdev.xml")

for layout in layout_list.findall("layout"):
    config_item = layout.find("configItem")

    if config_item is None:
        continue

    name = config_item.find("name")

    if name is not None and name.text == "terah":
        print("Terah is already registered.")
        sys.exit(0)

layout = ET.Element("layout")

config_item = ET.SubElement(layout, "configItem")

ET.SubElement(config_item, "name").text = "terah"
ET.SubElement(config_item, "shortDescription").text = "Terah"
ET.SubElement(config_item, "description").text = "Terah"

ET.SubElement(layout, "variantList")

layout_list.append(layout)

ET.indent(tree, space="  ")

tree.write(
    xml_path,
    encoding="UTF-8",
    xml_declaration=True
)

print("Terah registered successfully.")
PY

########################################
# Done
########################################

echo
echo "Done."
echo
echo "Installed:"
echo "  $SYMBOLS_TARGET"
echo "  $TYPES_TARGET"
echo
echo "Registered in:"
echo "  $RULES_XML"