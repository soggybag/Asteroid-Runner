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

## Particles

Particle textures are small, soft white images, tinted and scaled in
code: `spark` and `bokeh` are 64 × 64 px in the Particle Sprite Atlas.
Keep new ones at 64 × 64 or 128 × 128 px, white on transparent, no @2x/@3x
needed. The comet tail and hit sparks use `spark`; the starfield and ship
explosion are `.sks` files in `Particles/`.

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
