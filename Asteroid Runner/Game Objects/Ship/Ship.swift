//
//  Ship.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// ----------------------------------------------

// Ship

// ----------------------------------------------


class Ship: SKSpriteNode {
  
  // MARK: Public Properties
  
  let shipSpeedSlow: CGFloat = 0.1
  let shipSpeedMed: CGFloat = 0.25
  let shipSpeedFast: CGFloat = 0.5
  
  let shipDampingSlow: CGFloat = 0.25
  let shipDampingMed: CGFloat = 0.5
  let shipDampingFast: CGFloat = 1
  
  var shipSpeed: CGFloat = 0.25
  
  static var shipSize = CGSize(width: 32, height: 32)
  
  var shieldSprite = SKShapeNode()
  var shieldActive = false
  var shield: ShipShield?
  
  var mm: CGFloat = 0
  
  
  // MARK: Getters Setters
  
  override var position: CGPoint {
    didSet {
      super.position = self.position
      // shield?.position = self.position
    }
  }
  
  
  // MARK: Initializers
  
  init() {
    let size = CGSize(width: Ship.shipSize.width + 6, height: Ship.shipSize.height + 6)
    super.init(texture: nil, color: Colors.shipBlue, size: size)
    
    name = "Ship"
    
    setupShield()
    setupTextures()
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: Setup methods
  
  func setupTextures() {
    var textures = [SKTexture]()
    for i in 1 ... 5 {
      let texture = SKTexture(imageNamed: "Satellite_4_\(i).png")
      textures.append(texture)
    }
    
    self.size = textures[0].size()
    self.texture = textures[0]
    run(.repeatForever(.animate(with: textures, timePerFrame: 0.1)))
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
  
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: 15)
    physicsBody!.categoryBitMask = PhysicsCategory.Ship
    physicsBody!.collisionBitMask = PhysicsCategory.Edge
    physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid
    
    physicsBody!.linearDamping = 0.5
    
    mm = physicsBody!.mass
  }
  
  
  // MARK: Public methods
  
  
  // ----------------------------
  // Hide
  // ----------------------------
  
  func hide() {
    isHidden = true
  }
  
  
  // ----------------------------
  // Show
  // ----------------------------
  
  func show() {
    isHidden = false
  }
  
  
  // ---------------------------
  // Move by impulse
  // ---------------------------
  
  func move(x: CGFloat) {
    physicsBody?.applyImpulse(CGVector(dx: x * shipSpeed, dy: 0))
  }
  
  
  // ---------------------------
  // Move by force
  // ---------------------------
  
  func moveForce(x: CGFloat) {
    physicsBody?.applyForce(CGVector(dx: x * shipSpeed, dy: 0))
  }
  
  
  // ---------------------------
  // Set speed slow
  // ---------------------------
  
  func setShipSpeedSlow() {
    shipSpeed = shipSpeedSlow
    physicsBody?.linearDamping = shipDampingSlow
  }
  
  
  // ---------------------------
  // Set speed med
  // ---------------------------
  
  func setShipSpeedMed() {
    shipSpeed = shipSpeedMed
    physicsBody?.linearDamping = shipDampingMed
  }
  
  
  // ---------------------------
  // Set speed fast
  // ---------------------------
  
  func setShipSpeedFast() {
    shipSpeed = shipSpeedFast
    physicsBody?.linearDamping = shipDampingFast
  }
  
  
  // ---------------------------
  // Activate Shield
  // ---------------------------
  
  func activateShield() {
    shieldSprite.isHidden = false
    shieldActive = true
    
    run(SKAction.sequence([.wait(forDuration: 6), .run({
      self.deactivateShield()
    })]))
  }
  
  
  // ---------------------------
  // Deactivate Shield
  // ---------------------------
  
  func deactivateShield() {
    shieldSprite.isHidden = true
    shieldActive = false
  }
}
