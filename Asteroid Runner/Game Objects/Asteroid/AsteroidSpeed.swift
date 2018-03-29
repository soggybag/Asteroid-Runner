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
    return allSpeeds[Int.random(n: allSpeeds.count)]
  }
}
