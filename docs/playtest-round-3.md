# Playtest Round 3: Balance Pass 2

Testing balance pass 2 and two quick wins. Round 2 runs ended around stage
10 on screens full of bosstroids; this round checks whether that wall is
gone without making the game too easy again. Earlier rounds:
[round 1](playtest-notes.md), [round 2](playtest-round-2.md).

**Build:** v2.0 (42) or later. Check the version in the bottom-left corner
and note it with each game.
**Device:** iPhone 11 Pro
**Gate to pass (Phase 3):** a strong player needs the power HUD to get past
stage 20.

Numbers to adjust are in `Asteroid Runner/Utilities/Tuning.swift`. If
bosstroid waves are now too gentle, raise `sizeSpacing(.bosstroid)` in
`Stages` or `bosstroidChance` in `Hazards`. If the game is too hard again,
turn down `speedScale` or `pairChance` in `Stages`.

## What changed since round 2

| | Round 2 | Now |
| --- | --- | --- |
| Spawn spacing | same for every rock size | bigger rocks further apart: 0.6× for tiny up to 5× for bosstroids |
| Pairs | any size, from stage 9 | only rocks smaller than massive |
| Bosstroid waves | 25% of waves from stage 6 | 12% from stage 8, 30% shorter, announced with a warning |
| Smart bomb | 10 pulses of 1 damage; couldn't break a bosstroid | 10 pulses of 2; breaks a bosstroid |
| Power levels, 0 to 4 | modest differences | wider: drag 100–620 pt/s, fire every 0.7–0.12 s, damage 0.5–4, shields up to 3 charges |
| Pickups at a station | faded away | pulled into the ship |
| Distance | not shown | in AU under the coins, and at game over |
| Game over | score and best | also stage, distance, asteroids and turrets destroyed |

## Game log

The game over screen now shows the stage, distance and counts; copy them in.

| # | Date | Version | Stage | Distance | Asteroids | Turrets | Lives left | Opened power HUD? | What felt off |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 10 5 26 | 20 (43) | 12 | 1.53 | 490 | 1 | 0 | No | On the last I had two smart bombs, there was a big wave of brastroids, just multiply into more brastroids. After two smart bombs the screen was full of normal sized brastroids. This felt like an error. |
| 2 | | | 16 | 2.08 | 665 | 1 | 0 | Yes | Looks like brass troids multiply into more same sized brastroids. To make it through these you need to avoid them since shooting them creates more! This might be good it might also prove hard for players to get past. |
| 3 | 10 6 26 |  | 15 | 1.8 | 313 | 7 | 0 | No | There was a Bossteroid stage that manifested no Bosteroids. not sure that happened. Elastroid wav can be interesting with many objects moving chaotically, shields are useful here. score: 10885, ended with 36 coins. Should get more interesting with ship upgrades. Currently with only three slots game starts to feel flat after a few stages.  |
| 4 | | | | | | | | | Stages with fast moving asteroids can be interesting since the player must dodge these firing is not as effective. The pre stage text might be themed as radar or scanners. These clues could cue a player to prepare for a stage using the HUD. Stages with many tiny asteroids are also interesting. A few large fast moving asteroids is also interesting. We can vary the composition of stages, imagine many tiny asteroids with a single bosteroids or a couple massive. All stages should mix up sizes to some extent. |
| 5 | | | 18 | 2.38 | 615 | 2 | 0 | No | manual fire sort of nullifies the effecicacy of rapid fire. This option needs closer scrutiny. I accidentally sold something when I meant to buy. We should rethink the UI of the station menu. This menu also looks too much like the ship HUD. Each should feel distinct. Tapping to fire and steer causes problems with the native phone UI, I played this entire game using the tap to fire and steer, and accidentally moved the whole screen down, and switched apps once, and opened the HUD by accident. Might be good to include some pickups that are released by breaking rocks. |

## Questions

### Difficulty

1. Is the stage 10 wall gone? Where does it start to feel hard now?

   Answer: There seems to be a ramp up after stage 10. Maybe the incline is too steep after stage 10. MIght be good to back off then ramp up, then back off again. I think this is a pattern in games?  

2. What usually ended your run?

   Answer: Getting crushed by asteroids. 

3. Too easy, too hard, or about right? Does the ramp feel steady?

   Answer: better but needs work. When we get commerce working We may have to back off the difficulty of space travel and asteroids. 

### Bosstroid waves

4. Did you see the bosstroid warning? Did it change what you did (shields up, saving a bomb)?

   Answer: This is something we should develop further. I didn't really use this. The messages went by a little too fast and weren't interesting enough to get my attention. Framing this more as radar or scanners might help along with some interesting design and UI to give the feel of space travel. 

5. Are bosstroid waves a fun challenge now, or too easy?

   Answer: Maybe. 

6. Did the smart bomb clear big rocks when you needed it?

   Answer: yes. with the exception of brasstroids. 

### Power HUD

7. Do power levels feel different enough now? Which change was most noticeable?

   Answer: 

8. Did you need the power HUD to get past stage 20?

   Answer: Didn't make it ot stage 20. 

### Stations

9. Were pickups pulled into the ship before docking? Does that feel right?

   Answer: Yes

### Stats

10. Is distance in the HUD useful or distracting? Do the game over stats make you want another run?

    Answer: Distance isn't dooing anything yet. Its just a number. In the future this could be important or we could drop it. 

## Summary (2026-10-06)

Four logged games on build 43: stages 12, 15, 16 and 18, no lives left, best distance 2.38 AU. **Better, but the ramp is still steep after stage 10 and stages start to feel flat.** No run reached stage 20, so the Phase 3 gate is still open.

**Bugs found, fixed in build 44 (`4fa93ad`):**

- Brasstroids split into same-size brasstroids forever. Brass is forced to at least large when it spawns, and its debris was forced back up too. Debris now always gets smaller.
- A bosstroid stage with no bosstroids. Likely cause: with the wider spacing only 2–3 spawn, and from the side they drift in so slowly they stay off screen. They now come from the top, and the first arrives right away.
- Tap-to-fire play pulled the screen down, switched apps and opened the HUD by accident. The home indicator was set to hide, which stops iOS deferring bottom-edge swipes; it now shows (dimmed). The accidental HUD opening is for the HUD rework.

**What worked:** elastroid waves (chaotic, shields useful), fast rocks you must dodge, waves of many tiny rocks, a few large fast rocks; pickups pulled in before docking; the smart bomb on big rocks.

**What didn't:** the ramp after stage 10; stage briefings go by too fast to matter; three tray slots get flat after a few stages; tap-to-fire makes rapid fire pointless; buying vs selling at a station is easy to mix up, and the station looks like the HUD; distance is just a number so far.

Changes are in [design-notes.md](design-notes.md#playtest-round-3-findings-2026-10-06).

## General notes

Anything else: ideas, bugs, what was fun.

- Might be good to include some pickups that are released by breaking rocks. If the rocks had a clue as to their type or that they may contain something that would create player incentive.
