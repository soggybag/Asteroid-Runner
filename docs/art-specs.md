# Art specs

Sizes, formats and resolution for game art. Sizes come from the code as it
is now (most objects are still drawn as colored squares and shapes); file
and line are given so you can check or change them.

## The basics

- **Units are points.** The scene is the size of the screen in points
  (`scaleMode = .resizeFill`), so a 32 pt ship is the same size on the
  screen on every iPhone. Portrait only.
- **Screens:** about 375–440 pt wide and 667–956 pt tall. For example
  iPhone 17: 402 × 874 pt; Pro Max: 440 × 956 pt; SE: 375 × 667 pt.
- **Resolution:** current iPhones are @3x (3 pixels per point), a few older
  ones @2x. Make each image at **@3x** (points × 3) and export an **@2x**
  (points × 2) as well. Skip @1x.
- **Format:** PNG, 32-bit RGBA with transparency, sRGB. Trim nothing off
  the canvas: keep the object centered, because SpriteKit positions and
  rotates a sprite around its center.
- **Where it goes:** a `.atlas` folder in `Asteroid Runner/`, added to
  the Xcode project (it's already done for `ship.atlas` and the four
  `asteroid-*.atlas` folders). Name each file with its scale:
  `Ship-1@3x.png`, `Ship-1@2x.png`. The code asks for `Ship-1` and gets
  the right one for the phone. Xcode packs each atlas into one texture,
  which is faster to draw. A new atlas folder must be dragged into the
  project once, or the game won't find it.
- **Clean edges:** everything outside the drawing must be fully
  transparent. Faint scan or selection edges show as a box around the
  sprite in the game, and tints make them stronger.
  `swift scripts/clean-sprite-edges.swift path/to/*.png` clears them after
  an export: it keeps the drawing (and anything inside it) and erases the
  rest. Paint that runs past an outline is part of the drawing to it, so
  fix that in the source.
- **Facing:** things that fly up the screen (ship, shots) face **up**.
  Enemy shots are rotated to their direction of travel with angle 0 to the
  **right**, so draw them facing right.
- **Tinting:** SpriteKit can tint a sprite (`colorBlendFactor`). Light gray
  or white art can be tinted in code, so one rock image can serve several
  asteroid types. Art made in its final colors needs no tint.

## Sizes

On-screen size in points, and pixel size of the files to make.

| Object | On screen (pt) | @2x (px) | @3x (px) | Notes |
|---|---|---|---|---|
| Ship | 32 × 32 | 64 × 64 | 96 × 96 | Hit circle radius 15. `Ship-1` in `ship.atlas`; Ship-2 … 10 are other designs, not used yet (`Ship.swift`). Faces up |
| Ship shield ring | 44 across | 88 × 88 | 132 × 132 | Drawn around the ship (`ShipShield.swift:22`) |
| Shield charge ring | 48 across | 96 × 96 | 144 × 144 | Faint ring showing powered shield (`Ship.swift:29`) |
| Lives icon (HUD) | 22 × 22 | 44 × 44 | 66 × 66 | Uses the ship drawing now (`Hud.swift`) |
| Asteroid, tiny | 10 | 20 | 30 | Diameter. All rocks spin, so draw them roughly round |
| Asteroid, small | 20 | 40 | 60 | Comets are always small |
| Asteroid, average | 30 | 60 | 90 | Smallest turret |
| Asteroid, large | 40 | 80 | 120 | Smallest brass rock |
| Asteroid, huge | 50 | 100 | 150 | |
| Asteroid, massive | 60 | 120 | 180 | Enemy bases are always massive |
| Bosstroid | 120 | 240 | 360 | |
| Turret / base gun | 8 × 8 | 16 × 16 | 24 × 24 | Sits on the rock; bases have three (`Asteroid.swift:240`) |
| Missile, power 0–4 | 2×5, 3×7, 3×9, 4×12, 5×15 | ×2 | ×3 | One size per weapons level (`Missile.swift:27`). Levels 3–4 add a glow 3.5× as wide. Faces up |
| Enemy shot | 5 × 5 | 10 × 10 | 15 × 15 | Faces right (`EnemyShot.swift:16`) |
| Pickups (points, bomb, shield, multi-shot, rapid fire) | 20 × 20 | 40 × 40 | 60 × 60 | They tumble as they fall, so any way up works (`PowerUp.swift:25`) |
| Coin | 20 across | 40 × 40 | 60 × 60 | Spins by squashing sideways; draw it face-on |
| Glass shard | 4 × 7 | 8 × 14 | 12 × 21 | Debris when a glassteroid shatters (`GameScene.swift:1044`) |
| Station | 140 across, about 160 × 170 with the dock | 320 × 340 | 480 × 510 | Ring radius 70, turns once every 30 s; docking port 26 × 14 under it (`StationNode.swift`). Name label goes above, in code |
| Item tray slot | 44 × 28 | 88 × 56 | 132 × 84 | The slot frame. An icon inside should be about 22 × 22 pt (`ItemTray.swift:15`) |

