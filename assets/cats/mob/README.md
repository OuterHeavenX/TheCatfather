# Mobster cat art

Full-body character art for the roster cats, cut from the supplied sheets.

Provenance differs by file, and it matters for quality:

- **11 cats** (everything except the two below) come from the lossless RGBA
  sheet at 1697x927 — real alpha, roughly 1.7x the resolution of the first
  pass. Source alpha topped out at 253, so it is renormalised to a true 255
  before cutting.
- **`lucky_clawciano` and `frankie_fastpaws`** still come from the original
  JPEG pair, which is the only sheet they appear on. Alpha there was solved
  from two composites (checkerboard and flat grey #404040): pixels identical
  in both plates are opaque, pixels that differ are background, and the size
  of the difference gives partial alpha on edges. They are lower resolution
  and carry mild JPEG noise in flat colour. Replace them if those two ever
  turn up on a lossless sheet.

Filenames match `id` in `src/data/game_data.gd`.

`head/` holds 128x128 headshot crops of the same drawings — square, centred
on the face, transparent-padded rather than clamped so no head is squashed.
These are what the roster points at (`"portrait": "mob/head/<id>"`), since
`UiKit.portrait()` draws at 64x64 where a full-body cat is unreadable. The
full-body versions in this folder are unused for now; they suit a larger
detail view.

Notes:
- `lefty_ruggiero.png` / `lefty_ruggiero_alt.png` — the sheet draws Lefty
  twice. The bottom-row pose is the primary.
- `frankie_fastpaws.png` — the sheet labels this siamese Frankie "The
  Lefty", which matches no roster entry. Filed under `frankie_fastpaws`
  since the running pose fits.
- Source sheets are JPEG, so flat colour areas carry mild compression
  noise. Re-matting from lossless originals would be cleaner.
- Twelve roster cats have no art here: carmela, bella_blade, ma_barker,
  bonnie_parker, griselda_widow, vikki_velvet, connie_don, rosie_red,
  penny_pickpocket, lucia_scarfo, trixie_twotoes, sophia_squeeze.
