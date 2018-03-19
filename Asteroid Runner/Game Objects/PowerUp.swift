//
//  PowerUp.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class PowerUp: SKSpriteNode {
  init() {
    
    super.init(texture: nil, color: .cyan, size: CGSize(width: 20, height: 20))
    
    name = "Powerup"
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    
    physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
    physicsBody?.collisionBitMask = PhysicsCategory.None
    physicsBody?.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Edge
    
    physicsBody?.velocity = CGVector(dx: 0, dy: -25)
    physicsBody?.linearDamping = 0
  }
  
}