Asteroid sizes are in `AsteroidSize.swift` (the numbers there are radii).
Each rock picks one of its size's drawings at random from
`asteroid-tiny.atlas`, `-small`, `-average` and `-large`; add more files to
an atlas and they're used. Huge, massive and bosstroid use the large
drawings scaled up until they have atlases of their own (that needs a line
in `Asteroid.textures`). Plain rocks show the drawing as it is; every other
type is tinted its color (`AsteroidType.color()`), so draw rocks in light
gray and keep the outline dark.
The hit circle for a rock is its full radius, so keep the visible rock
filling the circle; a little rough edge past it is fine.

## HUD, panels and buttons

Sizes as the code draws them now, in points, with @3x pixels. Widths
depend on the phone, so the table gives iPhone 17 (402 pt wide) and SE
(375 pt). Corner radius is what the code uses, for reference.

| Piece | Size (pt) | @3x (px) | Notes |
|---|---|---|---|
| Score strip (top) | full width × 40, plus the top safe area: 102 tall on iPhone 17, 60 on SE | 1320 × 306 covers the biggest | Lives at left, score at right, in the bottom 40 pt. The top part sits behind the Dynamic Island: keep it plain (`Hud.swift`) |
| Item tray slot | 44 × 28, three in a row 4 apart | 132 × 84 | Under the strip at left. Icon inside about 22 × 22; a charge bar 38 × 3 along the bottom (`ItemTray.swift`). Radius 6 |
| Menu button | 140 × 40 | 420 × 120 | Title and game over screens (`Button.swift`). Radius 20 |
| Tab button | 34 tall, 80–180 wide | 102 tall | Shop tabs, map route tabs, Back, Set course, Launch. Radius 17 |
| Shop button | 112 × 36; the power screen's + and − are 64 × 36 | 336 × 108 | Tinted by what it does: buy, sell, fit, repair. Radius 8 |
| Scanner panel | width − 32 × 156: 370 × 156 on iPhone 17 | 1110 × 468 | The briefing before each stage (`ScannerPanel.swift`). Radius 10 |
| Power panel | width − 16 × 316: 386 × 316 | 1158 × 948 | Swipe-up power controls (`PowerPanel.swift`). Radius 12 |
| Station and map panels | width − 16 × most of the screen: 386 × 712 on iPhone 17, 359 × 539 on SE | 1158 × 2136 | Same frame for both (`StationPanel.swift`, `MapPanel.swift`). The station's greeting band is full width × 78 at the top. Radius 14 |

**Draw frames to stretch.** Most of these change size with the phone or
the text in them, so a frame should be drawn as a "9-slice": four corners
that stay as drawn, edges that stretch along their length, and a middle
that fills. SpriteKit does this from one image (`centerRect`). Keep the
corners within about 16 pt (48 px) of the edge, keep detail in the
corners, and keep the edges plain enough to stretch. Draw each frame near
its usual size so it doesn't stretch much: a wobbly pen line stretched 3×
looks wrong.

**Text stays in code** for anything that changes: names, prices, scores,
dialog. Fixed words can be drawn: see the title and headings below.

## Font

