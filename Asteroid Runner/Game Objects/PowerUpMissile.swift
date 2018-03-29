//
//  PowerUpBomb.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class PowerUpMissile: PowerUp {
  override init() {
    super.init()
    
    name = PowerUp.PU_MISSILE_2
    
    color = Colors.powerupMissile
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
