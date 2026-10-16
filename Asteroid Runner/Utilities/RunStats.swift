//
//  RunStats.swift
//  Asteroid Runner
//

// What the player did in one run, shown at game over. Distance grows while
// the ship is flying the waves; it's the voyage out from the sun. Coins and
// routes are here so playtests can see where a run's money went.

import Foundation

struct RunStats: Equatable {
  var asteroidsDestroyed = 0
  var turretsDestroyed = 0
  // Astronomical units traveled
  var distance: Double = 0
  // How many of each kind of wave the run met
  var wavesSeen = [WaveRecipe: Int]()
  // Coins in (pickups, stage clears, selling) and out (items, repairs,
  // upgrades), and upgrade tiers fitted
  var coinsEarned = 0
  var coinsSpent = 0
  var upgradesBought = 0
  // Routes chosen on the map, by danger. The first leg has no choice.
  var routesTaken = [RouteDanger: Int]()

  var distanceText: String {
    return String(format: "%.2f AU", distance)
  }

  // "Coins 142 earned, 120 spent  ·  Upgrades 3"
  var coinsText: String {
    return "Coins \(coinsEarned) earned, \(coinsSpent) spent  ·  Upgrades \(upgradesBought)"
  }

  // "Routes: Safe 2  ·  Normal 4", safest first; nil before any choice
  var routesText: String? {
    let taken = RouteDanger.allCases.compactMap { danger in
      routesTaken[danger].map { "\(danger.name) \($0)" }
    }
    return taken.isEmpty ? nil : "Routes: " + taken.joined(separator: "  ·  ")
  }

  // "Rock field 6 · Swarm 2 · Lanes 1", most common first
  var wavesText: String {
    let order = WaveRecipe.allCases
    return wavesSeen
      .sorted { $0.value != $1.value ? $0.value > $1.value : order.firstIndex(of: $0.key)! < order.firstIndex(of: $1.key)! }
      .map { "\($0.key.name) \($0.value)" }
      .joined(separator: "  ·  ")
  }
}
