from pathlib import Path
import fontforge

FONT_NAME = "TerahIdentifier"
SVG_FILE = Path("placeholder.svg")

FIRST_CODE = 0xE000
LETTER_COUNT = 26

if not SVG_FILE.is_file():
    raise FileNotFoundError(
        f"SVG was not found: {SVG_FILE.resolve()}"
    )

font = fontforge.font()
font.fontname = FONT_NAME
font.familyname = FONT_NAME
font.fullname = FONT_NAME
font.encoding = "UnicodeFull"

for i in range(LETTER_COUNT):
    codepoint = FIRST_CODE + i

    glyph = font.createChar(codepoint) # create cell
    glyph.importOutlines(str(SVG_FILE))
    glyph.width = 1000 # advance width

font.save(f"{FONT_NAME}.sfd")
font.generate(f"{FONT_NAME}.ttf")

print("Generated dummy font")
