# Playtest Notes

Phase 0 gate: the game runs on a real phone, and 10 full games have been played
with notes on what feels off. Log each game in the table, answer the questions
below as you go, then sum up patterns at the bottom. Numbers to adjust live in
`Asteroid Runner/Utilities/Tuning.swift`.

Device: iPhone 11 Pro, iOS 26.6.2

## Game log

| # | Date | Version | Stage reached | Score | Controls used | What felt off |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 10-5-26 |v2.0(35)| ~48| 117205 | Only the three power ups in the tray at the top. I didn’t need to adjust controls in the HUD. | Power ups come too often especially early on. Often there are too many power ups. Multi shot should show a number in the tray, currently multi might be 2 or 3 we can’t tell. Space station appears and ship flies to it, through everything that was currently on the screen. A wave should pass before the station appears. Multi shot is fun we need more variation on this theme that works through many levels of power. Tray at the top feels good for game play but not right theme or style of the game. Id like it to feel more like you were operating a ship rather than a cell phone. The HUD appears on a Swipe up. I like the swipe down, it should also slide down from the top of the screen and overlay the screen. Currently it feels like a modal dialog box. Should feel more like a Head Up Display, use to operate the ship. The game is too easy, I was able to get to level 31 with 3 lives. I am able to drag the ship with my finger, this wasn’t in the original game, it doesn’t feel like piloting the ship. It does make for more fun game play. This might be more interesting if the speed of the drag was affected by the speed of the ship.  |
| 2 | | | | | | |
| 3 | | | | | | |
| 4 | | | | | | |
| 5 | | | | | | |
| 6 | | | | | | |
| 7 | | | | | | |
| 8 | | | | | | |
| 9 | | | | | | |
| 10 | | | | | | |

## Questions

Things the simulator couldn't test. Answer in a few words; skip any that don't apply.

### Steering

1. Does tilt steering feel responsive, or floaty?

   Answer: Feels good

2. Does drag-to-steer feel better or worse than tilt?

   Answer: This makes fun game play. but doesn’t feel like piloting a ship, it negates the effects of setting speed. Might be better if the ship lagged behind your finger based on the speed setting. 

3. Do tilt and drag fight each other when used together?

   Answer: Not really. 

### Haptics

4. Do the ship-hit and powerup buzzes feel right, too strong, or too weak?

   Answer: Feels fine. We should add sound in the future. Add a note. 

### Difficulty

5. Which stage did you usually reach?

   Answer: 42 and still going. I think the combination of shields and drag steering are over powered, at least early on. 

6. Did any stage feel unfair or boring? Which one, and why?

   Answer: They all start to feel boring as the game progresses. The stages have the same quality. There is little variation. 

7. Is the difficulty ramp too fast, too slow, or about right?

   Answer: The difficulty range feels very narrow. 

### Asteroid types

8. Can you tell each type apart at a glance? Which ones are confusing?

   Answer: Mostly. 

9. Are glassteroids and blacksteroids hard to see in a fun way, or an annoying way?

   Answer: no opinion

10. Are turret and enemy base shots possible to dodge?

    Answer: Turrets are probably the most interesting game play element so far. 

### Effects

11. Did you see the gas explosion, glass shatter and ice shards? Do they read clearly?

    Answer: yes, mostly, art needs work. We will have a future art update. For now the placeholders are working. 

### Pacing

12. Is the stage announcement too long?

    Answer: no opinion

13. Is the wait for the screen to clear between stages too long?

    Answer: no opinion 

### Performance

14. Any stutter, especially with many asteroids or comet trails on screen?

    Answer: performance is good. 

### Item tray

17. Can you reach the tray at the top of the screen mid-flight without losing the ship?

    Answer: yes, the tray feels like using a cell phone interface rather than piloting a ship. Multi should show the number of of shots 2 or 3. So we can tell what we have. Multi shot is fun. We should develop a wide variety of these study the game Tyrian. 

18. Did you save items for a hard wave, or use them right away?

    Answer: yes but the items come too often and in large numbers I found myself using them as fast as possible to I could pick up more. 

