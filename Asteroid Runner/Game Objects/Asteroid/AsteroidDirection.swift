//
//  AsteroidDirection.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// ----------------------------------
// Asteroid Directions
// ----------------------------------

enum AsteroidDirection {
  case top, left, right
  
  static func random() -> AsteroidDirection {
    let allDirections = [AsteroidDirection.left, .top, .right]
    return allDirections.randomElement()!
  }
  
  func toString() -> String {
    switch self {
    case .top: return "Top"
    case .left: return "Left"
    case .right: return "Right"
    }
  }
}
