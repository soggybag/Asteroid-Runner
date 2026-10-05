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
| 1 | 10 5 26 | 20 (37) |  ~7 (we should show the stage on the game over screen) | 0 | no | Score: 6465. The last level was very hard. It might have been possible if I had adjusted controls in the HUD... I bought a smart bomb. |
| 2 |  |  | ~8 | 0 | Yes| Score: 7675. Used the HUD, tried to play the whole game with weapons full. Switched to Speed full at the end level when the screen was full. Would be good to position the HUD higher on the screen and make it transparent, player needs to see what is going underneath it. |
| 3 |  | | 10 | 0 | Yes | Game seems to ramp up the difficulty at level 10. A screen full of super massive rocks is very hard there is  little room to maneuver and weapons are not so effective. |
| 4 |  |  | 13? | 0 | Yes | Score 7110, Tried shields > weapons > speed. Died on a screen filled with bosstroids. |
| 5 |  |  | 11? | 0 | Yes, once | Score 12005. Died on a screen filled with bosstroids. This seems to be a theme. Maybe it’s a good point to challenge players? Seems like one game I got through this with shields and smart bomb. Maybe adjusting controls in HUD to maximize shields might get through? |

## Questions

### Difficulty

1. At what stage did it start to feel hard? Too early, too late, about right?

   Answer: Around stage 10. A screen full of super massive rocks fills the space and leaves little room to move. The large rocks take many hits and smart bomb is not effective. 

2. What usually ended your run?

   Answer: Crushed by rocks. A screen full of Bosstroids leaves no room for the ship. Sometimes a shield or shield and smart bond was able to pass this event. 

3. Does the ramp feel steady, or are there sudden jumps?

   Answer: Seems to ramp up more steeply after level 10 or 12. 

### Power HUD

4. Did you need the power HUD to survive? When did you open it, and what did you change?

   Answer: I played one game on default, another with weapons full, and another with speed full. I tried a couple other combination. The effects were not dramatic but noticeable. 

5. Did you change power between waves to suit the featured asteroid type?

   Answer: Not often but I did switch if it looked like I needed to change to survive. 

### Pickups and items

6. Are pickups rare enough now to be worth saving, or too rare?

   Answer: This is a good rarity. I found that if a space station was due and the level just ended it was disappointing to see some pickups on the screen disappear.

7. Did turrets and bases dropping items make you go after them?

   Answer: yes, I think this is a good idea. What if there were were special items that were only dropped by turrets?

### Steering

8. Is the drag lag noticeable? Does it feel like piloting, or just sluggish?

   Answer: Yes, could use fine tuning. 

9. Did engine power change how the ship handles enough to matter?

   Answer: yes.

### Shields

10. Starting empty and recharging slowly: fair, or too punishing early on?

    Answer: seems fair

### Stations

11. Does docking feel right now: clear screen, slower approach?

    Answer: better could use work. A screen might contain pickups at the end of a level, the station would show up and you wouldn’t get the pickups you could see, was frustrating. 

12. Did you have coins to spend, and anything worth buying?

    Answer: yes, i spent coins. 

## Summary (2026-10-05)

Five games on build 37. **"This is a better game"**, but the balance pass overshot: from stage 48 on 3 lives down to stages 7–13 with no lives left. Every run that ended in a known way ended at a screen full of bosstroids.

- **The wall at stage 10 is bosstroid waves.** From stage 6, 1 wave in 4 is all bosstroids, 120 pt across, so three fill the screen's width. Faster spawns, pairs from stage 9 and the speed ramp pack them in tighter. The smart bomb deals 10 damage over its shake, and a bosstroid takes 12, so it doesn't clear them.
- **The power HUD gets used now** (4 of 5 games), but the difference between levels is "noticeable, not dramatic". It needs to sit higher on the screen and be transparent.
- **Pickup rarity is right.** Pickups fading away when a station arrives is frustrating.
- **Turret and base drops work**; idea: special items only turrets drop.
- **Shields fair; docking better; coins spent; drag lag needs fine-tuning.**
- **New ideas:** the station screen should look different from the HUD; show stats at game over (stage reached, distance traveled, asteroids destroyed, turrets destroyed), with distance in the HUD too; a wider range of power-ups and ship modifications so players personalize their ships; if commerce is added, the difficulty has to leave room for it.

Changes are in [design-notes.md](design-notes.md#playtest-round-2-findings-2026-10-05). Round 3 is [playtest-round-3.md](playtest-round-3.md).

## General notes

Anything else: This is a better game. The difficulty ramps past level 10. If game play centers on flying the ship through asteroids this might be okay. If we add commerce and other ideas this might make it hard to complete the other tasks. 

A wider range of power ups and modifications to the ship would make the game more interesting. It might also increase engagement as players personalize their ships. 

The space station screen looks too much like the HUD. These should each have unique look to flavor the experience. 

The end screen should show the max level completed. We might also add a distance traveled through space. This might show up in the HUD, and could be shown at the end of the game. Other numbers might be good like number of asteroids destroyed or turrets neutralized. 

-
