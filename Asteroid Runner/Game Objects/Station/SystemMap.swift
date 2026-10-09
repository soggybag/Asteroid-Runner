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

    // Each station leads to stations in the next region out. Past
    // Neptune, to the other Neptune stations, until there's a win.
    var routes: [String: [MapRoute]] = [:]
    for from in stations {
      let targets = stations.filter {
        $0.region == (from.region.next ?? from.region) && $0.id != from.id
      }.shuffled()
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
