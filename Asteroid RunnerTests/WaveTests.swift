//
//  WaveTests.swift
//  Asteroid RunnerTests
//

// Rules that decide what each stage throws at the player: spawn timing,
// which sizes, speeds and types unlock when. Random pickers are sampled
// many times and checked against what each stage allows.

import CoreGraphics
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

  @Test func pairsStartAtStageEleven() {
    #expect(Tuning.Stages.pairChance(level: 10) == 0)
    #expect(Tuning.Stages.pairChance(level: 11) > 0)
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

  @Test func rockFieldsNeverHaveBosstroids() {
    for level in 1 ..< 100 {
      #expect(!AsteroidSize.pool(forLevel: level).contains(.bosstroid))
    }
  }

  @Test func onlyBosstroidFieldsHaveBosstroids() {
    for recipe in WaveRecipe.allCases {
      let sizes = recipe.sizes(difficulty: 50).map(\.size)
      #expect(sizes.contains(.bosstroid) == (recipe == .bosstroidField))
    }
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

  // Brasstroids are forced to at least large when they spawn. Their debris
  // used to be forced back up too, so they split into same-size copies forever.
  @Test(arguments: [AsteroidType.normal, .lowMass, .black, .brass, .turret, .base, .elastic])
  func debrisIsAlwaysSmallerThanItsParent(type: AsteroidType) {
    for size in [AsteroidSize.average, .large, .huge, .massive, .bosstroid] {
      let rock = Asteroid(asteroidSize: size, type: type)
      guard let debris = rock.hitAsteroid(value: 1000) else { continue }
      for piece in debris {
        #expect(piece.asteroidSize.rawValue < rock.asteroidSize.rawValue)
      }
    }
  }

  @Test func brassBreaksDownToNothingEventually() {
    var rocks = [Asteroid(asteroidSize: .huge, type: .brass)]
    for _ in 0 ..< 10 {
      rocks = rocks.flatMap { $0.hitAsteroid(value: 1000) ?? [] }
    }
    #expect(rocks.isEmpty)
  }

  @Test func aHitThatDoesNotBreakItReturnsNil() {
    let brass = Asteroid(asteroidSize: .large, type: .brass)
    #expect(brass.hitAsteroid(value: MissilePower.weak.rawValue) == nil)
  }
}


// Wave recipes and pacing: which kind of wave comes when, how difficulty
// eases after a station, and the lane and maze layouts.

struct PacingTests {

  @Test func easierJustAfterAStation() {
    let stage = 12
    #expect(Tuning.Pacing.difficulty(stage: stage, progress: 0) == stage - Tuning.Pacing.relief)
    #expect(Tuning.Pacing.difficulty(stage: stage, progress: 1) == stage)
  }

  @Test func neverEasesBelowStageOne() {
    #expect(Tuning.Pacing.difficulty(stage: 1, progress: 0) == 1)
    #expect(Tuning.Pacing.difficulty(stage: 2, progress: 0) == 1)
  }

  @Test func buildsUpAlongTheWay() {
    var last = 0
    for step in 0 ... 10 {
      let difficulty = Tuning.Pacing.difficulty(stage: 20, progress: Double(step) / 10)
      #expect(difficulty >= last)
      last = difficulty
    }
  }

  @Test func legProgressRunsFromZeroToOne() {
    let station = Station(id: "a", name: "A", keeper: .init(name: "K", title: "T"), greetings: [:], farewell: nil,
                          shop: .init(sells: [], buyMultiplier: 1, sellMultiplier: 1))
    for _ in 0 ..< 50 {
      var route = StationRoute(stations: [station])
      if route.legLength > 1 {
        #expect(route.legProgress == 0)
      }
      while !route.stationAfterThisWave {
        _ = route.waveCleared()
      }
      #expect(route.legProgress == 1)
    }
  }

  @Test func noStationsMeansFullDifficulty() {
    #expect(StationRoute(stations: []).legProgress == 1)
  }
}

struct WaveRecipeTests {

  @Test func firstStagesArePlainRockFields() {
    for stage in 1 ... Tuning.Waves.fieldOnlyThrough {
      for _ in 0 ..< 50 {
        #expect(WaveRecipe.choose(stage: stage, progress: 1, previous: nil) == .field)
      }
    }
  }

  @Test func recipesWaitForTheirStage() {
    for stage in 1 ..< 30 {
      for _ in 0 ..< 40 {
        let recipe = WaveRecipe.choose(stage: stage, progress: 1, previous: nil)
        #expect(recipe.unlockStage <= stage)
      }
    }
  }

  @Test func hardWavesOnlyInTheSecondHalfOfTheTrip() {
    for _ in 0 ..< 500 {
      let recipe = WaveRecipe.choose(stage: 30, progress: 0.2, previous: nil)
      #expect(!recipe.isHard)
    }
  }

  @Test func everyRecipeTurnsUpEventually() {
    let seen = Set((0 ..< 2000).map { _ in WaveRecipe.choose(stage: 30, progress: 1, previous: nil) })
    #expect(seen == Set(WaveRecipe.allCases))
  }

  @Test func noSpecialWaveTwiceInARow() {
    for recipe in WaveRecipe.allCases where recipe != .field {
      for _ in 0 ..< 100 {
        #expect(WaveRecipe.choose(stage: 30, progress: 1, previous: recipe) != recipe)
      }
    }
  }

  @Test func aDebutStageShowsTheNewType() {
    for stage in 3 ... 11 {
      for _ in 0 ..< 40 {
        #expect(WaveRecipe.choose(stage: stage, progress: 1, previous: nil).usesFeatured)
      }
    }
  }

  @Test func scatterWavesMixSizes() {
    for recipe in WaveRecipe.allCases where recipe.layout == .scatter {
      #expect(recipe.sizes(difficulty: 10).count >= 2)
    }
  }

  @Test func bouncersAreAllElastroids() {
    let plan = WavePlan(recipe: .bouncers, stage: 12, difficulty: 12, featured: .turret, speed: .average,
                        direction: .top, sizes: WaveRecipe.bouncers.sizes(difficulty: 12))
    for _ in 0 ..< 100 {
      #expect(plan.randomType() == .elastic)
    }
  }

  @Test func onlyScatterWavesSendPairs() {
    for recipe in WaveRecipe.allCases {
      let plan = WavePlan(recipe: recipe, stage: 40, difficulty: 40, featured: .normal, speed: .average,
                          direction: .top, sizes: recipe.sizes(difficulty: 40))
      #expect((plan.pairChance > 0) == (recipe.layout == .scatter))
    }
  }
}

struct WaveLayoutTests {

  let width: CGFloat = 375

  @Test func lanesAreOnScreenAndWiderThanTheShip() {
    for lane in 0 ..< Tuning.Waves.laneCount {
      let x = WavePlan.laneX(lane, width: width)
      #expect(x > 0 && x < width)
    }
    let laneWidth = width / CGFloat(Tuning.Waves.laneCount)
    #expect(laneWidth > Ship.shipSize.width * 2)
  }

  @Test func someLanesAreAlwaysClear() {
    for _ in 0 ..< 50 {
      let lanes = WavePlan.activeLanes()
      #expect(lanes.count < Tuning.Waves.laneCount)
      #expect(Set(lanes).count == lanes.count)
    }
  }

  @Test func theMazeGapStaysOnScreen() {
    var center = width / 2
    for _ in 0 ..< 500 {
      center = WavePlan.nextMazeGap(after: center, width: width)
      #expect(center - Tuning.Waves.mazeGap / 2 >= 0)
      #expect(center + Tuning.Waves.mazeGap / 2 <= width)
    }
  }

  @Test func mazeRowsLeaveTheGapClear() {
    let rock = AsteroidSize.large.rawValue
    for center in stride(from: CGFloat(80), through: width - 80, by: 25) {
      let xs = WavePlan.mazeRow(gapCenter: center, width: width)
      #expect(!xs.isEmpty)
      for x in xs {
        // Room for the nudge and turn each rock gets when placed
        let edge = rock + Tuning.Waves.mazeClearance
        let clear = x + edge <= center - Tuning.Waves.mazeGap / 2 || x - edge >= center + Tuning.Waves.mazeGap / 2
        #expect(clear)
      }
    }
  }

  @Test func theMazeGapFitsTheShip() {
    #expect(Tuning.Waves.mazeGap > Ship.shipSize.width * 2.5)
  }
}


struct RoundFourTests {

  private func plan(_ recipe: WaveRecipe, featured: AsteroidType = .normal, speed: AsteroidSpeed = .average,
                    direction: AsteroidDirection = .top, difficulty: Int = 20) -> WavePlan {
    return WavePlan(recipe: recipe, stage: difficulty, difficulty: difficulty, featured: featured, speed: speed,
                    direction: direction, sizes: recipe.sizes(difficulty: difficulty))
  }

  @Test func shootersCallForShields() {
    #expect(plan(.field, featured: .turret).advice.system == .shields)
    #expect(plan(.heavy, featured: .base).advice.system == .shields)
  }

  @Test func aFastRockFieldIsNotBalanced() {
    #expect(plan(.field, speed: .veryFast).advice.system != nil)
    #expect(plan(.field, speed: .slow).advice.system == nil)
  }

  @Test func turretsAreCappedHoweverLate() {
    #expect(plan(.field, featured: .turret, difficulty: 200).featuredShare <= AsteroidType.turret.maxWaveShare)
    #expect(plan(.field, featured: .base, difficulty: 200).featuredShare <= AsteroidType.base.maxWaveShare)
  }

  @Test func shootersEnterFromTheTop() {
    #expect(AsteroidType.turret.entersFromTop)
    #expect(AsteroidType.base.entersFromTop)
    #expect(!AsteroidType.normal.entersFromTop)
  }

  @Test func scannerBlipsStartOnTheRadar() {
    let r: CGFloat = 48
    for recipe in WaveRecipe.allCases {
      for direction in [AsteroidDirection.top, .left, .right] {
        let wave = plan(recipe, direction: direction)
        for i in 0 ..< 9 {
          let p = WavePlan.scannerStart(wave, index: i, count: 9, radius: r)
          #expect(hypot(p.x, p.y) <= r * 1.01)
        }
      }
    }
  }

  @Test func scannerBlipsFollowSideWaves() {
    #expect(WavePlan.scannerHeading(plan(.field, direction: .left)).dx > 0)
    #expect(WavePlan.scannerHeading(plan(.field, direction: .right)).dx < 0)
    #expect(WavePlan.scannerHeading(plan(.lanes, direction: .left)).dx == 0)
  }

  @Test func gameOverListsWavesMostCommonFirst() {
    var stats = RunStats()
    stats.wavesSeen = [.swarm: 2, .field: 5, .maze: 1]
    #expect(stats.wavesText == "Rock field 5  ·  Swarm 2  ·  Asteroid maze 1")
  }
}


struct RoundFiveTests {

  @Test func missilesDontPushShooters() {
    for type in [AsteroidType.turret, .base, .brass] {
      let rock = Asteroid(asteroidSize: .large, type: type)
      #expect(rock.physicsBody!.collisionBitMask & PhysicsCategory.Missile == 0)
    }
  }

  @Test func shootersFireSlowerEarly() {
    #expect(Tuning.Hazards.fireScale(level: 1) == 1.5)
    #expect(Tuning.Hazards.fireScale(level: 10) > 1)
    #expect(Tuning.Hazards.fireScale(level: 21) == 1)
    #expect(Tuning.Hazards.fireScale(level: 100) == 1)
  }
}
