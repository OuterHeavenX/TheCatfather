# Long-term progression

Status: proposed pacing over the current day-based game. No live service clock has been implemented.

## Existing progression

- Character levels 1–5; next level costs current level ×40 XP. Levels add 0.5 effective stat and one maximum energy each. Energy is 8 + level, plus one for the Flophouse.
- Gym gives `max(0.05, 0.30/(1 + trained*0.45))` per session. Fee is `12 + round(trained*26)`, energy cost 3; a consumed catnip boost doubles one gain. This slows growth but ultimately has a 0.05 floor, not a hard ceiling.
- Nerve starts at 10, recovers 4 per resolved day; Social Club adds 3 to both capacity and recovery.
- Respect comes from successful venue jobs (2 collection / 3 shakedown), capped at 100. Venue gates are 0, 4, 10 and 16; holdings reach 32; displayed ranks reach 90.
- Racket tiers use prior-tier crime XP. Practice odds reach their bonus cap after ten attempts of a crime.
- Nine campaign chapters across days 1–16, with three possible ninth chapters. All current respect requirements in story data are zero.

These are useful foundations but short ladders. Calling them “weeks” currently means player-resolved game days, not calendar weeks. A new level-1 cat has 9 energy, enough for a 4-energy job, 3-energy Gym session and 2-energy petty crime; the interesting constraint is shared nerve plus prioritization across crew, not strict exclusivity of all three.

## Proposed layers

| Horizon | Player question | Reward |
|---|---|---|
| One visit | Who is available and which resource is scarce? | A crime, useful information, recovery or a training session |
| Several days | Which business or contact should I cultivate? | New action, address, introduction or crew technique |
| An arc | What operation is the crew building toward? | New district access, holding, specialist approach or faction obligation |
| A long campaign | Who controls the city's opportunities? | Organization identity, rule-changing businesses, contextual faction standing |

Progression should widen choices before inflating numbers. Earn neighborhood access through known routes: initial street work, a dock introduction, meaningful organized-crime practice, a business relationship. Never make wealth the sole key to higher crime. Preserve legacy access when introducing new gates.

## Time transition

First document and retain manual days. Then build a separate experimental clock behind a feature flag with persisted timestamps and explicit rollover IDs. Test returning after one hour, one day and one week, backward/forward local clock changes, two open tabs, daylight-saving changes and repeated reloads. A local clock is not authoritative; keep that limitation explicit.

Choose one source of truth for any given resource. If nerve later replenishes with elapsed time, remove its extra manual-day minting in that mode through a deliberate migration and balance pass. Let players plan Desk/Jobs anytime; settle each empire period once. Cap offline catch-up and show what was accrued. Do not simulate unlimited missed payroll/raids that punish absence. Accounts/cloud authority are a separate future project, not a dependency for the City.

## Balance acceptance

Use seeded simulations plus observed playtests. Compare time-to-first-holding, first district, specialist hire and organized crime; cash after payroll/bribes; negative-cash incidence; recovery after arrests; choice diversity; and how often the best action is simply “advance another empty day.” No calendar pacing promise should ship until the clock and economy support it.
