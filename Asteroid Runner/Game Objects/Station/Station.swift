//
//  Station.swift
//  Asteroid Runner
//

// Space stations the ship docks at between runs of waves. Names, keepers,
// dialog and shop stock come from Data/stations.json; this file decides
// which greeting to show, what things cost, and when the next station
// comes along.

import Foundation

struct Station: Decodable, Equatable {

  struct Keeper: Decodable, Equatable {
    let name: String
    let title: String
  }

  struct Shop: Decodable, Equatable {
    // Item ids from the file: "bomb", "shield", "multiShot", "rapidFire", "fuel"
    let sells: [String]
    // Multiplies what the player pays. Below 1 is cheap.
    let buyMultiplier: Double
    // Multiplies what the player is paid. Above 1 pays well.
    let sellMultiplier: Double
    // Upgrade ids from the file: "reactor", "cargoRack", "hullPlating",
    // "thrusters", "weaponFocus", "shieldCapacitor"
    var upgrades: [String]? = nil
  }

  let id: String
  let name: String
  let keeper: Keeper
  let greetings: [String: [String]]
  let farewell: [String]?
  let shop: Shop


  // Items this station sells that exist in the game. Fuel is skipped
  // until fuel is built.
  var itemsForSale: [ItemType] {
    return shop.sells.compactMap { ItemType(id: $0) }
  }


  // Ship upgrades this station can fit
  var upgradesForSale: [ShipUpgrade] {
    return (shop.upgrades ?? []).compactMap { ShipUpgrade(id: $0) }
  }

  // Price of an upgrade's next tier here, or nil when it's maxed
  func upgradePrice(_ upgrade: ShipUpgrade, tier: Int) -> Int? {
    guard let base = upgrade.basePrice(forTier: tier) else { return nil }
    return Int((Double(base) * shop.buyMultiplier).rounded(.up))
  }

  // The same kind of station under another name, for the system map
  func renamed(id: String, name: String) -> Station {
    return Station(id: id, name: name, keeper: keeper, greetings: greetings,
                   farewell: farewell, shop: shop)
  }

  // A line for the situation, falling back to the first-visit lines
  func greeting(for situation: StationSituation) -> String {
    let lines = greetings[situation.rawValue] ?? []
    let fallback = greetings[StationSituation.firstVisit.rawValue] ?? []
    return (lines.isEmpty ? fallback : lines).randomElement() ?? "Welcome to \(name)."
  }

  func farewellLine() -> String {
    return farewell?.randomElement() ?? "Safe flying."
  }


  // MARK: Prices, in coins

  func buyPrice(_ item: ItemType) -> Int {
    return Int((Double(Tuning.Stations.price(item)) * shop.buyMultiplier).rounded(.up))
  }

  func sellPrice(_ item: ItemType) -> Int {
    let value = Double(Tuning.Stations.price(item)) * Tuning.Stations.resaleShare * shop.sellMultiplier
    return max(1, Int(value.rounded(.down)))
  }

  var repairPrice: Int {
    return Int((Double(Tuning.Stations.repairPrice) * shop.buyMultiplier).rounded(.up))
  }
}


// Which greeting a keeper uses. The first that applies wins, in the order
// listed in stations.json: damaged, low fuel, carrying something the
// station wants, been here before, first visit.

enum StationSituation: String {
  case shipDamaged, lowFuel, carryingWanted, returnVisit, firstVisit

  static func pick(damaged: Bool, carryingWanted: Bool, visitedBefore: Bool) -> StationSituation {
    if damaged { return .shipDamaged }
    if carryingWanted { return .carryingWanted }
    if visitedBefore { return .returnVisit }
    return .firstVisit
  }
}


// All the stations, loaded from Data/stations.json

struct StationList: Decodable {
  let stations: [Station]
  // Made-up names for the system map's stations
  let mapNames: [String]?

  static func load() -> [Station] {
    return GameData.load(StationList.self, from: "stations")?.stations ?? []
  }

  static func loadMapNames() -> [String] {
    return GameData.load(StationList.self, from: "stations")?.mapNames ?? []
  }
}


// Plans the trip across the system map: which station is next, how many
// waves until it, and what each of those waves holds. A leg's waves are
// planned when its route is chosen, so the map can show what's on a
// route. One run of the game keeps one route and one map.

struct StationRoute {

