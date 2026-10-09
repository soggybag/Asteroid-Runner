# Playtest Round 6: Ship Upgrades

Testing the ship upgrades sold at stations: reactor, cargo rack, hull
plating, thrusters, weapon focus and shield capacitor, kept for the rest of
the run. Round 5 found it got very hard around stages 18–20, and there was
nothing worth spending coins on to get further.
Earlier rounds: [1](playtest-notes.md), [2](playtest-round-2.md),
[3](playtest-round-3.md), [4](playtest-round-4.md), [5](playtest-round-5.md).

**Build:** v2.0 (56)
**Device:** iPhone 11 Pro

Upgrade prices and effects are in `Asteroid Runner/Utilities/Tuning.swift`
(`Upgrades`); which station sells which is in
`Asteroid Runner/Data/stations.json`.

## Game log

| # | Version | Score | Stage | Distance | Asteroids | Turrets | Upgrades bought | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 2.0 (56) | 6,645 | 10 | 1.26 | 278 | 2 | one | Seems harder now. Didn't really notice the upgrade |
| 2 | | 8,535 | 12 | 1.43 | 372 | 4 | | |
| 3 | | 13,075 | 14 | 1.56 | 483 | 5 | cargo rack, reactor | Bought as many upgrades as possible. The last stage, a bouncer swarm, was very hard. Difficulty seems to ramp up faster |
| 4 | | 9,100 | 10 | 1.16 | 336 | 2 | cargo rack | |
| 5 | | 10,930 | 13 | 1.49 | 393 | 7 | power upgrades only | Seemed effective, but still only stage 13 |

## Notes

- With a cargo rack upgrade, the tray at the top is too small. Rearrange the
  UI so items are easier to use.
- Levels seem to get harder faster than you can buy upgrades. Later, a map
  could let players choose where to go: explore easier regions before
  dangerous ones, and collect upgrades along the way.
- Instead of coins, some asteroids drop valuable ores you pick up and trade
  at stations. Different asteroid types hold different resources, and not
  every asteroid has any: you destroy them to find out. That gives
  destroying asteroids a point.
- Score seems pointless except to show how far you got. Distance could take
  its place.

## Summary (2026-10-09)

Five games on build 56: stages 10–14, best 14 (1.56 AU, 483 asteroids).
**Upgrades didn't carry anyone further, and the game felt harder.** The
ramp, wave mix and shooter tuning are the same as in round 5. Round 5 runs
ended at stages 9, 9, 12 and 20; round 6 runs at 10, 12, 14, 10 and 13. So
the average is about the same, but no run reached 20. The likely reason is
money: upgrades cost 15–70 coins and compete with items and repairs for the
same few coins. Buying upgrades leaves fewer items and repairs for the hard
stages. And the upgrades bought (one reactor unit, one tray slot) are hard
to feel.

**Fixed in the next build:**

- The tray had to shrink its slots to fit a cargo rack. It now has its own
  row just under the top strip, on the left, with coins and distance on the
  right. Slots stay full size with up to five.

**Still open:**

- **Upgrades should be felt.** One tier of most upgrades is a small change.
  Bigger steps, or a visible change on the ship, would help.
- **Coins vs. upgrades.** Not enough coins for upgrades, items and repairs.
  The ore idea below would change how money comes in.
- **The bouncer swarm** at stage 14 was very hard.
- **Direction:** ores that replace coins, distance in place of score, and a
  map that lets players choose easier regions first. These are in
  [design-notes.md](design-notes.md#playtest-round-6-findings-2026-10-09).
