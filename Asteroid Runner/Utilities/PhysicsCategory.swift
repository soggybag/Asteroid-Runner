//
//  PhysicsCategories.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
  static let None:      UInt32 = 0          // 0000000
  static let Ship:      UInt32 = 0b1        // 0000001
  static let Asteroid:  UInt32 = 0b10       // 0000010
  static let Missile:   UInt32 = 0b100      // 0000100
  static let Edge:      UInt32 = 0b1000     // 0001000
  static let OuterEdge: UInt32 = 0b10000    // 0010000
  static let PowerUp:   UInt32 = 0b100000   // 0100000
}
