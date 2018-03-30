//
//  PowerUp.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class PowerUp: SKSpriteNode {
  
  static let PU_POINTS = "points"
  static let PU_BOMB = "bomb"
  static let PU_SHIELD = "shield"
  static let PU_MISSILE_2 = "PU_NAME_MISSILE_2"
  static let PU_MISSILE_3 = "PU_NAME_MISSILE_3"
  static let PU_MISSILE_RAPID = "PU_NAME_MISSILE_RAPID"
  
  static let powerup_duration: TimeInterval = 10
  
  init() {
    
    super.init(texture: nil, color: .cyan, size: CGSize(width: 20, height: 20))
    
    name = PowerUp.PU_POINTS
    
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


