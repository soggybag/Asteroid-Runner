//
//  Pickup.swift
//  Asteroid Runner
//

// The things that drift down for the ship to collect, and how often each
// turns up. Points and coins count right away; items go into the tray.

import Foundation

enum Pickup: CaseIterable {
  case points, coin, bomb, shield, multiShot, rapidFire

  // Items go into the tray and are capped per wave
  var isItem: Bool {
    switch self {
    case .points, .coin: return false
    default: return true
    }
  }

  func make() -> PowerUp {
    switch self {
    case .points: return PowerUp()
    case .coin: return PowerUpCoin()
    case .bomb: return PowerUpBomb()
    case .shield: return PowerUpShield()
    case .multiShot: return PowerUpMissile()
    case .rapidFire: return PowerUpRapid()
    }
  }

  // Pick one by weight from Tuning.PowerUps.weights
  static func random(itemsOnly: Bool = false) -> Pickup {
    let choices = Tuning.PowerUps.weights.filter { !itemsOnly || $0.pickup.isItem }
    let total = choices.reduce(0) { $0 + $1.weight }
    var roll = Int.random(in: 0 ..< total)
    for choice in choices {
      if roll < choice.weight {
        return choice.pickup
      }
      roll -= choice.weight
    }
    return choices[0].pickup
  }
}
