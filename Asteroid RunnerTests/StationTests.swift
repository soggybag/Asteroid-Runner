//
//  StationTests.swift
//  Asteroid RunnerTests
//

// Stations: the data file loads, keepers pick the right greeting,
// prices follow each station's multipliers, and the route brings a
// station every few waves.

import Testing
@testable import Asteroid_Runner

private func makeStation(id: String = "test",
                         greetings: [String: [String]] = ["firstVisit": ["Hello"]],
                         sells: [String] = ["bomb", "fuel", "shield"],
                         buy: Double = 1, sell: Double = 1) -> Station {
  return Station(id: id, name: "Test \(id)", keeper: .init(name: "Keeper", title: "Tester"),
                 greetings: greetings, farewell: nil,
                 shop: .init(sells: sells, buyMultiplier: buy, sellMultiplier: sell))
}

struct StationDataTests {

  @Test func stationsFileLoads() {
    let stations = StationList.load()
    #expect(stations.count >= 1)
    for station in stations {
      #expect(!station.name.isEmpty)
      #expect(!station.greeting(for: .firstVisit).isEmpty)
    }
  }

  @Test func stationIdsAreUnique() {
    let ids = StationList.load().map(\.id)
    #expect(Set(ids).count == ids.count)
  }
}

struct StationGreetingTests {

  @Test func situationsGoInPriorityOrder() {
    #expect(StationSituation.pick(damaged: true, carryingWanted: true, visitedBefore: true) == .shipDamaged)
    #expect(StationSituation.pick(damaged: false, carryingWanted: true, visitedBefore: true) == .carryingWanted)
    #expect(StationSituation.pick(damaged: false, carryingWanted: false, visitedBefore: true) == .returnVisit)
    #expect(StationSituation.pick(damaged: false, carryingWanted: false, visitedBefore: false) == .firstVisit)
  }

  @Test func usesTheSituationsLines() {
    let station = makeStation(greetings: ["firstVisit": ["Hello"], "shipDamaged": ["Ouch"]])
    #expect(station.greeting(for: .shipDamaged) == "Ouch")
  }

  @Test func fallsBackToFirstVisit() {
    let station = makeStation(greetings: ["firstVisit": ["Hello"], "returnVisit": []])
    #expect(station.greeting(for: .returnVisit) == "Hello")
    #expect(station.greeting(for: .lowFuel) == "Hello")
  }

  @Test func hasALineEvenWithNoGreetings() {
    let station = makeStation(greetings: [:])
    #expect(station.greeting(for: .firstVisit).contains(station.name))
  }
}

struct StationShopTests {

  @Test func skipsItemsTheGameDoesntHaveYet() {
    #expect(makeStation(sells: ["bomb", "fuel", "shield"]).itemsForSale == [.bomb, .shield])
  }

  @Test func buyPriceFollowsTheMultiplier() {
    let base = Tuning.Stations.price(.bomb)
    #expect(makeStation(buy: 1).buyPrice(.bomb) == base)
    #expect(makeStation(buy: 2).buyPrice(.bomb) == base * 2)
  }

  @Test func sellingPaysLessThanBuying() {
    let station = makeStation()
    for item in ItemType.allCases {
      #expect(station.sellPrice(item) < station.buyPrice(item))
      #expect(station.sellPrice(item) >= 1)
    }
  }

  @Test func takingFromTheTrayRemovesIt() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.bomb)
    inventory.add(.shield)
    let taken = inventory.take(slot: 0)
    #expect(taken?.type == .bomb)
    #expect(inventory.items.map(\.type) == [.shield])
  }
}

struct StationRouteTests {

  @Test func stationComesWithinTheWaveRange() {
    for _ in 0 ..< 200 {
      var route = StationRoute(stations: [makeStation()])
      var waves = 0
      while route.waveCleared() == nil {
        waves += 1
        #expect(waves < Tuning.Stations.maxWaves)
        if waves >= Tuning.Stations.maxWaves { break }
      }
      #expect(waves + 1 >= Tuning.Stations.minWaves)
    }
  }

  @Test func warnsOnTheLastWaveBeforeAStation() {
    var route = StationRoute(stations: [makeStation()])
    while !route.stationAfterThisWave {
      #expect(route.waveCleared() == nil)
    }
    #expect(route.waveCleared() != nil)
  }

  @Test func nextStationIsADifferentOne() {
    var route = StationRoute(stations: [makeStation(id: "a"), makeStation(id: "b")])
    for _ in 0 ..< 20 {
      let current = route.next!
      route.docked(at: current, nextStage: 1)
      #expect(route.next != current)
      #expect(route.hasVisited(current))
    }
  }

  @Test func plansEveryWaveOfTheLeg() {
    for _ in 0 ..< 50 {
      var route = StationRoute(stations: [makeStation(id: "a"), makeStation(id: "b")])
      #expect(route.legStartStage == 1)
      #expect(route.legWaves.count == route.legLength)
      #expect(route.legWaves.map(\.stage) == Array(1 ... route.legLength))

      route.docked(at: route.next!, nextStage: 7)
      #expect(route.legStartStage == 7)
      #expect(route.legWaves.count == route.legLength)
      #expect(route.wave(forStage: 7)?.stage == 7)
      #expect(route.wave(forStage: 6) == nil)
      #expect(route.wave(forStage: 7 + route.legLength) == nil)
    }
  }

