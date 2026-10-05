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
    static let engineTilt: [CGFloat] = [0.08, 0.15, 0.25, 0.38, 0.5]
    static let engineDamping: [CGFloat] = [0.25, 0.35, 0.5, 0.75, 1]
    static let engineDragSpeed: [CGFloat] = [250, 400, 600, 850, 1200]

    // Weapons: seconds between shots, damage per hit, and missile mass
    // (how hard a shot pushes an asteroid). Level 0 is the Command
    // module's weak trickle shot.
    static let weaponFireTime: [TimeInterval] = [0.6, 0.4, 0.3, 0.22, 0.16]
    static let weaponDamage: [CGFloat] = [0.5, 1, 2, 2.5, 3]
    static let weaponMass: [CGFloat] = [0.001, 0.00125, 0.0025, 0.004, 0.005]

    // Shields: each level holds one charge that absorbs one hit. Seconds
    // to rebuild one charge at each level (level 0 has no shield).
    static let shieldRecharge: [TimeInterval] = [0, 15, 12, 9, 6]
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

    static let points = 100
    static let coinPoints = 250

    // Each spawn rolls 0 ..< spawnRoll. Rolls 0 to 5 are powerups and coins,
    // so 6 in 25 spawns are pickups and the rest are asteroids.
    static let spawnRoll = 25
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

    // Docking and launching animations, in seconds
    static let dockTime: TimeInterval = 2.5
    static let launchTime: TimeInterval = 1.5
  }


  // MARK: Stages

  enum Stages {
    // How long asteroids keep spawning each wave
    static let waveDuration: TimeInterval = 10
    // After a wave, wait for the screen to clear, checking this often, up to the max
    static let clearCheckInterval: TimeInterval = 0.5
    static let maxClearWait: TimeInterval = 10

    // Gap between lines of the stage announcement
    static let announcementLineDelay: TimeInterval = 1.5
    static let stageClearPause: TimeInterval = 1.5
    static let bonusPerStage = 50
    static let gameOverDelay: TimeInterval = 3

    // In waves from the left or right, this share still come from the top
    static let sideWaveTopShare = 1.0 / 3

    // Seconds between spawns: 1.0 at stage 1, 0.06 faster each stage, never below 0.35
    static func spawnInterval(level: Int) -> TimeInterval {
      return max(0.35, 1.0 - 0.06 * TimeInterval(level - 1))
    }
  }


  // MARK: Asteroid hazards

  enum Hazards {
    static let bosstroidFromLevel = 6
    // Chance a wave is bosstroids once they're unlocked
    static let bosstroidChance = 0.25

    // Upward speed a low mass asteroid gains from each hit
    static let lowMassKnockback: CGFloat = 60

    static let gasDamage: CGFloat = 4
    // Blast radius is the larger of the minimum and the asteroid's size times the scale
    static let gasMinRadius: CGFloat = 70
    static let gasRadiusScale: CGFloat = 1.5

    static let iceShards = 6
    static let elasticBounces = 3

    static let enemyShotSpeed: CGFloat = 160
    static let turretFireInterval: TimeInterval = 2.0
    static let baseFireInterval: TimeInterval = 2.6
    // Radians between the shots of an enemy base's spread
    static let baseSpread: CGFloat = 0.3
    // Enemy bases never move faster than this speed multiplier
    static let baseMaxSpeed: CGFloat = 0.5
  }
}
