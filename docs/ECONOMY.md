# Economy and holdings

Status: current baseline plus repair priorities; values are internal treats (T), despite some cash/dollar language in the brief. Changing display currency need not change saved `treats`.

## Flows that exist

Income: immediate Racket payouts, nightly venue takings, protection from controlled venues, five holding incomes, Fence sales and some story rewards. Sinks: recruitment, Gym fees, equipment/consumables, holdings, bail, nightly payroll/bribes and story payments. Energy and nerve are separate constraints; neither is a buyable consumable.

Tariff settings apply an averaged multiplier to every venue's cash: OFF 0%, LOW 18%, FAIR 34%, STEEP 55%. Per-good settings currently do not model separate cargo markets. Total tariff tension then loses 3 each night. Unrest grows on controlled venues and cuts protection yield. Collections reduce unrest only when successful; shakedowns raise it and heat, yield more cash and provide loot. Even botched jobs pay 35% of a collection or 25% of a shakedown, then crew traits apply.

Payroll starts at `5 + level*3` per cat, plus 6 for muscle / 3 for specialists, then SKIMMED/FAIR/GENEROUS multiplies the sum by 0.5/1/1.6. Loyalty changes by -9/+2/+6 when paid; unaffordable payroll loses 18. At zero, non-player cats leave and their equipped gear disappears. Police bribes are `round(heat*1.4)`; paying reduces heat 6, failing adds 8. Tension ≥65 triggers one rival response and drops 22.

| Holding ID | Cost | Nightly income | Actual rule |
|---|---:|---:|---|
| flophouse | 620 | 16 | +1 maximum energy; purchase also fully refills hired cats immediately |
| garage | 940 | 24 | +12% Racket payout |
| bathhouse | 1240 | 18 | Existing wounds decrease 2 days at rollover instead of 1 |
| social_club | 1750 | 34 | +3 nerve capacity and nightly regeneration |
| back_room_bank | 2900 | 62 | Additional 4 heat reduction nightly |

## Confirmed weaknesses

1. Fence multipliers are independently rerolled each night in [0.78, 1.28]. Sale value is about 55% of list. Even the best sale is about 0.704 of list, below the cheapest buy at 0.78. The promised buy-low/sell-high trade cannot profit on any normal listed item; the probe prints exact rounded prices.
2. Crate liquidation uses a fallback `power*10+40`, then the 55% sale factor. At base price a crate sells for 407 T, versus 70 T from USE. At the market extremes it sells for about 317–521 T. This overwhelms its advertised purpose and changes the value of Piazza shakedowns.
3. Ledger `net` subtracts payroll/bribes owed even when they were not paid and excludes a possible rival cash theft. A zero-cash, idle day reports -38 net with an actual zero cash change. Immediate Racket/Gym/Fence transactions are not in this report either. Decide whether it is a settlement statement or full daily cashflow and label it accordingly.
4. Price “up/down” is relative to base price, not yesterday, despite its comment. No history, stock limit, demand or event causality exists.
5. Unbounded manual day advancement refreshes nerve, energy, prices and income. Once sustainable passive income covers upkeep, skip-day farming erodes pacing. This is a current game rule, not a browser exploit.

## Repair and expansion rules

First make previews, statements and transactions truthful. Model due/paid/unpaid separately. Validate affordability for story costs, preserve balances and clearly define debt if ever added. Test crate USE/SELL values and all market extremes. Do not rebalance by casually reducing existing saved balances.

Then decide a bounded spread/volatility model that can occasionally reward stockpiling without yielding unlimited same-day arbitrage. Persist daily market state and explain events. Useful goods should be desirable for actual operations as well as resale. Distinguish a predictable base quote from rare temporary opportunities.

Keep passive holdings as permanent changes to decisions, with income secondary. Later businesses can add crew posts, storage or introductions; no giant production-chain system is required. Any upkeep added later needs migration and absence protection. Compare expected profit after heat, jail, injuries, payroll and opportunity cost, not gross crime payout alone.
