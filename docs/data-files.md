# Data Files

The game reads its story, dialog and some tuning from files in
`Asteroid Runner/Data/`. You can edit them without touching the Swift code,
then build and run.

| File | What's in it |
| --- | --- |
| `intro.json` | The opening story lines, and how fast they show |
| `stations.json` | Station kinds: keepers, greetings and farewells, shops, upgrades; the made-up names for map stations |
| `map.json` | The system map: stations per region, routes per station, the first leg, each region's difficulty, the win bonus, and safe, normal and risky routes (stages, difficulty, loot) |

Each file explains its entries in comments at the top and next to them.

## The format: JSON with comments

The files are JSON, read as **JSON5**: plain JSON plus a few conveniences.

- `// a comment` to the end of the line, and `/* a comment */` anywhere.
- A trailing comma after the last item in a list or object is fine.
- Text goes in double quotes. Write `\"` for a quote inside text and `\n`
  for a line break.

```json5
{
  "routes": {
    // Shorter and harder, pays more
    "risky": {
      "minStages": 2,
      "maxStages": 3,
    },
  },
}
```

Why this format: Swift reads it with no extra library, and it's the
format the files already used. YAML reads more easily for long passages
but needs a library, and it's sensitive to indentation. If dialog grows
into big branching scenes, a dialog language like Ink or Yarn Spinner may
be worth a look then.

**Editors:** Xcode opens the files fine. In VS Code, choose "JSON with
Comments" or "JSON5" as the language (bottom right) so comments aren't
marked as errors. GitHub may show comments in red; that's only display.

## When something's wrong

- **A broken file** (a missing comma or quote) doesn't crash the game.
  `intro.json` falls back to one line, a broken `stations.json` means no
  stations, and a broken `map.json` falls back to numbers built into the
  code (`Tuning.Map.builtIn`), a copy of the file as first written. It's
  only a safety net: you don't need to update it when you change the file. Xcode's console prints the file
  and where it broke.
- **Run the tests** (⌘U) after an edit. `DataTests` and `StationTests` load
  every file and check its numbers make sense: stage ranges at least 1,
  chances from 0 to 1, risky paying more than safe, every region named
  (a misspelt region is caught), regions harder further out, enough map
  names.
- **Out-of-range numbers** are kept in range by the game: a pickup chance
  over 1 counts as 1, and a stage range below 1 becomes 1.

## Writing dialog

### Stations (now)

In `stations.json`, each station kind has:

- **greetings**: lines by situation, picked when the ship docks: damaged,
  low on fuel, carrying something wanted, a return visit, a first visit.
  Give a situation several lines and one is picked at random.
- **farewell**: lines said on launch.
- **personality** and **specialty**: notes for you on how the keeper
  talks. The first sentence of the specialty is shown on the map card.
- **conversation**: a branching talk, written but not used yet. Each node
  has the keeper's text and the player's options; an option leads to
  another node, or ends the talk.

Every station on the map is one of these kinds under a made-up name, so
all outposts share Mara Halden's lines for now. Giving each map station its
own keeper is a later step.

### Missions (proposed, not built)

Missions don't exist in the game yet. When they're built, their dialog
should go in a `missions.json` in the same style, so you can start writing
to this shape now:

```json5
{
  "missions": [
    {
      // Used by the code and saved games
      "id": "neptune-return",
      // Shown in the mission list
      "title": "The Long Way Home",
      // A note for the writer. Not shown in the game.
      "summary": "Carry the core from Neptune back to Earth without breaking it.",

      // Who gives it: a station kind, or a region
      "givenAt": { "region": "neptune" },

      // What the keeper says, at each point in the mission. Several lines
      // each, one picked at random, as with greetings.
      "offer": ["TODO: the keeper asks a favour."],
      "accept": ["TODO: the keeper hands over the cargo."],
      "decline": ["TODO: the keeper is disappointed."],
      "progress": ["TODO: a line at a station on the way."],
      "success": ["TODO: delivered."],
      "failure": ["TODO: the cargo broke."],

      // The goal and reward, filled in when missions are designed
      "goal": { "deliverTo": "earth" },
      "reward": { "coins": 50 },
    },
  ],
}
```

The goal and reward entries will change as missions are designed. The
dialog points (offer, accept, decline, progress, success, failure) are
the part worth writing to now.
