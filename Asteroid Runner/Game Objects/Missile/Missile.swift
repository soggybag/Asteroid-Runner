//
//  Missile.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit


class Missile: SKSpriteNode {
  
  // --------------------------------
  // MARK: Static Properties
  // --------------------------------
  
  static let powerLevelLow: CGFloat = 0.00125
  static let powerLevelMed: CGFloat = 0.0025
  static let powerLevelHi: CGFloat  = 0.005
  
  static var power: CGFloat = 0.00125
  
  static var missilePower: MissilePower = .average
  
  static let NAME = "missile"
  
  
  // --------------------------------
  // MARK: Static Methods
  // --------------------------------
  
  static func setPowerLow() {
    Missile.power = Missile.powerLevelLow
    Missile.missilePower = .weak
  }
  
  static func setPowerMed() {
    Missile.power = Missile.powerLevelMed
    Missile.missilePower = .average
  }
  
  static func setPowerHi() {
    Missile.power = Missile.powerLevelHi
    Missile.missilePower = .strong
  }
  
  
  // --------------------------------
  // MARK: Initializers
  // --------------------------------
  
  init() {
    let size = CGSize(width: 2, height: 4)
    super.init(texture: nil, color: .yellow, size: size)
    
    name = Missile.NAME
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // --------------------------------
  // MARK: Public Methods
  // --------------------------------
  
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
  
}
