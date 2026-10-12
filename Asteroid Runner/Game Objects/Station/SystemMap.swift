//
//  SystemMap.swift
//  Asteroid Runner
//

// The system map: regions from Earth out to Neptune, stations in each,
// and routes from every station to stations in the next region out. The
// regions are the same every run; the stations and routes are new each
// run. A route's danger sets how long and how hard the leg is.
// See docs/system-map.md.

import Foundation

enum Region: Int, CaseIterable {
  case earth, mars, mainBelt, jupiter, saturn, uranus, neptune

  var name: String {
    switch self {
    case .earth: return "Earth and Moon"
    case .mars: return "Mars"
    case .mainBelt: return "Main belt"
    case .jupiter: return "Jupiter"
    case .saturn: return "Saturn"
    case .uranus: return "Uranus"
    case .neptune: return "Neptune"
    }
  }

  // The next region out, or nil at Neptune
  var next: Region? {
    return Region(rawValue: rawValue + 1)
  }

  // Difficulty on arriving here
  var difficulty: Int {
    return Tuning.Map.regionDifficulty[rawValue]
  }
}


// Safe routes are longer and easier, risky ones shorter and harder

enum RouteDanger: CaseIterable {
  case safe, normal, risky

  var name: String {
    switch self {
    case .safe: return "Safe"
    case .normal: return "Normal"
    case .risky: return "Risky"
    }
  }

  var lengths: ClosedRange<Int> {
    return Tuning.Map.legLengths(self)
  }

  var difficultyOffset: Int {
    return Tuning.Map.dangerOffset(self)
  }

  var loot: RouteLoot {
    return Tuning.Map.loot(self)
  }

  // 1 for safe up to 3 for risky, for the map's marks
  var level: Int {
    return RouteDanger.allCases.firstIndex(of: self)! + 1
  }
}


// What a route pays: how often pickups drift in, how many of them can be
// items, and coins for a coin pickup and for clearing a stage

struct RouteLoot: Equatable {
  let pickupChance: Double
  let maxItemsPerWave: Int
  let coinPickup: Int
  let stageClearCoins: Int
}


// One kind of route's numbers, as written in Data/routes.json. The file
// explains each one.

struct RouteSettings: Decodable, Equatable {
  let minStages: Int
  let maxStages: Int
  let difficulty: Int
  let pickupChance: Double
  let maxItemsPerWave: Int
  let coinPickup: Int
  let stageClearCoins: Int

  // At least one stage, even if min and max are swapped or below 1
  var stages: ClosedRange<Int> {
    let low = max(1, min(minStages, maxStages))
    return low ... max(low, maxStages, minStages)
  }

  // Kept in range: a chance from 0 to 1, no negative counts
  var loot: RouteLoot {
    return RouteLoot(pickupChance: min(max(pickupChance, 0), 1),
                     maxItemsPerWave: max(0, maxItemsPerWave),
                     coinPickup: max(0, coinPickup),
                     stageClearCoins: max(0, stageClearCoins))
  }
}


// Data/routes.json: settings for each danger

struct RouteTable: Decodable, Equatable {
  let safe: RouteSettings
  let normal: RouteSettings
  let risky: RouteSettings

  subscript(danger: RouteDanger) -> RouteSettings {
    switch danger {
    case .safe: return safe
    case .normal: return normal
    case .risky: return risky
    }
  }

  // The file, or the built-in numbers if it can't be read
  static func load() -> RouteTable {
    return GameData.load(RouteTable.self, from: "routes") ?? Tuning.Map.builtInRoutes
  }
}


// A station on the map: one of the station kinds from stations.json,
// with its own name, placed in a region

struct MapStation: Equatable {
  let station: Station
  let region: Region

  var id: String {
    return station.id
  }
}


// A way from one station to another

struct MapRoute: Equatable {
  // The station it leads to
  let to: String
  let danger: RouteDanger
  // Waves until the station
  let length: Int
}


// A route out of the station the ship is docked at, ready to fly: where
// it goes, how hard it is, and the waves on the way

struct LegOffer {
  let route: MapRoute
  let station: MapStation
  let difficulty: LegDifficulty
  let waves: [WavePlan]

  // The kinds of wave on the way, each once, in the order they come
  var recipes: [WaveRecipe] {
    var seen: [WaveRecipe] = []
    for wave in waves where !seen.contains(wave.recipe) {
      seen.append(wave.recipe)
    }
    return seen
  }
}


// How hard a leg is along the way: from where it starts to where it
// arrives, eased just after a station as before, shifted by danger

struct LegDifficulty: Equatable {
  let start: Int
  let end: Int
  let offset: Int

  func at(progress: Double) -> Int {
    let p = min(max(progress, 0), 1)
    let ramp = Double(start) + Double(end - start) * p
    let ease = Double(Tuning.Pacing.relief) * (1 - p)
    return max(1, Int((ramp - ease).rounded()) + offset)
  }
}


struct SystemMap {

  let stations: [MapStation]
  // Routes out of each station, by station id, safest first
  let routes: [String: [MapRoute]]
  // The first leg, from launch to a station near Earth
  let start: MapRoute

  func station(_ id: String) -> MapStation? {
    return stations.first { $0.id == id }
  }

  func stations(in region: Region) -> [MapStation] {
    return stations.filter { $0.region == region }
  }

  func routes(from id: String) -> [MapRoute] {
    return routes[id] ?? []
  }


  // A new map for a run. `kinds` are the stations from stations.json,
  // `names` the made-up names to give the map's stations. Nil without
  // any kinds.
  static func generate(kinds: [Station], names: [String]) -> SystemMap? {
    guard !kinds.isEmpty else { return nil }
    var names = names.shuffled()

    var stations: [MapStation] = []
    for region in Region.allCases {
      // Different kinds in a region while there are enough
      let regionKinds = kinds.shuffled()
      let count = Int.random(in: Tuning.Map.stationsPerRegion)
      for index in 0 ..< count {
        let kind = regionKinds[index % regionKinds.count]
        let id = "\(kind.id)-\(region.rawValue)-\(index)"
        let name = names.popLast() ?? "\(kind.name) \(region.rawValue + 1)-\(index + 1)"
        stations.append(MapStation(station: kind.renamed(id: id, name: name), region: region))
      }
    }

    // Each station leads to stations in the next region out. Neptune's
    // have none: reaching Neptune wins the run.
    var routes: [String: [MapRoute]] = [:]
    for from in stations {
      let targets = stations.filter { $0.region == from.region.next }.shuffled()
      let count = min(Int.random(in: Tuning.Map.routesPerStation), targets.count)
      let dangers = RouteDanger.allCases.shuffled().prefix(count)
      routes[from.id] = zip(targets, dangers).map { target, danger in
        MapRoute(to: target.id, danger: danger, length: Int.random(in: danger.lengths))
      }.sorted { $0.danger.difficultyOffset < $1.danger.difficultyOffset }
    }

    let first = stations.filter { $0.region == .earth }.randomElement()!
    let start = MapRoute(to: first.id, danger: .normal, length: Tuning.Map.firstLegLength)
    return SystemMap(stations: stations, routes: routes, start: start)
  }
}
