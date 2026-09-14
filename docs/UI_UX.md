# UI and mobile UX direction

Status: audit and design direction based on desktop, 390×844 phone, 844×390 landscape and 768×1024 tablet browser captures. Screenshots are in `docs/audit/screenshots/`.

## Keep

The black, wood, brass and parchment palette is coherent and readable enough to establish a strong 1928 crime identity. The logo title screen, illustrated dialogue, full-width primary action, status strip, tactile parchment cards and venue art should survive. The choice screen, Racket cards, Gym cost clarity and Ledger consequence summary already communicate the intended genre well. Current desktop and tablet layouts scale cleanly.

## Fix before navigation expansion

Phone content is visually too small in many card interiors even though no horizontal overflow is visible in ordinary flows. The status strip consumes valuable height while its labels are near the minimum readable size. Touch targets are mostly generous, but tiny portraits, mute control, dense three-column Gym cells, Racket crew selection and compact ledger rows need real-device validation. The headless width smoke test does not cover populated maximum-crew states: audit probes found a 441px picker, a 1029px full-assignment Jobs state and an 822px populated Ledger state against the 440px design target.

Avoid 15 peer destinations. The next navigation should have a persistent bottom bar on phone: City, Racket, Crew, Empire, More. The Desk becomes Empire's overview; Gym, Fence, Ledger, Contacts, News and Settings live under context or More until use frequency proves they deserve a tab. On desktop, expose the same destinations as a compact rail/header, not a separate information architecture.

City is the default task-entry screen once it exists. The top status area should become a condensed tappable resource rail: cash, energy/available crew, nerve and heat. Do not make each statistic equally prominent. Open a location detail view from City; actions remain contextual, with a clear Back to City path and persistent selected-district state.

## Visual direction

Use the period treatment as framing rather than a texture blanket. Reserve warm brass for action and achievement, parchment for readable information, oxblood for danger, and the dark background for rest. Use location art in a fixed, appropriate card slot; do not stretch the 96px venue scenes into hero images. The existing 128px headshots work well for cards; full-body character art belongs in story, profiles and major operation setup. The asset inventory identifies current resolution constraints.

For new place art, define target slots before commissioning: card thumbnail, location detail landscape/portrait, event masthead and optional map marker. Include art direction, owner/contact and district tags in the source manifest. Do not replace lower-resolution existing art merely to fill a larger surface.

## Accessibility and interaction checks

Keep text at a practical mobile size after dynamic scaling; do not rely on a visual-only status color; supply text for locked, ready, injured and jailed states; preserve keyboard focus styles instead of using `StyleBoxEmpty` for focus; make icon-only controls accessible; respect safe areas; support scroll drag on panels; test with large browser text/zoom and long localized names. Screenshot evidence cannot certify screen-reader or keyboard support, so add a focus traversal and target-size test alongside manual device checks.

The Web shell forbids page zoom (`user-scalable=no`) and uses `touch-action:none`; reassess both before public launch because they can restrict browser accessibility and expected gestures. Any change needs regression testing for Godot touch input and the existing scroll workaround.
