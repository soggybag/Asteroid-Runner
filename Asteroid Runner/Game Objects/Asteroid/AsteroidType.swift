//
//  AsteroidType.swift
//  Asteroid Runner
//

import SpriteKit

// ----------------------------------
// Asteroid Types
// ----------------------------------

enum AsteroidType {
  case normal
  case lowMass    // Knocked back by every shot
  case glass      // Glassteroid - nearly invisible, shatters in one hit
  case black      // Blacksteroid - dark and hard to see against space
  case ice        // Icestroid - bursts into sharp shards
  case comet      // Small and fast, flies in at an angle
  case gas        // Gasteroid - explodes, damaging everything nearby
  case elastic    // Elastroid - bounces off the edges of the screen
  case brass      // Brasserteroid - super massive and tough
  case turret     // Fires at the ship
  case base       // Enemy base - big, armored, fires a spread

  // A new type debuts each stage from stage 2, in this order
  static let unlockOrder: [AsteroidType] = [
    .lowMass, .glass, .black, .ice, .comet, .gas, .elastic, .brass, .turret, .base
  ]

  // The special type featured in a wave. Stage 1 is plain rocks, then
  // each stage introduces a new type. Once all are unlocked, any of them.
  static func featured(forLevel level: Int) -> AsteroidType {
    if level <= 1 {
      return .normal
    }
    let index = level - 2
    if index < unlockOrder.count {
      return unlockOrder[index]
    }
    return unlockOrder.randomElement()!
  }

  // Fraction of a wave's asteroids that are the featured type
  var waveShare: Double {
    switch self {
    case .normal: return 0
    case .turret: return 0.15
    case .base: return 0.06
    default: return 0.4
    }
  }

  // Some types force a size
  func adjust(size: AsteroidSize) -> AsteroidSize {
    switch self {
    case .comet:
      return .small
    case .brass:
      return size.rawValue < AsteroidSize.large.rawValue ? .large : size
    case .turret:
      return size.rawValue < AsteroidSize.average.rawValue ? .average : size
    case .base:
      return .massive
    default:
      return size
    }
  }

  // Multiplies the number of hits it takes to break
  var toughness: CGFloat {
    switch self {
    case .glass: return 0
    case .brass: return 3
    case .base: return 2
    case .turret: return 1.5
    default: return 1
    }
  }

  // Multiplies the points for destroying it
  var pointMultiplier: Int {
    switch self {
    case .normal, .lowMass, .glass: return 1
    case .black, .ice, .gas, .elastic: return 2
    case .brass, .comet: return 3
    case .turret: return 4
    case .base: return 5
    }
  }

  // Debris from a broken asteroid keeps the type only where that makes sense
  var debrisType: AsteroidType {
    switch self {
    case .lowMass, .black, .brass, .ice: return self
    default: return .normal
    }
  }

  func color() -> UIColor {
    switch self {
    case .normal: return Colors.randomAsteroidColor()
    case .lowMass: return UIColor(r: 170, g: 160, b: 150)
    case .glass: return UIColor(r: 180, g: 240, b: 255, alpha: 0.3)
    case .black: return UIColor(r: 22, g: 22, b: 44)
    case .ice: return UIColor(r: 180, g: 230, b: 255)
    case .comet: return UIColor(r: 235, g: 245, b: 255)
    case .gas: return UIColor(r: 120, g: 200, b: 60)
    case .elastic: return UIColor(r: 150, g: 90, b: 230)
    case .brass: return UIColor(r: 190, g: 150, b: 60)
    case .turret: return UIColor(r: 110, g: 110, b: 120)
    case .base: return UIColor(r: 90, g: 60, b: 70)
    }
  }

  func toString() -> String {
    switch self {
    case .normal: return "Asteroids"
    case .lowMass: return "Low Mass"
    case .glass: return "Glassteroids"
    case .black: return "Blacksteroids"
    case .ice: return "Icestroids"
    case .comet: return "Comets"
    case .gas: return "Gasteroids"
    case .elastic: return "Elastroids"
    case .brass: return "Brasserteroids"
    case .turret: return "Turrets"
    case .base: return "Enemy Bases"
    }
  }
}
