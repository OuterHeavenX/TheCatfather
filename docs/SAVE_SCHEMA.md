# Save schema and compatibility

Status: schema 2. The format remains Godot `ConfigFile` at `user://pawfellas_save.cfg`. On Web, `user://` normally maps to IndexedDB. The loader probes storage and starts in volatile mode if a browser never answers; the new shell displays a persistent warning in this mode.

Schema 1 added `game.save_version`, `game.last_report`, and `game.journal`. Schema 2 adds `game.tutorial_step` and `game.tutorial_complete`. New games begin the guided tour and save progress after every step. Schema 0/1 empires migrate with the tour completed so returning players are not interrupted; More can replay it. The journal retains the most recent 24 gameplay events and Ledger reports persist across reloads. Versions newer than the supported version are rejected without overwriting the save. A checked-in unversioned fixture verifies finances, crew, gear, assignment and story continuity. `save_error` exposes a failed ConfigFile write to the UI. Writes are still direct ConfigFile writes; atomic backup/restore and comprehensive corrupt-input validation remain future hardening work.

## Current saved fields

| Section | Fields |
|---|---|
| `game` | save_version, day, phase, treats, respect, heat, tension, payout_level, started, tariffs, venues, cats, stash, nerve, properties, prices, crime_xp, last_report, journal, tutorial_step, tutorial_complete |
| `story` | seen, flags, align |

`cats[id]` contains hired, level, xp, loyalty, wounded_days, gear, venue, op, energy, jail_days, boosted and train. IDs are save contracts. In particular preserve `frankie_fastpaws`, `jimmy_twotimes`, venue IDs and crime IDs; presentation names can change without breaking saves.

`last_report` now persists. New reports distinguish payroll/bribes due from amounts actually paid and record actual net cash movement including rival losses. Jukebox settings are separately saved in `user://pawfellas_audio.cfg`.

## What works today

Loading fills defaults for new tariffs, venues, roster entries, Jimmy's hired status, Racket per-cat fields and empty prices. A synthetic pre-Racket save migrated and round-tripped in the audit. The shipped smoke test also covers save/write/load during a 20-day simulation.

## Remaining hardening before major data expansion

Schema 1 implements explicit versioning, legacy default filling, write-error reporting and bounded report/journal persistence. Future migrations should become a pure, ordered chain as the schema grows. Normalize types, validate references, retain unknown data where safe, and use an atomic backup/restore strategy. Corrupt input and interrupted writes need stronger coverage; the current fixture tests do not certify those paths.

Event handling must remain idempotent: reloading or reopening a report must not pay, heal, release, collect, or advance practice twice. Existing crime, assignment and story regression cases now guard the defects found in the initial audit.

## Future state shape

Keep definition data in GDScript and mutable state in one versioned document. Add city state under a dedicated key: discovered districts/locations, contact records, daily modifiers, operation reservations, and event journal. Do not duplicate current venue control/unrest under both `venues` and `locations` during the first City pass. A migration can later map `venues[id]` to locations while compatibility reads preserve legacy saves.

Use explicit timestamps only if real-time pacing is introduced. Store a rollover/event ID and timezone-independent time; test backward clocks, duplicate tabs and interrupted writes. Browser local storage is not authoritative and cannot safely support future trading, PvP or leaderboards by itself.

## Required test matrix

New save; every historical fixture; missing optional fields; unknown future field retention; invalid/corrupt file; save failure; reload from Desk, Jobs, story and Ledger; browser persistent and deliberately volatile modes; interrupted multi-step operation; web export. Keep fixtures as copied ConfigFiles, not code that manufactures its own expectation from the current implementation.
