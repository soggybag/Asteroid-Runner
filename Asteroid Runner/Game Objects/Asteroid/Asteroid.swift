//
//  Asteroid.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// ==================================
//
// Asteroid Class
//
// ==================================

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

  // Init with size. Call launch(from:speed:) to place it off screen and
  // send it on its way, or set position and velocity directly for debris.

  init(asteroidSize: AsteroidSize) {

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

    configurePhysics(radius: radius)
  }

  // Init with size, entering the screen from a direction

  convenience init(asteroidSize: AsteroidSize, speed: AsteroidSpeed, direction: AsteroidDirection) {
    self.init(asteroidSize: asteroidSize)
    launch(from: direction, speed: speed)
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
    for _ in 0 ... 2 {
      let asteroid = Asteroid(asteroidSize: asteroidSize)
      // Fly apart from the impact while keeping the parent's momentum
      let scatter = CGVector(dx: CGFloat.random(in: -40 ... 40), dy: CGFloat.random(in: -20 ... 40))
      asteroid.physicsBody!.velocity = velocity + scatter
      asteroid.position.x = point.x + CGFloat.random(in: -20 ... 20)
      asteroid.position.y = point.y + CGFloat.random(in: -20 ... 20)
      a.append(asteroid)
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


  // Configure the physics body

  func configurePhysics(radius: CGFloat) {
    // Make a physics body
    physicsBody = SKPhysicsBody(circleOfRadius: radius)

    guard let physicsBody = physicsBody else { return }

    // Set physics categories
    physicsBody.categoryBitMask = PhysicsCategory.Asteroid
    physicsBody.collisionBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile | PhysicsCategory.Shield
    physicsBody.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Missile | PhysicsCategory.Edge

    // Remove damping
    physicsBody.linearDamping = 0
    physicsBody.angularDamping = 0

    // Apply some spin
    physicsBody.angularVelocity = CGFloat.random(in: -1.25 ... 1.25)
  }


  // Place the asteroid off screen and set its velocity. Waves from the
  // sides still send some asteroids from the top so the middle of the
  // screen doesn't go quiet.

  func launch(from direction: AsteroidDirection, speed: AsteroidSpeed) {
    let screen = Screen.sharedInstance
    let centerY = screen.centerY

    var direction = direction
    if direction != .top && Int.random(in: 0 ..< 3) == 0 {
      direction = .top
    }

    // Use these to set the initial position and velocity of asteroid
    var x: CGFloat
    var y: CGFloat
    var dx: CGFloat
    var dy: CGFloat

    // Set direction and speed
    switch direction {
    case .left: // Starts on Left
      x = -60
      y = CGFloat.random(in: centerY ... centerY * 2)
      dx = CGFloat.random(in: 15 ... 50)
      dy = CGFloat.random(in: 25 ... 80) * -1

    case .right: // Starts on the Right
      x = screen.width + 60
      y = CGFloat.random(in: centerY ... centerY * 2)
      dx = CGFloat.random(in: 15 ... 50) * -1
      dy = CGFloat.random(in: 25 ... 80) * -1

    case .top: // Down from Top
      x = CGFloat.random(in: 20 ... screen.width - 20)
      y = CGFloat.random(in: screen.height + 60 ... screen.height + 120)
      dx = CGFloat.random(in: -10 ... 10)
      dy = CGFloat.random(in: 40 ... 100) * -1
    }

    position = CGPoint(x: x, y: y)
    physicsBody?.velocity = CGVector(dx: dx * speed.rawValue, dy: dy * speed.rawValue)
  }

}
