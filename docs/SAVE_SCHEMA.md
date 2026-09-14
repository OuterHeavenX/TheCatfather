# Save schema and compatibility

Status: audit baseline. The current format is Godot `ConfigFile` at `user://pawfellas_save.cfg`. On Web, `user://` normally maps to IndexedDB. The loader probes storage and deliberately starts in volatile mode if a browser never answers; the game must then explain that persistence is unavailable without blocking play.

## Current saved fields

| Section | Fields |
|---|---|
| `game` | day, phase, treats, respect, heat, tension, payout_level, started, tariffs, venues, cats, stash, nerve, properties, prices, crime_xp |
| `story` | seen, flags, align |

`cats[id]` contains hired, level, xp, loyalty, wounded_days, gear, venue, op, energy, jail_days, boosted and train. IDs are save contracts. In particular preserve `frankie_fastpaws`, `jimmy_twotimes`, venue IDs and crime IDs; presentation names can change without breaking saves.

`last_report` is currently runtime-only. Reloading after end of day loses the Ledger detail, even though the settlement has already occurred. Jukebox settings are separately saved in `user://pawfellas_audio.cfg`.

## What works today

Loading fills defaults for new tariffs, venues, roster entries, Jimmy's hired status, Racket per-cat fields and empty prices. A synthetic pre-Racket save migrated and round-tripped in the audit. The shipped smoke test also covers save/write/load during a 20-day simulation.

## Required repair before major data expansion

Add `game.save_version` and a pure, ordered migration chain. `load_game()` should read a version, normalize types, migrate in order, validate references, retain unknown data where safe, save the upgraded result only after successful validation, then report a structured error on failure. Never use a field's absence as the only record of a version once migrations multiply.

Save mutations must report failure. `ConfigFile.save()` return values are currently ignored. UI needs a non-blocking, accessible notice when Web persistence is disabled or a write fails. Keep running in volatile mode, but do not imply that progress will survive a reload.

Persist a bounded `last_report` or event journal before changing Ledger navigation. Event IDs must be idempotent: reloading or reopening an event must not pay, heal, release, collect, or advance practice twice.

## Future state shape

Keep definition data in GDScript and mutable state in one versioned document. Add city state under a dedicated key: discovered districts/locations, contact records, daily modifiers, operation reservations, and event journal. Do not duplicate current venue control/unrest under both `venues` and `locations` during the first City pass. A migration can later map `venues[id]` to locations while compatibility reads preserve legacy saves.

Use explicit timestamps only if real-time pacing is introduced. Store a rollover/event ID and timezone-independent time; test backward clocks, duplicate tabs and interrupted writes. Browser local storage is not authoritative and cannot safely support future trading, PvP or leaderboards by itself.

## Required test matrix

New save; every historical fixture; missing optional fields; unknown future field retention; invalid/corrupt file; save failure; reload from Desk, Jobs, story and Ledger; browser persistent and deliberately volatile modes; interrupted multi-step operation; web export. Keep fixtures as copied ConfigFiles, not code that manufactures its own expectation from the current implementation.
