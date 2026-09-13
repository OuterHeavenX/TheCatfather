#!/usr/bin/env python3
"""Generate the venue emblems for the jobs cards.

Simple ink silhouettes in the spirit of a period trade sign — drawn, not
sourced. Transparent PNGs sized for a 64px slot on parchment.

    python3 tools/make_icons.py assets/ui/gen/venue
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

S = 256                      # drawn large, downsampled for clean edges
INK = (42, 33, 24, 255)
INK_SOFT = (42, 33, 24, 120)


def _canvas():
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def bottle_and_glass():
    """The Blind Pig — a bottle and a tumbler."""
    im, d = _canvas()
    d.rounded_rectangle([64, 96, 120, 216], radius=10, fill=INK)   # body
    d.rectangle([82, 54, 102, 100], fill=INK)                      # neck
    d.rectangle([78, 44, 106, 58], fill=INK)                       # cap
    d.rectangle([70, 130, 114, 160], fill=(255, 255, 255, 0))      # label cut-out
    d.polygon([(140, 120), (196, 120), (186, 216), (150, 216)], fill=INK)
    d.polygon([(146, 132), (190, 132), (184, 150), (152, 150)], fill=(255, 255, 255, 0))
    return im


def fish():
    """The Docks Fishmonger."""
    im, d = _canvas()
    d.ellipse([48, 96, 186, 172], fill=INK)
    d.polygon([(180, 134), (228, 100), (228, 168)], fill=INK)      # tail
    d.polygon([(96, 96), (130, 62), (140, 100)], fill=INK)         # dorsal
    d.polygon([(100, 168), (128, 196), (140, 166)], fill=INK)      # ventral
    d.ellipse([74, 118, 92, 136], fill=(255, 255, 255, 0))         # eye
    return im


def fruit():
    """Piazza Fruit Market — apple and leaf."""
    im, d = _canvas()
    d.ellipse([64, 92, 192, 216], fill=INK)
    d.rectangle([122, 56, 134, 100], fill=INK)                     # stalk
    d.polygon([(134, 70), (196, 48), (160, 96)], fill=INK)         # leaf
    d.ellipse([92, 120, 116, 150], fill=(255, 255, 255, 0))        # shine
    return im


def scissors():
    """Luxury Tailor Shop."""
    im, d = _canvas()
    d.line([(70, 60), (176, 178)], fill=INK, width=16)
    d.line([(186, 60), (80, 178)], fill=INK, width=16)
    d.ellipse([52, 168, 108, 224], outline=INK, width=16)
    d.ellipse([148, 168, 204, 224], outline=INK, width=16)
    d.ellipse([116, 104, 140, 128], fill=INK)                      # pivot
    return im


def hammer():
    """The Corner Hardware Store."""
    im, d = _canvas()
    d.rounded_rectangle([116, 96, 146, 222], radius=6, fill=INK)   # handle
    d.rounded_rectangle([62, 52, 200, 100], radius=8, fill=INK)    # head
    d.polygon([(62, 52), (40, 66), (40, 86), (62, 100)], fill=INK) # claw
    return im


def _diamond(size, fill, outline=None, width=3):
    """Risk pip / ornament. Fonts in this project carry no U+25C6, so these
    are drawn rather than typed — a missing glyph renders as a tofu box."""
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    m = size // 2
    pts = [(m, 2), (size - 3, m), (m, size - 3), (2, m)]
    if fill is not None:
        d.polygon(pts, fill=fill)
    if outline is not None:
        d.line(pts + [pts[0]], fill=outline, width=width)
    return im


def _note(size, colour):
    """Music toggle glyph, drawn for the same reason."""
    im = Image.new("RGBA", (size * 4, size * 4), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    s = size * 4
    d.ellipse([s * 0.10, s * 0.62, s * 0.48, s * 0.92], fill=colour)
    d.rectangle([s * 0.42, s * 0.12, s * 0.52, s * 0.78], fill=colour)
    d.polygon([(s * 0.52, s * 0.12), (s * 0.86, s * 0.26), (s * 0.86, s * 0.44),
               (s * 0.52, s * 0.30)], fill=colour)
    return im.resize((size, size), Image.LANCZOS)


GLYPHS = {
    # ink pips for the jobs cards, on parchment
    "pip_full": lambda: _diamond(64, (42, 33, 24, 255)),
    "pip_empty": lambda: _diamond(64, None, (42, 33, 24, 150), 4),
    # brass ornament for the screen header, on wood
    "rule_diamond": lambda: _diamond(64, (177, 146, 51, 255)),
    "note_on": lambda: _note(64, (212, 175, 55, 255)),
    "note_off": lambda: _note(64, (140, 132, 120, 255)),
}


EMBLEMS = {
    "blind_pig": bottle_and_glass,
    "fishmonger": fish,
    "piazza": fruit,
    "tailor": scissors,
    "hardware": hammer,
}


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "assets/ui/gen/venue")
    out.mkdir(parents=True, exist_ok=True)
    for name, fn in GLYPHS.items():
        fn().resize((32, 32), Image.LANCZOS).save(out.parent / ("%s.png" % name))
        print("%-12s -> %s" % (name, out.parent / ("%s.png" % name)))

    for name, fn in EMBLEMS.items():
        im = fn()
        # a soft drop shadow lifts the ink off the paper slightly
        shadow = im.filter(ImageFilter.GaussianBlur(4))
        plate = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        plate.alpha_composite(Image.new("RGBA", (S, S), (0, 0, 0, 0)))
        plate.alpha_composite(shadow.point(lambda v: int(v * 0.35)), (2, 3))
        plate.alpha_composite(im)
        plate.resize((96, 96), Image.LANCZOS).save(out / ("%s.png" % name))
        print("%-12s -> %s" % (name, out / ("%s.png" % name)))


if __name__ == "__main__":
    main()
