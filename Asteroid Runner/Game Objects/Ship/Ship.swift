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

  let shipSpeedSlow = Tuning.Ship.speedSlow
  let shipSpeedMed = Tuning.Ship.speedMed
  let shipSpeedFast = Tuning.Ship.speedFast

  let shipDampingSlow = Tuning.Ship.dampingSlow
  let shipDampingMed = Tuning.Ship.dampingMed
  let shipDampingFast = Tuning.Ship.dampingFast

  var shipSpeed = Tuning.Ship.speedMed

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
  // Set speed slow
  // ---------------------------

  func setShipSpeedSlow() {
    shipSpeed = shipSpeedSlow
    physicsBody?.linearDamping = shipDampingSlow
  }


  // ---------------------------
  // Set speed med
  // ---------------------------

  func setShipSpeedMed() {
    shipSpeed = shipSpeedMed
    physicsBody?.linearDamping = shipDampingMed
  }


  // ---------------------------
  // Set speed fast
  // ---------------------------

  func setShipSpeedFast() {
    shipSpeed = shipSpeedFast
    physicsBody?.linearDamping = shipDampingFast
  }
}
