//
//  Tuning.swift
//  Asteroid Runner
//

// Every gameplay number worth tuning, in one place. Change a value, rebuild
// and play. Per-type asteroid stats (toughness, points, wave share) live in
// AsteroidType.swift. Visual details stay with the code that draws them.

import CoreGraphics
import Foundation

enum Tuning {

  // MARK: Player

  enum Player {
    static let startingLives = 3
    // Blinking, can't be hit, after losing a life
    static let invulnerableTime: TimeInterval = 2
    // Accelerometer tilt to steering force
    static let tiltForce: CGFloat = 100
  }


  // MARK: Power
  //
  // The reactor's units are shared between engines, shields and weapons.
  // Tables are indexed by a system's power level, 0 ... maxLevel.

  enum Power {
    static let reactorUnits = 6
    static let maxLevel = 4
    static let startingLevel = 2

    // Game speed while the power HUD is open
    static let hudTimeScale: CGFloat = 0.25

    // Engines: tilt steering force and drift damping, and how fast the
    // ship can follow a dragging finger, in points per second
    // High engine power maneuvers much faster, so it can dodge turret fire
    static let engineTilt: [CGFloat] = [0.05, 0.12, 0.25, 0.5, 0.85]
    static let engineDamping: [CGFloat] = [0.25, 0.35, 0.5, 0.75, 1]
    static let engineDragSpeed: [CGFloat] = [100, 180, 300, 500, 800]

    // Reactor units used to reach each level. The top two weapons levels
    // cost 2 units each, so maxing weapons takes the whole reactor.
    static func levelCost(_ system: ShipSystem) -> [Int] {
      switch system {
      case .weapons: return [0, 1, 2, 4, 6]
      default: return [0, 1, 2, 3, 4]
      }
    }

    // Weapons: seconds between shots, damage per hit, and missile mass
    // (how hard a shot pushes an asteroid). Level 0 is the Command
    // module's weak trickle shot.
    static let weaponFireTime: [TimeInterval] = [0.7, 0.45, 0.3, 0.2, 0.12]
    static let weaponDamage: [CGFloat] = [0.5, 1, 2, 3, 4]
    static let weaponMass: [CGFloat] = [0.001, 0.00125, 0.0025, 0.004, 0.005]

    // Shields: charges held at each level (each blocks one hit), and seconds
    // to rebuild one charge. The shield starts each game empty.
    static let shieldCapacity: [Int] = [0, 1, 1, 2, 3]
    static let shieldRecharge: [TimeInterval] = [0, 22, 15, 10, 6]
    // Blinking, can't be hit, after the shield blocks a hit
    static let shieldHitInvulnerable: TimeInterval = 1

    static func shieldRechargeTime(level: Int) -> TimeInterval {
      return shieldRecharge[min(max(level, 1), maxLevel)]
    }

    // Read a table safely at a level
    static func value<T>(_ table: [T], level: Int) -> T {
      return table[min(max(level, 0), table.count - 1)]
    }
  }


  // MARK: Weapons

  enum Weapons {
    // Rapid fire multiplies the time between shots by this
    static let rapidFireFactor: TimeInterval = 0.5

    static let missileSpeed: CGFloat = 300
  }


  // MARK: Powerups and coins

  enum PowerUps {
    // How long multi-shot and rapid fire last
    static let duration: TimeInterval = 10
    static let fallSpeed: CGFloat = 25

    // The smart bomb shakes the screen in pulses, damaging every rock each
    // pulse. 10 pulses of 2 breaks a bosstroid (12 hits).
    static let bombPulses = 10
    static let bombDamage: CGFloat = 2

    static let points = 100
    static let coinPoints = 250

    // Chance that a spawn is a pickup instead of a rock. Was 24%.
    static let pickupChance = 0.06

    // At most this many items (bomb, shield, multi-shot, rapid fire) drift
    // in per wave. Points and coins don't count. Items dropped by destroyed
    // turrets and bases don't count either.
    static let maxItemsPerWave = 2

    // How often each pickup turns up, relative to the others
    static let weights: [(pickup: Pickup, weight: Int)] = [
      (.points, 3), (.coin, 3), (.multiShot, 2), (.rapidFire, 2), (.bomb, 1), (.shield, 1)
    ]
  }


  // MARK: Item tray

