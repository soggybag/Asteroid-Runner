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

struct RouteDataTests {

  @Test func routesFileLoads() {
    let file = GameData.load(RouteTable.self, from: "routes")
    #expect(file != nil)
    #expect(Tuning.Map.routes == file)
  }

  @Test func routesFileNumbersMakeSense() {
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
