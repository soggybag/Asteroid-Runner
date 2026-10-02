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
  var type = AsteroidType.normal

  // Comet tail. Its targetNode must be set to the scene once added.
  var trail: SKEmitterNode?

  // Elastroids bounce off the screen edges once they are fully on screen
  var bouncesLeft = 3
  var edgeArmed = false


  // --------------------------------
  // MARK: Initializers
  // --------------------------------

  // Init with size and type. Call launch(from:speed:) to place it off screen
  // and send it on its way, or set position and velocity directly for debris.

  init(asteroidSize: AsteroidSize, type: AsteroidType = .normal) {
    let asteroidSize = type.adjust(size: asteroidSize)
    let radius = asteroidSize.rawValue
    let size = CGSize(width: radius * 2, height: radius * 2)

    super.init(texture: nil, color: .white, size: size)

    // Set name
    name = Asteroid.NAME

    self.asteroidSize = asteroidSize
    self.type = type

    // Set hits
    hits = asteroidSize.rawValue / 5 * type.toughness

    color = type.color()

    configurePhysics(radius: radius)
    configureType()
  }

  // Init with size, entering the screen from a direction

  convenience init(asteroidSize: AsteroidSize, speed: AsteroidSpeed, direction: AsteroidDirection, type: AsteroidType = .normal) {
    self.init(asteroidSize: asteroidSize, type: type)
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

  static func makeAsteroidDebrisAt(point: CGPoint, asteroidSize: AsteroidSize, velocity: CGVector, type: AsteroidType = .normal) -> [Asteroid] {
    var a = [Asteroid]()
    for _ in 0 ... 2 {
      let asteroid = Asteroid(asteroidSize: asteroidSize, type: type)
      // Fly apart from the impact while keeping the parent's momentum
      let scatter = CGVector(dx: CGFloat.random(in: -40 ... 40), dy: CGFloat.random(in: -20 ... 40))
      asteroid.physicsBody!.velocity = velocity + scatter
      asteroid.position.x = point.x + CGFloat.random(in: -20 ... 20)
      asteroid.position.y = point.y + CGFloat.random(in: -20 ... 20)
      a.append(asteroid)
    }
    return a
  }

  // Icestroids burst into tiny, fast shards that fly out in all directions

  static func makeIceShardsAt(point: CGPoint) -> [Asteroid] {
    var a = [Asteroid]()
    let count = 6
    for i in 0 ..< count {
      let shard = Asteroid(asteroidSize: .tiny, type: .ice)
      let angle = CGFloat(i) / CGFloat(count) * .pi * 2 + CGFloat.random(in: -0.3 ... 0.3)
      let speed = CGFloat.random(in: 70 ... 110)
      shard.position = point
      shard.physicsBody!.velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
      a.append(shard)
    }
    return a
  }


  // --------------------------------
  // MARK: Public methods
  // --------------------------------

  // Hit asteroid with value/damage. Returns nil if it survives, otherwise
  // the debris (possibly none) to add to the scene.

  func hitAsteroid(value: CGFloat) -> [Asteroid]? {
    hits -= value
    guard hits < 0 else { return nil }

    switch type {
    case .glass, .gas:
      // Shatters or explodes. The scene makes the effect.
      return []
    case .ice:
      return asteroidSize == .tiny ? [] : Asteroid.makeIceShardsAt(point: position)
    default:
      if let s = asteroidSize.nextSize() {
        let v = physicsBody!.velocity
        return Asteroid.makeAsteroidDebrisAt(point: position, asteroidSize: s, velocity: v, type: type.debrisType)
      } else {
        return []
      }
    }
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


  // Extra setup for the special types

  func configureType() {
    guard let physicsBody = physicsBody else { return }

    switch type {
    case .brass:
      // So heavy missiles don't push it and it shoves other rocks aside
      physicsBody.density = 20
      physicsBody.collisionBitMask &= ~PhysicsCategory.Missile

    case .elastic:
      physicsBody.restitution = 1
      physicsBody.friction = 0

    case .comet:
      let tail = SKEmitterNode()
      tail.particleTexture = SKTexture(imageNamed: "spark")
      tail.particleBirthRate = 80
      tail.particleLifetime = 0.6
      tail.particleScale = 0.15
      tail.particleScaleSpeed = -0.2
      tail.particleAlphaSpeed = -1.6
      tail.particleColor = UIColor(r: 150, g: 210, b: 255)
      tail.particleColorBlendFactor = 1
      tail.particleBlendMode = .add
      tail.particlePositionRange = CGVector(dx: 6, dy: 6)
      tail.zPosition = -1
      addChild(tail)
      trail = tail

    case .turret:
      addGun(at: .zero)
      startFiring(interval: 2.0, spread: [0])

    case .base:
      let r = asteroidSize.rawValue * 0.5
      addGun(at: CGPoint(x: -r, y: -r))
      addGun(at: CGPoint(x: r, y: -r))
      addGun(at: .zero)
      startFiring(interval: 2.6, spread: [-0.3, 0, 0.3])

    default:
      break
    }
  }


  // Draw a small red gun on the asteroid

  func addGun(at point: CGPoint) {
    let gun = SKSpriteNode(color: Colors.enemyShot, size: CGSize(width: 8, height: 8))
    gun.position = point
    gun.zRotation = .pi / 4
    addChild(gun)
    gun.run(.repeatForever(.sequence([.fadeAlpha(to: 0.4, duration: 0.4), .fadeAlpha(to: 1, duration: 0.4)])))
  }


  // Fire at the ship every interval. Spread is a list of angle offsets.

  func startFiring(interval: TimeInterval, spread: [CGFloat]) {
    let firstWait = SKAction.wait(forDuration: interval, withRange: interval * 0.5)
    let fire = SKAction.run { [weak self] in
      self?.fire(spread: spread)
    }
    run(.sequence([firstWait, .repeatForever(.sequence([fire, .wait(forDuration: interval)]))]))
  }

  func fire(spread: [CGFloat]) {
    guard let scene = scene as? GameScene, scene.shipInPlay else { return }
    // Only fire while on screen
    guard scene.frame.contains(position) else { return }

    let target = scene.ship.position
    let aim = atan2(target.y - position.y, target.x - position.x)
    for offset in spread {
      let shot = EnemyShot(angle: aim + offset)
      shot.position = position
      scene.addChild(shot)
    }
  }


  // Elastroids start bouncing off the screen edges once fully on screen.
  // Called by the scene each frame until armed.

  func armBounceIfOnScreen(in rect: CGRect) {
    guard type == .elastic, !edgeArmed, rect.contains(frame) else { return }
    edgeArmed = true
    physicsBody?.collisionBitMask |= PhysicsCategory.Edge
  }

  // Count a bounce. After the last one it can leave the screen.

  func bounced() {
    guard type == .elastic, edgeArmed else { return }
    bouncesLeft -= 1
    if bouncesLeft <= 0 {
      physicsBody?.collisionBitMask &= ~PhysicsCategory.Edge
    }
  }


  // Place the asteroid off screen and set its velocity. Waves from the
  // sides still send some asteroids from the top so the middle of the
  // screen doesn't go quiet.

  func launch(from direction: AsteroidDirection, speed: AsteroidSpeed) {
    let screen = Screen.sharedInstance
    let centerY = screen.centerY

    // Comets streak in diagonally from a top corner
    if type == .comet {
      let fromLeft = Bool.random()
      position.x = fromLeft ? -40 : screen.width + 40
      position.y = CGFloat.random(in: screen.height * 0.7 ... screen.height + 40)
      let dx = CGFloat.random(in: 90 ... 150) * (fromLeft ? 1 : -1)
      let dy = -CGFloat.random(in: 160 ... 240)
      physicsBody?.velocity = CGVector(dx: dx, dy: dy)
      return
    }

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

    // Enemy bases are slow and menacing
    let speedFactor = type == .base ? min(speed.rawValue, 0.5) : speed.rawValue

    position = CGPoint(x: x, y: y)
    physicsBody?.velocity = CGVector(dx: dx * speedFactor, dy: dy * speedFactor)
  }

}
