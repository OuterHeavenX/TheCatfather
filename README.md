# The Catfather

A mobster-cat crew empire. Recruit mobsters, run heists, become **Don of the House**.

Godot 4.7 2D pixel-art game, built for the browser. Live at
https://outerheavenx.github.io/TheCatfather/

## Play

New York, 1928. You are Jimmy "Two-Times." Don Corle-meow-ne's catnip shipment
vanished off the Kelso dock, the truce with Carmela's Alley Syndicate is held
together by manners alone, and somebody wants a war.

Each day runs in three phases:

1. **Morning at the desk** — set tariffs on catnip, salmon and furniture, and
   decide what cut the crew takes tonight. Steep tariffs pay more and push the
   city closer to war.
2. **The blocks** — send cats to five venues as **collections** (charm and
   sneak, steady money, calms the street) or **shakedowns** (muscle, bigger
   take, loot, and unrest). Odds are shown before you commit.
3. **The ledger** — takings, protection money, payroll and police bribes are
   totalled. Unpaid crews lose loyalty and eventually walk. When war tension
   runs hot, the Alley Syndicate hits back and blocks change hands.

Nine story chapters unfold across the first sixteen days, with choices that
decide where you land: with the Don, with Carmela, or on top of both.

## Dev

- Godot 4.7.2, GL Compatibility renderer, 640x360 canvas_items stretch
- `src/autoload/game_man.gd` — empire state, the day cycle, save/load
- `src/data/game_data.gd` — 25-cat roster, traits, rank ladder
- `src/data/world_data.gd` — venues, tariffs, loot
- `src/data/story_data.gd` — story beats and branching choices
- `src/ui/` — code-built screens: title, story, desk, ops, ledger, crew,
  recruit
- Web export: repo root (`index.html`, `index.js`, `index.wasm`, `index.pck`),
  served by GitHub Pages

Headless checks, which need no display:

```sh
godot --headless --path . --import          # generate .import files
godot --headless --path . --quit-after 90   # boot the main scene
```

## Web export: keep Thread Support OFF

In the Godot Web export preset, **Thread Support must stay unchecked**
(`variant/thread_support=false` in `export_presets.cfg`).

A threaded build needs `SharedArrayBuffer`, which browsers only hand out to a
cross-origin-isolated page — that requires the server to send
`Cross-Origin-Opener-Policy: same-origin` and
`Cross-Origin-Embedder-Policy: require-corp`. GitHub Pages serves static files
with fixed headers and cannot send those, so a threaded build dies on load with:

```
Error
The following features required to run Godot projects on the Web are missing:
Cross-Origin Isolation - Check that the web server configuration sends the correct headers.
SharedArrayBuffer - Check that the web server configuration sends the correct headers.
```

If you re-export and see that, the checkbox got turned back on: uncheck it,
re-export, and commit the regenerated `index.*` files. To confirm a build is
clean, the browser console should log
`Build configuration: ... single-threaded, no GDExtension support`.

After deploying, hard-refresh — Safari in particular will keep serving the
cached page for a while.

### index.html is patched after every export

Godot regenerates `index.html` on every web export, which drops the boot
fixes below. Re-apply them with the checked-in tool — it is idempotent, so
running it twice is harmless:

```sh
godot --headless --path . --export-release "Web" index.html
python3 tools/patch_web_shell.py index.html
```

What the tool restores:

- **Storage probe.** Godot mounts `user://` on IndexedDB via
  `FS.syncfs(true, cb)` with no timeout, and the promise its `init()` returns
  has no reject path. Safari can leave `indexedDB.open()` pending forever —
  when it does, that promise never settles *and never rejects*, so the splash
  sits at 100% with no error. The shell probes IndexedDB first and, if it
  doesn't answer within 5s, boots with `persistentPaths: []`: saves stop
  persisting between sessions, but the game runs.
- **Stall detection.** A watchdog (120s during download, 45s during engine
  start) replaces the endless splash with a message naming the stage it got
  stuck at, bytes downloaded, and storage state.
- **Stage text** under the progress bar, so "slow" is distinguishable from
  "wedged".

Cat art: ToffeeCraft free pack — see NOTICE.
