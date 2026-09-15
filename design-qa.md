# Mobile responsiveness design QA

Source visual truth:

- `C:/Users/jimmy/.codex/codex-remote-attachments/01a09bfc-9d95-71d3-9dd3-2f727d3a36ff/86CC5D39-600F-4F1B-A267-438C3CA3A9EB/1-Pasted-Image-1.jpg`
- `C:/Users/jimmy/.codex/codex-remote-attachments/01a09bfc-9d95-71d3-9dd3-2f727d3a36ff/86CC5D39-600F-4F1B-A267-438C3CA3A9EB/2-Pasted-Image-2.jpg`

Source dimensions: 590 × 1280 pixels, including iPhone and browser chrome. The page content represents an approximately 390 CSS-pixel portrait viewport at high device density. Test implementation: `http://127.0.0.1:8765/mobile-final.html`, 390 × 844 CSS pixels, device scale factor 1. State: existing-save Back Room and City destinations.

## Findings and comparison history

- **P0 — Retina canvas selected the desktop layout.** In both source screenshots, the Back Room remains two columns and the City district cards remain three columns. Type, controls and imagery are reduced to roughly one third of their intended mobile size. The engine used the high-density canvas backing width for its breakpoint. Fixed by deriving the logical game size from `visualViewport`/`innerWidth` on Web. A 1179 × 2556 backing surface with a 393 × 852 CSS viewport now resolves to 393 × 852 and the portrait layout.
- **P1 — Typography was not consistently guarded.** Metadata could render at 12–15 logical pixels. Fixed with a 16-pixel label floor, 16-pixel utility buttons and additional line spacing. The type-size regression walks every current destination at phone widths.
- **P1 — A long crew selector could widen a location screen at 320 pixels.** Fixed by clipping the closed selector while keeping the full names in its popup. The populated layout suite now passes at 320 × 568.
- **P1 — Full mobile journey coverage was incomplete.** The responsive suite now opens Back Room, City, district, location, Racket, Crew, profile, recruitment, Gym, Fence, Empire, news, morning business, operations, Ledger, story and More at phone widths. Each state must fit horizontally, retain 43-pixel touch targets and keep visible text at 16 pixels or larger.

## Fidelity surfaces

- Fonts and typography: Lora and Arsenal SC remain the intended bundled families. The new minimum size and line spacing address the unreadable screenshot scale while preserving the established hierarchy.
- Spacing and layout: portrait grids stack to one column; persistent status and five-item bottom navigation remain within 320 pixels. Landscape phones retain their real CSS height rather than scaling down from a taller minimum.
- Colors and tokens: unchanged; the charcoal, brass, parchment and oxblood system already matches the approved direction.
- Image quality: existing scene art remains high-resolution and uses covered aspect crops. This pass changes scale and layout only.
- Copy and content: unchanged except documentation; long dynamic names are still shown in full when the crew picker opens.
- Interaction and accessibility: primary controls remain at least 43 pixels high, use visible focus treatment, require no hover and remain vertically scrollable.

## Visual evidence limitation

The in-app browser loaded the final Web build and reported a 390 × 844 CSS viewport with no console errors, but its screenshot command repeatedly timed out while capturing the running WebGL canvas. The browser-rendered implementation screenshot required for a visual side-by-side comparison is therefore unavailable. Automated render-tree checks are passing, but they are not a substitute for a fresh physical iPhone capture.

Implementation screenshot path: unavailable because WebGL capture timed out.

Focused region comparison: blocked for the same reason.

Primary interactions tested: destination routing, scrolling, save reload, location crew assignment and immediate Racket resolution were previously exercised in the Web build; this pass additionally validates all destination render trees at mobile widths.

Console errors checked: none in the final local Web run.

final result: blocked
