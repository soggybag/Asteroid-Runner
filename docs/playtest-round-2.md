# Playtest Round 2: Balance Pass

Testing the balance pass: rarer pickups, a difficulty ramp that keeps
climbing, weaker early shields, slower drag steering, and a clear screen
before docking. Round 1 is in [playtest-notes.md](playtest-notes.md).

**Build:** v2.0 (37) or later. Check the version in the bottom-left corner
and note it with each game.
**Device:** iPhone 11 Pro
**Gate to pass (Phase 3):** a strong player needs the power HUD to get past
stage 20.

Numbers to adjust are in `Asteroid Runner/Utilities/Tuning.swift`. If it's
now too hard, the quickest to turn down are `speedScale` and `pairChance`
in `Stages`.

## What changed since round 1

| | Round 1 | Now |
| --- | --- | --- |
| Pickups | 24% of spawns | 6%, at most 2 items per wave |
| Turrets and bases | nothing extra | drop an item when destroyed |
| Spawn rate | stops speeding up at stage 12 | speeds up until stage 17 |
| Rock speed | fixed | 3% faster every stage, up to double |
| Rocks per spawn | 1 | from stage 9, sometimes 2 |
| Featured type | fixed share | grows after stage 11 |
| Wave length | 10 s | 10 s, growing to 18 s |
| Powered shields | 1 charge per level, start full | 1 charge at levels 1–2, 2 at 3–4; slower recharge; start empty |
| Drag steering | follows fast | follows at 140–520 pt/s by engine power |
| Docking | right after the wave | waits for a clear screen; 5 s approach |

## Game log

| # | Date | Version | Stage reached | Lives left | Opened power HUD? | What felt off |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | | | | | | |
| 2 | | | | | | |
| 3 | | | | | | |
| 4 | | | | | | |
| 5 | | | | | | |

## Questions

### Difficulty

1. At what stage did it start to feel hard? Too early, too late, about right?

   Answer:

2. What usually ended your run?

   Answer:

3. Does the ramp feel steady, or are there sudden jumps?

   Answer:

### Power HUD

4. Did you need the power HUD to survive? When did you open it, and what did you change?

   Answer:

5. Did you change power between waves to suit the featured asteroid type?

   Answer:

### Pickups and items

6. Are pickups rare enough now to be worth saving, or too rare?

   Answer:

7. Did turrets and bases dropping items make you go after them?

   Answer:

### Steering

8. Is the drag lag noticeable? Does it feel like piloting, or just sluggish?

   Answer:

9. Did engine power change how the ship handles enough to matter?

   Answer:

### Shields

10. Starting empty and recharging slowly: fair, or too punishing early on?

    Answer:

### Stations

11. Does docking feel right now: clear screen, slower approach?

    Answer:

12. Did you have coins to spend, and anything worth buying?

    Answer:

## General notes

Anything else: ideas, bugs, what was fun.

-
