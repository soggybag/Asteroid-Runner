//
//  Missile.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit


class Missile: SKSpriteNode {

  // --------------------------------
  // MARK: Static Properties
  // --------------------------------

  static let powerLevelLow = Tuning.Weapons.massLow
  static let powerLevelMed = Tuning.Weapons.massMed
  static let powerLevelHi  = Tuning.Weapons.massHi

  static var power: CGFloat = Missile.powerLevelMed

  static var missilePower: MissilePower = .average

  static let NAME = "missile"

  static let speed = Tuning.Weapons.missileSpeed


  // --------------------------------
  // MARK: Static Methods
  // --------------------------------

  static func setPowerLow() {
    Missile.power = Missile.powerLevelLow
    Missile.missilePower = .weak
  }

  static func setPowerMed() {
    Missile.power = Missile.powerLevelMed
    Missile.missilePower = .average
  }

  static func setPowerHi() {
    Missile.power = Missile.powerLevelHi
    Missile.missilePower = .strong
  }


  // --------------------------------
  // MARK: Initializers
  // --------------------------------

  init() {
    let size = CGSize(width: 3, height: 8)
    super.init(texture: nil, color: Colors.missile, size: size)

    name = Missile.NAME

    setupPhysics()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // --------------------------------
  // MARK: Public Methods
  // --------------------------------

  func setupPhysics() {
    physicsBody = SKPhysicsBody(circleOfRadius: 2)

    physicsBody?.mass = Missile.power

    physicsBody!.categoryBitMask = PhysicsCategory.Missile
    physicsBody!.collisionBitMask = PhysicsCategory.Asteroid
    physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Edge

    let missileVelocity = CGVector(dx: 0, dy: Missile.speed)
    physicsBody!.velocity = missileVelocity
    physicsBody!.linearDamping = 0
  }

}
