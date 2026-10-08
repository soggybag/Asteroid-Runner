//
//  Upgrades.swift
//  Asteroid Runner
//

// Permanent improvements to the ship, bought at stations and kept for the
// rest of the run. Each has a few tiers. Different stations sell
// different upgrades (stations.json), so where you dock shapes the ship.
// A step toward modules: later each upgrade can become a part on the ship.
// Prices and amounts are in Tuning.Upgrades.

import CoreGraphics
import Foundation

enum ShipUpgrade: String, CaseIterable {
  case reactor, cargoRack, hullPlating, thrusters, weaponFocus, shieldCapacitor

  // Ids used in stations.json
  init?(id: String) {
    self.init(rawValue: id)
  }

  var name: String {
    switch self {
    case .reactor: return "Reactor"
    case .cargoRack: return "Cargo rack"
    case .hullPlating: return "Hull plating"
    case .thrusters: return "Thrusters"
    case .weaponFocus: return "Weapon focus"
    case .shieldCapacitor: return "Shield capacitor"
    }
  }

  // What one tier does, for the station screen
  var effect: String {
    switch self {
    case .reactor: return "+1 power"
    case .cargoRack: return "+1 tray slot"
    case .hullPlating: return "+1 hull"
    case .thrusters: return "+15% maneuver"
    case .weaponFocus: return "+20% damage"
    case .shieldCapacitor: return "+1 shield charge"
    }
  }

  var maxTier: Int {
    return Tuning.Upgrades.prices(self).count
  }

  // Base price of the next tier, or nil when it's maxed
  func basePrice(forTier tier: Int) -> Int? {
    let prices = Tuning.Upgrades.prices(self)
    return prices.indices.contains(tier - 1) ? prices[tier - 1] : nil
  }
}


// The upgrades this ship has, and what they add up to

struct ShipUpgrades: Equatable {

  private(set) var tiers = [ShipUpgrade: Int]()

  func tier(_ upgrade: ShipUpgrade) -> Int {
    return tiers[upgrade] ?? 0
  }

  func isMaxed(_ upgrade: ShipUpgrade) -> Bool {
    return tier(upgrade) >= upgrade.maxTier
  }

  // Add a tier. False if it's already maxed.
  @discardableResult
  mutating func install(_ upgrade: ShipUpgrade) -> Bool {
    guard !isMaxed(upgrade) else { return false }
    tiers[upgrade] = tier(upgrade) + 1
    return true
  }

  var reactorUnits: Int {
    return Tuning.Power.reactorUnits + tier(.reactor)
  }

  var traySlots: Int {
    return Tuning.Items.slots + tier(.cargoRack)
  }

  var maxLives: Int {
    return Tuning.Player.startingLives + tier(.hullPlating)
  }

  // Multiplies maneuvering: drag speed and tilt force
  var maneuverScale: CGFloat {
    return 1 + Tuning.Upgrades.thrusterBoost * CGFloat(tier(.thrusters))
  }

  // Multiplies missile damage
  var damageScale: CGFloat {
    return 1 + Tuning.Upgrades.damageBoost * CGFloat(tier(.weaponFocus))
  }

  // Extra shield charges, when shields have any power
  var extraShieldCharges: Int {
    return tier(.shieldCapacitor)
  }
}
