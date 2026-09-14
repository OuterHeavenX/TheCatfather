# The Catfather: production vision

Status: proposed direction for the existing game, audited 2026-09-13 at `4f01e37`. This is a design contract, not a claim that the City exists. Start with [the audit](AUDIT.md) and [roadmap](ROADMAP.md).

Jimmy “Two-Times” builds an empire in a living, feline New York in 1928. A stolen catnip shipment destabilizes the Claw-stra Nostra and the Alley Syndicate. The promise is a short visit with several worthwhile decisions, whose consequences accumulate into a personal criminal history.

The existing Desk → Jobs → Ledger loop is the operating rhythm of the empire. Energy allocates individual cats' work; organization nerve budgets crime; cash pays for growth and obligations; heat and unrest make taking more today costly tomorrow. Keep all of these.

## Product rules

- Develop the current Godot project. Preserve scene routes, content IDs, working art, existing saves and the single-threaded Web build through staged changes.
- Offer competing uses of scarce resources. At least two sensible choices should exist; success should not require clicking every available control.
- Let the City reveal progression: a new address, introduction or opportunity is often more satisfying than another numerical rank.
- Make crew competence identifiable: Frankie escapes, Sammy forces an entry, Nicky acquires information. Preserve `frankie_fastpaws` as Frankie's ID.
- Give businesses rules and relationships, as holdings already give rules and income. A friendly tailor can be worth more than today's shakedown.
- Make consequences understandable before commitment and visible afterward. Preview costs and odds from the same rules used to resolve actions.
- Mobile readability and touch operation are release requirements. Theme serves comprehension.
- Treat absence generously. Avoid streak loss, mandatory midnight attendance, escalating debt while offline, or news that punishes people for having lives.

## Identity and boundaries

Keep the cast, cat humor, missing-shipment mystery, and faction ambiguity. Gradually revise the old living-room/vet/toy flavor to the anthropomorphic city setting without changing IDs. Jimmy's current portrait depicts two cats; preserve it during the audit and decide deliberately how that visual joke fits the single protagonist.

The useful persistent-RPG ideas are recurring opportunities, skill earned through activity, specialization, economic planning and durable relationships. Do not copy another game's crime catalog, stat curve, navigation, monetization or social coercion. No multiplayer, premium nerve refills, PvP theft, global marketplace or backend framework in these passes.

Use period-appropriate crimes. Do not add WWII-style ration coupons to 1928 by accident; counterfeit freight papers, warehouse receipts and liquor permits fit the setting more naturally. These are writing directions, not a completed historical research pass.

## Time is a design decision

MAIN currently advances only when the player resolves a day. Real-world waiting replenishes nothing. First preserve that contract while giving activities places and context. Later prototype a clock separately, with bounded catch-up and no duplicate collection of nightly rewards. Do not attach wall-clock regeneration to manual “end day” refills: that would create two ways to mint the same resources. See [progression](PROGRESSION.md).

## Success criteria for playtests

A newcomer can explain energy versus nerve, find an affordable action, understand the cat selected, and return to the empire desk. A returning player can see what changed, choose among at least two affordable priorities, and leave with a reliable save. A veteran has unfinished specializations and meaningful relationships, not merely larger balances. Track decision diversity, abandoned actions, save errors, recovery from bad days and mobile interaction friction before adding more content.
