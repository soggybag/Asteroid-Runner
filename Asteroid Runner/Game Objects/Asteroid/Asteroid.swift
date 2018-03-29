//
//  Asteroid.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// ----------------------------------

// Asteroid Class

// ----------------------------------

class Asteroid: SKSpriteNode {
  
  // --------------------------------
  // MARK: Static Properties
  // --------------------------------
  
  static let NAME = "asteroid"
  
  // --------------------------------
  // MARK: Class properties
  // --------------------------------
  
  var hits: CGFloat = 0
  var asteroidSize = AsteroidSize.average
  
  
  // --------------------------------
  // MARK: Initializers
  // --------------------------------
  
  // Init with size and speed
  
  init(asteroidSize: AsteroidSize, speed: AsteroidSpeed) {
    let radius = asteroidSize.rawValue
    let size = CGSize(width: radius * 2, height: radius * 2)
    super.init(texture: nil, color: .white, size: size)
    // Set name 
    name = Asteroid.NAME
    // Set hits
    hits = asteroidSize.rawValue / 5
    self.asteroidSize = asteroidSize
    
    // Set the random color
    color = Colors.randomAsteroidColor()
    // Configure physics for types
    configurePhysics(radius: radius, speed: speed)
  }
  
  // Required init with coder
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // --------------------------------
  // MARK: Static methods
  // --------------------------------
  
  // Factory method makes asteroid debris from an asteroid of size and velocity
  
  static func makeAsteroidDebrisAt(point: CGPoint, asteroidSize: AsteroidSize, velocity: CGVector) -> [Asteroid] {
    var a = [Asteroid]()
    for i in 0 ... 2 {
      let asteroid = Asteroid(asteroidSize: asteroidSize, speed: .average)
      asteroid.physicsBody!.velocity = asteroid.physicsBody!.velocity + velocity
      a.append(asteroid)
      asteroid.position.x = point.x + CGFloat.random(min: -20, max: 20)
      asteroid.position.y = point.y + CGFloat.random(min: -20, max: 20)
    }
    return a
  }
  
  
  // --------------------------------
  // MARK: Public methods
  // --------------------------------
  
  // Hit asteroid with value/damage
  
  func hitAsteroid(value: CGFloat) -> [Asteroid]? {
    hits -= value
    if hits < 0 {
      if let s = asteroidSize.nextSize() {
        let v = physicsBody!.velocity
        return Asteroid.makeAsteroidDebrisAt(point: position, asteroidSize: s, velocity: v)
      } else {
        return []
      }
    }
    return nil
  }
  
  
  // Configure asteroid with radius and speed - used when creating debris???
  
  func configurePhysics(radius: CGFloat, speed: AsteroidSpeed) {
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
    
    // Set direction and speed
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
    physicsBody.mass = physicsBody.mass * 1
  }
  
  // Setup base physics properties and body -
  
//  func setupPhysics() {
//
//    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
//
//    physicsBody?.categoryBitMask = PhysicsCategory.Asteroid
//    physicsBody?.collisionBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile
//    physicsBody?.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Missile | PhysicsCategory.Edge
//
//    let r = CGFloat.random(min: -5, max: 5) * 0.25
//    physicsBody?.angularVelocity = r
//
//    physicsBody?.linearDamping = 0
//    physicsBody?.angularDamping = 0
//  }
  
  
  
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
  
}
