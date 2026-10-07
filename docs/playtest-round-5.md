# Playtest Round 5: Station Screen and Power Balance

Testing the reworked station screen, the power balance that makes maxed
weapons cost the whole reactor, faster maneuvering at high engine power,
slower turret fire, and the longer, tappable scanner. Round 4 found
weapons at max was the best strategy and sold items by accident twice.
Earlier rounds: [1](playtest-notes.md), [2](playtest-round-2.md),
[3](playtest-round-3.md), [4](playtest-round-4.md).

**Build:** v2.0 (51) or later. Check the version in the bottom-left corner
and note it with each game.
**Device:** iPhone 11 Pro
**Gate to pass (Phase 3):** a strong player needs the power HUD to get past
stage 20, and stages feel different from each other.

Numbers to adjust are in `Asteroid Runner/Utilities/Tuning.swift`: `Power`
(`levelCost` for what each level costs, `engineDragSpeed` and `engineTilt`
for maneuvering), `Hazards` (`turretFireInterval`, `baseFireInterval`) and
`Stages.briefingTime` for the scanner.

## What changed since round 4

| | Round 4 | Now |
| --- | --- | --- |
| Station screen | buy and sell buttons side by side, green like the HUD | Buy, Sell and Repair tabs, one list at a time; "Buy · 9" and "Sell +3" buttons; navy and station-blue look |
| Weapons power | every level costs 1 unit | levels 3 and 4 cost 2 units each (×2 in the HUD); max weapons takes the whole reactor |
| Engines at high power | drag up to 620 pt/s | up to 800 pt/s, stronger tilt |
| Turret and base fire | every 2.0 s and 2.6 s | every 2.8 s and 3.4 s |
| Scanner | 6 s | 9 s; tap it to start the wave |
| Turrets | drifted off the sides; up to 30% of a wave | enter from the top; capped at 20% (bases 8%) |
| Scanner advice | by wave kind only | follows the wave: shooters → shields, fast rocks → weapons or shields |
| Bouncers | crowded the screen | about half as many |
| Maze | regular blocks | mixed sizes, nudged and turned |
| Game over | stage, distance, counts | also lists the kinds of wave met |

## Game log

Copy the stage, distance, counts and waves from the game over screen.

| # | Date | Version | Stage | Distance | Asteroids | Turrets | Main power setting | Waves | What felt off |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | | | | | | | | | |
| 2 | | | | | | | | | |
| 3 | | | | | | | | | |
| 4 | | | | | | | | | |
| 5 | | | | | | | | | |

## Questions

### Power balance

1. Is weapons at max still the best strategy? What power setting did you use most?

   Answer:

2. With engines up, can you dodge turret fire now? Does high engine power feel worth it?

   Answer:

3. Are the "×2" marks on the top weapons levels clear? Did you notice raising weapons takes power from both other systems?

   Answer:

4. Did you change power between waves to suit the scanner's suggestion?

   Answer:

### Turrets

5. Is turret and base fire fair now: possible to dodge, still a threat?

   Answer:

### Station screen

6. Any accidental buys or sells with the tabs?

   Answer:

7. Does the station screen feel like its own place, different from the ship's HUD?

   Answer:

8. Did you have coins to spend, and anything worth buying?

   Answer:

### Scanner

9. Is 9 seconds about right? Did you tap to start sooner, or use the time to set power?

   Answer:

### Difficulty and variety

10. Where does it start to feel hard now? Any wave that's no fun?

    Answer:

11. Do bouncers and the maze feel fair now?

    Answer:

12. Did you get past stage 20? Did you need the power HUD to do it?

    Answer:

## General notes

Anything else: ideas, bugs, what was fun.

-
