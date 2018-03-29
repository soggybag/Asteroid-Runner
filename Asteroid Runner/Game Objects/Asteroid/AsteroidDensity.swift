//
//  AsteroidDensity.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

enum AsteroidDensity: CGFloat {
  // Set the mass
  case light    = 0.5
  case average  = 1.0
  case dense    = 2.0
  
  static func random() -> AsteroidDensity {
    let densities = [AsteroidDensity.light, .average, .dense]
    return densities[Int.random(n: densities.count)]
  }
}
