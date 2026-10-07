//
//  Wave.swift
//  Asteroid Runner
//

// What each wave throws at the player. A wave follows a recipe (a swarm
// of tiny rocks, fast movers to dodge, a maze to weave through) and a
// difficulty that eases just after a station and builds toward the next.
// Unlock stages, weights and pacing numbers are in Tuning.Waves and
// Tuning.Pacing.

import CoreGraphics
import Foundation

enum WaveLayout {
  // Rocks arrive one at a time from the wave's direction
  case scatter
  // Fast rocks straight down a few lanes; the safe lanes change
  case lanes
  // Rows of unbreakable rocks with a gap that wanders
  case maze
}


enum WaveRecipe: CaseIterable {
  case field, swarm, fastMovers, heavy, lanes, maze, bouncers, bosstroidField

  var name: String {
    switch self {
    case .field: return "Rock field"
    case .swarm: return "Swarm"
    case .fastMovers: return "Fast movers"
    case .heavy: return "Heavy rocks"
    case .lanes: return "Lanes"
    case .maze: return "Asteroid maze"
    case .bouncers: return "Bouncers"
    case .bosstroidField: return "Bosstroid field"
    }
  }

  // What the scanner suggests setting in the power HUD
  var advice: String {
    switch self {
    case .field: return "Balanced power"
    case .swarm: return "Weapons up"
    case .fastMovers: return "Engines up, dodge"
    case .heavy: return "Weapons up"
    case .lanes: return "Engines up, pick a lane"
    case .maze: return "Engines up, find the gap"
    case .bouncers: return "Shields up"
    case .bosstroidField: return "Shields up, save a bomb"
    }
  }

  var adviceSystem: ShipSystem? {
    switch self {
    case .field: return nil
    case .swarm, .heavy: return .weapons
    case .fastMovers, .lanes, .maze: return .engines
    case .bouncers, .bosstroidField: return .shields
    }
  }

  var layout: WaveLayout {
    switch self {
    case .lanes: return .lanes
    case .maze: return .maze
    default: return .scatter
    }
  }

  // Hard recipes only come in the second half of the run to a station
  var isHard: Bool {
    switch self {
    case .maze, .bouncers, .bosstroidField: return true
    default: return false
    }
  }

  // Whether the wave's featured asteroid type mixes in
  var usesFeatured: Bool {
    switch self {
    case .field, .swarm, .heavy: return true
    default: return false
    }
  }

  // Multiplies the time between spawns
  var spacing: TimeInterval {
    switch self {
    case .field: return 1
    case .swarm: return 0.45
    case .fastMovers: return 1.1
    case .heavy: return 1.3
    case .bouncers: return 2.2
    case .bosstroidField: return 0.7
    case .lanes, .maze: return 1  // set by their own layout
    }
  }

  // Multiplies the wave's length
  var durationScale: Double {
    switch self {
    case .maze: return 1.2
    case .bosstroidField, .bouncers: return 0.8
    default: return 1
    }
  }

  // Sizes in the wave, with weights. Every scatter wave mixes sizes.
  func sizes(difficulty: Int) -> [(size: AsteroidSize, weight: Int)] {
    switch self {
    case .field:
      return AsteroidSize.pool(forLevel: difficulty).map { ($0, 1) }
    case .swarm:
      return [(.tiny, 5), (.small, 4), (.average, 1)] + (difficulty >= 6 ? [(.large, 1)] : [])
    case .fastMovers:
      return [(.tiny, 2), (.small, 3), (.average, 2)]
    case .heavy:
      return [(.average, 1), (.large, 3), (.huge, 2)] + (difficulty >= 8 ? [(.massive, 1)] : [])
    case .lanes:
      return [(.small, 1), (.average, 2)]
    case .maze:
      return [(.large, 1)]
    case .bouncers:
      return [(.small, 2), (.average, 2), (.large, 1)]
    case .bosstroidField:
      return [(.tiny, 5), (.small, 3), (.bosstroid, 1)]
    }
  }

