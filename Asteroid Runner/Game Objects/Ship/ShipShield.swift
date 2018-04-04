//
//  ShipShield.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/31/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit


// ---------------------------

// Shield Sprite

// ---------------------------

class ShipShield: SKSpriteNode {
  
  // MARK: Public properties
  
  let shieldRadius: CGFloat = (Ship.shipSize.width / 2) + 6
  let shieldShape = SKShapeNode()
  var shieldBody: SKPhysicsBody?
  
  
  // MARK: Initializers
  
  init() {
    let size = CGSize(width: shieldRadius * 2, height: shieldRadius * 2)
    super.init(texture: nil, color: UIColor.clear, size: size)
    
    setupPhysics()
    setupShapes()
    deactivate()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup methods
  
  func setupPhysics() {
    shieldBody = SKPhysicsBody(circleOfRadius: shieldRadius)
    shieldBody?.isDynamic = false
    shieldBody?.categoryBitMask = PhysicsCategory.Shield
    shieldBody?.contactTestBitMask = PhysicsCategory.None
    shieldBody?.collisionBitMask = PhysicsCategory.Asteroid
  }
  
  
  func setupShapes() {
    addChild(shieldShape)
    
    shieldShape.path = UIBezierPath(ovalIn: self.frame).cgPath
    shieldShape.lineWidth = 1
    shieldShape.strokeColor = UIColor(r: 255, g: 200, b: 0, alpha: 1.0)
    shieldShape.fillColor = UIColor(r: 255, g: 200, b: 0, alpha: 0.5)
  }
  
  
  // MARK: Public Methods
  
  // ---------------------------------
  // Activate
  // ---------------------------------
  
  func activate() {
    isHidden = false
    physicsBody = shieldBody
    removeAllActions()
    let t: TimeInterval = 0.1
    
    let wait = SKAction.wait(forDuration: t)
    let fadeIn = SKAction.fadeIn(withDuration: t)
    let fadeOut = SKAction.fadeOut(withDuration: t)
    let seq = SKAction.sequence([wait, fadeOut, wait, fadeIn])
    let rep = SKAction.repeat(seq, count: 10)
    
    let seqEnd = SKAction.sequence([wait, fadeIn, wait, fadeOut])
    let repEnd = SKAction.repeat(seqEnd, count: 10)
    
    let deactivateShield = SKAction.run {
      self.deactivate()
    }
    
    let longWait = SKAction.wait(forDuration: 10)
    let longSeq = SKAction.sequence([rep, longWait, repEnd, deactivateShield])
    run(longSeq)
  }
  
  
  // --------------------------------
  // Deactivate
  // --------------------------------
  
  func deactivate() {
    isHidden = true
    physicsBody = nil
  }
  
}