  enum Items {
    // Pickups the player can carry. A full tray loses new pickups.
    static let slots = 3
    // Seconds of shield in one pickup. It only drains while it's up.
    static let shieldCharge: TimeInterval = 12
    // The shield flickers when this many seconds are left
    static let shieldWarning: TimeInterval = 2
  }


  // MARK: Stations and coins

  enum Stations {
    // A station comes after a random number of waves in this range
    static let minWaves = 1
    static let maxWaves = 5

    // Coins for picking up a coin, and for clearing a stage
    static let coinPickup = 5
    static let stageClearCoins = 3

    // Base prices in coins. Each station's multipliers adjust them.
    static func price(_ item: ItemType) -> Int {
      switch item {
      case .bomb: return 10
      case .shield: return 8
      case .multiShot: return 6
      case .rapidFire: return 6
      }
    }
    // Selling gets this share of the base price, before the station's multiplier
    static let resaleShare = 0.5
    // Repairing one point of damage (one lost life, until modules)
    static let repairPrice = 15

    // Before a station, wait up to this long for the screen to clear
    static let maxClearWait: TimeInterval = 20

    // Docking and launching animations, in seconds. The station arrives in
    // the first part, then the ship flies up to it.
    static let dockTime: TimeInterval = 5
    static let launchTime: TimeInterval = 1.5
  }


  // MARK: Waves
  //
  // Each wave follows a recipe; see Wave.swift for what each one holds.

  enum Waves {
    // Early stages are plain rock fields while the player learns
    static let fieldOnlyThrough = 2

    static func unlockStage(_ recipe: WaveRecipe) -> Int {
      switch recipe {
      case .field: return 1
      case .swarm: return 3
      case .fastMovers: return 4
      case .heavy: return 6
      case .lanes: return 7
      case .bouncers: return 8     // elastroids debut at stage 8
      case .bosstroidField: return Hazards.bosstroidFromLevel
      case .maze: return 9
      }
    }

    // How often each recipe is picked, relative to the others
    static func weight(_ recipe: WaveRecipe) -> Int {
      switch recipe {
      case .field: return 3
      case .swarm, .fastMovers, .heavy: return 2
      case .lanes, .maze, .bouncers, .bosstroidField: return 1
      }
    }

    // Lanes: how many, how many have rocks at once, the gap between
    // rocks, and how many rocks before the busy lanes change
    static let laneCount = 4
    static let activeLanes = 2
    static let laneGap: TimeInterval = 0.32
    static let laneSwitchEvery = 10
    static let laneSpeed: CGFloat = 230

    // Maze: seconds between rows, width of the way through, how far the
    // gap can move from one row to the next, and how fast rows fall
    static let mazeRowTime: TimeInterval = 1.8
    static let mazeGap: CGFloat = 120
    static let mazeGapStep: CGFloat = 70
    static let mazeSpeed: CGFloat = 80
    // Maze rocks vary: up to this much nudge sideways and up and down, a
    // slight turn, and a mix of sizes. The gap keeps this much extra room.
    static let mazeJitter: CGFloat = 5
    static let mazeVerticalJitter: CGFloat = 30
    static let mazeTurn: CGFloat = 0.3
    static let mazeClearance: CGFloat = 12
  }


  // MARK: Pacing
  //
  // Difficulty rises and falls with the journey: easier just after a
  // station, building to full strength on the last wave before the next.

  enum Pacing {
    // Right after a station the ramp acts this many stages easier
    static let relief = 3
    // Hard recipes (maze, bouncers, bosstroid field) only from this far
    // along the run to the next station
    static let hardFrom = 0.5

    // The stage number the difficulty ramp uses
    static func difficulty(stage: Int, progress: Double) -> Int {
      let ease = Int((Double(relief) * (1 - min(max(progress, 0), 1))).rounded())
      return max(1, stage - ease)
    }
  }


  // MARK: Ship upgrades
  //
  // Bought at stations, kept for the run. The number of prices is the
  // number of tiers; each station's buyMultiplier adjusts them.

  enum Upgrades {
    static func prices(_ upgrade: ShipUpgrade) -> [Int] {
      switch upgrade {
      case .reactor: return [25, 45, 70]
      case .cargoRack: return [15, 30]
      case .hullPlating: return [20, 40]
      case .thrusters: return [15, 30]
      case .weaponFocus: return [20, 40]
      case .shieldCapacitor: return [20, 40]
      }
    }

