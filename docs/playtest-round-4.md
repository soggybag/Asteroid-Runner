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
| 1   | 10 6 26 | 2.0 (48) | 13 | 1.5 | 441 | 5 | Yes | Can we summarize waves seen in the game over screen. Its hard to remember all of these by the end of the game | Stage 12 |
| 2   | | | 18 | 2.01 | 556 | 9 | No |  | The last level had a large number of turrest which seemed a little too much too soon. Score: 15835 |
| 3   | | | 16 | 1.91 | 566 | 4 | Yes, I followed all of the suggestions in the pre stage message. | | The suggestion of balanced against fast rocks moving down the screen seems like a bad suggestions, I think i would have done better with shields, or weapons up. |
| 4   | 10 7 26 |  | 16 | 1.81 | 600 | 4 | Yes | | Noticed that turrest often drifted off the screen to the left or right. Sometimes turrest fire a lot. This make it challengeing, the maneuverability of the ship is low making it hard to dodge many bullets. Seems like Weapons on max is generally a better strategy than other settings. |
| 5   | | | 18 | 2.1 | 657 | 1 | Yes |  | Finally got a maze level. This looks good but the blocks are too regularlly spaced. keep the general arrangement but add some variation. Accidentially sold something I meant to buy, station UI needs some work. Does rapid and multi stack? Lanes feels good and is an interesting change. Bouncers just crsuhed me, even with shields full. The screen was filled with objects. |

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

## Summary (2026-10-07)

Five games on build 48: stages 13–18, no lives left; the power HUD opened in 4 of 5. **Waves feel more varied: lanes are a good change, the maze looks good, the scanner adds to play.** Still no run past stage 20, and **weapons at max looks like the best strategy** in general.

**Fixed in build 49:**

- Turrets drifted off the left and right edges, and late waves had too many. Turrets and bases now come in from the top and cross the screen, and their share of a wave is capped (turrets 20%, bases 8%) however late the stage.
- The scanner suggested "Balanced" for a fast rock field. Advice now depends on the wave: shooters call for shields, a fast rock field for weapons or shields.
- Bouncers filled the screen and crushed the ship even with full shields. Bouncer waves now spawn about half as often (2.2× spacing, was 1.2×) and are 20% shorter.
- Maze blocks were too regular. Rocks now mix sizes, are nudged and turned a little, and keep extra room around the gap.
- Game over now lists the kinds of wave met, most common first.
- The scanner's blips now cross the radar the way the wave will come: down from the top, in from a side, in columns for lanes, in a row with a gap for a maze.

**Answered:** rapid fire and multi-shot do stack. Multi-shot sets how many missiles each shot fires; rapid fire halves the time between shots.

**Still open:**

- Weapons at max beats other settings, and the ship is hard to maneuver around turret fire.
- Accidentally sold something meant to be bought (second time): the station screen needs rework.

Changes are in [design-notes.md](design-notes.md#playtest-round-4-findings-2026-10-07).

## General notes

Anything else: ideas, bugs, what was fun.

- Radar/scanner lools good adds to game play. Would be better if what was shown on the scanner matched the trajectory of the coming asteroid swarm. 
- 
