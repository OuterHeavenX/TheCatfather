#!/usr/bin/env python3
"""Fail if the UI types a character none of the bundled fonts can draw.

Godot renders a missing glyph as a "tofu" box containing the codepoint, which
is how ◆ ◇ ♪ ended up on screen as little numbered squares. Any symbol the
fonts lack has to be drawn as a texture instead of typed into a string.

    python3 tools/check_glyphs.py
"""

import re
import sys
import unicodedata
from pathlib import Path

from fontTools.ttLib import TTFont

FONT_DIR = Path("assets/fonts")
SRC_DIRS = [Path("src"), Path(".")]
STRING = re.compile(r'"((?:[^"\\]|\\.)*)"')

# Characters Godot never asks a font to draw.
IGNORE = set("\n\r\t")


def font_coverage() -> set:
    covered = set()
    for ttf in sorted(FONT_DIR.glob("*.ttf")):
        font = TTFont(ttf, fontNumber=0)
        for table in font["cmap"].tables:
            covered |= set(table.cmap.keys())
    return covered


def main() -> int:
    covered = font_coverage()
    if not covered:
        print("no fonts found in %s" % FONT_DIR, file=sys.stderr)
        return 1

    files = list(Path("src").rglob("*.gd")) + [Path("main.gd")]
    missing = {}
    for path in files:
        for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith("#"):
                continue
            for lit in STRING.findall(line):
                for ch in lit:
                    cp = ord(ch)
                    if cp < 0x20 or ch in IGNORE or cp in covered:
                        continue
                    missing.setdefault((cp, ch), []).append("%s:%d" % (path, n))

    if not missing:
        print("glyph check: every typed character is covered by the bundled fonts")
        return 0

    print("glyph check FAILED — these would render as tofu boxes:\n")
    for (cp, ch), where in sorted(missing.items()):
        try:
            name = unicodedata.name(ch)
        except ValueError:
            name = "?"
        print("  U+%04X %s  (%s)" % (cp, ch, name))
        for w in where[:4]:
            print("      %s" % w)
    print("\nDraw these as textures (see tools/make_icons.py) rather than typing them.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
