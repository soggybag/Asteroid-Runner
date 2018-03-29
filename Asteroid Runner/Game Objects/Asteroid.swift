//
//  Asteroid.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

enum AsteroidSize: CGFloat {
  // set the radius
  case tiny      = 5
  case small     = 10
  case average   = 15
  case large     = 20
  case huge      = 25
  case massive   = 30
  case bosstroid = 60
  
  func nextSize() -> AsteroidSize? {
    switch self {
    case .bosstroid:
      return .massive
      
    case .massive:
      return .average
      
    case .huge:
      return .small
      
    case .large:
      return .small
      
    case .average:
      return .tiny
      
    case .small:
      return .tiny
      
    default:
      return nil
      
    }
  }
  
  static func random() -> AsteroidSize {
    let allSizes = [AsteroidSize.tiny, .small, .average, .large, .huge, .massive, .bosstroid]
    return allSizes[Int.random(n: allSizes.count)]
  }
  
}

enum AsteroidSpeed: CGFloat {
  // set the velocity
  case slow     = 0.5
  case average  = 1.0
  case fast     = 2.0
  case veryFast = 4.0
  
  static func random() -> AsteroidSpeed {
    let allSpeeds = [AsteroidSpeed.slow, .average, .fast, .veryFast]
    return allSpeeds[Int.random(n: allSpeeds.count)]
  }
}

enum AsteroidDirection {
  case top, left, right
  
  static func random() -> AsteroidDirection {
    let allDirections = [AsteroidDirection.left, .top, .right]
    return allDirections[Int.random(n: allDirections.count)]
  }
}

enum AsteroidDensity: CGFloat {
  // Set the mass
  case light    = 0.5
  case average  = 1.0
  case dense    = 2.0
  
}


class Asteroid: SKSpriteNode {
  
  var hits: CGFloat = 0
  var asteroidSize = AsteroidSize.average
  
  static let NAME = "asteroid"
  
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
    color = randomColor()
    // Configure physics for types
    configurePhysics(radius: radius, speed: speed)
  }
  
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
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
    physicsBody.mass = physicsBody.mass * 1
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
