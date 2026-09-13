# The Catfather

A mobster-cat crew empire. Recruit mobsters, run heists, become **Don of the House**.

Godot 4.7 2D pixel-art game, built for the browser. Live at
https://outerheavenx.github.io/TheCatfather/

## Play

You are the Don. Start with 100 treats, Al Catpone, Bugsy Meow-sie, and
Penny "The Pickpocket". Recruit from 24 named mobster cats, send crews on
6 heists (Pantry Raid … The Big Kibble Score), earn treats and respect,
and take over the house turf by turf: Living Room Rug → Couch → Kitchen →
Pantry → Bedroom → The Whole House.

## Dev

- Godot 4.7.2, GL Compatibility renderer, 640x360 canvas_items stretch
- `src/autoload/game_man.gd` — state, save (User://), heist engine
- `src/data/game_data.gd` — 24-cat roster + 6 heists
- `src/ui/` — code-built screens: title, office, crew, recruit, heists
- Web export: repo root (`index.html`, `index.js`, `index.wasm`, `index.pck`),
  served by GitHub Pages

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

### index.html is hand-patched

`index.html` carries boot fixes that a plain re-export will overwrite, so
re-apply them (or diff against the previous `index.html`) after exporting:

- **Storage probe.** Godot mounts `user://` on IndexedDB via
  `FS.syncfs(true, cb)` with no timeout, and Safari can leave
  `indexedDB.open()` pending forever. When that happens the engine's init
  promise never settles *and never rejects* — the splash sits there at 100%
  with no error. The shell now probes IndexedDB first and, if it doesn't
  answer within 5s, boots with `persistentPaths: []`: saves stop persisting
  between sessions, but the game runs.
- **Stall detection.** A watchdog (120s during download, 45s during engine
  start) replaces the endless splash with a message naming the stage it got
  stuck at, bytes downloaded, and storage state.
- **Stage text** under the progress bar, so "slow" is distinguishable from
  "wedged".

Cat art: ToffeeCraft free pack — see NOTICE.
