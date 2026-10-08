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
  static let PU_COIN = "coin"
  
  static let powerup_duration = Tuning.PowerUps.duration
  
  init() {
    
    super.init(texture: nil, color: .cyan, size: CGSize(width: 20, height: 20))
    
    name = PowerUp.PU_POINTS
    
    setupPhysics()
    tumble()
  }

  // A slow spin as it drifts down, so it reads as something floating in space
  func tumble() {
    let turn = CGFloat.random(in: 0.6 ... 1.4) * (Bool.random() ? 1 : -1)
    run(.repeatForever(.rotate(byAngle: turn, duration: 1)))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    
    physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
    physicsBody?.collisionBitMask = PhysicsCategory.None
    physicsBody?.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Edge
    
    physicsBody?.velocity = CGVector(dx: 0, dy: -Tuning.PowerUps.fallSpeed)
    physicsBody?.linearDamping = 0
  }
  
}


