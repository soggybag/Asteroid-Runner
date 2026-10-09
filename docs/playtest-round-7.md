# Playtest Round 7: Tray Row

The second round on build 56, after round 6 found upgrades weren't felt
and the game seemed harder. The item tray now has its own row under the
top strip.
Earlier rounds: [1](playtest-notes.md), [2](playtest-round-2.md),
[3](playtest-round-3.md), [4](playtest-round-4.md), [5](playtest-round-5.md),
[6](playtest-round-6.md).

**Date:** 2026-10-09
**Build:** v2.0 (56)

## Game log

| # | Version | Score | Stage | Distance | Asteroids | Turrets | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 2.0 (56) | 5,215 | 9 | 0.95 | 205 | 0 | Tried buying engine upgrades |
| 2 | | 5,615 | 9 | 1.01 | 266 | 0 | The swarm stage was really tough at stage 9; might be too hard so early |
| 3 | | 5,750 | 9 | 0.98 | 265 | 0 | Swarm at stage ~6 was very hard, swarm at stage 9 also very hard |
| 4 | | 4,245 | 9 | 1.02 | 133 | 0 | Lost again at the stage 9 swarm |
| 5 | | 29,360 | 24 | 2.91 | 1,060 | 7 | Made it to the new maze stage. Changed the power settings in the HUD for each stage, and that helped. Overwhelmed on the last swarm stage; maybe fast bouncers? |

## Notes

- The maze's staggered blocks look better. Stagger them up and down too, to
  look more organic.
- **Maybe the whole game should play slower.** That gives players time to
  use upgrades and work the HUD and ship systems, and stretches out the
  game so tougher stages come later. The risk is early stages feel slow.
- A stage of lightweight asteroids might be interesting. Their physics is a
  little different.

## Summary (2026-10-09)

Five games on build 56: four ended at the stage 9 swarm, one reached stage
24 (2.91 AU, 1,060 asteroids), the best since round 4. **The stage 9 swarm
is a wall.** The one long run changed the HUD power settings every stage,
which is the game working as intended.

**Why stage 9:** every stage up to 11 introduces a new asteroid type, and
that stage's wave must use it, so it's a field, swarm or heavy wave. Stage 9
introduces brasserteroids, which are always large and take three times the
hits. A swarm was spacing its spawns as if each rock were tiny, so a stage
9 swarm sent large, armored rocks at the rate of tiny ones. Stage 6 swarms
were already hard because large rocks joined swarms from stage 6, at up to
very fast speed.

**Fixed in the next build:**

- **Spawn spacing goes by a rock's real size.** A brass rock in a swarm now
  takes the time of a large rock, not a tiny one. This also applies to rock
  fields.
- **Gentler swarms:** 33% longer between spawns (0.6 of a field's spacing,
  was 0.45), never very fast, and large rocks only from stage 10 (was 6).
- **Maze rocks stagger up and down** by up to 30 points (was 12).

**Still open:**

- **Slow the whole game down?** See
  [design-notes.md](design-notes.md#playtest-round-7-findings-2026-10-09).
  The swarm changes are a small step that way. Worth playing them first.
- **The last swarm at stage 24** was overwhelming, maybe with elastroids
  (bouncers) as the featured type. Watch for it.
- **A lightweight asteroid stage:** a wave recipe of low-mass rocks.
- **Upgrades and coins** (from round 6): runs 1–4 ended at stage 9, too
  early to say anything new.
