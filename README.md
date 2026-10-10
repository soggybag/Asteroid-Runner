# Astervoids

Built with SpriteKit. 

Fly through asteroids, try not to get hit. You have three lives; after a hit
the ship blinks and can't be hit again for a moment. Survive a stage for a
bonus. Stages get harder as you go: bigger, faster asteroids, more often.

Requires Xcode 15+ and iOS 17+.

Design notes and roadmap: [docs/design-notes.md](docs/design-notes.md)

System map design (draft): [docs/system-map.md](docs/system-map.md)

## Controls

- Drag anywhere to steer, or tilt the phone. The ship follows your finger as
  fast as its engines allow.
- The ship fires automatically. Turn Auto Fire off in the power HUD (swipe
  up) to fire only while a finger is held down, at the weapon's rate.
- Pickups go into the item tray just under the top strip. Tap a slot to use
  it: bomb, multi-shot or rapid fire. Tap a shield to raise it and again to
  lower it; it only drains while it's up. The tray holds three; when it's
  full, new pickups are lost.
- Every 2 to 5 stages you dock at a space station, one region further out
  each time, from Earth toward Neptune (the system map; see
  [docs/system-map.md](docs/system-map.md)). The stage announcement
  warns you a wave ahead ("Station ahead: Bastion Seven"). Tap to skip the
  docking. At the station, the Buy, Sell, Repair and Upgrade tabs show one
  list at a time: buy items, sell what's in your tray, repair lost hull
  (lives), fit ship upgrades, then tap Launch.
- Launch opens the system map, from Earth at the bottom to Neptune at the
  top. Choose the next station: a safe route is longer and easier, a risky
  one shorter and harder. Tap a station or a route tab to see how many
  stages, the kinds of wave on the way, and what the station sells, then
  tap Set course.
- Ship upgrades last for the rest of the run. Each station fits its own set:

  | Upgrade | Each tier | Tiers |
  |---|---|---|
  | Reactor | +1 power unit | 3 |
  | Cargo rack | +1 tray slot | 2 |
  | Hull plating | +1 hull (life), fitted with it | 2 |
  | Thrusters | +15% maneuvering | 2 |
  | Weapon focus | +20% damage | 2 |
  | Shield capacitor | +1 shield charge while shields have power | 2 |
- Coins (shown under the score) pay for it: 5 per gold coin picked up, 3 per
  stage cleared. Pickups still on screen when a station arrives are pulled
  into the ship.
- Distance traveled (in AU) shows under the coins. Game over shows the stage
  reached, distance, and asteroids and turrets destroyed.
- Tap during the intro to skip it.
- The game pauses when the app goes to the background. Tap to resume.

## Power

Swipe up mid-flight to open the power HUD; swipe down to close it. Time slows
to a quarter speed and steering locks while it's open.

The reactor makes 6 units of power, shared between three systems, each from
0 to 4. Each level costs a unit, except the top two weapons levels, which
cost 2 each (marked ×2): maxing weapons takes the whole reactor. Tap + to
raise a system; if the reactor is maxed out, levels come from the system
with the most. Tap − to free its units.

- **Engines:** how fast the ship follows your finger, and how hard tilt pushes
  it. High engine power maneuvers much faster, for dodging turret fire.
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

## Waves

Before each wave the scanner shows what's coming for 9 seconds (tap it to
start sooner): the kind of wave, rock
sizes and speed, any special asteroid type, a suggested power setting, and
whether a station is next. Waves come in kinds, unlocked as stages go by:

| From stage | Wave | What it is |
|---|---|---|
| 1 | Rock field | Mixed sizes from the wave's direction |
| 3 | Swarm | Lots of tiny and small rocks, close together |
| 4 | Fast movers | Small rocks moving fast straight down; dodge them |
| 6 | Heavy rocks | Fewer, bigger, faster rocks |
| 7 | Lanes | Fast rocks down a few lanes; the busy lanes change |
| 8 | Bouncers | Elastroids bouncing around the screen |
| 8 | Bosstroid field | A swarm of small rocks around a bosstroid |
| 9 | Asteroid maze | Rows of unbreakable rocks with a gap to fly through |

Difficulty rises and falls: the first wave after a station is a few stages
easier, building to full strength just before the next station. Mazes,
bouncers and bosstroid fields only come in the second half of the way.

Rocks break into smaller rocks when hit enough. Special types are worth more
points. Turrets and enemy bases drop an item when destroyed. Stages keep
getting harder: rocks spawn faster and move faster every stage, waves get
longer, and from stage 11 smaller rocks sometimes come in pairs. Bigger rocks
spawn further apart. A smart bomb can break bosstroids. The shield blocks enemy shots. Gold coins are worth 250 points.

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
  round 2 (balance pass) is [docs/playtest-round-2.md](docs/playtest-round-2.md);
  round 3 (balance pass 2) is [docs/playtest-round-3.md](docs/playtest-round-3.md);
  round 4 (waves and pacing) is [docs/playtest-round-4.md](docs/playtest-round-4.md);
  round 5 (station screen and power balance) is [docs/playtest-round-5.md](docs/playtest-round-5.md);
  round 6 (ship upgrades) is [docs/playtest-round-6.md](docs/playtest-round-6.md);
  round 7 (tray row) is [docs/playtest-round-7.md](docs/playtest-round-7.md).
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
