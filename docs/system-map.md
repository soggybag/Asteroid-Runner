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

Each region has 2–3 stations. At every station, the map offers **2 or 3
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
  4 to Ceres Yard"). Distance in AU replaces score as the measure of a run.

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
│ MAIN BELT ·   ◌ Ceres   ◌ Vesta  │  ← 2 routes: tap one
│                  ╲     ╱         │
│ MARS      ·    ◎ Bastion Seven   │  you are here
│ EARTH     ·    ✓ Halden's Rock   │
│      ☀                           │
├──────────────────────────────────┤
│ To Ceres Yard · outpost          │
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

## Building it

Each step can be played on its own:

1. **Plan legs in advance.** `StationRoute` holds a leg's waves planned at
   launch, not chosen as each wave starts. No visible change; tests check
   the plans match today's rules.
2. **Regions and routes.** A map model: regions, stations placed in them,
   2–3 routes per station with length and danger. Generated per run.
   Difficulty from region and danger. Tests.
3. **The map screen** after Launch, with route cards and Set course. Scanner
   briefing shows "Stage 2 of 4 to …".
4. **Loot by danger:** coins and pickup chance scaled by route danger.
5. **Reaching Neptune** ends the run with a win screen (distance, stages,
   stations visited). Endless play beyond it can come later.
6. **Playtest.**

Ores, trade goods and missions come after this. Rich and poor routes are
where ores will come in.

## Open questions

- [ ] Does a run end at Neptune (a win), or go on forever? Proposed: win at
      Neptune; maybe an endless mode later.
- [ ] Can the player go back toward the sun? Proposed: not in the first
      version.
- [ ] Same map every run, or a new one each run? Proposed: same regions,
      new stations and routes each run.
- [ ] Is 2–3 routes per station enough choice?
- [ ] Danger as marks (▲▲▲), or words (safe, risky)?
- [ ] Does the first leg from Earth stay fixed, or start with the map?
- [ ] Real place names (Ceres, Titan) for stations, or made-up ones?