  func speed(difficulty: Int) -> AsteroidSpeed {
    switch self {
    case .fastMovers: return difficulty >= 5 ? .veryFast : .fast
    case .heavy: return difficulty >= 6 ? .fast : .average
    case .bouncers: return .average
    default: return AsteroidSpeed.random(forLevel: difficulty)
    }
  }

  var unlockStage: Int {
    return Tuning.Waves.unlockStage(self)
  }


  // Pick the recipe for a stage. `progress` runs from 0 just after a
  // station to 1 on the last wave before the next.
  static func choose(stage: Int, progress: Double, previous: WaveRecipe?) -> WaveRecipe {
    if stage <= Tuning.Waves.fieldOnlyThrough {
      return .field
    }

    // A stage that debuts a new asteroid type shows it off in a wave
    // that uses the featured type
    let debut = stage - 2 < AsteroidType.unlockOrder.count

    let choices = allCases.filter { recipe in
      recipe.unlockStage <= stage
        && (!recipe.isHard || progress >= Tuning.Pacing.hardFrom)
        && (recipe == .field || recipe != previous)
        && (!debut || recipe.usesFeatured)
    }
    let total = choices.reduce(0) { $0 + Tuning.Waves.weight($1) }
    var roll = Int.random(in: 0 ..< max(total, 1))
    for recipe in choices {
      let weight = Tuning.Waves.weight(recipe)
      if roll < weight {
        return recipe
      }
      roll -= weight
    }
    return .field
  }
}


// One wave, ready to spawn

struct WavePlan {

  let recipe: WaveRecipe
  let stage: Int
  // The stage number the ramp uses, eased after a station
  let difficulty: Int
  let featured: AsteroidType
  let speed: AsteroidSpeed
  let direction: AsteroidDirection
  let sizes: [(size: AsteroidSize, weight: Int)]

  static func make(stage: Int, progress: Double, previous: WaveRecipe?) -> WavePlan {
    let difficulty = Tuning.Pacing.difficulty(stage: stage, progress: progress)
    let recipe = WaveRecipe.choose(stage: stage, progress: progress, previous: previous)
    return WavePlan(recipe: recipe, stage: stage, difficulty: difficulty,
                    featured: AsteroidType.featured(forLevel: stage),
                    speed: recipe.speed(difficulty: difficulty),
                    direction: recipe == .fastMovers ? .top : AsteroidDirection.random(),
                    sizes: recipe.sizes(difficulty: difficulty))
  }

  // Seconds between spawns, before size spacing
  var baseInterval: TimeInterval {
    return Tuning.Stages.spawnInterval(level: difficulty) * recipe.spacing
  }

  var duration: TimeInterval {
    return Tuning.Stages.waveDuration(level: difficulty) * recipe.durationScale
  }

  var speedScale: CGFloat {
    return Tuning.Stages.speedScale(level: difficulty)
  }

  var smallest: AsteroidSize {
    return sizes.map(\.size).min { $0.rawValue < $1.rawValue } ?? .average
  }

  var largest: AsteroidSize {
    return sizes.map(\.size).max { $0.rawValue < $1.rawValue } ?? .average
  }

  func randomSize() -> AsteroidSize {
    let total = sizes.reduce(0) { $0 + $1.weight }
    var roll = Int.random(in: 0 ..< max(total, 1))
    for entry in sizes {
      if roll < entry.weight {
        return entry.size
      }
      roll -= entry.weight
    }
    return sizes.first?.size ?? .average
  }

  // A rock's type: bouncers are all elastroids; some recipes mix in the
  // featured type, more of it in later stages
  func randomType() -> AsteroidType {
    if recipe == .bouncers {
      return .elastic
    }
    guard recipe.usesFeatured else { return .normal }
    return Double.random(in: 0 ..< 1) < featuredShare ? featured : .normal
  }

  // Share of rocks that are the featured type: grows in later stages, up
  // to a cap per type
  var featuredShare: Double {
    let share = featured.waveShare * Tuning.Stages.featuredScale(level: difficulty)
    return min(share, featured.maxWaveShare)
  }


  // MARK: Scanner advice

