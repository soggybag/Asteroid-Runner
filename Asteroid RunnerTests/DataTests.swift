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

struct VersionTests {

  @Test func labelShowsVersionAndBuild() {
    #expect(AppVersion.label.hasPrefix("v"))
    #expect(AppVersion.label.contains("("))
  }
}
