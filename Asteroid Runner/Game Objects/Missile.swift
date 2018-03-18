//
//  Missile.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Missile: SKSpriteNode {
  init() {
    let size = CGSize(width: 2, height: 4)
    super.init(texture: nil, color: .yellow, size: size)
    
    name = "Missile"
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: 2)
    
    physicsBody?.mass = 0.005
    
    physicsBody!.categoryBitMask = PhysicsCategory.Missile
    physicsBody!.collisionBitMask = PhysicsCategory.Asteroid
    physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Edge
    
    let missileVelocity = CGVector(dx: 0, dy: 50)
    physicsBody!.velocity = missileVelocity
    physicsBody!.linearDamping = 0
  }
}
