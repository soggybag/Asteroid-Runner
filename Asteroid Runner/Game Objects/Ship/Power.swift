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
      var level = min(startingLevel, maxLevel)
      while level > 0 && PowerGrid.cost(system, level: level) > left {
        level -= 1
      }
      levels[system] = level
      left -= PowerGrid.cost(system, level: level)
    }
  }

  // Reactor units a system uses at a level. Most systems use one unit a
  // level; the top weapons levels cost more (Tuning.Power.levelCost).
  static func cost(_ system: ShipSystem, level: Int) -> Int {
    return Tuning.Power.value(Tuning.Power.levelCost(system), level: level)
  }

  // Units the next level up would add
  static func stepCost(_ system: ShipSystem, toLevel level: Int) -> Int {
    return cost(system, level: level) - cost(system, level: level - 1)
  }

  func level(_ system: ShipSystem) -> Int {
    return levels[system] ?? 0
  }

  var used: Int {
    return ShipSystem.allCases.reduce(0) { $0 + PowerGrid.cost($1, level: level($1)) }
  }

  var free: Int {
    return reactor - used
  }


  // One level more for a system. Uses free units first, then takes levels
  // from the system with the highest level until there's enough. False,
  // with nothing changed, if it can't be done.
  @discardableResult
  mutating func raise(_ system: ShipSystem) -> Bool {
    guard level(system) < maxLevel else { return false }
    let need = PowerGrid.stepCost(system, toLevel: level(system) + 1)

    var grid = self
    while grid.free < need {
      let donors = ShipSystem.allCases.filter { $0 != system && grid.level($0) > 0 }
      guard let donor = donors.max(by: { grid.level($0) < grid.level($1) }) else { return false }
      grid.levels[donor] = grid.level(donor) - 1
    }
    grid.levels[system] = grid.level(system) + 1
    self = grid
    return true
  }


  // The same levels on a bigger reactor; the new units start free
  func withReactor(_ units: Int) -> PowerGrid {
    var grid = PowerGrid(reactor: units, maxLevel: maxLevel, startingLevel: 0)
    grid.levels = levels
    return grid
  }

  // One level less for a system; its units go back to the reactor
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

  // Starts empty unless `full`. `bonus` is extra charges from a shield
  // capacitor upgrade, added whenever shields have power.
  init(level: Int = 0, bonus: Int = 0, full: Bool = false) {
    capacity = ShieldCharge.capacity(level: level, bonus: bonus)
    charge = full ? capacity : 0
    self.level = level
  }

  private var level = 0

  static func capacity(level: Int, bonus: Int = 0) -> Int {
    let base = Tuning.Power.value(Tuning.Power.shieldCapacity, level: level)
    return base > 0 ? base + bonus : 0
  }

  // Call when the shield's power level or bonus changes. Charge above the
  // new capacity is lost; new capacity has to recharge.
  mutating func setLevel(_ level: Int, bonus: Int = 0) {
    self.level = level
    capacity = ShieldCharge.capacity(level: level, bonus: bonus)
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
