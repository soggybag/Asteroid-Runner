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
      let difficulty = LegDifficulty(start: 7, end: 11, offset: 2)
      let waves = StationRoute.planLeg(from: 12, length: length, difficulty: difficulty, previous: .swarm)
      for (index, wave) in waves.enumerated() {
        let progress = length > 1 ? Double(index) / Double(length - 1) : 1
        #expect(wave.difficulty == difficulty.at(progress: progress))
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


struct SystemMapTests {

  private let kinds = [makeStation(id: "outpost"), makeStation(id: "depot"), makeStation(id: "trader")]
  private let names = (1 ... 24).map { "Station \($0)" }

  @Test func everyRegionHasStationsWithTheirOwnNames() {
    for _ in 0 ..< 50 {
      let map = SystemMap.generate(kinds: kinds, names: names)!
      for region in Region.allCases {
        #expect(Tuning.Map.stationsPerRegion.contains(map.stations(in: region).count))
      }
      #expect(Set(map.stations.map(\.id)).count == map.stations.count)
      #expect(Set(map.stations.map(\.station.name)).count == map.stations.count)
    }
  }

  @Test func routesLeadToTheNextRegionOut() {
    for _ in 0 ..< 50 {
      let map = SystemMap.generate(kinds: kinds, names: names)!
      for from in map.stations {
        let routes = map.routes(from: from.id)
        #expect(!routes.isEmpty)
        #expect(routes.count <= Tuning.Map.routesPerStation.upperBound)
        #expect(Set(routes.map(\.to)).count == routes.count)
        #expect(Set(routes.map(\.danger)).count == routes.count)
        for route in routes {
          let to = map.station(route.to)!
          #expect(to.region == (from.region.next ?? from.region))
          #expect(to.id != from.id)
          #expect(route.danger.lengths.contains(route.length))
        }
      }
    }
  }

  @Test func runStartsWithANormalLegToEarth() {
    let map = SystemMap.generate(kinds: kinds, names: names)!
    #expect(map.station(map.start.to)?.region == .earth)
    #expect(map.start.danger == .normal)
    #expect(map.start.length == Tuning.Map.firstLegLength)
  }

  @Test func noKindsMeansNoMap() {
    #expect(SystemMap.generate(kinds: [], names: names) == nil)
  }

  @Test func outOfNamesStillNamesEveryStation() {
    let map = SystemMap.generate(kinds: kinds, names: [])!
    #expect(map.stations.allSatisfy { !$0.station.name.isEmpty })
  }

  @Test func eachLegFliesOneRegionOut() {
    var route = StationRoute(stations: kinds, names: names)
    var stage = 1
    for region in Region.allCases {
      let next = route.next!
      #expect(route.map?.station(next.id)?.region == region)
      stage += route.legLength
      route.docked(at: next, nextStage: stage)
    }
    // Past Neptune, legs stay at Neptune and keep getting harder
    let past = route.legDifficulty.start
    #expect(past >= Region.neptune.difficulty)
    route.docked(at: route.next!, nextStage: stage + route.legLength)
    #expect(route.legDifficulty.start > past)
  }

  @Test func takesTheNormalRouteUntilThereIsAMapScreen() {
    for _ in 0 ..< 50 {
      var route = StationRoute(stations: kinds, names: names)
      route.docked(at: route.next!, nextStage: 4)
      if route.routesOut.contains(where: { $0.danger == .normal }) {
        #expect(route.route?.danger == .normal)
      }
    }
  }

  @Test func legDifficultyRampsAndDangerShiftsIt() {
    let normal = LegDifficulty(start: 7, end: 11, offset: 0)
    #expect(normal.at(progress: 1) == 11)
    #expect(normal.at(progress: 0) == 7 - Tuning.Pacing.relief)
    var last = 0
    for step in 0 ... 10 {
      let value = normal.at(progress: Double(step) / 10)
      #expect(value >= last)
      last = value
    }
    let safe = LegDifficulty(start: 7, end: 11, offset: RouteDanger.safe.difficultyOffset)
    let risky = LegDifficulty(start: 7, end: 11, offset: RouteDanger.risky.difficultyOffset)
    #expect(safe.at(progress: 0.5) < normal.at(progress: 0.5))
    #expect(risky.at(progress: 0.5) > normal.at(progress: 0.5))
    #expect(LegDifficulty(start: 1, end: 1, offset: -2).at(progress: 0) == 1)
  }

  @Test func harderRegionsFurtherOut() {
    let values = Region.allCases.map(\.difficulty)
    #expect(values == values.sorted())
    #expect(Set(values).count == values.count)
  }

  @Test func stationsFileHasEnoughMapNames() {
    let names = StationList.loadMapNames()
    let most = Region.allCases.count * Tuning.Map.stationsPerRegion.upperBound
    #expect(names.count >= most)
    #expect(Set(names).count == names.count)
  }
}
