//
//  Ship.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Ship: SKSpriteNode {
  
  let shipSpeedSlow: CGFloat = 0.1
  let shipSpeedMed: CGFloat = 0.25
  let shipSpeedFast: CGFloat = 0.5
  
  let shipDampingSlow: CGFloat = 0.25
  let shipDampingMed: CGFloat = 0.5
  let shipDampingFast: CGFloat = 1
  
  var shipSpeed: CGFloat = 0.25
  
  init() {
    let size = CGSize(width: 20, height: 40)
    super.init(texture: nil, color: Colors.shipBlue, size: size)
    
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
    physicsBody?.applyImpulse(CGVector(dx: x * shipSpeed, dy: 0))
  }
  
  func moveForce(x: CGFloat) {
    physicsBody?.applyForce(CGVector(dx: x * shipSpeed, dy: 0))
  }
  
  func setShipSpeedSlow() {
    shipSpeed = shipSpeedSlow
    physicsBody?.linearDamping = shipDampingSlow
  }
  
  func setShipSpeedMed() {
    shipSpeed = shipSpeedMed
    physicsBody?.linearDamping = shipDampingMed
  }
  
  func setShipSpeedFast() {
    shipSpeed = shipSpeedFast
    physicsBody?.linearDamping = shipDampingFast
  }
}
