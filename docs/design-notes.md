# Asteroid Runner — Design Notes & Roadmap

Last updated: 2026-10-04 · Shared copy:[Claude Doc](https://claude.ai/code/artifact/da71df5d-26d1-4b6d-b3a7-aa7c934369c5)

## Vision

Asteroid Runner becomes a game about **piloting a ship you care about**: you dodge and shoot, but you also decide where limited power goes, and the ship grows like a character in an RPG.

- **Power management is the identity.** A power plant makes less power than the systems want, so every stage is a choice between engines, shields and weapons.
- **Managing is part of the gameplay.** Opening the HUD mid-flight is the pilot looking down at the console. The tension is intended; the UI must be easy, never fiddly.
- **The ship is a character.** It takes damage, needs repairs and earns upgrades. A bigger power plant over time is the main progression.
- **The asteroid types make it matter.** Each threat rewards a different allocation, so the stage announcement becomes a cue to reroute power.
- **A run is a journey between stations** (added 2026-10-04). You fly a few waves, collect items and salvage, then dock at a station to trade, repair and refit. What you carry and what you bolt on are the decisions.

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

### Idea 1: Space stations

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

**HUD decisions (2026-10-02)**

- **Swipe up reveals the HUD, swipe down hides it.** This reverses today's config panel gesture. Revisit if more gestures are added.
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

Seven phases, each ending at a gate it must pass before the next begins. Phase 0 is waiting on playtests; Phase 1 (the item tray) started 2026-10-04.

**Phase 0 status**

- [x] Commit current work
- [x] Fix signing: builds and installs on an iPhone 11 Pro with automatic signing
- [x] Move tuning numbers to one file (`Asteroid Runner/Utilities/Tuning.swift`)
- [x] Tests for waves and difficulty: 20 tests in `Asteroid RunnerTests/WaveTests.swift`
- [ ] Play 10 full games on the phone and log them in [playtest-notes.md](playtest-notes.md)
- [ ] TestFlight build (needs an App Store Connect app record; can wait until other testers join)

| Phase | Goal | Scope | Gate to move on |
| --- | --- | --- | --- |
| **0 · Foundation** | Run it on a real phone | Commit current work, fix signing, TestFlight build. Move tuning numbers to one file; tests for waves. | Runs on your phone; 10 full games played and notes taken |
| **1 · Item tray** | Every pickup is a decision | Bomb, shield, multi-shot and rapid fire go into a 3-slot tray; tap to use. Shield toggles on and off. Tray-full rule. | Players save items for a hard wave, and the game feels less flat |
| **2 · Power core and HUD** | Prototype engines, shields, weapons | Command module reactor (small, never runs out) and fuel that boosts it and depletes. HUD redesign: ship view and/or bars; swipe up to open. Time slows and steering locks while open. | Testers reroute power without being told, and call it fun |
| **3 · Stations, look and sound** | A run with a shape | Named stations every 1–5 waves with a warning, docking sequence, 3 keepers with greetings from `stations.json`, a shop to buy and sell items and fuel, and repair. Procedural rock art, sound, music, hit effects. | Players look forward to the next station; someone who is not you asks to play again |
| **4 · Modular ship** | A ship you care about | Command module as the base; modules bolt on and replace lives; maybe a hull meter. Salvage to recover. Modules map to power systems, tray slots and fuel space. Buy, repair and upgrade at stations. | Players spend coins on modules, and runs last longer |
| **5 · Launch** | Ready for strangers | Tutorial that introduces systems one at a time. Settings, Game Center, App Store assets, TestFlight beta. | Shipped to the App Store |
| **6 · Expand** | Driven by player feedback | Station conversations (Star Control style decision trees), scanner and sensors, power-user gestures, maze levels. Bosses, daily challenge, story campaign, iPad, controllers. | — |

The item tray comes first because it's small, it builds on code that exists, and it's the quickest way to test whether decisions make the game less flat. Power management comes next and before art and content on purpose: if it isn't fun on a real phone, it's cheaper to learn that before building stations, the shop and the art around them. Stations come before modules because modules need somewhere to be bought and repaired; a station with only items and repairs is still worth testing.

**Phase 1 status**

- [x] Pickups go into a 3-slot tray in the top strip; tap a slot to use it
- [x] Shield toggles and drains only while up; flickers when nearly empty
- [x] Tray full: the pickup is lost, its points kept
- [x] Tests for the tray rules in `Asteroid RunnerTests/InventoryTests.swift`
- [ ] Playtest: is the top strip reachable mid-flight? Is the tray-full rule fun? (Testing now)

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
- **Maze levels:** a stage of asteroids to weave through rather than shoot
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
- [ ] HUD: ship view, bars, or both?
- [ ] Does the item tray stay on screen, or move into the HUD so using items means opening it?
- [ ] Which module does a hit knock off: the side that was hit (proposed), armor first, or random?
- [ ] How far ahead does the game announce a station: one wave, two, or a scanner reading?
- [ ] Tray full: lose the pickup (built), replace the oldest, or convert to coins?
- [ ] Should weapons only fire while powered, so cutting them leaves the ship defenseless?
- [ ] How many power units to start with, and how much does each level do?
- [ ] How slow should time run while the HUD is open, and is the slow-time budget needed?

**Decisions log**

| Date | Decision |
| --- | --- |
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
