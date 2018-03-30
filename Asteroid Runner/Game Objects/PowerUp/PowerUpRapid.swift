//
//  PowerUpBomb.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class PowerUpRapid: PowerUp {
  override init() {
    super.init()
    
    name = PowerUp.PU_MISSILE_RAPID
    
    color = Colors.powerupRapid
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
