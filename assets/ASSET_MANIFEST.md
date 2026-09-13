# The Catfather — Asset Manifest

Game-ready sprites in `game/assets/`, prepped from the ToffeeCraft MegaPackFree
(source: `~/workspace/catfather/assets_raw/MegaPackFree/`, untouched).
All PNGs are RGBA, original pixel dimensions — **no resampling or scaling**.
Single sprites are trimmed to their alpha bbox + 2px transparent padding.
Animation strips are kept whole (cheaper for `AnimatedSprite2D`); only fully-transparent
top/bottom rows were removed, so the horizontal frame grid is pixel-exact.

## cats/ — crew portraits & ambient cats

| File | Source | Dims | Frames | Game use |
|---|---|---|---|---|
| `cats/sit_01.png` | `CatMegaFree/PochiFree/FreeSprites.png` | 45x49 | 1 | Portrait: "The Don" — tan tabby, tired frown, blue collar w/ gem |
| `cats/sit_02.png` | same | 45x48 | 1 | Portrait: "The Hothead" — tan tabby, narrowed eyes, open mouth, plain collar |
| `cats/sit_03.png` | same | 45x48 | 1 | Portrait: "The Consigliere" — tan tabby, sleepy closed eyes |
| `cats/sit_04.png` | same | 45x49 | 1 | Portrait: "The Enforcer" — tan tabby, frown (collar variant of 01) |
| `cats/sit_happy_01.png` | same | 44x48 | 1 | Portrait + **reward art**: tan tabby, big smile, blush (ear variant A) |
| `cats/sit_happy_02.png` | same | 44x48 | 1 | Portrait + **reward art**: tan tabby, big smile, blush (ear variant B) |
| `cats/sleep_row_01..04.png` | same | 64x39 / 64x38 / 64x37 / 64x38 | 1 each | Napping office cats. NOTE: near-identical pose variants of one tan cat, not 4 coats — `sleep_row_01` recommended, rest optional |
| `cats/mochi_idle.png` | `CatMegaFree/MochiFree/Idle.png` | 320x28 | **10 frames, 32x28 each, horizontal** | Office ambience: white cat sitting, blinking/tail-flick idle |
| `cats/mochi_box.png` | `CatMegaFree/MochiFree/Box3.png` | 128x31 | **4 frames, 32x31 each, horizontal** | Office ambience: white cat peeking out of a cardboard box |
| `cats/jump.png` | `FreeAnimalPack/JumpCattt.png` | 416x32 | **13 frames, 32x32 each, horizontal** | Bonus: gray tabby leap cycle — heist "getaway run" |
| `cats/sleep_wounds_01.png` | `CatMegaFree/SleepingCatFree/sleepingcat1.png` | 384x32 | **6 frames, 64x32 each, horizontal** | Injured/"Licking Wounds" cat — **cream** coat `#e6e1c7` |
| `cats/sleep_wounds_02.png` | `.../sleepingcat2.png` | 384x32 | 6 frames, 64x32 | Injured cat — **chocolate** coat `#ae846c` |
| `cats/sleep_wounds_03.png` | `.../sleepingcat3.png` | 384x32 | 6 frames, 64x32 | Injured cat — **orange tabby** coat `#e98d48` |
| `cats/sleep_wounds_04.png` | `.../sleepingcat4.png` | 384x32 | 6 frames, 64x32 | Injured cat — **charcoal** coat `#5d5d5d` |
| `cats/sleep_wounds_05.png` | `.../sleepingcat5.png` | 384x32 | 6 frames, 64x32 | Injured cat — **silver** coat `#bbbbbb` |

**Coat variants & recolor suggestion.** The 6 sitting portraits share one tan base
(`#c9ac99`); the 5 wound-strips give 5 genuinely distinct coats. For 24 mobsters,
use `modulate` tints on the tan sitters — multiply blends cleanly on this palette:

| Tint (modulate) | Result vibe | Suggested role |
|---|---|---|
| `1.0, 1.0, 1.0` | tan (as drawn) | default crew |
| `1.0, 0.72, 0.5` | ginger/orange | hothead bruisers |
| `0.8, 0.8, 0.9` | silver-gray | cool professionals |
| `0.45, 0.38, 0.42` | dark "black cat" | stealth specialists |
| `1.0, 0.9, 0.75` | cream | old-timers |

