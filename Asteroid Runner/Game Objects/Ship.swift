//
//  Ship.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Ship: SKSpriteNode {
  
  init() {
    let size = CGSize(width: 20, height: 40)
    super.init(texture: nil, color: .red, size: size)
    
    name = "Ship"
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func hide() {
    isHidden = true
  }
  
  func show() {
    isHidden = false
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: 15)
    physicsBody?.categoryBitMask = PhysicsCategory.Ship
    physicsBody?.collisionBitMask = PhysicsCategory.Edge
    physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid
    
    physicsBody?.linearDamping = 0.5
  }
  
  func move(x: CGFloat) {
    physicsBody?.applyImpulse(CGVector(dx: x, dy: 0))
  }
}
