# Mobster cat art

Full-body character art for 13 of the 24 roster cats, matted out of the two
source sheets (same drawings composited over a checkerboard and over flat
grey #404040). Alpha was solved from the pair rather than colour-keyed:
pixels identical in both plates are opaque, pixels that differ are
background, and the size of the difference gives partial alpha on edges.

Filenames match `id` in `src/data/game_data.gd`. Not yet wired into
`UiKit.portrait()` — that renders 64x64 and these are full-body, so they
need either a headshot crop or a larger portrait slot first.

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
