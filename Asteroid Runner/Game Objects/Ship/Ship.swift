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
  
  var shieldSprite = SKShapeNode()
  var shieldActive = false
  var shield: ShipShield?
  
  var mm: CGFloat = 0
  
  override var position: CGPoint {
    didSet {
      super.position = self.position
      // shield?.position = self.position
    }
  }
  
  init() {
    let size = CGSize(width: 20, height: 40)
    super.init(texture: nil, color: Colors.shipBlue, size: size)
    
    name = "Ship"
    
    setupShield()
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  func setupShield() {
    let rect = CGRect(x: -size.width, y: -size.width, width: size.width * 2, height: size.width * 2)
    let path = UIBezierPath(ovalIn: rect)
    shieldSprite.path = path.cgPath
    
    shieldSprite.strokeColor = Colors.shieldStrokeColor
    shieldSprite.lineWidth = 2
    shieldSprite.fillColor = Colors.shieldFillColor
    
    addChild(shieldSprite)
    
    deactivateShield()
  }
  
  func hide() {
    isHidden = true
  }
  
  func show() {
    isHidden = false
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: 15)
    physicsBody!.categoryBitMask = PhysicsCategory.Ship
    physicsBody!.collisionBitMask = PhysicsCategory.Edge
    physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid
    
    physicsBody!.linearDamping = 0.5
    
    mm = physicsBody!.mass
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
  
  func activateShield() {
    shieldSprite.isHidden = false
    shieldActive = true
    
    run(SKAction.sequence([.wait(forDuration: 6), .run({
      self.deactivateShield()
    })]))
  }
  
  func deactivateShield() {
    shieldSprite.isHidden = true
    shieldActive = false
  }
}
