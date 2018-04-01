//
//  ShipShield.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/31/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class ShipShield: SKSpriteNode {
  
  let shieldRadius: CGFloat = 20
  let shieldShape = SKShapeNode()
  
  init() {
    let size = CGSize(width: shieldRadius * 2, height: shieldRadius * 2)
    super.init(texture: nil, color: UIColor.clear, size: size)
    
    setupPhysics()
    setupShapes()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: shieldRadius)
    physicsBody?.isDynamic = false
    physicsBody?.categoryBitMask = PhysicsCategory.Shield
    physicsBody?.contactTestBitMask = PhysicsCategory.None
    physicsBody?.collisionBitMask = PhysicsCategory.Asteroid
  }
  
  func setupShapes() {
    addChild(shieldShape)
    
    shieldShape.path = UIBezierPath(ovalIn: self.frame).cgPath
    shieldShape.lineWidth = 1
    shieldShape.strokeColor = UIColor(r: 255, g: 200, b: 0, alpha: 1.0)
    shieldShape.fillColor = UIColor(r: 255, g: 200, b: 0, alpha: 0.5)
  }
  
}
