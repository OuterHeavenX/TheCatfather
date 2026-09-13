#!/usr/bin/env python3
"""Generate the Pawfellas UI textures.

Everything here is procedural — no stock art — so the set can be retuned and
regenerated. Outputs are small 9-patch tiles; Godot stretches their middles
and leaves the ornamented borders intact.

    python3 tools/make_textures.py assets/ui/gen
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

rng = np.random.default_rng(1928)


def _noise(w, h, scale, octaves=4):
    """Cheap fractal value noise via upscaled random grids."""
    out = np.zeros((h, w))
    amp = 1.0
    total = 0.0
    for o in range(octaves):
        gw = max(2, int(w / (scale / (2 ** o))))
        gh = max(2, int(h / (scale / (2 ** o))))
        g = rng.random((gh, gw))
        layer = np.asarray(Image.fromarray((g * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)) / 255.0
        out += layer * amp
        total += amp
        amp *= 0.5
    return out / total


def parchment(w=256, h=256, base=(226, 213, 184)):
    """Aged ledger paper: warm base, fibre noise, blotches, darkened edges."""
    n = _noise(w, h, 64) * 0.55 + _noise(w, h, 12) * 0.45
    shade = 0.86 + 0.14 * n
    # foxing: a few darker stains
    stain = np.zeros((h, w))
    for _ in range(7):
        cx, cy = rng.integers(0, w), rng.integers(0, h)
        r = rng.integers(w // 12, w // 5)
        yy, xx = np.mgrid[0:h, 0:w]
        d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / r
        stain += np.clip(1.0 - d, 0, 1) ** 2 * rng.uniform(0.05, 0.13)
    shade -= stain
    # edges age faster than the middle
    yy, xx = np.mgrid[0:h, 0:w]
    edge = np.minimum(np.minimum(xx, w - 1 - xx), np.minimum(yy, h - 1 - yy)) / (min(w, h) * 0.30)
    shade *= 0.80 + 0.20 * np.clip(edge, 0, 1)
    img = np.dstack([np.clip(np.array(base)[i] * shade, 0, 255) for i in range(3)]).astype(np.uint8)
    return Image.fromarray(img, "RGB")


def wood(w=256, h=256, base=(58, 40, 26)):
    """Dark stained wood: rings along the grain plus fine scratches."""
    yy, xx = np.mgrid[0:h, 0:w]
    warp = _noise(w, h, 90) * 26.0
    rings = np.sin((yy + warp) * 0.55) * 0.5 + 0.5
    grain = 0.72 + 0.28 * (rings * 0.55 + _noise(w, h, 7) * 0.45)
    grain -= (rng.random((h, w)) > 0.9975) * 0.25          # scratches
    img = np.dstack([np.clip(np.array(base)[i] * grain * 1.15, 0, 255) for i in range(3)]).astype(np.uint8)
    return Image.fromarray(img, "RGB")


def framed(inner: Image.Image, pad=14, brass=(196, 160, 72), dark=(28, 22, 14)) -> Image.Image:
    """Wrap a texture in a brass double rule with corner ticks (9-patch safe)."""
    w, h = inner.size
    im = inner.copy()
    d = ImageDraw.Draw(im)
    d.rectangle([1, 1, w - 2, h - 2], outline=dark, width=2)
    d.rectangle([3, 3, w - 4, h - 4], outline=brass, width=2)
    d.rectangle([7, 7, w - 8, h - 8], outline=tuple(int(c * 0.55) for c in brass), width=1)
    for (cx, cy, sx, sy) in ((7, 7, 1, 1), (w - 8, 7, -1, 1), (7, h - 8, 1, -1), (w - 8, h - 8, -1, -1)):
        d.line([cx, cy + 5 * sy, cx + 5 * sx, cy], fill=brass, width=2)
    return im


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "assets/ui/gen")
    out.mkdir(parents=True, exist_ok=True)

    p = parchment()
    p.save(out / "parchment.png")
    framed(p).save(out / "parchment_framed.png")

    w = wood()
    w.save(out / "wood.png")
    framed(w).save(out / "wood_framed.png")

    # darker card stock for secondary panels
    framed(parchment(base=(196, 182, 152))).save(out / "parchment_dim_framed.png")

    # brass plate for the status chips
    plate = wood(128, 64, base=(30, 26, 22))
    framed(plate, brass=(212, 175, 55)).save(out / "chip.png")

    for f in sorted(out.glob("*.png")):
        print("%-26s %s  %d bytes" % (f.name, Image.open(f).size, f.stat().st_size))


if __name__ == "__main__":
    main()
