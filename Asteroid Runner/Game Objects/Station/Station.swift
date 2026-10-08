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

  static func load() -> [Station] {
    return GameData.load(StationList.self, from: "stations")?.stations ?? []
  }
}


// Plans the trip: which station is next and how many waves until it.
// One run of the game keeps one route.

struct StationRoute {

  let stations: [Station]
  private(set) var next: Station?
  private(set) var wavesLeft = 0
  // Waves from the last station to the next
  private(set) var legLength = 0
  private(set) var visited = Set<String>()

  init(stations: [Station]) {
    self.stations = stations
    planNext()
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

  // Count a cleared wave. Returns the station to dock at, if one is here.
  mutating func waveCleared() -> Station? {
    guard let station = next else { return nil }
    wavesLeft -= 1
    return wavesLeft <= 0 ? station : nil
  }

  // Remember the visit and plan the next stop
  mutating func docked(at station: Station) {
    visited.insert(station.id)
    planNext()
  }

  func hasVisited(_ station: Station) -> Bool {
    return visited.contains(station.id)
  }

  // A different station from the last one, when there's a choice
  private mutating func planNext() {
    let others = stations.filter { $0.id != next?.id }
    next = (others.isEmpty ? stations : others).randomElement()
    wavesLeft = Int.random(in: Tuning.Stations.minWaves ... Tuning.Stations.maxWaves)
    legLength = wavesLeft
  }
}
