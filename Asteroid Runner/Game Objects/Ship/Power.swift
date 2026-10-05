//
//  Power.swift
//  Asteroid Runner
//

// The ship's power. The Command module's reactor makes a fixed number of
// units that never run out, shared between engines, shields and weapons.
// What each level does is in Tuning.Power.

import Foundation

enum ShipSystem: CaseIterable {
  case engines, shields, weapons

  var name: String {
    switch self {
    case .engines: return "ENGINES"
    case .shields: return "SHIELDS"
    case .weapons: return "WEAPONS"
    }
  }
}


struct PowerGrid: Equatable {

  let reactor: Int
  let maxLevel: Int
  private(set) var levels: [ShipSystem: Int]

  init(reactor: Int = Tuning.Power.reactorUnits,
       maxLevel: Int = Tuning.Power.maxLevel,
       startingLevel: Int = Tuning.Power.startingLevel) {
    self.reactor = reactor
    self.maxLevel = maxLevel
    levels = [:]
    var left = reactor
    for system in ShipSystem.allCases {
      let level = min(startingLevel, maxLevel, left)
      levels[system] = level
      left -= level
    }
  }

  func level(_ system: ShipSystem) -> Int {
    return levels[system] ?? 0
  }

  var used: Int {
    return levels.values.reduce(0, +)
  }

  var free: Int {
    return reactor - used
  }


  // One more unit to a system. Uses a free unit if there is one, otherwise
  // takes one from the system with the most. False if nothing changed.
  @discardableResult
  mutating func raise(_ system: ShipSystem) -> Bool {
    guard level(system) < maxLevel else { return false }

    if free <= 0 {
      let donors = ShipSystem.allCases.filter { $0 != system && level($0) > 0 }
      guard let donor = donors.max(by: { level($0) < level($1) }) else { return false }
      levels[donor] = level(donor) - 1
    }
    levels[system] = level(system) + 1
    return true
  }


  // One less unit to a system; the unit goes back to the reactor
  @discardableResult
  mutating func lower(_ system: ShipSystem) -> Bool {
    guard level(system) > 0 else { return false }
    levels[system] = level(system) - 1
    return true
  }
}


// Powered shields: each level holds some charge (Tuning.Power.shieldCapacity),
// and each point absorbs one hit. Charge rebuilds a point at a time,
// faster with more power. Separate from the shield item in the tray.

struct ShieldCharge: Equatable {

  private(set) var charge = 0
  private(set) var capacity = 0
  private var timer: TimeInterval = 0

  // Starts empty unless `full`
  init(level: Int = 0, full: Bool = false) {
    capacity = ShieldCharge.capacity(level: level)
    charge = full ? capacity : 0
    self.level = level
  }

  private var level = 0

  static func capacity(level: Int) -> Int {
    return Tuning.Power.value(Tuning.Power.shieldCapacity, level: level)
  }

  // Call when the shield's power level changes. Charge above the new
  // capacity is lost; new capacity has to recharge.
  mutating func setLevel(_ level: Int) {
    self.level = level
    capacity = ShieldCharge.capacity(level: level)
    charge = min(charge, capacity)
    if capacity == 0 {
      timer = 0
    }
  }

  mutating func update(seconds: TimeInterval) {
    guard charge < capacity else {
      timer = 0
      return
    }
    timer += seconds
    let rechargeTime = Tuning.Power.shieldRechargeTime(level: level)
    if timer >= rechargeTime {
      timer -= rechargeTime
      charge += 1
    }
  }

  // Spend a point to block a hit. False if there's none.
  @discardableResult
  mutating func absorb() -> Bool {
    guard charge > 0 else { return false }
    charge -= 1
    return true
  }
}
