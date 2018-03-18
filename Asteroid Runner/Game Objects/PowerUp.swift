//
//  PowerUp.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

/*
 
Powerup Types
 
 1. Smart Bomb - Tapping asteroids destroys them
 2. Smarter Bomb - Destroys all asteroids on screen
 3. Coins - gain extra points
 4. Missile PU - Missiles do more damage
 5. Shield - Puts up a shield for limited time
 6. Rapid fire - Fires alot
 7. Scatter Gun - Fires in all directions
 8. Time Dilation - Slows the game
 9. Time Expansion - Speeds the game
 10. Shrinker - ...
 11. Manuever Jets - Makes controling the easier
 
 */

import SpriteKit

class PowerUp: SKSpriteNode {
  init() {
    
    super.init(texture: nil, color: .cyan, size: CGSize(width: 20, height: 20))
    
    name = "Powerup"
    
    setupPhysics()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    
    physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
    physicsBody?.collisionBitMask = PhysicsCategory.None
    physicsBody?.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Edge
    
    physicsBody?.velocity = CGVector(dx: 0, dy: -25)
    physicsBody?.linearDamping = 0
  }
  
}