    // Each tier of thrusters adds this share to maneuvering, and each
    // tier of weapon focus this share to damage
    static let thrusterBoost: CGFloat = 0.15
    static let damageBoost: CGFloat = 0.2
  }


  // MARK: Travel

  enum Travel {
    // How far the ship travels per second of flying, in astronomical units
    static let auPerSecond = 0.004
  }


  // MARK: Stages

  enum Stages {
    // How long asteroids keep spawning: 10 s at stage 1, a quarter second
    // longer each stage, up to 18 s
    static func waveDuration(level: Int) -> TimeInterval {
      return min(18, 10 + 0.25 * TimeInterval(level - 1))
    }
    // After a wave, wait for the screen to clear, checking this often, up to the max
    static let clearCheckInterval: TimeInterval = 0.5
    static let maxClearWait: TimeInterval = 10

    // How long the scanner briefing shows before a wave; tap it to start sooner
    static let briefingTime: TimeInterval = 9
    static let stageClearPause: TimeInterval = 1.5
    static let bonusPerStage = 50
    static let gameOverDelay: TimeInterval = 3

    // In waves from the left or right, this share still come from the top
    static let sideWaveTopShare = 1.0 / 3

    // Seconds between spawns: 1.0 at stage 1, 0.05 faster each stage,
    // never below the floor (reached at stage 17)
    static let spawnFloor: TimeInterval = 0.2
    static func spawnInterval(level: Int) -> TimeInterval {
      return max(spawnFloor, 1.0 - 0.05 * TimeInterval(level - 1))
    }

    // Rocks get faster every stage: 2.5% a stage, up to double speed at stage 41
    static func speedScale(level: Int) -> CGFloat {
      return min(2, 1 + 0.025 * CGFloat(level - 1))
    }

    // From stage 11, a spawn sometimes brings two rocks: 3% more each stage, up to half
    static func pairChance(level: Int) -> Double {
      return min(0.5, max(0, 0.03 * Double(level - 10)))
    }

    // Rocks this size or bigger never come in pairs
    static let noPairsFrom = AsteroidSize.massive

    // Bigger rocks spawn less often, so a wave covers about the same amount
    // of screen whatever the size. Multiplies the time between spawns.
    static func sizeSpacing(_ size: AsteroidSize) -> TimeInterval {
      switch size {
      case .tiny: return 0.6
      case .small: return 0.8
      case .average: return 1
      case .large: return 1.4
      case .huge: return 1.9
      case .massive: return 2.6
      case .bosstroid: return 5
      }
    }

    // Once every type has debuted (stage 12), the featured type makes up a
    // growing share of each wave: 5% more each stage, up to double
    static func featuredScale(level: Int) -> Double {
      return min(2, 1 + 0.05 * Double(max(0, level - 11)))
    }
  }


  // MARK: Asteroid hazards

  enum Hazards {
    // Bosstroids come in bosstroid field waves (see Waves), from this stage
    static let bosstroidFromLevel = 8

    // Upward speed a low mass asteroid gains from each hit
    static let lowMassKnockback: CGFloat = 60

    static let gasDamage: CGFloat = 4
    // Blast radius is the larger of the minimum and the asteroid's size times the scale
    static let gasMinRadius: CGFloat = 70
    static let gasRadiusScale: CGFloat = 1.5

    static let iceShards = 6
    static let elasticBounces = 3

    static let enemyShotSpeed: CGFloat = 160
    // Seconds between shots at full strength (bases were 3.4; their
    // three-shot spread laid down too much fire)
    static let turretFireInterval: TimeInterval = 2.8
    static let baseFireInterval: TimeInterval = 4.2

    // Shooters fire more slowly in early stages: 1.5x the interval at
    // stage 1, easing to normal by stage 21
    static func fireScale(level: Int) -> TimeInterval {
      return max(1, 1.5 - 0.025 * TimeInterval(level - 1))
    }
    // Radians between the shots of an enemy base's spread
    static let baseSpread: CGFloat = 0.3
    // Enemy bases never move faster than this speed multiplier
    static let baseMaxSpeed: CGFloat = 0.5
  }
}
