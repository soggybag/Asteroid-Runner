//
//  Missile.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

enum MissileType: CGFloat {
  case weak     = 1
  case average  = 2
  case strong   = 3
}

class Missile: SKSpriteNode {
  
  static let powerLevelLow: CGFloat = 0.00125
  static let powerLevelMed: CGFloat = 0.0025
  static let powerLevelHi: CGFloat  = 0.005
  
  static var power: CGFloat = 0.00125
  
  static var missileType: MissileType = .average
  
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
    
    physicsBody?.mass = Missile.power
    
    physicsBody!.categoryBitMask = PhysicsCategory.Missile
    physicsBody!.collisionBitMask = PhysicsCategory.Asteroid
    physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Edge
    
    let missileVelocity = CGVector(dx: 0, dy: 100)
    physicsBody!.velocity = missileVelocity
    physicsBody!.linearDamping = 0
  }
  
  static func setPowerLow() {
    Missile.power = Missile.powerLevelLow
    Missile.missileType = .weak
  }
  
  static func setPowerMed() {
    Missile.power = Missile.powerLevelMed
    Missile.missileType = .average
  }
  
  static func setPowerHi() {
    Missile.power = Missile.powerLevelHi
    Missile.missileType = .strong
  }
  
}
