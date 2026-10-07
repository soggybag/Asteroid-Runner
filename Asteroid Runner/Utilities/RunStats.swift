//
//  RunStats.swift
//  Asteroid Runner
//

// What the player did in one run, shown at game over. Distance grows while
// the ship is flying the waves; it's the voyage out from the sun.

import Foundation

struct RunStats: Equatable {
  var asteroidsDestroyed = 0
  var turretsDestroyed = 0
  // Astronomical units traveled
  var distance: Double = 0
  // How many of each kind of wave the run met
  var wavesSeen = [WaveRecipe: Int]()

  var distanceText: String {
    return String(format: "%.2f AU", distance)
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
