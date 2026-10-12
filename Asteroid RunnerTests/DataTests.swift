//
//  DataTests.swift
//  Asteroid RunnerTests
//

// The JSON files in Data/ are edited by hand. These catch a typo before
// it reaches the game, where a broken file falls back to default text.

import Testing
@testable import Asteroid_Runner

struct IntroDataTests {

  @Test func introFileLoads() {
    let intro = GameData.load(IntroText.self, from: "intro")
    #expect(intro != nil)
    #expect(intro?.lines.isEmpty == false)
    #expect((intro?.lineDelay ?? 0) > 0)
  }
}

struct MapDataTests {

  @Test func mapFileLoads() {
    let file = GameData.load(MapSettings.self, from: "map")
    #expect(file != nil)
    #expect(Tuning.Map.settings == file)
  }

  @Test func mapFileNumbersMakeSense() {
    let map = Tuning.Map.settings
    #expect(map.stationsPerRegion.min >= 1)
    #expect(map.stationsPerRegion.min <= map.stationsPerRegion.max)
    #expect(map.routesPerStation.min >= 1)
    #expect(map.routesPerStation.min <= map.routesPerStation.max)
    #expect(map.firstLegStages >= 1)
    #expect(map.winBonus >= 0)
    // Every region is in the file, and none is left over from a typo
    #expect(Set(map.regionDifficulty.keys) == Set(Region.allCases.map(\.key)))
  }

  @Test func countRangeKeepsItselfInRange() {
    #expect(CountRange(min: 3, max: 2).range == 2 ... 3)
    #expect(CountRange(min: 0, max: -1).range == 1 ... 1)
  }

  @Test func routeNumbersMakeSense() {
    let table = Tuning.Map.routes
    for danger in RouteDanger.allCases {
      let route = table[danger]
      #expect(route.minStages >= 1)
      #expect(route.minStages <= route.maxStages)
      #expect((0 ... 1).contains(route.pickupChance))
      #expect(route.maxItemsPerWave >= 0)
      #expect(route.coinPickup >= 0)
      #expect(route.stageClearCoins >= 0)
    }
  }

  @Test func routeSettingsKeepThemselvesInRange() {
    let odd = RouteSettings(minStages: 5, maxStages: 0, difficulty: 0, pickupChance: 2,
                            maxItemsPerWave: -1, coinPickup: -3, stageClearCoins: 1)
    #expect(odd.stages == 1 ... 5)
    #expect(odd.loot.pickupChance == 1)
    #expect(odd.loot.maxItemsPerWave == 0)
    #expect(odd.loot.coinPickup == 0)
  }

  @Test func filesWithCommentsLoad() {
    #expect(GameData.load(IntroText.self, from: "intro") != nil)
    #expect(!StationList.load().isEmpty)
  }
}

struct VersionTests {

  @Test func labelShowsVersionAndBuild() {
    #expect(AppVersion.label.hasPrefix("v"))
    #expect(AppVersion.label.contains("("))
  }
}