The game uses **Patrick Hand** (2026-10-15), neat printed handwriting
that sits well next to pen drawings and stays readable small, with clear
numbers. It's free (SIL Open Font License), bundled in
`Asteroid Runner/Fonts/` with its license, and listed under `UIAppFonts`
in `Info.plist`. The font is set in one place, `Utilities/Fonts.swift`;
`Fonts.din` is the old font (DIN Alternate Bold, built into iOS) for
comparing.

Other fonts considered:

- **Architects Daughter**: engineering-notebook lettering. Suits the dot
  grid and ship-designer theme, but wider and harder to read under 12 pt.
- **Your own handwriting** as a font (Calligraphr and similar services
  make one from a filled-in template). Everything would match the art
  exactly. More work; Patrick Hand can stand in until then.

Notes:

- Handwriting fonts blur at small sizes. Patrick Hand also looks a bit
  smaller and lighter than DIN Bold at the same point size. Some labels
  are 10–11 pt (map region names, hints); raise the smallest to about
  12 pt if they read poorly on a phone.
- Its digits aren't all the same width, so a number shifts a little as it
  changes. The score is right-aligned, so this is fine.
- Pick drawn lettering and the font to look alike, so drawn headings and
  typed text sit together.

## Title and headings

Words that never change can be drawn by hand instead of set in the font.
This does the most for the look, especially the title.

| Draw | Size (pt) | Notes |
|---|---|---|
| Title: ASTEROID RUNNER | about 300 × 60 (900 × 180 px) | Title screen. Set at 34 pt in the font now (`Menu.swift`) |
| GAME OVER, PAUSED, the Neptune win heading, SYSTEM MAP | about 200–300 wide, 30–40 tall | One image each |
| Region names on the map (7) | 10–12 tall | Fixed words, and they'd suit the orbit bands. Letter them small and check they read on a phone |

Keep in the font: tab labels (BUY, SELL, SAFE, NORMAL, RISKY), station
names, prices, dialog and scores. They're small or they change, and
redrawing a word every time it's edited gets old fast. Drawn words can't
be translated; fine unless the game is localized.

## Particles

Particle textures are small, soft white images, tinted and scaled in
code: `spark` and `bokeh` are 64 × 64 px in the Particle Sprite Atlas.
Keep new ones at 64 × 64 or 128 × 128 px, white on transparent, no @2x/@3x
needed. The comet tail and hit sparks use `spark`; the ship explosion is
an `.sks` file in `Particles/`. Effects are drawn as ink (normal blending),
not glows: additive blending turns white on the paper and disappears.

## Paper and ink

The background is cream notebook paper with a dot grid
(`UI/Paper.swift`), drawn in code and scrolling down to show speed. Dots
are 20 pt apart. All colors are in `Utilities/Colors.swift`: graphite
(`ink`) for most text and lines, red, blue and green pens, and a few
marker colors. Art should read on cream: dark outlines, no white or pale
glows. Pale colors are for things meant to be hard to see (glass and
black rocks).

## Full-screen art

A background or splash image should cover the largest phone, 440 × 956 pt:
**1320 × 2868 px**. Keep anything important inside the middle 375 × 667 pt
so it isn't cut off on smaller screens, and clear of the top 60 pt (notch,
Dynamic Island and the score strip) and bottom 35 pt (home indicator).

## App icon

One **1024 × 1024 px** PNG, square, no transparency, no rounded corners
(iOS rounds them). Xcode makes the smaller sizes from it. The current icon
set still has the old separate sizes; it can be switched to Single Size in
the asset's attributes.

## Notes on the current art

- The ship frames (`Satellite_4.atlas`, at the repo root) are 32 × 32 px
  with no @2x/@3x versions, so they're scaled up and soft on the phone.
  New ship art should come in at 96 × 96 px (@3x) and 64 × 64 px (@2x).
  The atlas has 20 frames; the game uses 1–5.
- Everything else (rocks, pickups, shots, station) is drawn in code for
  now. Swapping in art means changing that object's setup to load a
  texture; the sizes above keep the hit areas and gameplay the same.
