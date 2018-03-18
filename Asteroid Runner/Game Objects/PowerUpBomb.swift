//
//  PowerUpBomb.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class PowerUpBomb: PowerUp {
  override init() {
    super.init()
    name = "Powerup Bomb"
    
    color = .orange
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
