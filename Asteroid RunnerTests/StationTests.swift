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
      route.docked(at: current)
      #expect(route.next != current)
      #expect(route.hasVisited(current))
    }
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
