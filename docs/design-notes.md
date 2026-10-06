# Asteroid Runner — Design Notes & Roadmap

Last updated: 2026-10-05 · Shared copy:[Claude Doc](https://claude.ai/code/artifact/da71df5d-26d1-4b6d-b3a7-aa7c934369c5)

## Vision

Asteroid Runner becomes a game about **piloting a ship you care about**: you dodge and shoot, but you also decide where limited power goes, and the ship grows like a character in an RPG.

- **Power management is the identity.** A power plant makes less power than the systems want, so every stage is a choice between engines, shields and weapons.
- **Managing is part of the gameplay.** Opening the HUD mid-flight is the pilot looking down at the console. The tension is intended; the UI must be easy, never fiddly.
- **The ship is a character.** It takes damage, needs repairs and earns upgrades. A bigger power plant over time is the main progression.
- **The asteroid types make it matter.** Each threat rewards a different allocation, so the stage announcement becomes a cue to reroute power.
- **The setting is an in-system voyage** (added 2026-10-05). The ship travels from the inner planets to the outer planets at sublight speed. Stations orbit planets and moons, and there are encounters along the way.
- **A run is a journey between stations** (added 2026-10-04). You fly a few waves, collect items and salvage, then dock at a station to trade, repair and refit. What you carry and what you bolt on are the decisions.

## Playtest findings (2026-10-05)

About 10 games on an iPhone 11 Pro, build v2.0 (35); details in [playtest-notes.md](playtest-notes.md). **The game is too easy and too samey, so none of the decision systems are needed yet.** The best run reached stage 48 with all 3 lives, without opening the power HUD.

| Finding | What it means |
| --- | --- |
| Reached stages 42–48 on 3 lives; the difficulty range feels narrow | Difficulty must ramp further and faster |
| Shields plus drag steering are overpowered early | Weaker early shields; drag should lag behind the finger by engine power |
| Pickups come too often and too randomly; items used as fast as possible to make room | Fewer, more purposeful pickups; saving one only matters if they're scarce |
| Never spent coins; no need to buy items found everywhere in space | Stations need things space doesn't give: trade goods, repairs, maybe items only sold there |
| Stages all feel the same as the game goes on | More kinds of waves (maze, lanes) and enemies |
| Turrets are the most interesting part so far | More enemies that shoot back |
| Multi-shot is fun | A wide range of weapons in that spirit; study Tyrian's weapon upgrades |
| The tray and the power panel feel like a phone app, not a ship | The HUD should be a heads-up display: slides down from the top as a transparent overlay |
| Drag steering is fun but doesn't feel like piloting, and overrides engine speed | Keep it, but the ship lags behind the finger based on engine power |
| Docking flies the ship through everything on screen, and is too quick | Wait for the screen to clear before the station appears |
| Tilt, haptics, pause and performance all good | No change |

## Playtest round 3 findings (2026-10-06)

Four logged games on build 43 after balance pass 2; details in [playtest-round-3.md](playtest-round-3.md). Stages 12–18, no lives left. **Better, but steep after stage 10, and stages feel flat after a while.** Three bugs fixed in build 44: brasstroids splitting into same-size copies forever, bosstroid waves that showed no bosstroids, and edge swipes reaching iOS.

| Finding | What it means |
| --- | --- |
| The ramp climbs too steeply after stage 10 | Pacing in waves: ramp up, back off, ramp up again. Tie it to the journey: easier just after a station, hardest just before the next |
| The best stages have a clear character: fast rocks to dodge, swarms of tiny rocks, a few big fast ones, chaotic elastroids | Design waves as recipes that mix sizes and types: many tiny rocks with one bosstroid, a couple of massive rocks in a swarm. Every wave mixes sizes somewhat |
| Stage briefings go by too fast and don't get attention | Make the briefing a scanner or radar readout that stays up, looks like ship equipment, and hints what to set in the HUD |
| Three tray slots get flat after a few stages | Ship upgrades: more slots, modules (Phase 5) |
| Tap-to-fire makes rapid fire pointless, and tapping and dragging hit iOS gestures | Rethink fire control: hold to fire at the weapon's rate, or auto fire only |
| Bought vs sold by mistake at a station; the station looks like the HUD | Rework the station screen: separate buy and sell clearly, its own look |
| Distance is just a number | Give it meaning with the system map and voyage, or drop it |
| Ended a game with 36 coins | Coins pile up; stations need more worth buying |

**New ideas from round 3:**

- **Rocks that carry pickups:** some rocks hold an item, with a visible hint (a glint, a different color) so players go after them.
- **Pacing in waves**, as in many games: tension and release rather than a straight climb.
- **Wave recipes** instead of one size and type per wave.
- **A scanner briefing** with the feel of space travel, cueing the player to prepare in the HUD.
- **When commerce arrives,** flying may need to be easier to leave room for it (already an open question).

## Playtest round 2 findings (2026-10-05)

Five games on build 37 after the balance pass; details in [playtest-round-2.md](playtest-round-2.md). **A better game, but it overshot:** runs now end at stages 7–13 with no lives left, almost always on a screen full of bosstroids.

| Finding | What it means |
| --- | --- |
| A wall around stage 10: a screen of bosstroids leaves no room to move | Bigger rocks should spawn less often, so a wave covers about the same area whatever the size. No pairs of huge rocks. A bosstroid wave becomes a set piece, rarer and announced, that shields and a bomb can get you through |
| The smart bomb doesn't help against big rocks | Make it stronger: enough to break a bosstroid |
| The power HUD gets used (4 of 5 games); effects noticeable, not dramatic | Widen the gap between power levels |
| The HUD covers what's underneath | Place it higher and make it transparent (HUD rework) |
| Pickup rarity is right | Keep it |
| Pickups on screen fade away when a station arrives; frustrating | Pull remaining pickups into the ship before docking |
| Turret and base drops make you go after them | Keep it; maybe special items only turrets drop |
| Shields starting empty: fair | Keep it |
| Drag lag noticeable; needs fine-tuning | Tune after the HUD rework |
| Game over doesn't say how far you got | Show stage reached, distance traveled, asteroids destroyed, turrets destroyed |

**New ideas from round 2:**

- **Station screens need their own look,** different from the HUD, to give each station flavor.
- **Distance traveled** shown in the HUD as the ship moves out through the system, and at game over. Fits the voyage setting.
- **Stats at game over:** stage reached, distance, asteroids destroyed, turrets destroyed.
- **Special items only turrets drop.**
- **A wider range of power-ups and ship modifications,** so players personalize their ships and stay engaged.
- **Difficulty vs. other activities:** if the game centers on flying through asteroids, a steep ramp past stage 10 is fine. If commerce and other tasks are added, the pressure has to leave room for them. See open questions.

## The core loop (2026-10-04)

Gameplay felt flat because nothing you pick up asks for a decision: powerups fire the moment you touch them, and coins are only points. Three ideas fix that, and they fit together:

```
 Fly 1–5 waves ──► Station ──► Fly 1–5 waves ──► Station ...
   collect items      trade, repair,
   lose modules       refit modules
   save items for     sell spare items
   the right moment
```

- **Items** give in-flight decisions: use it now, save it, or sell it.
- **Stations** give a place to spend coins and items, and a breather between runs of waves.
- **Modules** make damage visible and meaningful, and give stations something to sell.

Each one works without the others, so they can be built and tested one at a time: items first (smallest, playable now), then stations, then modules.

### Idea 1: Space stations (first version built 2026-10-04)

**Built:** a station every 1–5 waves, warned one wave ahead; the station slides in and the ship docks (tap to skip); the keeper greets by situation from `stations.json`; a shop to buy items, sell tray items and repair lost lives with coins; Launch starts the next wave. Coins: 5 per gold coin, 3 per stage cleared. Prices and timings are in `Tuning.Stations`. **Not yet:** conversation trees, fuel, modules, station art (placeholder ring for now).

A station appears after every 1 to 5 waves. The player docks, meets the station's keeper, and can refuel, buy, sell, repair and upgrade. Stations replace the "Dock between every stage" plan below.

- **Every station has a name** (Halden's Rock, Bastion Seven, The Lucky Drift), shown when it comes into view and on docking.
- **Personality.** Each station is an NPC: a name, a keeper, a voice, and a specialty that shapes its shop. Examples: a mining outpost that pays well for salvage, a military depot that sells weapon pods, a shady trader with rare items at bad prices.
- **Dialog.** Two or three lines on arrival, chosen by the situation: first visit, returning visit, ship badly damaged, carrying something the station wants. Dialog lives in data, not code: [`Asteroid Runner/Data/stations.json`](../Asteroid%20Runner/Data/stations.json) has three placeholder stations with names, keepers, greetings per situation, farewells and shop hints. Lines marked TODO are waiting for real writing.
- **Conversations, later.** A simple decision tree like Star Control: the keeper says something, the player picks a reply, and the reply leads to another line, a discount, a rumor about the next waves, or the shop. The data file already has a small `conversation` tree per station so the format is settled; the game only uses the greetings for now.
- **Docking sequence.** Short and skippable: the station slides in, the ship lines up, the screen eases into the station view. 3–4 seconds the first time, a tap skips it after that. A docking mini-game (line up with the port) is a later option; it would need to be fun on the 20th time, not just the first.
- **Warn the player before it arrives.** "Station in 2 waves" on the stage announcement lets players plan: save a bomb to sell, or push on with a damaged ship. Fully random arrival with no warning makes saving items guesswork.
- **Between stations,** the stage break stays short, as now.
- **Refuel** depends on whether fuel exists (see the open question). Fuel earlier risked a death spiral; stations make it more workable because there's a known place to refill. If added, an empty tank should cut power, not end the run.
- **Risk:** content cost. Each station needs a portrait, dialog and a shop list. Start with 3 stations and generic text, then grow.
- **Docking fixes from playtesting (2026-10-05):** a wave should pass and the screen clear before the station appears, and the approach should be slower.
- **Trading (2026-10-05).** A sub-game: buy raw materials or products at one station and sell them at another, hopefully for a profit. Goods are cargo. The Command module holds a little cargo; cargo modules add more; space pirates can steal it.
- **Items only from stations?** Since space is full of pickups, nobody buys them. One fix: powerups are mostly bought at stations, and space gives raw loot and coins.
- **Visits have side effects (2026-10-05).** What happens at a station can affect later encounters: a favor owed, a bounty, a rumor that proves true.
- **Stations orbit planets and moons** along the voyage outward.

### Idea 2: Items in the tray, used when you choose (built, testing)

Pickups go into a tray of slots in the HUD instead of firing on contact. Tap a slot to use it. Points and coins still count automatically.

The tray is a quick test of "pickups are decisions." The original idea was bigger: items and ship systems live in the HUD, and using them means bringing up the HUD. If the tray works, it may move into the redesigned HUD (see Power and fuel below).

- **Three slots to start.** A cargo module (Idea 3) or a station upgrade adds slots.
- **Bomb, multi-shot and rapid fire** fire when tapped and leave the tray.
- **Shield toggles.** Tap to raise it, tap again to lower it; it only drains while up, so a shield can be saved for a turret wave. It flickers when about to run out.
- **Tray full:** a new item is lost, and only its points are kept ("FULL" pops up). This makes the choice real: use something to make room, or let the pickup go. Alternatives to try if it feels bad: replace the oldest item, or convert to coins.
- **Where the tray goes.** First version sits in the top strip between lives and score. Playtest whether reaching the top of the phone mid-flight works; the fallback is the bottom corners, clear of the ship.
- **Later:** items have a sell price at stations; rare items only from certain stations.

### Idea 3: A modular ship

The ship starts as a **Command module**, the default ship, and everything else bolts onto it. Players add and upgrade modules at stations. When the ship is hit, it loses a module. Art for the modules is in progress; more design talk on modules to come.

- **Modules replace lives (decided 2026-10-04).** Each hit knocks off one module; when none are left, the Command module takes the damage.
- **A hull meter could work with this.** For example, the Command module has a hull meter that only drops once its add-on modules are gone, or each module has a small hull meter of its own. To be decided.
- **Modules are the power systems.** Engine module, shield generator, weapon pods, cargo bay (tray slots and fuel space). The Command module holds the reactor. Losing a weapon pod drops a gun; losing the cargo bay drops an item. This ties damage straight into power management.
- **Salvage.** A knocked-off module tumbles away for a couple of seconds; fly into it to bolt it back on. Like Sonic's rings, it turns a hit into a scramble instead of a flat loss.
- **Which module goes?** Options: the one on the side that was hit (readable and skill-based), armor plates first (protects the important modules), or random. Side-that-was-hit is the recommendation.
- **Death spiral risk.** Lose the guns and the next wave is harder. Mitigations: the core always has a basic gun, salvage lets you recover, and a cheap repair at the next station.
- **Fixed slots before a free grid.** A grid (like a shape-fitting inventory) is a lot of UI on a phone. Fixed slots are easy to read during play and to draw.
- **Art impact:** each module is its own sprite drawn to fit its slot, which matters for the hand-drawn art plan.

### Power and fuel (2026-10-04)

Power comes from two places: a small reactor that never runs out, and fuel you burn for more.

- **The Command module has a reactor.** It supplies a small amount of energy and never runs out, so the ship can always fly and fire a little. No death spiral from running dry.
- **Weapon and shield modules may draw power** in the future. More modules than the reactor can feed means choosing what's on.
- **Fuel is the boost.** Burn it to power more weapons and shields at once. It depletes as it's used.
- **Fuel takes up space,** so carrying it competes with items and modules (the cargo bay).
- **Fuel is bought at stations or found in space** (a pickup, or salvage from rocks).
- This settles the old fuel question: fuel exists, but an empty tank drops you back to reactor power instead of ending the run.

### Thrust and maneuver (2026-10-05)

Split engines in two:

- **Thrust:** forward speed. Reach the next station sooner and move through fields faster. Sometimes going slower is the smart move, such as in a maze.
- **Maneuver:** side-to-side speed. Dodging obstacles and fighting enemy bases. Drag steering follows the finger at maneuver speed, so the ship visibly lags at low power.

### HUD redesign (2026-10-04)

The HUD should feel like the ship's console. Two layouts to try, possibly together:

```
 Ship view                         Bars
 ┌───────────────────────┐         ┌───────────────────────────┐
 │        [WEAPON]       │         │ REACTOR ▮▮▮▮▯▯  FUEL ▮▮▮▯  │
 │  [SHIELD][CMD][SHIELD]│         │                           │
 │        [ENGINE]       │         │ WEAPONS  ▮▮▮▯▯   ▲ ▼      │
 │  tap a module: on/off │         │ SHIELDS  ▮▮▯▯▯   ▲ ▼      │
 └───────────────────────┘         │ ENGINES  ▮▯▯▯▯   ▲ ▼      │
                                   └───────────────────────────┘
```

- **Ship view:** the HUD shows the ship and its modules; tap a module to turn it on or off. Lit means powered. It doubles as the damage display, since lost modules are missing.
- **Bars:** one bar per system. Raising a bar sends it more energy; if there isn't enough power, raising one lowers another.
- The power HUD decisions above (swipe up, time slows, one tap per decision) still apply.

### More kinds of waves (2026-10-05)

Every wave today is the same shape: rocks fall, you shoot. The game needs some different types of levels and waves for variety between stations. Waves need an official name too (see open questions).

- **Rock waves:** most waves, as now.
- **Maze wave:** too many rocks, too large to shoot through, but there's a path the ship can navigate by dodging.
- **Lane wave:** fast asteroids moving straight down the screen, so the player picks a lane and when to switch.
- **Turrets and bases:** the most interesting thing in the game so far; more enemies that shoot back.
- Both reward engine power over weapons, which gives the power HUD a reason to change between waves. The stage announcement says what kind of wave is coming.

### Encounters inside the ship (2026-10-05)

Some threats happen in the HUD instead of on screen, so opening it matters:

- **Space pirates board the ship.** They show up in one of the HUD screens and head for the cargo bay to make off with cargo. The player removes them by hand.
- **A space virus** gets into the HUD at a random place and siphons energy from the reactor until the player removes it.

These need the reworked HUD and cargo first.

### Weapon variety (2026-10-05)

Multi-shot is the most fun pickup. Develop a wide range of weapons in that spirit that keep working through many levels of power, like Tyrian's front and side guns with upgrade levels. Spread shots, side guns, rear guns, homing shots, beams. The tray should show what you have, such as multi ×2 or ×3.

### Sound (2026-10-05)

Haptics feel right. Sound and music come with the art update.

### What the game borrows from FTL (2026-10-05)

FTL: Faster Than Light is the closest model for the ship-and-journey side of the game. What carries over, and what changes:

| FTL | Asteroid Runner | Status |
| --- | --- | --- |
| Reactor power split between systems with bars | Reactor units shared by engines, shields and weapons in the power HUD | Built |
| Damage knocks out systems, repaired at stores | Hits knock off modules; repairs at stations | Planned (Phase 5) |
| Sector map: choose the next beacon, see a little of what's there | System map: choose the next station and see hints of the stages on the way | New idea, below |
| Stores at some beacons; scrap as currency | Stations with shops; coins | Built (basic) |
| Text events with choices and side effects | Station conversations and visits with side effects | Planned (Phase 4 and 9) |
| Real-time fights you can pause | Action flight; time slows while the HUD is open | Built |

What stays our own: the moment-to-moment game is flying and shooting through asteroid fields, not tactical ship-to-ship combat.

### System map (2026-10-05)

An abstract map of the solar system, shown at a station when the player is ready to launch. The player chooses the next destination; the map hints at what lies between here and there.

```
   SUN ·  ◉ Halden's Rock ──── ◉ Bastion Seven ──── ◉ The Lucky Drift ···· outer planets
               (you are here)    ▲▲ rocks, turrets      ▦ maze, ▲ rocks
                     \               3 stages              5 stages
                      ◉ Mars Yard
                        ║ lanes, bosstroids
                        2 stages
```

- **Each route shows hints, not details:** icons for the kinds of stages on the way (rocks, maze, lanes, turrets, a bosstroid set piece) and how many stages long it is. A scanner or sensor upgrade could reveal more.
- **The route sets the number of stages** to the next station, replacing today's random 1–5.
- **Choice is the point.** A short route through turrets, or a long safe one; a station with good trade prices, or one that repairs cheaply. Players set their own pace, which answers the question of how hard flying should be once trading is added.
- **The voyage goes outward.** Inner planets first, outer planets later; distance traveled is shown in the HUD and at game over. Difficulty can rise with distance from the sun.
- **Ties into other ideas:** trade (prices differ by station), station side effects (a rumor marks a route), pirates (a route known for them), and sensors (more detail on the map).

### Other ideas from 2026-10-02

- **Maze levels:** an alternate stage type with a field of asteroids to navigate rather than shoot. Good variety between stations; parked below.
- **Hand-drawn art (pencil on paper).** Use PNG with transparency, in an asset catalog sprite atlas. Draw at 3× the in-game point size: the ship is 32 pt, so draw at 96 px or larger; the largest normal asteroid is 60 pt across (about 180 px) and a bosstroid 120 pt (about 360 px). Scan at 300 dpi or more, clean the paper to transparent, and keep line weight consistent so small and large sprites look like the same pencil. Draw rocks as a few shapes per size that the code can rotate and tint, rather than one per rock.

## Where the game stands

The core loop works on iOS 17+ in the simulator; the gaps are presentation, real-device testing and long-term reasons to play.

**Working now**

- Dodge, shoot, waves, three lives, a saved high score
- Ten asteroid types, unlocked one per stage from stage 2
- Powerups (bomb, shield, multi-shot, rapid fire) and gold coins
- A state machine for stage flow, pause on background, drag and tilt steering
- A speed-vs-power config panel, the seed of power management

**Holding it back**

- Asteroids and powerups are plain colored squares
- No sound or music
- Runs on a real phone (iPhone 11 Pro), but not yet playtested there
- Balance numbers are guesses; they now all live in `Tuning.swift`
- Coins are only points; nothing to spend them on

## Power management

A power plant produces a fixed number of power units, fewer than the three systems can use, and the player splits them between engines, shields and weapons. Precedents: X-Wing and TIE Fighter (lasers, shields, engines) and Elite Dangerous ("pips").

| System | More power gives | Best against | Existing code to build on |
| --- | --- | --- | --- |
| Engines | Faster, more responsive ship | Comets, elastroids | `Ship` speed and damping settings |
| Shields | Stronger, faster-recharging shield that absorbs hits before a life is lost | Turrets, enemy bases | `ShipShield` (today a timed powerup) |
| Weapons | Higher fire rate and damage | Brasserteroids, bosses | `missileFireTime`, `MissilePower` |

**HUD decisions (2026-10-02, revised 2026-10-05)**

- **Swipe down reveals the HUD, swipe up hides it** (changed 2026-10-05 after playtesting). The HUD slides down from the top of the screen as a transparent overlay, like a heads-up display you operate the ship with, not a dialog box.
- **Maybe two side panels** revealed by swiping left and right: weapons on the right, shields on the left. To try after the top panel works.
- **Items move into the HUD.** The tray at the top works for play but looks like a phone app. Items should be part of the ship's console, with counts shown (multi-shot ×2 or ×3) and clear rules for what stacks.
- **Steering locks while the HUD is open**, for now, to test how it feels.
- **Time slows while the HUD is open** (about 25% speed) so decisions are tense but fair. Proposed; tune in testing.
- **One tap per decision.** Tapping a system's [+] moves one unit to it from the system that has the most. No sliders.
- **First version: engines, shields and weapons only.** Three systems keep the screen clear and the choices readable.
- The HUD is a transparent overlay that replaces the current config panel.

```
┌─────────────────────────────────┐
│  POWER  ▮▮▮▮▮▮▯▯  6/8           │
│                                 │
│  ┌────────┐┌────────┐┌────────┐│
│  │ENGINES ││SHIELDS ││WEAPONS ││
│  │  ▮▮    ││  ▮▮▮   ││  ▮     ││
│  │  [+]   ││  [+]   ││  [+]   ││
│  └────────┘└────────┘└────────┘│
│        ⟲ slow time ▮▮▮▮▯        │
└─────────────────────────────────┘
```

The slow-time meter is optional: a budget that drains while the HUD is open would stop players leaving it open all the time.

## Game rhythm: Flight and Dock

The game alternates intense waves with calm breaks: **Flight** for quick reactions, **Dock** for careful planning. As of 2026-10-04 the Dock happens at a station every 1–5 waves (see Idea 1), not after every stage; the other stage breaks stay short.

| | Flight (during a wave) | Dock (at a station) |
| --- | --- | --- |
| Pressure | Time slows while the HUD is open, but threats keep coming | None; the player launches when ready |
| Power | Quick one-tap shifts | Full allocation |
| Ship | Takes damage | Repairs and upgrades, paid with coins |
| Information | Stage announcement (later: sensor warnings) | Scanner previews the next wave (later) |
| Exit | Wave cleared | **Launch** button |

At a station the player controls how long the Dock lasts, so impatient players aren't forced to wait. Between stations, today's stage announcement (`NextLevelState`) stays, shortened.

## The ship as a character

The ship grows like an RPG character: hits wear it down, the Dock fixes it, and coins make it stronger. These are proposals to test, not decisions yet. As of 2026-10-04 the modular ship (Idea 3) is the planned form of this: modules are the damage model and the upgrades.

- **Damage:** ~~a hull meter could replace the three lives~~ losing modules replaces the three lives. Shields absorb hits first.
- **System damage:** a hit knocks off a module, and with it part of a system (a weapon pod, the cargo bay). This ties damage straight into power management (FTL works this way).
- **Repairs:** done at a station, paid with coins. Skipping repairs saves coins but flies the next stage weaker.
- **Upgrades:** a bigger power plant (the main progression), higher system limits, faster shield recharge, more efficient systems.
- **Coins gain a purpose:** they pay for repairs and upgrades, giving players a reason to keep playing.
- **Later:** unlockable ships with different power plants and system limits, and a ship log of stages survived and rocks destroyed.

## Ideas considered

Most ideas fit; turning the phone sideways is dropped, and fuel is back as a boost on top of a reactor that never runs out.

| Idea | Verdict | Why |
| --- | --- | --- |
| Managing power mid-flight as gameplay | Yes, core | It is the pilot fantasy. Slow time and one-tap controls keep it fair. |
| Swipe up / down for the HUD | Yes, decided | Already half-built as the config panel. Watch for vertical swipes misfiring while drag-steering; an edge-only swipe is the fallback. |
| Turn the phone sideways for the HUD | No | Rotating the phone steers the ship through tilt controls. iOS also takes about half a second to register rotation and ignores it under rotation lock. |
| Gestures for power users | Later | Keep it to 3–4 two-finger gestures that are hard to trigger by accident. List them in settings; map them to controller buttons later. |
| More time between stages | Yes | Becomes the Dock, with the player choosing when to launch. Now at stations every 1–5 waves. |
| Space stations with names and NPC keepers (2026-10-04) | Yes, Phase 3 | Gives coins and items a purpose and the run a shape. Warn a wave or two ahead so players can plan. |
| Pickups held in a tray, used on tap (2026-10-04) | Yes, building now | The cheapest fix for flat gameplay: every pickup becomes a decision. |
| Modular ship, modules lost on hits (2026-10-04) | Yes, Phase 4 | Visible damage, a reason to repair, and the natural shape of upgrades. Salvage softens the death spiral. |
| Maze levels (2026-10-02) | Later | Variety between stations; parked. |
| Station conversations as decision trees, like Star Control (2026-10-04) | Yes, later | Greetings first; the data format already holds a tree per station. |
| Scanner instead of automatic announcements | Yes, later | Turns information into a resource and gives a fourth system (sensors) a job. Give new players a free basic scan. |
| Fuel drawn down by power use | Yes, changed (2026-10-04) | Fuel is a boost on top of a reactor that never runs out, so an empty tank can't cause a death spiral. Bought at stations or found in space. |

**A fourth system, if one is added:** sensors. Low power hides blacksteroids and glassteroids; high power highlights them and warns of off-screen threats. Stop at four systems to keep the HUD readable.

## Roadmap

Ten phases, each ending at a gate it must pass before the next begins. Phase 0 is done; Phases 1 and 2 are built but their gates aren't met, because the game is too easy for their choices to matter.

**Phase 0 status**

- [x] Commit current work
- [x] Fix signing: builds and installs on an iPhone 11 Pro with automatic signing
- [x] Move tuning numbers to one file (`Asteroid Runner/Utilities/Tuning.swift`)
- [x] Tests for waves and difficulty: 20 tests in `Asteroid RunnerTests/WaveTests.swift`
- [x] Play 10 full games on the phone and log them in [playtest-notes.md](playtest-notes.md) (2026-10-05)
- [ ] TestFlight build (needs an App Store Connect app record; can wait until other testers join)

| Phase | Goal | Scope | Gate to move on |
| --- | --- | --- | --- |
| **0 · Foundation** | Run it on a real phone | Signing, tuning file, wave tests, 10 games played. Done 2026-10-05 except TestFlight. | Runs on your phone; 10 full games played and notes taken (passed) |
| **1 · Item tray** | Every pickup is a decision | Built. Playtest: pickups too common to save; the tray looks like a phone app. Rework folds into Phase 2's HUD and Phase 3's pickup balance. | Players save items for a hard wave (not yet) |
| **2 · Power core and HUD** | Prototype engines, shields, weapons | Built: reactor, bars HUD, per-level effects. Next: HUD slides down from the top as a transparent overlay (swipe down); items move into it with counts; thrust and maneuver split; maybe left and right panels. Later: fuel. | Testers reroute power without being told, and call it fun (not yet: the game is too easy to need it) |
| **3 · Challenge and variety** | Make choices matter | Fewer, more purposeful pickups. Steeper, wider difficulty ramp; weaker early shields; drag lag. Wave types: maze and lanes. More enemies that shoot back. Weapon variety in the spirit of multi-shot (Tyrian). | A strong player needs the HUD to get past stage 20, and stages feel different from each other |
| **4 · Stations and trade** | A reason to dock | Screen clears and a slower approach before docking. A system map to choose the next station, with hints of the stages on each route. Trade goods and cargo; powerups mostly from stations; visits with side effects; stations orbiting planets on the voyage outward; real dialog. | Players spend coins at most stations |
| **5 · Modular ship** | A ship you care about | Command module as the base; modules bolt on and replace lives; maybe a hull meter; cargo modules. Salvage to recover. Buy, repair and upgrade at stations. | Players spend coins on modules, and runs last longer |
| **6 · Encounters** | Threats inside the ship | Space pirates boarding to steal cargo; a space virus draining energy; both removed by hand in the HUD. | Players handle an encounter without being told how |
| **7 · Look and sound** | Feel like a real game | Art update (hand-drawn), station and module art, sound, music, hit effects. | Someone who is not you asks to play again |
| **8 · Launch** | Ready for strangers | Tutorial that introduces systems one at a time. Settings, Game Center, App Store assets, TestFlight beta. | Shipped to the App Store |
| **9 · Expand** | Driven by player feedback | Station conversations (Star Control style), scanner and sensors, fuel, power-user gestures. Bosses, daily challenge, story campaign, iPad, controllers. | — |

**Up next (revised after round 2, 2026-10-05).**

1. ~~**Balance pass** (Phase 3)~~ Done 2026-10-05; see Phase 3 status.
2. ~~**Balance pass 2**~~ Done 2026-10-05.
3. ~~**Quick wins**~~ Done 2026-10-05: pickups pulled in before docking; stats at game over.
4. ~~**Round 3 bug fixes**~~ Done 2026-10-06: brasstroid splitting, missing bosstroids, edge swipes.
5. ~~**Waves and pacing**~~ Done 2026-10-06: wave recipes, difficulty that eases after stations, scanner briefing, hold to fire.
6. **HUD rework** (Phase 2): slides down from the top, sits higher, transparent; items move into it with counts. Fix accidental opening.
7. **Thrust and maneuver** (Phase 2), then fine-tune drag lag.
8. **Weapon variety and loot** (Phase 3): weapons in the spirit of multi-shot, turret-only items, rocks that carry pickups.
9. **Station screen rework** (Phase 4): clear buy vs sell, its own look.

Stations were built early, ahead of their phase, to see how they work; trade waits for Phase 4.

**Phase 3 status (started 2026-10-05)**

- [x] Balance pass. Numbers in `Tuning.swift`:
    - Pickups: 6% of spawns (was 24%), weighted toward points, coins, multi-shot and rapid fire; at most 2 items drift in per wave
    - Turrets and bases drop an item when destroyed
    - Ramp keeps climbing: spawn floor 0.2 s (was 0.35) reached at stage 17; rocks 3% faster each stage up to double; pairs from stage 9 up to half of spawns; featured type's share grows after stage 11 up to double; waves 10 s rising to 18 s
    - Shields: 1 charge at levels 1–2 and 2 at 3–4 (was 1 per level), slower recharge (20/15/12/9 s), start each game empty
    - Drag follows at 140–520 pt/s by engine level (was 250–1200)
    - Before a station: wait up to 20 s for rocks and enemy shots to clear, fade out anything left, then a 5 s approach (station first, then the ship)
- [x] Playtest round 2 ([playtest-round-2.md](playtest-round-2.md)): overshot. Runs end at stages 7–13 on bosstroid waves; the HUD gets used. Gate not met yet
- [x] Balance pass 2 (2026-10-05):
    - Bigger rocks spawn further apart (`sizeSpacing`: 0.6× tiny to 5× bosstroid); massive rocks and bosstroids never pair
    - Bosstroid waves: 12% from stage 8 (was 25% from 6), 30% shorter, announced "WARNING: Bosstroid field"
    - Smart bomb: 10 pulses of 2 damage, enough to break a bosstroid (was 1)
    - Wider power gaps: drag 100–620 pt/s, fire 0.7–0.12 s, damage 0.5–4, shields up to 3 charges recharging in 6 s at level 4
- [x] Quick wins: pickups on screen are pulled into the ship before docking; distance in AU in the HUD; game over shows stage, distance, asteroids and turrets destroyed
- [x] Playtest round 3 ([playtest-round-3.md](playtest-round-3.md)): stages 12–18; steep after stage 10; stages feel flat. Gate not met
- [x] Round 3 bugs fixed: brasstroid debris, bosstroid waves from the top, home indicator for edge swipes
- [x] Waves and pacing (2026-10-06):
    - Eight wave recipes in `Wave.swift`: rock field, swarm, fast movers, heavy rocks, lanes, bouncers, bosstroid field, asteroid maze. Each mixes sizes; unlocks and weights in `Tuning.Waves`
    - Spawn gaps follow each rock's size, so mixed waves keep an even density
    - Pacing: difficulty runs 3 stages easier just after a station, back to full on the last wave before the next (`Tuning.Pacing`). Hard recipes only in the second half. Steeper parts softened: rock speed +2.5% a stage (was 3%), pairs from stage 11 (was 9)
    - Scanner briefing replaces the scrolling text: radar, wave name, sizes and speed, featured type, suggested power, station ahead; up for 6 s
    - Hold to fire replaces tap to fire: with auto fire off, a held finger fires at the weapon's rate, so rapid fire counts
- [ ] Playtest round 4
- [ ] Maze and lane waves
- [ ] More enemies that shoot back
- [ ] Weapon variety

**Phase 1 status**

- [x] Pickups go into a 3-slot tray in the top strip; tap a slot to use it
- [x] Shield toggles and drains only while up; flickers when nearly empty
- [x] Tray full: the pickup is lost, its points kept
- [x] Tests for the tray rules in `Asteroid RunnerTests/InventoryTests.swift`
- [x] Playtest (2026-10-05): reachable, but it feels like a phone app; items come too often to save; multi-shot should show ×2 or ×3; unclear what stacks

**Phase 2 status (started 2026-10-05)**

- [x] Reactor of 6 units shared by engines, shields and weapons, each 0–4, starting 2/2/2
- [x] Power HUD as bars: swipe up to open, down to close; time runs at 25% and steering locks while open; + and − per system; raising when maxed takes from the system with the most
- [x] Engines: drag-follow speed and tilt force
- [x] Shields: one charge per level that blocks a hit and recharges; ring around the ship
- [x] Weapons: fire rate and damage; level 0 is a weak trickle shot; shots look stronger with power; sparks where shots hit
- [x] Old speed-vs-power config panel removed; auto fire toggle moved into the power HUD
- [x] Tests in `Asteroid RunnerTests/PowerTests.swift`
- [x] Playtest (2026-10-05): systems feel distinct and weapon levels read clearly, but the HUD wasn't needed; the game is too easy. Swipe down preferred, as an overlay from the top
- [ ] HUD rework: slides down from the top as a transparent overlay; items move into it
- [ ] Thrust and maneuver
- [ ] Later in Phase 2: fuel as a boost; the ship-view HUD once module art exists

**Stations status (built early 2026-10-04; now part of Phase 4)**

- [x] Named stations every 1–5 waves, warned a wave ahead
- [x] Docking sequence, tap to skip
- [x] Keeper greetings by situation from `stations.json`
- [x] Shop: buy items, sell tray items, repair lost lives; coins earned from coin pickups and stage clears
- [x] Tests for station data, greetings, prices and the route in `Asteroid RunnerTests/StationTests.swift`
- [x] Playtest (2026-10-05): coins never spent; docking too quick and flies through rocks; the warning is good
- [ ] Real dialog, station art, sound

## Ideas parking lot

Good ideas with no phase yet; pull them in when a phase needs them.

- **Story campaign:** `IntroState.swift` has a commented-out story about a drone AI that calls itself "the savior". Short scenes between stages, alongside an endless mode.
- **Boss stages** every 5 stages, built on the existing bosstroid size
- **More powerups from the README:** scatter gun, time dilation, tap-to-destroy smart bomb
- **Daily challenge:** the same seeded waves for everyone each day, with a leaderboard
- **Game Center** leaderboards and achievements ("Destroy 100 gasteroids")
- **Coin waves:** a special wave of coin patterns, from the README
- **iPad layout, game controllers, Mac**
- **Procedural rock art** for each asteroid type (cracked glass, glowing gas, metallic brass)
- **Maze and lane waves:** see "More kinds of waves" above
- **Docking mini-game:** line up with the station's port; only if it stays fun on repeat
- **Station reputation:** keepers remember you, give better prices to regulars

## Open questions and decisions

**Open questions**

- [ ] What does success mean: App Store release, portfolio piece, teaching project, or a personal project?
- [ ] How many hours a week can go into it? This turns phases into dates.
- [ ] Free, paid, or ads? This decides whether coins tie into a business model.
- [x] Lives or a hull meter? Modules replace lives (2026-10-04); a hull meter may be added on top.
- [ ] How do modules and a hull meter combine: hull on the Command module only, or a small meter per module?
- [x] Does fuel exist? Yes (2026-10-04): it boosts the reactor and depletes; empty means reactor power only.
- [ ] Does fuel use tray slots, its own tank, or cargo bay space?
- [ ] HUD: ship view, bars, or both? Bars built first (2026-10-05); ship view once module art exists
- [ ] Does the item tray stay on screen, or move into the HUD so using items means opening it?
- [ ] Which module does a hit knock off: the side that was hit (proposed), armor first, or random?
- [ ] How far ahead does the game announce a station: one wave, two, or a scanner reading?
- [ ] Tray full: lose the pickup (built), replace the oldest, or convert to coins?
- [ ] What's the official name for a wave/stage/level? Options: wave, stage, sector, leg (the stretch between stations). Pick one and use it everywhere.
- [ ] Do powerups stack? Two shields, or rapid fire with multi-shot: show it clearly either way.
- [ ] Should powerups mostly come from stations, with space giving loot and coins?
- [ ] Left and right HUD panels (shields left, weapons right): worth it, or one top panel?
- [ ] How hard should flying be once commerce and other tasks are added? Calm stretches between hard ones, or difficulty by distance from the sun?
- [ ] System map: how much does a route hint show by default, and what does a sensor upgrade add? Can the player go back toward the sun?
- [x] Tap-to-fire: replaced by hold to fire at the weapon's rate (2026-10-06)
- [ ] Distance: give it meaning (system map, voyage goals) or drop it?
- [ ] Is a screen full of bosstroids a designed challenge (announced, survivable with shields and a bomb) or something to remove?
- [x] Should weapons only fire while powered? No: level 0 is a weak trickle shot from the Command module (2026-10-05)
- [x] How many power units to start with? 6 units, max 4 per system, starting 2/2/2 (2026-10-05); per-level effects in `Tuning.Power`
- [ ] How slow should time run while the HUD is open, and is the slow-time budget needed?

**Decisions log**

| Date | Decision |
| --- | --- |
| 2026-10-06 | Waves and pacing built: eight wave recipes, difficulty easing after each station, a scanner briefing, hold to fire. Bosstroids now only in bosstroid field waves |
| 2026-10-06 | Round 3 playtest: stages 12–18, steep after 10, flat after a while. Fixed brasstroid splitting, missing bosstroids, edge swipes. Next: waves and pacing (wave recipes, difficulty in waves, scanner briefing) |
| 2026-10-05 | Balance pass 2: size-scaled spawn spacing, rarer announced bosstroid waves, a smart bomb that breaks bosstroids, wider power gaps. Quick wins: pickups pulled in before docking, distance and stats at game over |
| 2026-10-05 | New idea: a system map, FTL style. Choose the next station at launch; routes hint at their stages and length. Added to Phase 4 |
| 2026-10-05 | Round 2 playtest: a better game but too hard past stage 10 (bosstroid waves). Next: balance pass 2, pickups collected before docking, game over stats, then the HUD rework |
| 2026-10-05 | Balance pass: pickups a quarter as common and capped, turrets and bases drop items, a ramp that keeps climbing, weaker early shields, slower drag, a clear screen before docking |
| 2026-10-05 | Phase 0 playtest done (about 10 games, best stage 48 on 3 lives). Game too easy and samey; challenge and variety (new Phase 3) come before more systems |
| 2026-10-05 | HUD: swipe down shows it, sliding from the top as a transparent overlay; swipe up hides it. Items move into the HUD |
| 2026-10-05 | Engines to split into thrust (forward) and maneuver (sideways); drag follows at maneuver speed |
| 2026-10-05 | New ideas: in-system voyage setting, trading and cargo, station side effects, pirates and a space virus in the HUD, Tyrian-style weapon variety, sound |
| 2026-10-05 | Roadmap reordered: 3 challenge and variety, 4 stations and trade, 5 modular ship, 6 encounters, 7 look and sound, 8 launch, 9 expand |
| 2026-10-05 | Phase 2 power core built: 6-unit reactor, bars HUD, engines/shields/weapons effects; weapons at 0 keep a trickle shot |
| 2026-10-05 | Shots show their power level; sparks where they hit |
| 2026-10-05 | Need more kinds of waves: a maze wave (dodge obstacles) and a lane wave (obstacles in lanes) |
| 2026-10-04 | Stations built ahead of the power core: docking, greetings, shop with coins, repairs restore lost lives until modules exist |
| 2026-10-04 | Opening story moved to `Asteroid Runner/Data/intro.json`; the old draft story is kept there as `draftStory` |
| 2026-10-04 | Version, build number and commit shown in the bottom-left corner, stamped on every build |
| 2026-10-04 | Every station has a name; placeholder station data in `Asteroid Runner/Data/stations.json`; conversation trees come later |
| 2026-10-04 | Modules replace lives; the Command module is the default ship and everything bolts onto it |
| 2026-10-04 | The Command module's reactor gives a little power forever; fuel boosts it, depletes, takes space, and is bought at stations or found |
| 2026-10-04 | HUD redesign planned: a ship view with tap-to-toggle modules and/or bars per system |
| 2026-10-04 | Three new directions added: space stations, items held in a tray, a modular ship. Roadmap reordered: item tray is Phase 1, stations Phase 3, modular ship Phase 4 |
| 2026-10-04 | Stations replace the Dock after every stage; stage breaks between stations stay short |
| 2026-10-04 | Item tray built: 3 slots in the top strip, tap to use, shield toggles, a full tray loses the pickup |
| 2026-10-02 | Phase 0 started: device signing fixed, tuning moved to `Tuning.swift`, wave tests added |
| 2026-10-02 | First HUD version has engines, shields and weapons; scanner comes later |
| 2026-10-02 | Swipe up reveals the HUD, swipe down hides it; revisit if gestures are added |
| 2026-10-02 | Steering locks while the HUD is open, for now, to test the feel |
| 2026-10-02 | Turning the phone sideways for the HUD is dropped (conflicts with tilt steering) |
| 2026-10-02 | Fuel deferred until the core three systems are fun |
| 2026-10-02 | Ten asteroid types and coins added |
| 2026-10-02 | Project updated for Xcode 27 / iOS 17; lives, difficulty ramp, high score added |