  // What to set in the power HUD for this wave. Shooters call for
  // shields; a fast rock field for weapons; otherwise the recipe's own.
  var advice: (text: String, system: ShipSystem?) {
    if recipe.usesFeatured && featured.entersFromTop {
      return ("Shields up, take out the shooters", .shields)
    }
    if recipe == .field && (speed == .fast || speed == .veryFast) {
      return ("Weapons or shields up", .weapons)
    }
    return (recipe.advice, recipe.adviceSystem)
  }

  var pairChance: Double {
    return recipe.layout == .scatter ? Tuning.Stages.pairChance(level: difficulty) : 0
  }


  // MARK: Scanner

  // Which way blips cross the scanner: the way the wave's rocks travel
  static func scannerHeading(_ wave: WavePlan) -> CGVector {
    guard wave.recipe.layout == .scatter else { return CGVector(dx: 0, dy: -1) }
    switch wave.direction {
    case .left: return CGVector(dx: 0.8, dy: -0.6)
    case .right: return CGVector(dx: -0.8, dy: -0.6)
    default: return CGVector(dx: 0, dy: -1)
    }
  }

  // Where a blip starts: on the edge the wave comes from. Lanes start in
  // columns, maze rows in a line with a gap.
  static func scannerStart(_ wave: WavePlan, index: Int, count: Int, radius r: CGFloat) -> CGPoint {
    let spread = CGFloat(index) / CGFloat(max(count - 1, 1))
    switch wave.recipe.layout {
    case .lanes:
      let lane = CGFloat(index % Tuning.Waves.laneCount)
      let x = -r * 0.6 + lane * (r * 1.2 / CGFloat(Tuning.Waves.laneCount - 1))
      return CGPoint(x: x, y: r * 0.75)
    case .maze:
      // Leave a gap in the middle of the row
      let x = -r * 0.8 + spread * r * 1.6
      return CGPoint(x: abs(x) < r * 0.2 ? x + r * 0.4 : x, y: r * 0.55)
    case .scatter:
      switch wave.direction {
      case .left: return CGPoint(x: -r * 0.85, y: -r * 0.4 + spread * r * 0.8)
      case .right: return CGPoint(x: r * 0.85, y: -r * 0.4 + spread * r * 0.8)
      default: return CGPoint(x: -r * 0.6 + spread * r * 1.2, y: r * 0.75)
      }
    }
  }


  // MARK: Lanes

  // Center of a lane, counting from the left
  static func laneX(_ lane: Int, width: CGFloat) -> CGFloat {
    let count = CGFloat(Tuning.Waves.laneCount)
    return width * (CGFloat(lane) + 0.5) / count
  }

  // A new set of lanes with rocks in them, never all of them
  static func activeLanes() -> [Int] {
    let all = Array(0 ..< Tuning.Waves.laneCount)
    return Array(all.shuffled().prefix(Tuning.Waves.activeLanes))
  }


  // MARK: Maze

  // Where the next row's gap is centered: a step left or right of the
  // last one, always fully on screen
  static func nextMazeGap(after center: CGFloat, width: CGFloat) -> CGFloat {
    let half = Tuning.Waves.mazeGap / 2 + 10
    let step = Tuning.Waves.mazeGapStep
    let next = center + CGFloat.random(in: -step ... step)
    return min(max(next, half), width - half)
  }

  // X positions for one maze row's rocks, leaving the gap clear. The
  // rocks are nudged and turned a little when placed (see GameScene), so
  // they keep `mazeClearance` extra room from the gap.
  static func mazeRow(gapCenter: CGFloat, width: CGFloat) -> [CGFloat] {
    let rock = AsteroidSize.large.rawValue * 2
    let step = rock + 4
    let margin = Tuning.Waves.mazeClearance
    let gapLeft = gapCenter - Tuning.Waves.mazeGap / 2
    let gapRight = gapCenter + Tuning.Waves.mazeGap / 2
    var xs = [CGFloat]()
    var x = rock / 2
    while x - rock / 2 < width {
      if x + rock / 2 + margin <= gapLeft || x - rock / 2 - margin >= gapRight {
        xs.append(x)
      }
      x += step
    }
    return xs
  }
}