Frame 0 of each `sleep_wounds_*` strip also works as a static portrait for the 5
distinct coats above. `sit_happy_01/02` double as heist-success reward art.

## dog/ — the rival

| File | Source | Dims | Frames | Game use |
|---|---|---|---|---|
| `dog/bark.png` | `FreeAnimalPack/GoldenBarking.png` | 704x33 | **11 frames, 64x33 each, horizontal** | THE DOG rival — bark cycle for heist-resolve scenes |
| `dog/sleep.png` | `FreeAnimalPack/SleepDog.png` | 512x33 | **8 frames, 64x33 each, horizontal** | Bonus: spotted dog sleeping w/ "Z"s — rival "laying low" / defeated state |

## office/ — speakeasy hideout backdrop (dark plum/brown bg)

| File | Source | Dims | Game use |
|---|---|---|---|
| `office/bookshelf.png` | `CatMegaFree/CatRoomFree/Furnitures.png` | 104x132 | Wooden bookshelf — the Don's records shelf |
| `office/cat_tree.png` | `CatMegaFree/PochiFree/FreeSprites.png` | 89x179 | Tall cat tree — crew lounge centerpiece |
| `office/plant.png` | `CatMegaFree/CatRoomFree/Furnitures.png` | 49x112 | Potted plant — corner greenery |
| `office/poster.png` | same | 45x67 | Small framed picture — use as "wanted poster" / framed blueprint |
| `office/wall_art.png` | same | 43x93 | Framed plant print — wall dressing |
| `office/window.png` | same | 65x99 | Brown-framed window, blue glass — back-wall window |

**Floor tile:** `FreeEnvironment/FreePack.png` contains **no indoor floor tile** (it's all
outdoor: cacti, pines, rocks, fruit). Recommendation: solid dark-plum fill
(`#241a2e`) or a 16x16 two-tone checker drawn in code under the furniture.

## food/ — treats currency & loot

| File | Source | Dims | Game use |
|---|---|---|---|
| `food/treats_bowl.png` | `CatMegaFree/PochiFree/FreeSprites.png` | 47x41 | **Treats currency "T" icon** — blue bowl of kibble |
| `food/food_bag.png` | same | 37x66 | "CAT" food bag w/ paw print — shop/heist loot art |
| `food/tuna_can.png` | same | 22x22 | Red tuna can — small heist loot / consumable |
| `food/ball_toy.png` | same | 26x24 | Purple ball — office toy clutter |

(Alternate treats icon in source, not extracted: `FreeAnimalPack/AnimalStuffs/DogMeat.png`, 32x32 meat.)

## ui/ — chrome (purple & gold)

