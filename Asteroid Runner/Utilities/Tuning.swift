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


  // MARK: Ship handling, set by the config panel

  enum Ship {
    static let speedSlow: CGFloat = 0.1
    static let speedMed: CGFloat = 0.25
    static let speedFast: CGFloat = 0.5

    static let dampingSlow: CGFloat = 0.25
    static let dampingMed: CGFloat = 0.5
    static let dampingFast: CGFloat = 1
  }


  // MARK: Weapons

  enum Weapons {
    // Seconds between shots
    static let fireTime: TimeInterval = 0.3
    static let rapidFireTime: TimeInterval = 0.15

    static let missileSpeed: CGFloat = 300

    // Missile mass, how hard a shot pushes an asteroid
    static let massLow: CGFloat = 0.00125
    static let massMed: CGFloat = 0.0025
    static let massHi: CGFloat = 0.005
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
