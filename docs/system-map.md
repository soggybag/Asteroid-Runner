# System Map Design

Draft, 2026-10-09. Not built yet. This expands the
[System map](design-notes.md#system-map-2026-10-05) idea in the design
notes, after playtest rounds 6 and 7.

**The map lets the player choose the next station, and that choice sets
how hard the next stretch is.** A safe route is longer, with easier stages
and less loot. A risky route is shorter, with harder stages and more loot.
Both take the ship the same distance outward.

## Why now

Rounds 6 and 7 raised four problems, and the map answers each one:

| From playtests | How the map answers it |
| --- | --- |
| Difficulty climbs faster than you can buy upgrades (round 6) | Take a safe route to earn coins and fit upgrades before a hard region |
| Upgrades not felt; coins split three ways (round 6) | Risky routes pay more, so there's a way to earn more |
| A map with easier and harder regions (round 6 idea) | This is that map |
| Maybe the whole game should play slower (round 7 idea) | Players who want it slower take safe routes; the game doesn't have to slow down for everyone |

It also gives distance a meaning (it's how far out you are), sets up trade
(stations differ in what they sell), and gives a run a goal.

## How it works

### The voyage outward

The solar system is a ladder of **regions**, from the sun outward:

| # | Region | Feel |
| --- | --- | --- |
| 1 | Earth and Moon | Start. Plain rock fields |
| 2 | Mars | Swarms, fast movers |
| 3 | Main belt | Heavy rocks, mazes, lanes |
| 4 | Jupiter | Shooters, bouncers |
| 5 | Saturn | Bosstroid fields, rings as lanes |
| 6 | Uranus | Everything, harder |
| 7 | Neptune | Everything, hardest. Reaching it wins the run |
| ← | Back inward | After the win, the return mission (see After Neptune) |

Each region has 2–3 stations with made-up names; regions keep their
planet names. The regions are the same every run; the stations and routes
are new each run. At every station, the map offers **2 or 3
routes**, each to a station in the next region out. You can't go back
toward the sun in the first version.

Six legs from Earth to Neptune, at about 3–4 stages each, is a run of
20–25 stages. That's about where good runs end today, so reaching Neptune
should be hard but possible.

### Difficulty comes from the region, not the stage count

Today, difficulty is the stage number, eased for a few stages after each
station (`Tuning.Pacing`). With the map:

- **Each region has a base difficulty.** Region 1 is about today's stage 1;
  region 7 is about today's stage 25.
- **A route's danger shifts it:** safe −2, normal 0, risky +2.
- **Within a leg, difficulty ramps** from the region's base to the next
  region's, as `legProgress` does today.
- **The stage number becomes a count,** shown in the briefing ("Stage 2 of
  4 to Gannet Yard"). Distance in AU replaces score as the measure of a run.

| Route | Stages | Danger | Loot |
| --- | --- | --- | --- |
| Safe | 4–5 | −2 | Fewer coins and pickups |
| Normal | 3–4 | 0 | As today |
| Risky | 2–3 | +2 | More coins, items more likely; later, rich ore |

A safe route means more stages at a gentler ramp, so more time to use the
HUD, earn coins and try upgrades. That's the "slower game," for the players
who choose it.

### Route hints

When the ship launches, the map plans each route's waves in advance,
instead of picking each wave as it starts. So the map can show:

- **How many stages**, and the danger as 1–3 marks.
- **Icons for the wave types on the way:** rocks, swarm, maze, lanes,
  shooters, bouncers, bosstroids. Not the order.
- **The destination:** its name, kind (outpost, depot, black market) and
  what it sells, including upgrades.

The scanner briefing still shows each wave in detail as it comes. Later, a
sensor upgrade could show more on the map: the order of the waves, the
featured asteroid types, or pirates.

### The screen

Portrait, with the sun at the bottom and Neptune at the top, so the ship
flies up the map the same way it flies up the screen.

```
┌──────────────────────────────────┐
│ NEPTUNE   ·                      │
│ URANUS    ·                      │
│ SATURN    ·                      │
│ JUPITER   ·   ◌         ◌        │
│ MAIN BELT ·   ◌ Gannet  ◌ Kestrel│  ← 2 routes: tap one
│                  ╲     ╱         │
│ MARS      ·    ◎ Bastion Seven   │  you are here
│ EARTH     ·    ✓ Halden's Rock   │
│      ☀                           │
├──────────────────────────────────┤
│ To Gannet Yard · outpost         │
│ 4 stages · Danger ▲ · Loot ◆     │
│ ● rock field  ● swarm  ▦ maze    │
│ Sells: shields, bombs, reactor   │
│          [ Set course ]          │
└──────────────────────────────────┘
```

- **When it shows:** after Launch at a station. Tap a route to see its
  card, then Set course. The first leg, from Earth, is fixed so the game
  starts right away.
- **Stations further out** show as unnamed dots, so the player sees how far
  there is to go.
- It uses the station screen's look (navy and station blue).

### Stations

Three stations exist today (Halden's Rock, Bastion Seven, The Lucky
Drift). A map with 2–3 per region needs 15–20. In the first version, each
of the three becomes a **kind** (outpost, depot, black market) with its
shop and upgrades. Each map station is a named station of one kind, with
its own name and keeper. Names and keepers are placeholders in
`stations.json` until you write them.

### After Neptune: the return mission

Idea, 2026-10-09. Not part of the first version of the map.

**Reaching Neptune wins the run, and then comes a surprise:** the Neptune
station keeper offers a mission back to the inner system. Nothing before
Neptune mentions it. The win screen shows first, so a player who stops
there has still won. Accepting the mission is the second act.

Two things make the trip home play differently from the trip out:

- **You carry something fragile home.** A sample, a passenger or an
  unstable core takes tray slots or reactor power, and hits damage it. If
  it's destroyed, the mission fails. The run has taught you to shoot
  everything; now dodging matters more than shooting, and engines and
  shields matter more than weapons.
- **The system has changed while you were out.** Stations you visited on
  the way out react to you: one is gone, one has turned hostile, one
  remembers that you helped it, and prices have moved. The map keeps your
  outward run, so earlier choices come back. This builds on new stations
  and routes each run: every run's return is different.

**Length:** out and back would be 40–50 stages, too long for a phone. The
return is shorter: about three legs that skip regions, each harder than
the way out.

**Later twist:** something woken at Neptune follows the ship inward on the
map, so long, safe routes let it catch up.

**Open:** what the cargo is and how it's damaged (a meter, or a hit
count); what reaching home gives (a bigger win, an unlock for the next
run); and whether the Kuiper belt as endless play still has a place.

## Building it

Each step can be played on its own:

1. ~~**Plan legs in advance.**~~ Done 2026-10-09. `StationRoute` plans a
   leg's waves (`legWaves`) when it picks the next station, not as each
   wave starts. No visible change; tests check the plans follow today's
   rules.
2. ~~**Regions and routes.**~~ Done 2026-10-09. `SystemMap.swift`: seven
   regions, 2–3 stations in each (a station kind under a made-up name from
   `mapNames` in `stations.json`), 2–3 routes per station, each with a
   danger and length. A new map each run. Difficulty ramps from the region
   a leg leaves to the one it reaches, eased after a station and shifted
   by danger; numbers in `Tuning.Map`. Past Neptune, legs stay at Neptune
   and get harder until the win screen exists. **Until the map screen, the
   game takes the normal route,** so danger can't be seen in play yet.
   Every station of a kind shares its keeper and greetings for now.
3. **The map screen** after Launch, with route cards and Set course. Scanner
   briefing shows "Stage 2 of 4 to …".
4. **Loot by danger:** coins and pickup chance scaled by route danger.
5. **Reaching Neptune** wins the run: a win screen with distance, stages
   and stations visited. The return mission comes later (see After
   Neptune).
6. **Playtest.**

Ores, trade goods and missions come after this. Rich and poor routes are
where ores will come in.

## Open questions

- [x] Does a run end at Neptune? **Yes, reaching Neptune wins** (2026-10-09).
- [x] After the win? **A surprise return mission to the inner system,
      carrying something fragile through a system that has changed**
      (2026-10-09). Endless play in the Kuiper belt is set aside for now.
- [ ] Can the player go back toward the sun? Proposed: not in the first
      version.
- [x] Same map every run? **Same regions, new stations and routes each
      run** (2026-10-09).
- [ ] Is 2–3 routes per station enough choice?
- [ ] Danger as marks (▲▲▲), or words (safe, risky)?
- [ ] Does the first leg from Earth stay fixed, or start with the map?
- [x] Station names: **made-up** (2026-10-09). Regions keep their planet
      names (Mars, Jupiter).