| File | Source | Dims | Game use |
|---|---|---|---|
| `ui/panel.png` | `UIBundleFree/FreeUI.png` | 92x126 | Dark-purple panel w/ gold border + blue gem — dialogs, menus |
| `ui/button_gold.png` | same (PLAY btn, bg keyed out) | 58x21 | Gold rounded button w/ "PLAY" text — reskin text per use |
| `ui/bar_hp.png` | `CatMegaFree/CatUIFree/free.png` | 80x32 | Pink HP/XP bar — crew health in hideout/heist UI |
| `ui/skull.png` | `UIBundleFree/FreeUI.png` | 30x29 | Skull — danger / failed-heist icon |
| `ui/hat_witch.png` | same | 23x21 | Gray witch hat — "schemer" trait icon |
| `ui/hat_wizard.png` | same | 23x21 | Purple wizard hat — "mastermind" trait icon |
| `ui/teddy.png` | same | 24x25 | Dark teddy — crew mascot / morale icon |
| `ui/paw.png` | same | 12x13 | Purple paw print — on-brand bullet/marker |
| `ui/nap_cat.png` | `CatMegaFree/CatUIFree/free.png` | 47x36 | Sleeping cream cat illustration — "resting" state art |
| `ui/catface_01..04.png` | same | 25x22 each | 4 mini cat-face icons (pink UI set) — roster pips |
| `ui/tile_play.png` / `tile_pause.png` / `tile_check.png` / `tile_x.png` / `tile_dollar.png` / `tile_question.png` | `UIBundleFree/FreeUI.png` | 18x17–18x18 | 14px glyph tiles on purple rounded squares — transport & confirm UI |
| `ui/glyph_check_white/red.png` | same (low icon grid) | 11x9 | Bare check glyphs — quest/objective states |
| `ui/glyph_x_white/red.png` | same | 12x11 | Bare X glyphs — decline/fail |
| `ui/glyph_dollar_white.png` | same | 11x13 | Bare $ — payouts |
| `ui/glyph_question_white.png` | same | 10x12 | Bare ? — unknown/intel |
| `ui/glyph_plus_red.png` | same | 11x11 | Bare + — recruit/add |
| `ui/glyph_minus_red.png` | same | 10x6 | Bare − — dismiss/remove |
| `ui/glyph_gear_white/red.png` | same | 15x16 | Bare gear — settings |
| `ui/glyph_speaker_white.png` / `glyph_mute_white.png` | same | 14x14 / 20x14 | Audio toggles |
| `ui/glyph_play_white.png` | same | 8x12 | Bare play triangle |
| `ui/glyph_bag_purple/red.png` | same | 11x12 | Loot-bag glyph — heist loot marker |

### 9-patch regions (source coords in `UIBundleFree/FreeUI.png`, 224x256)

- **Dark panel** — source rect `x=4..91, y=3..124` (88x122, gem included).
  Suggested `NinePatchRect` patch margins: left 8, right 8, top 26 (clears the gem),
  bottom 8. Stretch region is the flat purple center. For a gem-less panel, crop
  `y=22..124` and use top margin 8.
- **Gold button** — extracted `ui/button_gold.png` (58x21, transparent corners).
  Suggested patch margins: left 8, right 8, top 7, bottom 8 (keeps the 4px corner
  radius and the darker bottom shadow edge intact). Center the label text.
- **Tiles** (`ui/tile_*.png`, 18px): fixed-size, do not 9-patch — scale by integer
  factors only.

### Source icon coords not extracted (for future use)

In `UIBundleFree/FreeUI.png`: 7x8 grid of 14px tiles at `x=113..222, y=17..142`
(columns `x=113,129,145,161,177,193,209`, rows `y=17,33,49,65,81,97,113,129`;
glyphs = play, pause, +, check, x, minus, ?, $) in purple (rows 1-4), teal
(rows 5-6), brown (rows 7-8). Bare-glyph grid: 7 cols x 6 rows of 16px cells at
`x=109+16c, y=145+16r`. Paw-print column at `x=97..104`, eight 8x14 prints,
`y=17..142`.

## Left in source (not extracted, available)

- `FreeAnimalPack/BirdFly.png`, `FrogIdle.png`, `PigIdle.png` — ambient critters
- `FreeAnimalPack/AnimalStuffs/` — DogBalls, DogToys2, DogVitamins (32x32 / 120x64)
- `FreeEnvironment/FreePack.png` — outdoor tiles (cacti, pines, rocks, fruit) if a heist ever goes outside
- `UIBundleFree/` alternate UI sets: `FreeHorrorUi.png`, `MediavelFree.png`, `PastelUIFree.png`, `UiCozyFree.png`, `freefantasy.png`, `FreeDemo.png`
- `CatMegaFree/CatRoomFree/Furnitures.png` — more beds, scratching posts, bowls, balls, windows, frames

## Processing notes

- Script: `/tmp/build_assets.py` + `/tmp/fix_assets.py`, `/tmp/fix2.py`–`/tmp/fix4.py`
  (kept in /tmp; rerun from source if anything needs re-cropping).
- Never copied: `MegaPackFree.zip`, `__MACOSX/._*`, `.DS_Store` — none exist under `game/assets/`.
- Godot import: leave `filter` off (nearest-neighbor) on all of these; strips are
  sized for `AnimatedSprite2D` with `hframes` = frame count above.
