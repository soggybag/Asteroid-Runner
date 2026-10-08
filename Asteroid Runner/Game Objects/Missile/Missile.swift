//
//  Missile.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit


// A shot from the ship. Its weapons power level sets how hard it hits
// and how it looks: a dim speck at level 0, up to a long white-hot bolt
// with a glow at the top level.

class Missile: SKSpriteNode {

  // --------------------------------
  // MARK: Static Properties
  // --------------------------------

  static let NAME = "missile"

  static let speed = Tuning.Weapons.missileSpeed

  // Size and color at each weapons level
  static let sizes = [CGSize(width: 2, height: 5), CGSize(width: 3, height: 7), CGSize(width: 3, height: 9),
                      CGSize(width: 4, height: 12), CGSize(width: 5, height: 15)]
  static let colors = [Colors.missileWeak, Colors.missileLow, Colors.missile, Colors.missileHigh, Colors.missileMax]


  // --------------------------------
  // MARK: Properties
  // --------------------------------

  let level: Int
  let damage: CGFloat

  // --------------------------------
  // MARK: Initializers
  // --------------------------------

  // `damageScale` multiplies damage, from weapon focus upgrades
  init(level: Int, damageScale: CGFloat = 1) {
    self.level = level
    damage = Tuning.Power.value(Tuning.Power.weaponDamage, level: level) * damageScale
    let color = Tuning.Power.value(Missile.colors, level: level)
    super.init(texture: nil, color: color, size: Tuning.Power.value(Missile.sizes, level: level))

    name = Missile.NAME

    // A soft glow behind the stronger shots
    if level >= 3 {
      let glow = SKShapeNode(ellipseOf: CGSize(width: size.width * 3.5, height: size.height * 1.8))
      glow.fillColor = color
      glow.strokeColor = .clear
      glow.alpha = level >= 4 ? 0.4 : 0.25
      glow.blendMode = .add
      glow.zPosition = -1
      addChild(glow)
    }

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

    physicsBody?.mass = Tuning.Power.value(Tuning.Power.weaponMass, level: level)

    physicsBody!.categoryBitMask = PhysicsCategory.Missile
    physicsBody!.collisionBitMask = PhysicsCategory.Asteroid
    physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Edge

    let missileVelocity = CGVector(dx: 0, dy: Missile.speed)
    physicsBody!.velocity = missileVelocity
    physicsBody!.linearDamping = 0
  }

}
