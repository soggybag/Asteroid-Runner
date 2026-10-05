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
| 1 | | | | | | | | | |
| 2 | | | | | | | | | |
| 3 | | | | | | | | | |
| 4 | | | | | | | | | |
| 5 | | | | | | | | | |

## Questions

### Difficulty

1. Is the stage 10 wall gone? Where does it start to feel hard now?

   Answer:

2. What usually ended your run?

   Answer:

3. Too easy, too hard, or about right? Does the ramp feel steady?

   Answer:

### Bosstroid waves

4. Did you see the bosstroid warning? Did it change what you did (shields up, saving a bomb)?

   Answer:

5. Are bosstroid waves a fun challenge now, or too easy?

   Answer:

6. Did the smart bomb clear big rocks when you needed it?

   Answer:

### Power HUD

7. Do power levels feel different enough now? Which change was most noticeable?

   Answer:

8. Did you need the power HUD to get past stage 20?

   Answer:

### Stations

9. Were pickups pulled into the ship before docking? Does that feel right?

   Answer:

### Stats

10. Is distance in the HUD useful or distracting? Do the game over stats make you want another run?

    Answer:

## General notes

Anything else: ideas, bugs, what was fun.

-
