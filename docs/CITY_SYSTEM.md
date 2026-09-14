# City architecture

Status: proposed; no City, district or contact system exists in MAIN. Existing venue IDs are the integration boundary. See [audit](AUDIT.md).

## Initial slice

Start with Little Italy and the Docks as a small linked hub. Little Italy contains `blind_pig`, `piazza`, `tailor`, `hardware`, the Gym and the Fence. The Docks contains `fishmonger`; reveal further addresses gradually. Existing saves must retain access to every venue they already unlocked, regardless of new district gates. Midtown, the Tenements and Uptown can appear as future destinations, with an explanation rather than empty menus.

Use a readable district list plus an optional illustrated map. Location cards open a reusable detail screen: art, name, owner/contact, description, control, local conditions, relationship summary and available actions. Unknown information is explicitly unknown. Do not display invented heat, ownership or relationship numbers to fill a template.

## Separate definitions from state

| Record | Static definition | Saved state |
|---|---|---|
| District | ID, name, description, art, location IDs, access requirements | discovery/access, local attention, event references |
| Location | ID, district ID, name, owner contact ID, art slots, tags, action IDs, optional venue/property ID | discovery, relationships/control only as implemented |
| Action | ID, handler, permitted context, preview text | any reservation or operation instance, never a UI node |
| Contact | ID, character reference or portrait, role, home locations | introduced, trust/fear/favor balance, cooldowns |

Begin with `src/data/city_data.gd`, `src/city/city_service.gd` and `src/ui/city_screen.gd` / `location_screen.gd`. Fit existing project conventions; no global directory reshuffle. Keep GameMan as a compatibility facade while services are extracted behind it. Static data must not hold mutable save dictionaries.

## Reuse the actual systems

Location COLLECT/SHAKEDOWN calls the existing assignment flow and queues the existing nightly job. The Jobs screen remains a summary of those commitments. Do not resolve that same job immediately on entering a location. Gym and Fence links initially open the working screens. Holdings reference their existing property IDs and are managed under Empire.

Current `venues[id].controlled` and `.unrest` remain authoritative during the first slice. Do not create an independently mutable `locations[id].controlled` copy. A later migration can replace the boolean with explicit control state, with compatibility reads for older clients/tests.

## Actions as contracts

`preview_action(context)` returns availability, reason, resource costs, relevant crew contributions, success/risk details and resolution timing. `execute_action(context)` revalidates, applies costs once, resolves or reserves work, returns a structured result and records an event. UI only presents these results. Invalid IDs, unavailable cats, duplicate requests and unaffordable actions fail without mutation. Introduce a dedicated RNG per service and a clock dependency as each becomes needed.

The location framework should register a few concrete handlers, not a generic scripting language. First actions: existing job assignment, Talk at the Blind Pig, and one Investigate action tied to a real clue. No paid travel or walking animation is required to make an address feel real.

## Contacts and consequences

Start with a bartender and Nicky. Trust, fear and a small favor balance are enough; do not instantiate five meaningless meters for every NPC. Fear may yield cash while closing a voluntary introduction. Trust can unlock information. A favor has a named cause and payoff. Story NPCs can be contacts without being hired crew; their contact state and crew state have distinct purposes.

After the first location loop works, persist structured event records (`event_id`, day/time, type, actor/target IDs, outcome data). Ledger and News may render the same event without paying its reward twice. Rumors distinguish speculation from facts; headlines describe what actually happened. Daily modifiers are generated once and saved, not rerolled whenever a screen opens.

## Acceptance

An old save visits all previously unlocked venues, assigns a collection from a location, sees it in Jobs, resolves it exactly once in Ledger and reloads with the same control/unrest. A new save discovers a second district through a clear opportunity. Back navigation preserves selected district and scroll position. Phone users can complete every action without hover or horizontal scrolling. The export remains single-threaded and current saves remain readable.
