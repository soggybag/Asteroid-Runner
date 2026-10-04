//
//  InventoryTests.swift
//  Asteroid RunnerTests
//

// Rules for the item tray: what fits, what a tap does, and how the
// shield drains and keeps its place as other items are used.

import Testing
@testable import Asteroid_Runner

struct InventoryAddTests {

  @Test func holdsUpToCapacity() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.bomb)
    inventory.add(.shield)
    inventory.add(.rapidFire)
    #expect(inventory.isFull)

    let addedWhenFull = inventory.add(.multiShot)
    #expect(!addedWhenFull)
    #expect(inventory.items.map(\.type) == [.bomb, .shield, .rapidFire])
  }

  @Test func onlyWeaponAndDefensePowerupsAreItems() {
    #expect(ItemType(powerupName: PowerUp.PU_BOMB) == .bomb)
    #expect(ItemType(powerupName: PowerUp.PU_SHIELD) == .shield)
    #expect(ItemType(powerupName: PowerUp.PU_MISSILE_2) == .multiShot)
    #expect(ItemType(powerupName: PowerUp.PU_MISSILE_RAPID) == .rapidFire)
    #expect(ItemType(powerupName: PowerUp.PU_POINTS) == nil)
    #expect(ItemType(powerupName: PowerUp.PU_COIN) == nil)
  }
}

struct InventoryTapTests {

  @Test func usingAnItemRemovesIt() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.bomb)
    inventory.add(.rapidFire)

    let action = inventory.tap(slot: 0)
    #expect(action == .use(.bomb))
    #expect(inventory.items.map(\.type) == [.rapidFire])
  }

  @Test func tappingAnEmptySlotDoesNothing() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.bomb)

    let action = inventory.tap(slot: 2)
    #expect(action == .none)
    #expect(inventory.items.count == 1)
  }

  @Test func shieldTogglesAndStaysInTheTray() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.shield)

    let first = inventory.tap(slot: 0)
    #expect(first == .shieldOn)
    #expect(inventory.shieldIsOn)

    let second = inventory.tap(slot: 0)
    #expect(second == .shieldOff)
    #expect(!inventory.shieldIsOn)
    #expect(inventory.items.map(\.type) == [.shield])
  }

  @Test func onlyOneShieldIsUpAtATime() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.shield)
    inventory.add(.shield)
    inventory.tap(slot: 0)

    let action = inventory.tap(slot: 1)
    #expect(action == .shieldOn)
    #expect(inventory.activeShield == 1)
  }

  @Test func activeShieldKeepsItsPlaceWhenAnEarlierItemIsUsed() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.bomb)
    inventory.add(.shield)
    inventory.tap(slot: 1)
    inventory.tap(slot: 0)
    #expect(inventory.activeShield == 0)
    #expect(inventory.items.map(\.type) == [.shield])
  }
}

struct InventoryShieldTests {

  @Test func drainsOnlyWhileUp() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.shield)
    inventory.drainShield(seconds: 5)
    #expect(inventory.items[0].charge == Tuning.Items.shieldCharge)

    inventory.tap(slot: 0)
    inventory.drainShield(seconds: 5)
    #expect(inventory.shieldCharge == Tuning.Items.shieldCharge - 5)
  }

  @Test func keepsItsChargeWhenLowered() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.shield)
    inventory.tap(slot: 0)
    inventory.drainShield(seconds: 5)
    inventory.tap(slot: 0)
    inventory.tap(slot: 0)
    #expect(inventory.shieldCharge == Tuning.Items.shieldCharge - 5)
  }

  @Test func isRemovedWhenItRunsOut() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.shield)
    inventory.add(.bomb)
    inventory.tap(slot: 0)

    let ranOut = inventory.drainShield(seconds: Tuning.Items.shieldCharge)
    #expect(ranOut)
    #expect(!inventory.shieldIsOn)
    #expect(inventory.items.map(\.type) == [.bomb])
  }
}
