//
//  WaveTests.swift
//  Asteroid RunnerTests
//

// Rules that decide what each stage throws at the player: spawn timing,
// which sizes, speeds and types unlock when. Random pickers are sampled
// many times and checked against what each stage allows.

import Testing
@testable import Asteroid_Runner

private let samples = 2000

struct SpawnIntervalTests {

  @Test func startsAtOneSecond() {
    #expect(Tuning.Stages.spawnInterval(level: 1) == 1.0)
  }

  @Test func neverGetsSlowerAsStagesGoUp() {
    for level in 1 ..< 40 {
      #expect(Tuning.Stages.spawnInterval(level: level + 1) <= Tuning.Stages.spawnInterval(level: level))
    }
  }

  @Test func neverDropsBelowTheFloor() {
    #expect(Tuning.Stages.spawnInterval(level: 100) == Tuning.Stages.spawnFloor)
  }
}

struct DifficultyRampTests {

  @Test func rocksSpeedUpEveryStageThenLevelOff() {
    #expect(Tuning.Stages.speedScale(level: 1) == 1)
    for level in 1 ..< 30 {
      #expect(Tuning.Stages.speedScale(level: level + 1) > Tuning.Stages.speedScale(level: level))
    }
    #expect(Tuning.Stages.speedScale(level: 200) == 2)
  }

  @Test func pairsStartAtStageNine() {
    #expect(Tuning.Stages.pairChance(level: 8) == 0)
    #expect(Tuning.Stages.pairChance(level: 9) > 0)
    #expect(Tuning.Stages.pairChance(level: 200) == 0.5)
  }

  @Test func biggerRocksSpawnLessOften() {
    let sizes: [AsteroidSize] = [.tiny, .small, .average, .large, .huge, .massive, .bosstroid]
    for (smaller, bigger) in zip(sizes, sizes.dropFirst()) {
      #expect(Tuning.Stages.sizeSpacing(bigger) > Tuning.Stages.sizeSpacing(smaller))
    }
  }

  @Test func theBiggestRocksNeverComeInPairs() {
    #expect(AsteroidSize.bosstroid.rawValue >= Tuning.Stages.noPairsFrom.rawValue)
    #expect(AsteroidSize.huge.rawValue < Tuning.Stages.noPairsFrom.rawValue)
  }

  @Test func aSmartBombBreaksABosstroid() {
    let rock = Asteroid(asteroidSize: .bosstroid)
    var broke = false
    for _ in 0 ..< Tuning.PowerUps.bombPulses where !broke {
      broke = rock.hitAsteroid(value: Tuning.PowerUps.bombDamage) != nil
    }
    #expect(broke)
  }

  @Test func featuredShareGrowsAfterEveryTypeHasDebuted() {
    #expect(Tuning.Stages.featuredScale(level: 11) == 1)
    #expect(Tuning.Stages.featuredScale(level: 20) > 1)
    #expect(Tuning.Stages.featuredScale(level: 200) == 2)
    // Even doubled, a wave is never all one special type
    for type in AsteroidType.unlockOrder {
      #expect(type.waveShare * Tuning.Stages.featuredScale(level: 200) < 1)
    }
  }

  @Test func wavesGetLongerUpToACap() {
    #expect(Tuning.Stages.waveDuration(level: 1) == 10)
    #expect(Tuning.Stages.waveDuration(level: 20) > 10)
    #expect(Tuning.Stages.waveDuration(level: 200) == 18)
  }
}

struct PickupTests {

  @Test func everyPickupCanTurnUp() {
    let weighted = Set(Tuning.PowerUps.weights.filter { $0.weight > 0 }.map(\.pickup))
    #expect(weighted == Set(Pickup.allCases))
  }

  @Test func itemsOnlyNeverGivesPointsOrCoins() {
    for _ in 0 ..< 500 {
      #expect(Pickup.random(itemsOnly: true).isItem)
    }
  }

  @Test func pickupsAreRare() {
    #expect(Tuning.PowerUps.pickupChance <= 0.1)
    #expect(Tuning.PowerUps.maxItemsPerWave >= 1)
  }
}

struct AsteroidSizeTests {

  @Test func stageOneIsSmallRocksOnly() {
    let allowed: Set<AsteroidSize> = [.tiny, .small, .average]
    for _ in 0 ..< samples {
      #expect(allowed.contains(AsteroidSize.random(forLevel: 1)))
    }
  }

  @Test func noBosstroidsBeforeTheirStage() {
    for level in 1 ..< Tuning.Hazards.bosstroidFromLevel {
      for _ in 0 ..< samples / 10 {
        #expect(AsteroidSize.random(forLevel: level) != .bosstroid)
      }
    }
  }

