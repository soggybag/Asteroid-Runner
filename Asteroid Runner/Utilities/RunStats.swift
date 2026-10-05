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

  var distanceText: String {
    return String(format: "%.2f AU", distance)
  }
}
