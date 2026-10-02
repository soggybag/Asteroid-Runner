//
//  AsteroidSpeed.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// ----------------------------------
// Asteroid Speeds
// ----------------------------------

enum AsteroidSpeed: CGFloat {
  // set the velocity
  case slow     = 0.5
  case average  = 1.0
  case fast     = 2.0
  case veryFast = 4.0
  
  static func random() -> AsteroidSpeed {
    let allSpeeds = [AsteroidSpeed.slow, .average, .fast, .veryFast]
    return allSpeeds.randomElement()!
  }
  
  // Faster asteroids become possible as the stages go by.
  static func random(forLevel level: Int) -> AsteroidSpeed {
    let allSpeeds = [AsteroidSpeed.slow, .average, .fast, .veryFast]
    let fastest = min(allSpeeds.count, 1 + (level + 1) / 2)
    return allSpeeds[0 ..< fastest].randomElement()!
  }
  
  func toString() -> String {
    switch self {
    case .slow: return "Slow"
    case .average: return "Average"
    case .fast: return "Fast"
    case .veryFast: return "Very Fast"
    }
  }
}
