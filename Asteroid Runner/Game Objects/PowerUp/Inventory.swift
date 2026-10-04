//
//  Inventory.swift
//  Asteroid Runner
//

// Pickups the player is carrying. Items wait in the tray until the player
// taps one. The shield is the exception to use-it-and-it's-gone: tapping
// raises or lowers it, and it only drains while it's up.

import SpriteKit

enum ItemType: CaseIterable {
  case bomb, shield, multiShot, rapidFire

  // The item a powerup becomes when picked up. Points and coins aren't items.
  init?(powerupName: String?) {
    switch powerupName {
    case PowerUp.PU_BOMB: self = .bomb
    case PowerUp.PU_SHIELD: self = .shield
    case PowerUp.PU_MISSILE_2: self = .multiShot
    case PowerUp.PU_MISSILE_RAPID: self = .rapidFire
    default: return nil
    }
  }

  // Ids used in data files such as stations.json
  init?(id: String) {
    switch id {
    case "bomb": self = .bomb
    case "shield": self = .shield
    case "multiShot": self = .multiShot
    case "rapidFire": self = .rapidFire
    default: return nil
    }
  }

  var name: String {
    switch self {
    case .bomb: return "Bomb"
    case .shield: return "Shield"
    case .multiShot: return "Multi-shot"
    case .rapidFire: return "Rapid fire"
    }
  }

  var label: String {
    switch self {
    case .bomb: return "BOMB"
    case .shield: return "SHLD"
    case .multiShot: return "MULTI"
    case .rapidFire: return "RAPID"
    }
  }

  var color: UIColor {
    switch self {
    case .bomb: return Colors.powerupBomb
    case .shield: return Colors.powerupShield
    case .multiShot: return Colors.powerupMissile
    case .rapidFire: return Colors.powerupRapid
    }
  }
}


struct Item: Equatable {
  let type: ItemType
  // Seconds of shield left. Unused by other items.
  var charge: TimeInterval = Tuning.Items.shieldCharge
}


// What the scene should do after a slot is tapped
enum TrayAction: Equatable {
  case none
  case use(ItemType)
  case shieldOn
  case shieldOff
}


struct Inventory {

  let capacity: Int
  private(set) var items: [Item] = []
  // Index of the shield that's up, if any
  private(set) var activeShield: Int?

  init(capacity: Int = Tuning.Items.slots) {
    self.capacity = capacity
  }

  var isFull: Bool {
    return items.count >= capacity
  }

  var shieldIsOn: Bool {
    return activeShield != nil
  }

  // Seconds left on the shield that's up, or 0
  var shieldCharge: TimeInterval {
    guard let index = activeShield else { return 0 }
    return items[index].charge
  }


  // Returns false, and keeps nothing, when the tray is full
  @discardableResult
  mutating func add(_ type: ItemType) -> Bool {
    guard !isFull else { return false }
    items.append(Item(type: type))
    return true
  }


  // Use the item in a slot. A shield is raised or lowered and stays in the
  // tray; anything else is used up. Only one shield is up at a time.
  @discardableResult
  mutating func tap(slot: Int) -> TrayAction {
    guard items.indices.contains(slot) else { return .none }
    let item = items[slot]

    if item.type == .shield {
      if activeShield == slot {
        activeShield = nil
        return .shieldOff
      }
      activeShield = slot
      return .shieldOn
    }

    remove(at: slot)
    return .use(item.type)
  }


  // Drain the shield that's up. Returns true when it runs out this step.
  @discardableResult
  mutating func drainShield(seconds: TimeInterval) -> Bool {
    guard let index = activeShield else { return false }
    items[index].charge -= seconds
    if items[index].charge <= 0 {
      remove(at: index)
      return true
    }
    return false
  }


  // Take an item out of the tray without using it, to sell it
  mutating func take(slot: Int) -> Item? {
    guard items.indices.contains(slot) else { return nil }
    let item = items[slot]
    remove(at: slot)
    return item
  }


  mutating func lowerShield() {
    activeShield = nil
  }


  mutating func removeAll() {
    items.removeAll()
    activeShield = nil
  }


  // Remove a slot, keeping the active shield index pointing at the same item
  private mutating func remove(at index: Int) {
    items.remove(at: index)
    if let shield = activeShield {
      if shield == index {
        activeShield = nil
      } else if shield > index {
        activeShield = shield - 1
      }
    }
  }
}
