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
    case .bosstroid: return "Bosstroid"
    }
  }
  
  static func random() -> AsteroidSize {
    let allSizes = [AsteroidSize.tiny, .small, .average, .large, .huge, .massive, .bosstroid]
    return allSizes.randomElement()!
  }
  
  // Larger asteroids become possible as the stages go by.
  // Bosstroids only show up from stage 6.
  static func random(forLevel level: Int) -> AsteroidSize {
    let sizes: [AsteroidSize] = [.tiny, .small, .average, .large, .huge, .massive]
    let largest = min(sizes.count, 2 + level)
    if level >= Tuning.Hazards.bosstroidFromLevel && Double.random(in: 0 ..< 1) < Tuning.Hazards.bosstroidChance {
      return .bosstroid
    }
    return sizes[0 ..< largest].randomElement()!
  }
  
}
