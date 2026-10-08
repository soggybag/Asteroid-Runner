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
| 1 | 10 7 25 | 2.0 (53) | 9 | 1.12 | 201 | 0 | Normal, weapons +1 | Rocks 6, Swarm 2, heavy rocks 1 | |
| 2 | 10 8 26 |  | 9 | 1.03 | 282 | 0 | Weapons Full | Rock 6, Swarm 2, heavy 1 | Score: 5555, weapons vs engines balnce felt better, weapons are powerful but engines on low are slow. Dragging with engines low left good also. The ship was not very responsive when dragging with engines low. Might be good to give the pickups a little tumble. |
| 3 |  |  | 12 | 1.49 | 408 | 1 | yes | rocks 6, swarm 4, heavy 2 | Might good to have a comet swarm stage. Does the explosion of a blasteroid affect asteroids in the blast radius? Got a warning about shooters at the start of a level but didn't see any that level. Maybe they appeared off screen? the next level I saw a single turret at the top of the screen and was able to push it off the top with a couple shots, seems anti climactic. score: 9070 |
| 4 | | |  | | | | | | There was a good turret level this game. The turrets stayed on screen. They probably fired too much. At least for an early level the density fo fire seemed high.  |
| 5 | | | 20 | 2.4 | 1060 | 2 | Weapons, yes | Rocks 9, Swarm 4, Heavy 3, Lanes 2, Fast 1, Bouncers 1 | Seems to ramp up around stage 18 - 20. gets very difficult here. Might be good to back off then get more difficult later. This might be balanced by more elaborate ship upgrades, which might require and trade. |

## Questions

### Power balance

1. Is weapons at max still the best strategy? What power setting did you use most?

   Answer: Not always. Seems more balanced now. I found switching to engines was better on some levels.

2. With engines up, can you dodge turret fire now? Does high engine power feel worth it?

   Answer: Not sure but engines up was good in some cases. 

3. Are the "×2" marks on the top weapons levels clear? Did you notice raising weapons takes power from both other systems?

   Answer: Didn't notice this.

4. Did you change power between waves to suit the scanner's suggestion?

   Answer: Sometimes

### Turrets

5. Is turret and base fire fair now: possible to dodge, still a threat?

   Answer: Seems like the basses fire too much, at least initially. They can set down a field of fire that is very hard to dodge especially with lots of rocks on the screen. Shields help here. 

### Station screen

6. Any accidental buys or sells with the tabs?

   Answer: no

7. Does the station screen feel like its own place, different from the ship's HUD?

   Answer: it feels different still needs work. 

8. Did you have coins to spend, and anything worth buying?

   Answer: I spent often. At the end I felt I couldn't afford upgrades that might have helped me get beyond level 20. 

### Scanner

9. Is 9 seconds about right? Did you tap to start sooner, or use the time to set power?

   Answer: Scanner felt good. 

### Difficulty and variety

10. Where does it start to feel hard now? Any wave that's no fun?

    Answer: Around stage 18 to 20 things started to get really hard. 

11. Do bouncers and the maze feel fair now?

    Answer: hard to say, I only got to the maze once or twice. 

12. Did you get past stage 20? Did you need the power HUD to do it?

    Answer: I don't think I got past 20. 

## Summary (2026-10-08)

Five games on build 53: stages 9–20, and the best run so far reached **stage 20** (2.4 AU, 1,060 asteroids, six kinds of wave), using weapons and the power HUD. **Power is more balanced: weapons at max no longer always wins, and engines were better on some levels. No accidental station sales. The scanner feels good.** It still gets very hard around stages 18–20.

**Fixed in build 54:**

- A turret could be pushed off the top of the screen with a couple of shots. Missiles now damage turrets and bases without pushing them, like brasstroids.
- The scanner warned of shooters but none came. A shooter wave now starts with a shooter.
- Bases laid down too much fire, especially early. Base fire is slower (4.2 s, was 3.4), and all shooters fire 1.5× slower at stage 1, easing to normal by stage 21.
- Pickups now tumble as they drift down.

**Answered:** yes, a gasteroid's explosion damages every asteroid in its blast radius, and the ship too if it's close.

**Still open:** hard at stages 18–20 (back off, then harder later); the station screen feels different but needs work; ran out of coins for upgrades that might have got past stage 20. The general notes ask for commerce, a system map with destinations and missions, and ship upgrades that let players build ships for different roles.

Changes are in [design-notes.md](design-notes.md#playtest-round-5-findings-2026-10-08).

## General notes

Anything else: ideas, bugs, what was fun.

- We need to add some dimension with commerce and system map. Allowing players to choose destinations and solve missions. 
- More elaborate ship upgrades will add a lot to game play. Allowing players to design their own ship for different types of missions. Combat, cargo, exploration, balanced will add a lot and appeal to a range of players. 