19. Losing pickups when the tray is full: fair, annoying, or never noticed?

    Answer: A little since shields are not as fun to play with, if your tray is full of shields its not as fun and you have to wait for a shield to run out. hard to tell of some of these power ups stack for example two shields, or rapid and multi. 

20. Did you turn the shield off to save it?

    Answer: Not often. I tried it but the power ups come so often there was no need. I got to level 42 with 3 lives. 

### Stations

21. Did you have enough coins to buy something at most stations?

    Answer: I never spent any coins. We should add a sub game, take a note, where a player can buy raw materials or products at a station and sell these at other stations hopefully for a a profit. The command module holds a small amount of cargo. Cargo modules can be added to the ship. It might be better Only allow power ups to be bought at a station. As it is now there is no need to buy them, since there are so many available in space. 

22. Is the docking sequence too long, or did you skip it every time?

    Answer: Too fast. The screen should clear before docking. We might speed that part up. 

23. Did the "Station ahead" warning change what you did with your items?

    Answer: Station ahead warning is good will be better when stations are more a part of game play. 

24. Are the shop buttons easy to read and tap?

    Answer: no opinion. this will change in the future when stations are improved and expanded. 

### Pause

15. Leave the app mid-game and come back. Does it stay paused until you tap?

    Answer: good. 

### Power HUD

16. Did you open the power HUD (swipe up) without being reminded? When?

    Answer: I like swipe down. The HUD should overlay the screen as a transparent overlay. 

16a. Can you tell what each system does from how the ship feels?

    Answer: yeah I can tel the difference between systems. 

16b. Do the slowed time and locked steering feel fair, or frustrating?

    Answer: Feels fine, might make the game too easy. 

16c. Can you see your weapon level in the shots, and the sparks on hits?

    Answer: The weapons makes sense visibly. 

16d. Did the shield ring block hits you expected it to? Did you notice it recharge?

    Answer: Seems to work as expected. 

## Patterns

What came up in more than one game, and which numbers to change:

here are some general notes that repeat some of the answers above. some of these offer future ideas lets put these in the roadmap. \
\
Astervoids

- I notice I can steer the ship by dragging. This was not in the original game play. It is a good feature for players. It overrides the ship speed. 
- Ship speed seems good maybe we should split speed into to thrust and maneuver. Thrust is forward momentum. Get to the next station faster, move through asteroids fields faster. In some cases slower forward speed could be advantageous. Maneuver determines the side to side speed. Good for avoiding obstacles, and fighting alien bases. 
- Maybe the game is in system. Player travels from inner planets to outer planets at sub light speeds. 
- Encounters along the way. 
- Space stations and planets or stations orbiting planets or moons. Pickup supplies sell loot. 
    - Each station has a personality
    - Side effects of visiting a base might apply to future encounters? 
    - It is possible to buy products and raw materials at a base and sell or trade them at another base. This becomes cargo. The command module can carry a small amount of cargo. Cargo modules can be added to the ship. Space pirates (see below) can steal cargo.
    - It is possible for your 
- Loot comes too often and is too random
- HUD 
    - Better with a swipe down to show and a swipe up to put away. 
    - Maybe there are two panels left and right swipe left and right to reveal these
        - Weapons right? 
        - Shields left? 
- Waves/levels need to decide on an official name
    - Most often are rocks 
    - Sometimes a level is maze like. There are too many rocks that are too large but there is a path that can be navigated
    - There is a wave of fast moving asteroids that move straight down the screen forcing a player to choose lanes. 
    - Space pirates board your ship. They must be removed somehow. Maybe they appear in one of the HUD screens and must be manually removed? Space pirates enter the cargo bay and try to make off with cargo. 
    - Space Virus enters the HUD at a random place and starts to siphon energy. T must be removed manually.


### Summary (2026-10-05)

Build v2.0 (35), about 10 games. **Too easy and too samey: best run stage 48 on 3 lives, without needing the power HUD.** Pickups come too often to be worth saving, coins are never spent, and stages feel alike. Turrets and multi-shot are the most fun. The tray and power panel feel like a phone app rather than a ship's HUD. Findings and the changes they lead to are in [design-notes.md](design-notes.md#playtest-findings-2026-10-05).

Note: "It is possible for your" under stations is unfinished; add the rest when you remember it.