  // The planned waves follow the same rules as choosing each wave as it
  // comes: eased after a station, no recipe twice in a row but rock fields
  @Test func plannedLegFollowsTheWaveRules() {
    for _ in 0 ..< 200 {
      let length = Int.random(in: Tuning.Stations.minWaves ... Tuning.Stations.maxWaves)
      let waves = StationRoute.planLeg(from: 12, length: length, previous: .swarm)
      for (index, wave) in waves.enumerated() {
        let progress = length > 1 ? Double(index) / Double(length - 1) : 1
        #expect(wave.difficulty == Tuning.Pacing.difficulty(stage: wave.stage, progress: progress))
        if wave.recipe.isHard {
          #expect(progress >= Tuning.Pacing.hardFrom)
        }
        let previous = index == 0 ? WaveRecipe.swarm : waves[index - 1].recipe
        #expect(wave.recipe == .field || wave.recipe != previous)
      }
    }
  }

  @Test func noStationsPlansNoLeg() {
    let route = StationRoute(stations: [])
    #expect(route.legWaves.isEmpty)
    #expect(route.wave(forStage: 1) == nil)
  }

  @Test func noStationsMeansNoDocking() {
    var route = StationRoute(stations: [])
    for _ in 0 ..< 10 {
      #expect(route.waveCleared() == nil)
    }
    #expect(!route.stationAfterThisWave)
  }
}

struct RunStatsTests {

  @Test func distanceShowsTwoDecimals() {
    var stats = RunStats()
    #expect(stats.distanceText == "0.00 AU")
    stats.distance = 1.234
    #expect(stats.distanceText == "1.23 AU")
  }
}


// Ship upgrades: tiers, what they add, prices at each station, and how
// the reactor, tray and shields take them

struct UpgradeTests {

  @Test func tiersStopAtTheMax() {
    var upgrades = ShipUpgrades()
    for _ in 0 ..< ShipUpgrade.reactor.maxTier {
      let installed = upgrades.install(.reactor)
      #expect(installed)
    }
    let extra = upgrades.install(.reactor)
    #expect(!extra)
    #expect(upgrades.tier(.reactor) == ShipUpgrade.reactor.maxTier)
  }

  @Test func upgradesAddUp() {
    var upgrades = ShipUpgrades()
    #expect(upgrades.reactorUnits == Tuning.Power.reactorUnits)
    upgrades.install(.reactor)
    upgrades.install(.cargoRack)
    upgrades.install(.hullPlating)
    upgrades.install(.thrusters)
    upgrades.install(.weaponFocus)
    upgrades.install(.shieldCapacitor)
    #expect(upgrades.reactorUnits == Tuning.Power.reactorUnits + 1)
    #expect(upgrades.traySlots == Tuning.Items.slots + 1)
    #expect(upgrades.maxLives == Tuning.Player.startingLives + 1)
    #expect(upgrades.maneuverScale > 1)
    #expect(upgrades.damageScale > 1)
    #expect(upgrades.extraShieldCharges == 1)
  }

  @Test func eachTierCostsMore() {
    for upgrade in ShipUpgrade.allCases {
      let prices = Tuning.Upgrades.prices(upgrade)
      #expect(!prices.isEmpty)
      for (cheaper, dearer) in zip(prices, prices.dropFirst()) {
        #expect(dearer > cheaper)
      }
    }
  }

  @Test func stationPricesFollowTheMultiplier() {
    let cheap = makeStation(buy: 1)
    let dear = makeStation(buy: 2)
    let base = ShipUpgrade.reactor.basePrice(forTier: 1)!
    #expect(cheap.upgradePrice(.reactor, tier: 1) == base)
    #expect(dear.upgradePrice(.reactor, tier: 1) == base * 2)
    #expect(cheap.upgradePrice(.reactor, tier: ShipUpgrade.reactor.maxTier + 1) == nil)
  }

  @Test func everyStationFitsSomething() {
    for station in StationList.load() {
      #expect(!station.upgradesForSale.isEmpty)
      #expect(station.upgradesForSale.count == station.shop.upgrades?.count)
    }
  }

  @Test func aBiggerReactorKeepsLevelsAndFreesUnits() {
    let grid = PowerGrid(reactor: 6, maxLevel: 4, startingLevel: 2)
    let bigger = grid.withReactor(7)
    #expect(bigger.reactor == 7)
    #expect(bigger.free == 1)
    for system in ShipSystem.allCases {
      #expect(bigger.level(system) == grid.level(system))
    }
  }

  @Test func aCargoRackAddsTraySlots() {
    var inventory = Inventory(capacity: 3)
    inventory.add(.bomb)
    inventory.add(.bomb)
    inventory.add(.bomb)
    #expect(inventory.isFull)
    inventory.setCapacity(4)
    #expect(!inventory.isFull)
    #expect(inventory.items.count == 3)
  }

  @Test func shieldCapacitorNeedsShieldPower() {
    #expect(ShieldCharge.capacity(level: 0, bonus: 2) == 0)
    #expect(ShieldCharge.capacity(level: 1, bonus: 2) == Tuning.Power.shieldCapacity[1] + 2)
  }
}
