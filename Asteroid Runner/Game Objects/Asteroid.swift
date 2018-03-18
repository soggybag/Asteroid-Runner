//
//  Asteroid.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

/*
 
Asteroid types
 
 1. Normal
 2. Glassteroid - transparent but shatters when hit
 3. Blacksteroids - dark and hard to see against space background
 4. Gasteroids - Explode when hit
 5. Brasserteroids - Super massive
 6. Commets - Fly fast at an angle
 7. Icestroids - shard when hit
 8. Asteroids - break up when hit enough
 9. Asteroid Turret - Has turret that fires, can be broken to destroy turret
10. Low mass asteroids -
11. Elastroids - Bouncey asteroids
12. Coins - 
 
*/

import SpriteKit

class Asteroid: SKSpriteNode {
  init(size: CGSize) {
    super.init(texture: nil, color: .brown, size: size)
    
    color = randomColor()
    
    name = "Asteroid"
    
    setupPhysics()
    configure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    
    physicsBody?.categoryBitMask = PhysicsCategory.Asteroid
    physicsBody?.collisionBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile
    physicsBody?.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Missile | PhysicsCategory.Edge
    
    let r = (CGFloat(arc4random_uniform(10)) - 5) * 0.25
    physicsBody?.angularVelocity = r
    
    physicsBody?.linearDamping = 0
    physicsBody?.angularDamping = 0
  }
  
  func configure() {
    let r = arc4random_uniform(12)
    switch r {
    case 0: // Starts on Left
      let x: CGFloat = -20
      let y = CGFloat.random(min: 0, max: Screen.sharedInstance.centerY)
      position = CGPoint(x: x, y: y)
      let dx = CGFloat.random(min: 15, max: 50)
      let dy = CGFloat.random(min: 25, max: 60) * -1
      physicsBody?.velocity = CGVector(dx: dx, dy: dy)
      
    case 1: // Starts on the Right
      let x: CGFloat = Screen.sharedInstance.width + 20
      let y = CGFloat.random(min: 0, max: Screen.sharedInstance.centerY)
      position = CGPoint(x: x, y: y)
      let dx = CGFloat.random(min: 15, max: 50) * -1
      let dy = CGFloat.random(min: 25, max: 60) * -1
      physicsBody?.velocity = CGVector(dx: dx, dy: dy)
      
    case 2: // Down from Top
      let x = CGFloat.random(min: 20, max: Screen.sharedInstance.width - 20)
      let y = Screen.sharedInstance.height + 20
      position = CGPoint(x: x, y: y)
      physicsBody?.velocity = CGVector(dx: 0, dy: -20)
      
    default: // Normal
      let x = CGFloat.random(min: 20, max: Screen.sharedInstance.width - 20)
      let y = Screen.sharedInstance.height + 20
      position = CGPoint(x: x, y: y)
      physicsBody?.velocity = CGVector(dx: 0, dy: -20)
      
    }
  }
  
  func randomColor() -> UIColor {
    let r = CGFloat(arc4random_uniform(50) + 100)
    let g = CGFloat(arc4random_uniform(30) + 70)
    let b = CGFloat(arc4random_uniform(20) + 20)
    
    return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
  }
  
}
