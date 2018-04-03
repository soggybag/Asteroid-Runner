//
//  AsteroidSize.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// ----------------------------------
// Asteroid Sizes
// ----------------------------------

enum AsteroidSize: CGFloat {
  // set the radius
  case tiny      = 5
  case small     = 10
  case average   = 15
  case large     = 20
  case huge      = 25
  case massive   = 30
  case bosstroid = 60
  
  func nextSize() -> AsteroidSize? {
    switch self {
    case .bosstroid:
      return .large
      
    case .massive:
      return .average
      
    case .huge:
      return .small
      
    case .large:
      return .small
      
    case .average:
      return .tiny
      
    case .small:
      return .tiny
      
    default:
      return nil
      
    }
  }
  
  func toString() -> String {
    switch self {
    case .tiny: return "Tiny"
    case .small: return "Small"
    case .average: return "Average"
    case .large: return "Large"
    case .huge: return "Huge"
    case .massive: return "Massive"
    case .bosstroid: return "Boostroid"
    }
  }
  
  static func random() -> AsteroidSize {
    let allSizes = [AsteroidSize.tiny, .small, .average, .large, .huge, .massive, .bosstroid]
    return allSizes[Int.random(n: allSizes.count)]
  }
  
}
