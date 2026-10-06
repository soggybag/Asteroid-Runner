# Playtest Round 4: Waves and Pacing

Testing wave recipes, difficulty that rises and falls between stations, the
scanner briefing, and hold to fire. Round 3 found the ramp too steep after
stage 10 and stages flat after a while; this round checks whether waves now
feel varied and the difficulty has a rhythm. Earlier rounds:
[round 1](playtest-notes.md), [round 2](playtest-round-2.md),
[round 3](playtest-round-3.md).

**Build:** v2.0 (46) or later. Check the version in the bottom-left corner
and note it with each game.
**Device:** iPhone 11 Pro
**Gate to pass (Phase 3):** a strong player needs the power HUD to get past
stage 20, and stages feel different from each other.

Numbers to adjust are in `Asteroid Runner/Utilities/Tuning.swift`:
`Waves` (unlock stages, how often each wave comes up, lane and maze speeds,
the maze gap) and `Pacing` (how much easier waves are after a station).

## What changed since round 3

| | Round 3 | Now |
| --- | --- | --- |
| Waves | one size and type per wave | eight kinds of wave, each mixing sizes (table below) |
| Difficulty | a straight climb | 3 stages easier just after a station, building to full before the next |
| Hard waves | any time | maze, bouncers and bosstroid fields only in the second half of the way to a station |
| Climb | rocks +3% speed a stage, pairs from stage 9 | +2.5% a stage, pairs from stage 11 |
| Briefing | lines of text that scroll by | a scanner panel for 6 s: wave name, sizes, speed, featured type, suggested power, station ahead |
| Manual fire | tap to fire, one shot per tap | hold to fire at the weapon's rate; rapid fire counts |
| Bosstroids | in any wave from stage 8 | only in bosstroid field waves |
| Fixes | | brasstroids no longer split into same-size copies; home indicator shows so edge swipes don't reach iOS |

| From stage | Wave | What it is |
| --- | --- | --- |
| 1 | Rock field | Mixed sizes from the wave's direction |
| 3 | Swarm | Lots of tiny and small rocks, close together |
| 4 | Fast movers | Small rocks moving fast straight down |
| 6 | Heavy rocks | Fewer, bigger, faster rocks |
| 7 | Lanes | Fast rocks down 2 of 4 lanes; the busy lanes change |
| 8 | Bouncers | Elastroids bouncing around the screen |
| 8 | Bosstroid field | A swarm of small rocks around a bosstroid |
| 9 | Asteroid maze | Rows of unbreakable grey rocks with a gap to fly through |

## Game log

Copy the stage, distance and counts from the game over screen. "Waves seen"
is the kinds you remember from the scanner.

| # | Date | Version | Stage | Distance | Asteroids | Turrets | Opened power HUD? | Waves seen | What felt off |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | | | | | | | | | |
| 2 | | | | | | | | | |
| 3 | | | | | | | | | |
| 4 | | | | | | | | | |
| 5 | | | | | | | | | |

## Questions

### Variety

1. Do stages feel different from each other now? Which kinds of wave stood out?

   Answer:

2. Any wave that's no fun, too hard, or too easy? (Maze, lanes, bouncers, bosstroid field?)

   Answer:

3. In the maze, is the gap wide enough and does it move at a fair pace?

   Answer:

4. In lanes, can you see which lanes are safe and get there in time?

   Answer:

### Pacing

5. Does the first wave after a station feel like a breather? Does it build up before the next station?

   Answer:

6. Where does it start to feel hard now? Any sudden jumps?

   Answer:

7. What usually ended your run?

   Answer:

### Scanner briefing

8. Do you read the scanner? Does it stay up long enough?

   Answer:

9. Did the suggested power setting make you change power in the HUD?

   Answer:

### Fire control

10. Hold to fire (auto fire off in the HUD): does it feel better than tapping? Does rapid fire matter now?

    Answer:

11. Any more accidental app switches, pull-downs or HUD openings?

    Answer:

### Gate

12. Did you need the power HUD to get past stage 20?

    Answer:

## General notes

Anything else: ideas, bugs, what was fun.

-
