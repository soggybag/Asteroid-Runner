# Astervoids

Built with SpriteKit. 

Fly through asteroids, try not to get hit. You have three lives; after a hit
the ship blinks and can't be hit again for a moment. Survive a stage for a
bonus. Stages get harder as you go: bigger, faster asteroids, more often.

Requires Xcode 15+ and iOS 17+.

Design notes and roadmap: [docs/design-notes.md](docs/design-notes.md)

## Controls

- Drag anywhere to steer, or tilt the phone. The ship follows your finger as
  fast as its engines allow.
- The ship fires automatically. Turn Auto Fire off in the power HUD (swipe
  up) to tap to fire instead.
- Pickups go into the item tray at the top of the screen. Tap a slot to use
  it: bomb, multi-shot or rapid fire. Tap a shield to raise it and again to
  lower it; it only drains while it's up. The tray holds three; when it's
  full, new pickups are lost.
- Every 1 to 5 stages you dock at a space station. The stage announcement
  warns you a wave ahead ("Station ahead: Bastion Seven"). Tap to skip the
  docking. At the station, buy items, sell what's in your tray, repair lost
  hull (lives), then tap Launch.
- Coins (shown under the score) pay for it: 5 per gold coin picked up, 3 per
  stage cleared.
- Tap during the intro to skip it.
- The game pauses when the app goes to the background. Tap to resume.

## Power

Swipe up mid-flight to open the power HUD; swipe down to close it. Time slows
to a quarter speed and steering locks while it's open.

The reactor makes 6 units of power, shared between three systems, each from
0 to 4. Tap + to give a system a unit. If the reactor is maxed out, the unit
comes from the system with the most. Tap − to free a unit.

- **Engines:** how fast the ship follows your finger, and how hard tilt pushes it.
- **Shields:** charges that each block one hit, shown as a ring around the
  ship: 1 charge at levels 1–2, 2 at levels 3–4. The shield starts each game
  empty and rebuilds over time, faster with more power. The shield item in
  the tray is separate and still works.
- **Weapons:** fire rate and damage. Shots look stronger as power goes up, from
  a dim speck at 0 (the ship always has a weak shot) to a white-hot bolt at 4.
  Hits throw sparks.

Auto fire is switched on and off in the power HUD.

## Asteroid types

Stage 1 is plain rocks. Each stage after that introduces a new type, announced
before the wave ("Watch for: Comets"). Once all have appeared, each wave
features a random one.

| Stage | Type | Behavior |
|---|---|---|
| 2 | Low mass | Every shot knocks it back up the screen |
| 3 | Glassteroid | Nearly transparent, shatters in one hit |
| 4 | Blacksteroid | Dark, hard to see against space |
| 5 | Icestroid | Bursts into sharp ice shards that can hit you |
| 6 | Comet | Small and fast, streaks in diagonally with a tail |
| 7 | Gasteroid | Explodes, damaging nearby rocks and the ship if it's close |
| 8 | Elastroid | Bounces off the screen edges three times |
| 9 | Brasserteroid | Super massive and tough, missiles don't push it |
| 10 | Turret | Fires aimed shots at the ship |
| 11 | Enemy base | Big, slow and armored, fires a three-shot spread |

Rocks break into smaller rocks when hit enough. Special types are worth more
points. Turrets and enemy bases drop an item when destroyed. Stages keep
getting harder: rocks spawn faster and move faster every stage, waves get
longer, and from stage 9 rocks sometimes come in pairs. The shield blocks enemy shots. Gold coins are worth 250 points.

## Development

- **Run on a phone:** connect it, pick it as the run destination in Xcode and
  press Run. Signing is automatic with the team set in the project.
- **Tests:** press Cmd-U in Xcode, or run
  `xcodebuild test -scheme "Asteroid Runner" -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest'`.
  They cover spawn timing, what each stage unlocks and how asteroids break.
- **Tuning:** gameplay numbers (lives, fire rate, wave length, hazards) live in
  `Asteroid Runner/Utilities/Tuning.swift`. Per-type asteroid stats live in
  `AsteroidType.swift`.
- **Story and dialog:** the opening story is in `Asteroid Runner/Data/intro.json`
  and the stations (names, keepers, greetings, what they sell, price
  multipliers) in `Asteroid Runner/Data/stations.json`. Add a station by
  adding an entry. Edit them like any
  text file; the tests check that they still load.
- **Version:** the bottom-left corner shows `v2.0 (32) eb38a83`: the version,
  the build number (commits on the branch) and the commit. A `+` after the
  commit means the build had uncommitted changes. `scripts/stamp-version.sh`
  sets these on every build. Change the version itself in the target's
  General settings.
- **Playtesting:** round 1 notes are in [docs/playtest-notes.md](docs/playtest-notes.md);
  round 2 (balance pass) is [docs/playtest-round-2.md](docs/playtest-round-2.md).
  Note the version from the corner with each game.

## Todo

Add new Powerups: 
 
 1. Smart Bomb - Tapping asteroids destroys them
 2. Smarter Bomb - Destroys all asteroids on screen
 3. Coins - gain extra points
 4. Missile PU - Missiles do more damage
 5. Shield - Puts up a shield for limited time
 6. Rapid fire - Fires alot
 7. Scatter Gun - Fires in all directions
 8. Time Dilation - Slows the game
 9. Time Expansion - Speeds the game
 10. Shrinker - ...
 11. Manuever Jets - Makes controling the easier
 
 Add game play features 
 
 1. ~~Lives - Classic three lives~~ Done
 2. Shield - deflects an asteroid, wears down over time, or with each hit
 3. Armor - protects from one hit, no life lost
 4. Asteroids break when hit - Depending on size a number of hits will break an asteroid into two or more smaller asteroids
 5. Waves - Asteroids appear in waves of similar types
 6. Coins appear in special coin wave

Art and effects

1. ~~Starfield background~~ Done
2. Shots produce small exposition
