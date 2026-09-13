# Mobster cat art

Full-body character art for 13 of the 24 roster cats, matted out of the two
source sheets (same drawings composited over a checkerboard and over flat
grey #404040). Alpha was solved from the pair rather than colour-keyed:
pixels identical in both plates are opaque, pixels that differ are
background, and the size of the difference gives partial alpha on edges.

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
