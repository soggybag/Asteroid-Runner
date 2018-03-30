//
//  MissileMode.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

enum MissileMode {
  case normal, double, triple
  
  static let missilePoints = [
    [CGPoint(x: 0, y: 20)],
    [CGPoint(x: -10, y: 20), CGPoint(x: 10, y: 20)],
    [CGPoint(x: -20, y: 20), CGPoint(x: 0, y: 20), CGPoint(x: 20, y: 20)],
    [CGPoint(x: -10, y: 20), CGPoint(x: 0, y: 25), CGPoint(x: 10, y: 20)]
  ]
  
  func getPoints() -> [CGPoint] {
    return MissileMode.missilePoints[self.hashValue]
  }
  
  static func random() -> MissileMode {
    let modes = [MissileMode.normal, .double, .triple]
    return modes[Int.random(n: modes.count)]
  }
  
  static func randomPowerup() -> MissileMode {
    let modes = [MissileMode.double, .triple]
    return modes[Int.random(n: modes.count)]
  }
}
