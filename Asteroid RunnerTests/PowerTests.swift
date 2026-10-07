//
//  PowerTests.swift
//  Asteroid RunnerTests
//

// The reactor's units: how they're shared out when a system is raised or
// lowered, how powered shields charge and block hits, and that every
// per-level table covers every level.

import Testing
@testable import Asteroid_Runner

struct PowerGridTests {

  @Test func startsEvenlySplit() {
    let grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    for system in ShipSystem.allCases {
      #expect(grid.level(system) == 2)
    }
    #expect(grid.free == 0)
  }

  @Test func raisingTakesFromTheSystemWithTheMost() {
    var grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    grid.raise(.engines)
    #expect(grid.level(.engines) == 3)
    #expect(grid.used == 6)
    // Shields and weapons were both at 2; one of them gave a level
    #expect(grid.level(.shields) + grid.level(.weapons) == 3)
  }

  @Test func topWeaponsLevelsCostTwoUnits() {
    #expect(PowerGrid.stepCost(.weapons, toLevel: 2) == 1)
    #expect(PowerGrid.stepCost(.weapons, toLevel: 3) == 2)
    #expect(PowerGrid.stepCost(.weapons, toLevel: 4) == 2)
    #expect(PowerGrid.stepCost(.engines, toLevel: 4) == 1)
  }

  @Test func maxWeaponsTakeTheWholeReactor() {
    var grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    grid.raise(.weapons)
    #expect(grid.level(.weapons) == 3)
    #expect(grid.level(.engines) == 1)
    #expect(grid.level(.shields) == 1)
    grid.raise(.weapons)
    #expect(grid.level(.weapons) == 4)
    #expect(grid.level(.engines) == 0)
    #expect(grid.level(.shields) == 0)
    #expect(grid.used == 6)
  }

  @Test func maxEnginesStillLeaveRoom() {
    var grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    grid.raise(.engines)
    grid.raise(.engines)
    #expect(grid.level(.engines) == 4)
    #expect(grid.level(.shields) + grid.level(.weapons) == 2)
  }

  @Test func aFailedRaiseChangesNothing() {
    var grid = PowerGrid(reactor: 2, maxLevel: 4, startingLevel: 0)
    grid.raise(.weapons)
    grid.raise(.weapons)
    let before = grid
    let raised = grid.raise(.weapons)
    #expect(!raised)
    #expect(grid == before)
  }

  @Test func cantGoPastTheMax() {
    var grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    grid.raise(.weapons)
    grid.raise(.weapons)
    let raised = grid.raise(.weapons)
    #expect(!raised)
    #expect(grid.level(.weapons) == 4)
  }

  @Test func loweringFreesAUnitThatRaisingUsesFirst() {
    var grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    grid.lower(.engines)
    #expect(grid.free == 1)
    grid.raise(.shields)
    #expect(grid.free == 0)
    #expect(grid.level(.shields) == 3)
    #expect(grid.level(.weapons) == 2)
  }

  @Test func cantLowerBelowZero() {
    var grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    grid.lower(.engines)
    grid.lower(.engines)
    let lowered = grid.lower(.engines)
    #expect(!lowered)
    #expect(grid.level(.engines) == 0)
  }

  @Test func neverUsesMoreThanTheReactor() {
    var grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    let moves: [(Bool, ShipSystem)] = [(true, .engines), (true, .engines), (false, .weapons), (true, .shields),
                                       (true, .shields), (true, .weapons), (false, .shields), (true, .engines)]
    for (up, system) in moves {
      if up { grid.raise(system) } else { grid.lower(system) }
      #expect(grid.used <= grid.reactor)
      for s in ShipSystem.allCases {
        #expect((0 ... grid.maxLevel).contains(grid.level(s)))
      }
    }
  }
}

struct ShieldChargeTests {

  @Test func startsEmpty() {
    var shield = ShieldCharge(level: 2)
    #expect(shield.charge == 0)
    let blocked = shield.absorb()
    #expect(!blocked)
  }

  @Test func blocksOneHitPerCharge() {
    var shield = ShieldCharge(level: 4, full: true)
    #expect(shield.charge == Tuning.Power.shieldCapacity[4])
    for _ in 0 ..< shield.capacity {
      let blocked = shield.absorb()
      #expect(blocked)
    }
    let extra = shield.absorb()
    #expect(!extra)
  }

  @Test func rechargesOverTime() {
    var shield = ShieldCharge(level: 2)
    shield.update(seconds: Tuning.Power.shieldRechargeTime(level: 2) - 0.1)
    #expect(shield.charge == 0)
    shield.update(seconds: 0.2)
    #expect(shield.charge == 1)
  }

  @Test func noShieldAtLevelZero() {
    var shield = ShieldCharge(level: 0)
    shield.update(seconds: 100)
    let blocked = shield.absorb()
    #expect(!blocked)
  }

  @Test func loweringPowerDropsExtraCharge() {
    var shield = ShieldCharge(level: 4, full: true)
    shield.setLevel(1)
    #expect(shield.charge == Tuning.Power.shieldCapacity[1])
    shield.setLevel(4)
    #expect(shield.charge == Tuning.Power.shieldCapacity[1])
  }
}

struct PowerTuningTests {

  @Test func everyTableCoversEveryLevel() {
    let count = Tuning.Power.maxLevel + 1
    #expect(Tuning.Power.engineTilt.count == count)
    #expect(Tuning.Power.engineDamping.count == count)
    #expect(Tuning.Power.engineDragSpeed.count == count)
    #expect(Tuning.Power.weaponFireTime.count == count)
    #expect(Tuning.Power.weaponDamage.count == count)
    #expect(Tuning.Power.weaponMass.count == count)
    #expect(Tuning.Power.shieldRecharge.count == count)
    #expect(Tuning.Power.shieldCapacity.count == count)
    #expect(Missile.sizes.count == count)
    #expect(Missile.colors.count == count)
  }

  @Test func morePowerIsAlwaysBetter() {
    for level in 0 ..< Tuning.Power.maxLevel {
      #expect(Tuning.Power.engineDragSpeed[level + 1] > Tuning.Power.engineDragSpeed[level])
      #expect(Tuning.Power.weaponFireTime[level + 1] < Tuning.Power.weaponFireTime[level])
      #expect(Tuning.Power.weaponDamage[level + 1] > Tuning.Power.weaponDamage[level])
    }
    for level in 1 ..< Tuning.Power.maxLevel {
      #expect(Tuning.Power.shieldRecharge[level + 1] < Tuning.Power.shieldRecharge[level])
      #expect(Tuning.Power.shieldCapacity[level + 1] >= Tuning.Power.shieldCapacity[level])
    }
  }

  @Test func levelZeroWeaponsStillFire() {
    #expect(Tuning.Power.weaponDamage[0] > 0)
  }
}
