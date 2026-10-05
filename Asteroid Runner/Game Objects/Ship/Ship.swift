//
//  Ship.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// ----------------------------------------------

// Ship

// ----------------------------------------------


class Ship: SKSpriteNode {

  // MARK: Public Properties

  // Tilt force multiplier, set by engine power
  var shipSpeed = Tuning.Power.value(Tuning.Power.engineTilt, level: Tuning.Power.startingLevel)

  // How fast the ship can follow a dragging finger, set by engine power
  var dragSpeed = Tuning.Power.value(Tuning.Power.engineDragSpeed, level: Tuning.Power.startingLevel)

  // Faint ring showing powered shield charge
  let barrier = SKShapeNode(circleOfRadius: 24)

  static var shipSize = CGSize(width: 32, height: 32)

  static let INVULNERABLE = "INVULNERABLE"

  var shield: ShipShield?

  // True for a moment after losing a life
  var isInvulnerable = false

  // Asteroids only count when the ship is in play
  var canBeHit: Bool {
    return !isHidden && !isInvulnerable
  }


  // MARK: Initializers

  init() {
    let size = CGSize(width: Ship.shipSize.width + 6, height: Ship.shipSize.height + 6)
    super.init(texture: nil, color: Colors.shipBlue, size: size)

    name = "Ship"

    setupTextures()
    setupPhysics()
    setupBarrier()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: Setup methods

  func setupTextures() {
    var textures = [SKTexture]()
    for i in 1 ... 5 {
      let texture = SKTexture(imageNamed: "Satellite_4_\(i).png")
      textures.append(texture)
    }

    self.size = textures[0].size()
    self.texture = textures[0]
    run(.repeatForever(.animate(with: textures, timePerFrame: 0.1)))
  }


  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: 15)
    physicsBody!.categoryBitMask = PhysicsCategory.Ship
    physicsBody!.collisionBitMask = PhysicsCategory.Edge
    physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid

    physicsBody!.linearDamping = 0.5
    physicsBody!.allowsRotation = false
  }


  func setupBarrier() {
    barrier.strokeColor = Colors.shieldStrokeColor
    barrier.fillColor = .clear
    barrier.isHidden = true
    addChild(barrier)
  }


  // MARK: Public methods


  // ----------------------------
  // Hide
  // ----------------------------

  func hide() {
    isHidden = true
    physicsBody?.velocity = .zero
  }


  // ----------------------------
  // Show
  // ----------------------------

  func show() {
    isHidden = false
  }


  // ---------------------------
  // Blink and ignore hits for a moment
  // ---------------------------

  func makeInvulnerable(duration: TimeInterval = Tuning.Player.invulnerableTime) {
    isInvulnerable = true
    let blink = SKAction.sequence([.fadeAlpha(to: 0.2, duration: 0.1), .fadeAlpha(to: 1, duration: 0.1)])
    let count = Int(duration / 0.2)
    run(.sequence([.repeat(blink, count: count), .run {
      self.isInvulnerable = false
    }]), withKey: Ship.INVULNERABLE)
  }

  func clearInvulnerable() {
    removeAction(forKey: Ship.INVULNERABLE)
    isInvulnerable = false
    alpha = 1
  }


  // ---------------------------
  // Move by impulse
  // ---------------------------

  func move(x: CGFloat) {
    physicsBody?.applyImpulse(CGVector(dx: x * shipSpeed, dy: 0))
  }


  // ---------------------------
  // Move by force
  // ---------------------------

  func moveForce(x: CGFloat) {
    physicsBody?.applyForce(CGVector(dx: x * shipSpeed, dy: 0))
  }


  // ---------------------------
  // Engine power level
  // ---------------------------

  func setEngine(level: Int) {
    shipSpeed = Tuning.Power.value(Tuning.Power.engineTilt, level: level)
    dragSpeed = Tuning.Power.value(Tuning.Power.engineDragSpeed, level: level)
    physicsBody?.linearDamping = Tuning.Power.value(Tuning.Power.engineDamping, level: level)
  }


  // ---------------------------
  // Powered shield ring: brighter and thicker with more charge
  // ---------------------------

  func showBarrier(charge: Int, capacity: Int) {
    barrier.isHidden = charge == 0
    barrier.lineWidth = CGFloat(charge)
    barrier.alpha = 0.2 + 0.15 * CGFloat(charge)
  }

  // A bright flash when the barrier blocks a hit
  func flashBarrier() {
    let ring = SKShapeNode(circleOfRadius: 24)
    ring.strokeColor = Colors.shieldStrokeColor
    ring.lineWidth = 3
    addChild(ring)
    ring.run(.sequence([.group([.scale(to: 1.6, duration: 0.3), .fadeOut(withDuration: 0.3)]), .removeFromParent()]))
  }
}
