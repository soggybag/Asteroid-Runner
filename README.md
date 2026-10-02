# Astervoids

Built with SpriteKit. 

Fly through asteroids, try not to get hit. You have three lives; after a hit
the ship blinks and can't be hit again for a moment. Survive a stage for a
bonus. Stages get harder as you go: bigger, faster asteroids, more often.

Requires Xcode 15+ and iOS 17+.

## Controls

- Drag anywhere to steer, or tilt the phone.
- The ship fires automatically. Turn Auto Fire off in the config panel to
  tap to fire instead.
- Tap during the intro to skip it.
- The game pauses when the app goes to the background. Tap to resume.

## Configure your ship

Swipe down to show the ship configuration screen. Here you can choose one of three
ship configuration schemes. 

- Speed > Power - Moves faster shots are weaker
- Speed = Power - Speed and weapon are average
- Speed < Power - Moves slower, weapon is more powerful

In the future this screen will represent power allocation inthe ship for more 
complex and detail configuration. 

Swipe up to dismiss this menu. 

## Asteroid types

Stage 1 is plain rocks. Each stage after that introduces a new type, announced
before the wave ("Watch for: Comets"). Once all have appeared, each wave
features a random one.

| Stage | Type | Behavior |
|---|---|---|
| 2 | Low mass | Every shot knocks it back up the screen |
| 3 | Glassteroid | Nearly transparent, shatters in one hit |
| 4 | Blacksteroid | Dark, hard to see against space |
| 5 | Icestroid | Bursts into sharp ice shards that can hit you |
| 6 | Comet | Small and fast, streaks in diagonally with a tail |
| 7 | Gasteroid | Explodes, damaging nearby rocks and the ship if it's close |
| 8 | Elastroid | Bounces off the screen edges three times |
| 9 | Brasserteroid | Super massive and tough, missiles don't push it |
| 10 | Turret | Fires aimed shots at the ship |
| 11 | Enemy base | Big, slow and armored, fires a three-shot spread |

Rocks break into smaller rocks when hit enough. Special types are worth more
points. The shield blocks enemy shots. Gold coins are worth 250 points.

## Todo

Add new Powerups: 
 
 1. Smart Bomb - Tapping asteroids destroys them
 2. Smarter Bomb - Destroys all asteroids on screen
 3. Coins - gain extra points
 4. Missile PU - Missiles do more damage
 5. Shield - Puts up a shield for limited time
 6. Rapid fire - Fires alot
 7. Scatter Gun - Fires in all directions
 8. Time Dilation - Slows the game
 9. Time Expansion - Speeds the game
 10. Shrinker - ...
 11. Manuever Jets - Makes controling the easier
 
 Add game play features 
 
 1. ~~Lives - Classic three lives~~ Done
 2. Shield - deflects an asteroid, wears down over time, or with each hit
 3. Armor - protects from one hit, no life lost
 4. Asteroids break when hit - Depending on size a number of hits will break an asteroid into two or more smaller asteroids
 5. Waves - Asteroids appear in waves of similar types
 6. Coins appear in special coin wave

Art and effects

1. ~~Starfield background~~ Done
2. Shots produce small exposition