  // Nil when there are no stations: no docking, and waves are chosen as
  // they come
  let map: SystemMap?
  private(set) var next: Station?
  // The station last docked at, nil before the first
  private(set) var current: MapStation?
  // The route being flown
  private(set) var route: MapRoute?
  private(set) var wavesLeft = 0
  // Waves from the last station to the next
  private(set) var legLength = 0
  private(set) var visited = Set<String>()
  // The leg's waves, in order, and the stage number of the first one
  private(set) var legWaves: [WavePlan] = []
  private(set) var legStartStage = 1
  private(set) var legDifficulty = LegDifficulty(start: 1, end: 1, offset: 0)
  // Legs flown past Neptune, until reaching it wins the run
  private(set) var legsPastLastRegion = 0

  init(stations: [Station], names: [String] = [], firstStage: Int = 1) {
    map = SystemMap.generate(kinds: stations, names: names)
    if let map = map {
      fly(map.start, fromStage: firstStage)
    }
  }

  // How far along the run to the next station the coming wave is: 0 for
  // the first wave after a station, 1 for the last before the next.
  // With no stations, always 1.
  var legProgress: Double {
    guard next != nil, legLength > 1 else { return 1 }
    return Double(legLength - wavesLeft) / Double(legLength - 1)
  }

  // True when the coming wave is the last before a station
  var stationAfterThisWave: Bool {
    return next != nil && wavesLeft == 1
  }

  // The routes out of the station last docked at
  var routesOut: [MapRoute] {
    guard let map = map, let current = current else { return [] }
    return map.routes(from: current.id)
  }

  // Count a cleared wave. Returns the station to dock at, if one is here.
  mutating func waveCleared() -> Station? {
    guard let station = next else { return nil }
    wavesLeft -= 1
    return wavesLeft <= 0 ? station : nil
  }

  // Remember the visit and set off on a route out. `nextStage` is the
  // stage number of the first wave after this station. Until the map
  // screen lets the player choose, take the normal route.
  mutating func docked(at station: Station, nextStage: Int) {
    visited.insert(station.id)
    current = map?.station(station.id)
    let routes = routesOut
    guard let route = routes.first(where: { $0.danger == .normal }) ?? routes.randomElement() else {
      next = nil
      return
    }
    choose(route, nextStage: nextStage)
  }

  // Fly a route out of the current station
  mutating func choose(_ route: MapRoute, nextStage: Int) {
    fly(route, fromStage: nextStage)
  }

  // The planned wave for a stage, if it's on this leg
  func wave(forStage stage: Int) -> WavePlan? {
    let index = stage - legStartStage
    return legWaves.indices.contains(index) ? legWaves[index] : nil
  }

  func hasVisited(_ station: Station) -> Bool {
    return visited.contains(station.id)
  }

  // How hard a route from the current station would be: from the region
  // it leaves to the region it reaches, shifted by its danger. Past
  // Neptune, each leg a step harder.
  func difficulty(of route: MapRoute) -> LegDifficulty {
    let offset = route.danger.difficultyOffset
    guard let current = current else {
      return LegDifficulty(start: Tuning.Map.startDifficulty, end: Region.earth.difficulty, offset: offset)
    }
    let arriving = map?.station(route.to)?.region ?? current.region
    if arriving == current.region {
      let base = Region.neptune.difficulty + Tuning.Map.pastLastRegionStep * legsPastLastRegion
      return LegDifficulty(start: base, end: base + Tuning.Map.pastLastRegionStep, offset: offset)
    }
    return LegDifficulty(start: current.region.difficulty, end: arriving.difficulty, offset: offset)
  }

  // Set off on a route and plan its waves
  private mutating func fly(_ route: MapRoute, fromStage firstStage: Int) {
    legDifficulty = difficulty(of: route)
    if let current = current, map?.station(route.to)?.region == current.region {
      legsPastLastRegion += 1
    }
    self.route = route
    next = map?.station(route.to)?.station
    wavesLeft = route.length
    legLength = route.length
    legStartStage = firstStage
    legWaves = StationRoute.planLeg(from: firstStage, length: legLength,
                                    difficulty: legDifficulty, previous: legWaves.last?.recipe)
  }

  // Waves for a leg: the first right after a station (progress 0), the
  // last just before the next (progress 1)
  static func planLeg(from firstStage: Int, length: Int, difficulty: LegDifficulty,
                      previous: WaveRecipe?) -> [WavePlan] {
    var waves: [WavePlan] = []
    for index in 0 ..< length {
      let progress = length > 1 ? Double(index) / Double(length - 1) : 1
      waves.append(WavePlan.make(stage: firstStage + index, difficulty: difficulty.at(progress: progress),
                                 progress: progress, previous: waves.last?.recipe ?? previous))
    }
    return waves
  }
}
