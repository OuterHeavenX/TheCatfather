# Production roadmap

The noir city pass implements the navigation, Back Room, City/location framework, crime files, Family profiles, Gym, Fence, Empire deeds and Daily Whisker, while preserving the daily loop. It also fixes crime-preview, assignment, story-choice and Ledger trust defects and introduces save schema 1. See [implementation and validation](UI_DESIGN_SYSTEM.md).

Next production pass: deepen two existing locations with contacts and saved relationships, add one consequential daily city modifier, and complete physical-device Safari/touch validation. More bespoke venue art and character-art consistency should accompany this work. Multi-stage scores and territory follow once those foundations are proven.

The table below retains the broader production sequence; individual presentation and health outcomes are already delivered, while deeper mechanics remain planned.

| Pass | Outcome | Exit gate |
|---|---|---|
| 1. Health and trust | Versioned saves, honest save failure state, explicit ledger semantics, preview/resolution parity, expanded populated-layout tests, clean shutdown investigation | Old/new fixtures migrate; headless/startup/smoke/web tests pass; no save mutation is silent |
| 2. Navigation foundation | Responsive shell and destination ownership; Desk reframed as Empire overview | Phone navigation completes key loops with no horizontal overflow or hover |
| 3. City foundation | Little Italy/Docks district hub, location definitions and detail framework; existing venues accessible through it | Existing venue jobs resolve once through current Ledger; old saves retain access |
| 4. Place relationships | Two concrete contacts, Talk/Investigate actions and location relationship state | Contact action changes a real unlock or consequence and survives reload |
| 5. Racket quality | Correct odds, varied rewards, role hooks and first prepared operation design | Crime previews match results; jailed/wounded/gear/preparation paths are tested |
| 6. Crew identity | Named specialist techniques and intelligible crew selection | Each important named cat has at least one valuable, testable use case |
| 7. Living city | Saved daily modifiers, rumor/event journal and New York Feline prototype | News describes actual saved events without duplicate rewards |
| 8. Territory and empire | Explicit control states, businesses that bend rules, faction pressures | No duplicated control state; migration preserves existing venues/holdings |
| 9. Embedded campaign | Existing chapters converted into location invitations, evidence and faction consequences | All legacy endings and choices remain reachable after migration |

Do not start a real-time clock, multiplayer, cloud accounts, player trading, PvP, leaderboards or global territory competition during these passes. Reassess persistence authority after Pass 7, when the game has a stable event model and evidence from actual player behavior.

Every pass works on a development branch (`dev/*` or `feat/*`), has a focused commit, retains an up-to-date Web export only when shipped Web assets changed, and records Godot version, smoke result, save fixtures and web-loader result. Do not regenerate root `index.*` just because code changed; regenerate it only for a release-ready Web pass and run `tools/patch_web_shell.py` immediately afterward.
