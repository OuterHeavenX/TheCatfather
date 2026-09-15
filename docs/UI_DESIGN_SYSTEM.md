# The Catfather: noir city production pass

Implemented 2026-09-14 on `feat/noir-city-redesign`. The four supplied concept sheets guide the physical-object vocabulary: headquarters, map, crime files, dossiers, deeds and newspaper. Real controls render all text, values, navigation and decisions; scene artwork contains no interface.

## Structure

`Main` establishes a responsive canvas and routes through `NoirShell`. The shell owns persistent status, five primary destinations, scrollable content, safe-area margins and temporary selection state. `NoirKit` builds consistent buttons, paper cards, dark cards, text, images, columns and meters. `NoirActivities` implements crime, family, profiles, recruiting, Gym and Fence. `NoirBusiness` implements deeds, news, daily management and canonical story presentation. These views call existing `GameMan` methods; opening a view never resolves a job or advances time.

The primary navigation is City, Racket, Crew, Empire, More. The brand returns to the Back Room. More provides the newspaper, Gym, Fence/stash, morning business, operations, last settlement, recruitment and resource explanations. Body text is normally 18 logical pixels; commitment controls are at least 48 high, with 64-high primary navigation. Portrait stacks cards; wider screens use two or three columns. All content scrolls vertically. Short fades last 120 milliseconds.

## City and story

`CityData` maps existing venues into Little Italy (0 respect), Tenements (4), Docks (10), Midtown (16), and a visibly future Uptown district. This reuses current venue progression. No second control/unrest state is created: the original `GameMan.venues` remains authoritative. The map illustration is atmospheric, not a geographically exact navigation service. Location actions reserve existing collection/shakedown jobs; they resolve through Closing the Books.

The Back Room and City expose waiting canonical story messages. The player can leave a message for later. Existing dialogue and choices are preserved; the system no longer automatically chains chapters on entering the home screen. Choices reject unaffordable and repeat resolutions.

## Artwork

Five new cinematic environment assets supplement existing portraits and venue thumbnails: Back Room (white Jimmy), New York map, Little Italy speakeasy, docks and Gym. These were generated with the built-in image-generation tool. Prompts specified 1928, cinematic noir, charcoal/walnut/amber/brass, scene-only assets with no text or UI. The street artwork received a targeted correction removing a skyscraper resembling a post-1928 landmark. Existing small venue art stays at 96–128 pixels; it is not stretched into a backdrop. Character IDs and original art files are retained.

## Validation and limits

`tests/redesign.tscn` exercises migration, crime preview consistency, assignment reservations, choice validation, bounded news and settlement persistence, plus populated layouts and touch-control heights across 360×800, 390×844, 844×390, 768×1024 and 1440×900. The original smoke, glyph check and mocked loader failure tests remain part of `tools/run_audit.ps1`.

The browser check covers navigation, location assignment, crime resolution and persistent reload. Responsive browser emulation is not a physical iPhone/Safari certification. A real-device pass remains necessary for notches, keyboard focus, audio and touch behavior. Headless tests intentionally do not start the music player.

Contacts, business relationship dimensions, multi-stage scores, live temporary modifiers, bespoke artwork for every venue, advanced territory/factions and wall-clock offline progression remain future work. The Fence retains its existing buy/sell spread; percentage labels honestly compare today's price to its usual price. All daily recovery remains tied to Closing the Books.

Web exports use a content-hashed pack query URL so a newly loaded page cannot reuse an older game pack. The physical file remains `index.pck`; IndexedDB paths do not change.

## High-density mobile browsers

Godot can report the Web canvas in backing pixels on Retina-class phones. A 393 CSS-pixel iPhone may therefore appear roughly 1179 pixels wide to the engine, which previously selected the desktop grid and reduced every font and control to one third of its intended size. `Main` now reads `visualViewport`/`innerWidth` on Web and uses those CSS-pixel dimensions for content scaling and responsive breakpoints. Native builds continue to use the window size directly.

The mobile regression matrix covers every current player-facing destination at 320, 360 and 390 logical pixels. It rejects horizontal overflow, buttons under 43 pixels, and rendered label/button text under 16 pixels. Landscape phone, tablet and desktop sizes remain covered separately.
