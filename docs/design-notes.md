# Asteroid Runner — Design Notes & Roadmap

Last updated: 2026-10-02 · Shared copy: [Claude Doc](https://claude.ai/code/artifact/da71df5d-26d1-4b6d-b3a7-aa7c934369c5)

## Vision

Asteroid Runner becomes a game about **piloting a ship you care about**: you dodge and shoot, but you also decide where limited power goes, and the ship grows like a character in an RPG.

- **Power management is the identity.** A power plant makes less power than the systems want, so every stage is a choice between engines, shields and weapons.
- **Managing is part of the gameplay.** Opening the HUD mid-flight is the pilot looking down at the console. The tension is intended; the UI must be easy, never fiddly.
- **The ship is a character.** It takes damage, needs repairs and earns upgrades. A bigger power plant over time is the main progression.
- **The asteroid types make it matter.** Each threat rewards a different allocation, so the stage announcement becomes a cue to reroute power.

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
- Never run on a real phone, so tilt steering and haptics are untested
- Balance numbers are guesses, scattered through the code
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

The game alternates intense waves with calm breaks: **Flight** for quick reactions, **Dock** for careful planning.

| | Flight (during a wave) | Dock (between stages) |
| --- | --- | --- |
| Pressure | Time slows while the HUD is open, but threats keep coming | None; the player launches when ready |
| Power | Quick one-tap shifts | Full allocation |
| Ship | Takes damage | Repairs and upgrades, paid with coins |
| Information | Stage announcement (later: sensor warnings) | Scanner previews the next wave (later) |
| Exit | Wave cleared | **Launch** button |

Today's 9-second stage announcement (`NextLevelState`) becomes the Dock. The player controls how long it lasts, so impatient players aren't forced to wait.

## The ship as a character

The ship grows like an RPG character: hits wear it down, the Dock fixes it, and coins make it stronger. These are proposals to test, not decisions yet.

- **Damage:** a hull meter could replace the three lives. Shields absorb hits first; hull damage comes after.
- **System damage:** a heavy hit can damage one system, lowering how much power it can take until repaired. This ties damage straight into power management (FTL works this way).
- **Repairs:** done in the Dock, paid with coins. Skipping repairs saves coins but flies the next stage weaker.
- **Upgrades:** a bigger power plant (the main progression), higher system limits, faster shield recharge, more efficient systems.
- **Coins gain a purpose:** they pay for repairs and upgrades, giving players a reason to keep playing.
- **Later:** unlockable ships with different power plants and system limits, and a ship log of stages survived and rocks destroyed.

## Ideas considered

Most ideas fit; turning the phone sideways is dropped, and fuel waits until the core three systems are fun.

| Idea | Verdict | Why |
| --- | --- | --- |
| Managing power mid-flight as gameplay | Yes, core | It is the pilot fantasy. Slow time and one-tap controls keep it fair. |
| Swipe up / down for the HUD | Yes, decided | Already half-built as the config panel. Watch for vertical swipes misfiring while drag-steering; an edge-only swipe is the fallback. |
| Turn the phone sideways for the HUD | No | Rotating the phone steers the ship through tilt controls. iOS also takes about half a second to register rotation and ignores it under rotation lock. |
| Gestures for power users | Later | Keep it to 3–4 two-finger gestures that are hard to trigger by accident. List them in settings; map them to controller buttons later. |
| More time between stages | Yes | Becomes the Dock, with the player choosing when to launch. |
| Scanner instead of automatic announcements | Yes, later | Turns information into a resource and gives a fourth system (sensors) a job. Give new players a free basic scan. |
| Fuel drawn down by power use | Later, maybe changed | Running out tends to cause a death spiral that's hard to recover from. Alternatives: fuel as pickups from destroyed rocks, or heat that forces a cooldown. |

**A fourth system, if one is added:** sensors. Low power hides blacksteroids and glassteroids; high power highlights them and warns of off-screen threats. Stop at four systems to keep the HUD readable.

## Roadmap

Six phases, each ending at a gate it must pass before the next begins; Phase 0 is next.

| Phase | Goal | Scope | Gate to move on |
| --- | --- | --- | --- |
| **0 · Foundation** | Run it on a real phone | Commit current work, fix signing, TestFlight build. Move tuning numbers to one file; tests for waves. | Runs on your phone; 10 full games played and notes taken |
| **1 · Power core** | Prototype engines, shields, weapons | Power plant and three systems; swipe up for the HUD. Time slows and steering locks while open; tap [+] to boost. | Testers reroute power without being told, and call it fun |
| **2 · Dock, look and sound** | Make it feel like a real game | Dock between stages with a Launch button. Procedural rock art, sound, music, hit effects. | Someone who is not you asks to play again |
| **3 · Ship as a character** | A reason to keep playing | Hull and system damage, repairs in the Dock. Coin shop: bigger power plant, system upgrades. | Players spend coins on upgrades, and games last longer |
| **4 · Launch** | Ready for strangers | Tutorial that introduces systems one at a time. Settings, Game Center, App Store assets, TestFlight beta. | Shipped to the App Store |
| **5 · Expand** | Driven by player feedback | Scanner and sensors, power-user gestures, fuel or heat. Bosses, daily challenge, story campaign, iPad, controllers. | — |

Phase 1 comes before art and content on purpose: if power management isn't fun on a real phone, it's cheaper to learn that before building the Dock, the shop and the art around it. The scanner, gestures and fuel are spread into Phase 5 so they can be revisited once the core is proven.

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

## Open questions and decisions

**Open questions**

- [ ] What does success mean: App Store release, portfolio piece, teaching project, or a personal project?
- [ ] How many hours a week can go into it? This turns phases into dates.
- [ ] Free, paid, or ads? This decides whether coins tie into a business model.
- [ ] Lives or a hull meter?
- [ ] Should weapons only fire while powered, so cutting them leaves the ship defenseless?
- [ ] How many power units to start with, and how much does each level do?
- [ ] How slow should time run while the HUD is open, and is the slow-time budget needed?

**Decisions log**

| Date | Decision |
| --- | --- |
| 2026-10-02 | First HUD version has engines, shields and weapons; scanner comes later |
| 2026-10-02 | Swipe up reveals the HUD, swipe down hides it; revisit if gestures are added |
| 2026-10-02 | Steering locks while the HUD is open, for now, to test the feel |
| 2026-10-02 | Turning the phone sideways for the HUD is dropped (conflicts with tilt steering) |
| 2026-10-02 | Fuel deferred until the core three systems are fun |
| 2026-10-02 | Ten asteroid types and coins added |
| 2026-10-02 | Project updated for Xcode 27 / iOS 17; lives, difficulty ramp, high score added |