  @Test func bosstroidsAppearOnceUnlocked() {
    let level = Tuning.Hazards.bosstroidFromLevel
    let sizes = (0 ..< samples).map { _ in AsteroidSize.random(forLevel: level) }
    #expect(sizes.contains(.bosstroid))
  }

  // Debris shrinks every time, so breaking rocks always ends
  @Test(arguments: [AsteroidSize.tiny, .small, .average, .large, .huge, .massive, .bosstroid])
  func debrisAlwaysEndsAtTiny(size: AsteroidSize) {
    var current: AsteroidSize? = size
    var steps = 0
    while let s = current, steps < 10 {
      if let next = s.nextSize() {
        #expect(next.rawValue < s.rawValue)
      }
      current = s.nextSize()
      steps += 1
    }
    #expect(current == nil)
  }
}

struct AsteroidSpeedTests {

  @Test func firstStagesAreSlowOrAverage() {
    let allowed: Set<AsteroidSpeed> = [.slow, .average]
    for level in 1 ... 2 {
      for _ in 0 ..< samples / 2 {
        #expect(allowed.contains(AsteroidSpeed.random(forLevel: level)))
      }
    }
  }

  @Test func veryFastUnlocksAtStageFive() {
    for level in 1 ... 4 {
      for _ in 0 ..< samples / 10 {
        #expect(AsteroidSpeed.random(forLevel: level) != .veryFast)
      }
    }
    let speeds = (0 ..< samples).map { _ in AsteroidSpeed.random(forLevel: 5) }
    #expect(speeds.contains(.veryFast))
  }
}

struct AsteroidTypeTests {

  @Test func stageOneHasNoSpecialType() {
    #expect(AsteroidType.featured(forLevel: 1) == .normal)
  }

  // The order players meet the types, as documented in the README
  @Test func eachStageDebutsTheNextType() {
    let debuts: [AsteroidType] = [
      .lowMass, .glass, .black, .ice, .comet, .gas, .elastic, .brass, .turret, .base
    ]
    for (i, type) in debuts.enumerated() {
      #expect(AsteroidType.featured(forLevel: i + 2) == type)
    }
  }

  @Test func afterAllDebutsEveryWaveHasASpecialType() {
    let firstRandomLevel = AsteroidType.unlockOrder.count + 2
    for level in firstRandomLevel ..< firstRandomLevel + 20 {
      #expect(AsteroidType.featured(forLevel: level) != .normal)
    }
  }

  @Test func typesThatForceASize() {
    #expect(AsteroidType.comet.adjust(size: .massive) == .small)
    #expect(AsteroidType.base.adjust(size: .tiny) == .massive)
    #expect(AsteroidType.brass.adjust(size: .tiny) == .large)
    #expect(AsteroidType.brass.adjust(size: .huge) == .huge)
    #expect(AsteroidType.turret.adjust(size: .tiny) == .average)
    #expect(AsteroidType.normal.adjust(size: .tiny) == .tiny)
  }
}

@MainActor
struct AsteroidBreakTests {

  @Test func glassShattersInOneWeakHitWithNoDebris() {
    let glass = Asteroid(asteroidSize: .massive, type: .glass)
    #expect(glass.hitAsteroid(value: MissilePower.weak.rawValue) == [])
  }

  @Test func normalRocksBreakIntoThreeSmallerRocks() {
    let rock = Asteroid(asteroidSize: .large, type: .normal)
    let debris = rock.hitAsteroid(value: 100)
    #expect(debris?.count == 3)
    #expect(debris?.allSatisfy { $0.asteroidSize == .small && $0.type == .normal } == true)
  }

  @Test func iceBurstsIntoTinyShards() {
    let ice = Asteroid(asteroidSize: .average, type: .ice)
    let shards = ice.hitAsteroid(value: 100)
    #expect(shards?.count == Tuning.Hazards.iceShards)
    #expect(shards?.allSatisfy { $0.asteroidSize == .tiny } == true)
  }

  @Test func tinyIceShardsDoNotSplitAgain() {
    let shard = Asteroid(asteroidSize: .tiny, type: .ice)
    #expect(shard.hitAsteroid(value: 100) == [])
  }

  @Test func gasExplodesWithoutDebris() {
    let gas = Asteroid(asteroidSize: .large, type: .gas)
    #expect(gas.hitAsteroid(value: 100) == [])
  }

  @Test func brassTakesMoreHitsThanNormal() {
    let brass = Asteroid(asteroidSize: .large, type: .brass)
    let rock = Asteroid(asteroidSize: .large, type: .normal)
    #expect(brass.hits > rock.hits)
  }

  @Test func aHitThatDoesNotBreakItReturnsNil() {
    let brass = Asteroid(asteroidSize: .large, type: .brass)
    #expect(brass.hitAsteroid(value: MissilePower.weak.rawValue) == nil)
  }
}
