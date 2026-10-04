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

  static let FLICKER = "FLICKER"
  
  
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
    shieldShape.strokeColor = Colors.shieldStrokeColor
    shieldShape.fillColor = Colors.shieldFillColor
  }
  
  
  // MARK: Public Methods
  
  // ---------------------------------
  // Activate. Stays up until deactivated;
  // the item tray keeps track of the charge.
  // ---------------------------------
  
  var isActive: Bool {
    return !isHidden
  }
  
  func activate() {
    isHidden = false
    alpha = 1
    physicsBody = shieldBody
    removeAllActions()
  }
  
  
  // ---------------------------------
  // Flicker as a warning the charge is nearly gone
  // ---------------------------------
  
  func flicker(_ on: Bool) {
    if on {
      guard action(forKey: ShipShield.FLICKER) == nil else { return }
      let t: TimeInterval = 0.1
      let seq = SKAction.sequence([.fadeOut(withDuration: t), .fadeIn(withDuration: t)])
      run(.repeatForever(seq), withKey: ShipShield.FLICKER)
    } else {
      removeAction(forKey: ShipShield.FLICKER)
      alpha = 1
    }
  }
  
  
  // --------------------------------
  // Deactivate
  // --------------------------------
  
  func deactivate() {
    removeAllActions()
    isHidden = true
    physicsBody = nil
  }
  
}
