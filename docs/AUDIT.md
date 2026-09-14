# Inheritance audit — 2026-09-13

Audited commit: `4f01e37` on `main`; audit work lives on `dev/production-audit`. Engine: Windows 11 Pro x64, Godot `4.7.2.stable.official.ed1daf0bf`, official matching templates installed. Git and winget are available; the account was not elevated. `godot` / `godot4` shims were configured in the local Godot installation directory for command-line use.

This is an implementation audit, not a design pitch. Screenshots and asset inventory live under `docs/audit/`.

## What exists and works

The game is a code-built Godot UI with one main scene, two autoloads, four data modules and ten screens: title, story, desk, jobs, ledger, crew, recruitment, Gym, Racket and Fence. The working core is Desk → Jobs → Ledger, with five venue records, tariffs, payroll, tension retaliation, unrest/control, damage, loyalty/defection and a nine-chapter branching story.

The long-game layer is implemented: 25-cat roster; per-cat energy; organization nerve; Gym diminishing gains and increasing cost; 12 Racket crimes across four tiers; practice unlocks; heat; jail/bail; equipment; daily price multipliers; five holdings; story alignment; local ConfigFile save/load; responsive base resolutions; touch-scroll workaround; audio setting; and a Safari/IndexedDB-safe Web loader.

Verified: import/editor headless start, startup, existing smoke, 20-day simulation, glyph coverage, a fresh Web export, patched loader idempotence, mocked healthy/blocked/hung IndexedDB behavior, mocked engine failures, browser boot, browser save/reload, and desktop/phone/tablet flows. The browser run reached story, choices, Gym, Racket success, jobs, ledger and saved reload.

## Partial or unfinished systems

The City does not exist: venue cards are menu entries, with no districts, location detail, owner, contact, relationship, discovery or map state. Contacts, News, factions beyond global tension/alignment, territory beyond venue booleans, businesses beyond holdings, ongoing events, multi-stage scores, information, specialist mechanics and real-time persistence are absent. Heat has simple numerical effects; it lacks raids, access changes and pressure loops. Jail is a timer/bail state only.

Crew roles are labels. Only Lucky, Jimmy, Johnny, Lefty, Rosie and Vikki have wired traits, and the latter two generic IDs are not among the requested named specialists. Frankie, Sammy, Mobby, Nicky, Sonny and Vinnie currently win primarily by base stats. Story flags largely record flavor without later gates. Every story respect requirement is zero.

## Strong foundations

The resource lattice is the strongest part: activity costs are visible, nerve stays separate from money, holdings alter rules rather than only income, failure can create lasting downtime, and crime tier access follows actual attempts. The existing data-ID patterns and default-fill migration are a credible start for live evolution. Web work is unusually thoughtful: thread support is disabled for GitHub Pages, storage hang is bounded, failure state is visible, and audio has a browser gesture fallback.

The visual language and location cards already point in the right direction. The story art is effective, particularly in desktop dialogue. The code is small enough to understand, with shared UI construction and data modules rather than scene duplication.

## Technical debt and defects

`GameMan` is 1,043 lines and owns save, crew, training, crime, economy, daily resolution and story. Static data methods rebuild arrays/dictionaries on every lookup. There is no explicit save version, no failure handling from `ConfigFile.save`, no migration fixtures, and no persisted Ledger report. Save names still say `pawfellas`.

The audit probe reproduced: displayed crime odds differ from the actual roll because practice increments first; unaffordable story choices create negative cash and may be resolved repeatedly through direct calls; an already assigned cat can be assigned again, spending energy again and clear refunds only one job cost; zero cash reports negative Ledger net despite no cash leaving; Fence buy-low/sell-high cannot profit for normal goods; a crate sells for 407 T versus 70 T from USE; the Flophouse refills everyone on purchase; and browser save is intentionally volatile when IndexedDB fails but the game gives no player-facing warning.

The smoke suite only checks blank/default screen width. Fully populated probe states exceed the 440px portrait target: picker 441px, Jobs 1029px, Ledger 822px. Headless shutdown reports two leaked objects: AudioStreamWAV and AudioStreamPlaybackWAV. The code attempts to release the stream, but the issue remains reproducible and should be traced before release. Root Web shell encoding was platform-default until this pass; the patcher now explicitly reads/writes UTF-8 and a test guards that contract.

## UI review

Keep the palette, branded title, illustrated story, full-width commitment controls, status strip concept, cards and card-sized venue art. Redesign navigation around City and shrink the resource chrome. On phone, content density and small type undermine the otherwise good theme. Standard tested flows fit but maximum crew rows do not. See [UI_UX.md](UI_UX.md).

## Persistent-browser RPG fit

Fit: short recurring decisions, scarce resources, earned expertise, market observation, recovery, long-term holdings and district/contact discovery. Avoid copying another game's catalog, social pressure, stamina sales, mandatory streaks, player theft, broad PvP, speculative economy and generic crime UI. The Catfather's differentiators are its city, two syndicates, character writing and business relationships.

## Architecture and recommendation

Use the proposed City architecture in [CITY_SYSTEM.md](CITY_SYSTEM.md), gradual progression in [PROGRESSION.md](PROGRESSION.md), economy repair in [ECONOMY.md](ECONOMY.md), faction model in [FACTIONS.md](FACTIONS.md), and staged work in [ROADMAP.md](ROADMAP.md). The first substantive implementation pass should be health/trust repairs, followed by responsive navigation, then City. This differs from the original ordering only by moving save/economy/preview correctness ahead of a large UI redesign: it lowers migration and player-trust risk while preserving the playable build.
