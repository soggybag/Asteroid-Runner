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

enum AsteroidSize: CGFloat {
  // set the radius
  case tiny = 5
  case small = 10
  case average = 15
  case large = 20
  case huge = 25
  case massive = 30
}

enum AsteroidSpeed: CGFloat {
  // set the velocity
  case slow = 0.5
  case average = 1.0
  case fast = 2.0
  case veryFast = 4.0
}

enum AsteroidDensity: CGFloat {
  // Set the mass
  case light = 0.5
  case average = 1.0
  case dense = 2.0
  
}


class Asteroid: SKSpriteNode {
  
  init(size: AsteroidSize, speed: AsteroidSpeed, density: AsteroidDensity) {
    let radius = size.rawValue
    let size = CGSize(width: radius * 2, height: radius * 2)
    super.init(texture: nil, color: .white, size: size)
    // Set name 
    name = "Asteroid"
    // Set the random color
    color = randomColor()
    // Configure physics for types
    configurePhysics(radius: radius, density: density, speed: speed)
  }
  
  init(size: CGSize) {
    if Int.random(min: 0, max: 10) == 0 {
      print("*** BIG Stroid ***")
      let s = CGSize(width: size.width * 3, height: size.width * 3)
      super.init(texture: nil, color: .brown, size: s)
    } else {
      super.init(texture: nil, color: .brown, size: size)
    }
    
    color = randomColor()
    
    name = "Asteroid"
    
    setupPhysics()
    configure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configurePhysics(radius: CGFloat, density: AsteroidDensity, speed: AsteroidSpeed) {
    // Make a physics body
    physicsBody = SKPhysicsBody(circleOfRadius: radius)
    
    guard let physicsBody = physicsBody else { return }
    
    // Set physics categories
    physicsBody.categoryBitMask = PhysicsCategory.Asteroid
    physicsBody.collisionBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile
    physicsBody.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Missile | PhysicsCategory.Edge
    
    // Remove damping
    physicsBody.linearDamping = 0
    physicsBody.angularDamping = 0
    
    // Apply some spin
    let rotation = CGFloat.random(min: -5, max: 5) * 0.25
    physicsBody.angularVelocity = rotation
    
    // Get a random number to determine starting position
    let n = Int.random(min: 0, max: 12)
    // Get the center of the screen
    let centerY = Screen.sharedInstance.centerY
    // Use these to set the initial position and velocity of asteroid
    var x: CGFloat
    var y: CGFloat
    var dx: CGFloat
    var dy: CGFloat
    //
    switch n {
    case 0: // Starts on Left
      x = -60
      y = CGFloat.random(min: centerY, max: centerY * 2)
      dx = CGFloat.random(min: 15, max: 50)
      dy = CGFloat.random(min: 25, max: 80) * -1
      
    case 1: // Starts on the Right
      x = Screen.sharedInstance.width + 60
      y = CGFloat.random(min: centerY, max: centerY * 2)
      dx = CGFloat.random(min: 15, max: 50) * -1
      dy = CGFloat.random(min: 25, max: 80) * -1
      
    case 2: // Down from Top
      x = CGFloat.random(min: 20, max: Screen.sharedInstance.width - 20)
      y = Screen.sharedInstance.height + 60
      dx = CGFloat.random(min: -10, max: 10)
      dy = CGFloat.random(min: 40, max: 100) * -1
      
    default: // Normal
      x = CGFloat.random(min: 20, max: Screen.sharedInstance.width - 20)
      y = Screen.sharedInstance.height + 20
      dx = 0
      dy = -20
      
    }
    
    position = CGPoint(x: x, y: y)
    physicsBody.velocity = CGVector(dx: dx * speed.rawValue, dy: dy * speed.rawValue)
    physicsBody.mass = physicsBody.mass * density.rawValue
  }
  
  
  
  
  
  func setupPhysics() {
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    
    physicsBody?.categoryBitMask = PhysicsCategory.Asteroid
    physicsBody?.collisionBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile
    physicsBody?.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Missile | PhysicsCategory.Edge
    
    let r = CGFloat.random(min: -5, max: 5) * 0.25
    physicsBody?.angularVelocity = r
    
    physicsBody?.linearDamping = 0
    physicsBody?.angularDamping = 0
  }
  
  func configure() {
    let r = Int.random(min: 0, max: 12)
    
    let centerY = Screen.sharedInstance.centerY
    
    var x: CGFloat
    var y: CGFloat
    var dx: CGFloat
    var dy: CGFloat
    
    switch r {
    case 0: // Starts on Left
      x = -20
      y = CGFloat.random(min: centerY, max: centerY * 2)
      dx = CGFloat.random(min: 15, max: 50)
      dy = CGFloat.random(min: 25, max: 80) * -1
      
    case 1: // Starts on the Right
      x = Screen.sharedInstance.width + 20
      y = CGFloat.random(min: centerY, max: centerY * 2)
      dx = CGFloat.random(min: 15, max: 50) * -1
      dy = CGFloat.random(min: 25, max: 80) * -1
      
    case 2: // Down from Top
      x = CGFloat.random(min: 20, max: Screen.sharedInstance.width - 20)
      y = Screen.sharedInstance.height + 20
      dx = CGFloat.random(min: -10, max: 10)
      dy = CGFloat.random(min: 40, max: 100) * -1
      
    default: // Normal
      x = CGFloat.random(min: 20, max: Screen.sharedInstance.width - 20)
      y = Screen.sharedInstance.height + 20
      dx = 0
      dy = -20
      
    }
    
    position = CGPoint(x: x, y: y)
    physicsBody?.velocity = CGVector(dx: dx, dy: dy)
  }
  
  func randomColor() -> UIColor {
    let r = CGFloat.random(min: 100, max: 140)
    let g = CGFloat.random(min: 70, max: 110)
    let b = CGFloat.random(min: 20, max: 40)
    
    return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
  }
  
}
