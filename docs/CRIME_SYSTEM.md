# The Racket

Status: current rules plus proposed extension; audit baseline `4f01e37`.

## Current implementation

Twelve solo crimes, three in each of four tiers. Petty: milk bottle, newsboy, streetcar. Organised: motorcar, numbers game, prize fight. Serious: liquor truck, safe, alderman. Big Score: Merchants Bank, Pier Nineteen, mayor's letters. Keep their IDs even when presentation expands.

Each attempt spends organization nerve and one cat's energy immediately. Attempts bank one run regardless of outcome. `tier_xp` is runs multiplied by each crime's XP value; the immediately preceding tier unlocks the next at 14, 46 and 120 XP. This is organization practice, not individual cat mastery. Character XP is a separate pool, twice the listed amount on success and the listed amount on failure.

Odds are `clamp(0.42 + 0.075*(effective_stat - difficulty) + min(0.22, runs*0.022) - heat/400, 0.05, 0.95)`. Lucky adds 1.5 power. Each level still adds 0.5 effective stat despite the Gym documentation. Garage adds 12% payout, not success chance. Jimmy adds 25% payout. Failed crimes can jail a cat for 2–3 days; bail is 70 T per remaining day. The unlucky trait adds 10 percentage points to conditional jail risk.

No Racket crime currently drops items/intelligence or causes wounds. Those outcomes exist in venue jobs. Big Scores are currently expensive solo rolls, not planned multi-stage operations. A successful alderman crime both pays money and lowers heat; audit its dominance before expanding it.

## Fix before expansion

Compute the roll using the previewed practice value: currently the run is incremented first, giving a first milk-bottle attempt 59.2% after displaying 57% for Jimmy. Validate actor/action IDs, energy amounts and assignments at service boundaries. Decide explicitly whether assigned cats may use their remaining energy before their nightly job resolves. Preserve reserved job energy and make cancellation/refunds unambiguous.

Record actual outcomes, including attempts, success, payout, heat, injury/arrest and crew contribution. Keep legacy `crime_xp` values during migration; do not silently reprice old XP by changing the table or discard failed-attempt progress.

## Expansion design

Add variety within existing tiers before multiplying their count. Crime selection should depend on profit, heat, useful loot, information and crew fit. Repetition provides practice, while equipment and specialist roles open alternative approaches. Display exact resource costs, the selected cat, the tested stat, expected outcomes and reason for any lock.

Use soft role advantages for routine crimes. Frankie lowers escape/arrest risk; Sammy handles force entry; Nicky discovers a lead; Johnny protects information; Lucky shifts uncertain outcomes. Bigger jobs may require role coverage, but must offer alternative recruits or preparation routes so a wounded named character cannot permanently strand progression.

A first true Big Score should reuse one existing identity and add three explicit stages: gather a lead, prepare equipment/crew, commit. Persist preparations and reservations. Cancel with stated refunds; reload without duplicating either cost or reward. Do not add a parallel heist economy or an action minigame framework.

## Verification gates

Preview equals resolution input; rejected attempts spend nothing; save/reload retains practice; tier boundaries test immediately below and at each threshold; wounded/jailed/unknown cats cannot act; bail never creates energy or nerve; preparation resolves once; deterministic seeded simulations compare viable approaches after payroll, heat and downtime costs.
