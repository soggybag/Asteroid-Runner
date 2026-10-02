//
//  EnemyShot.swift
//  Asteroid Runner
//

import SpriteKit

// Shot fired by turrets and enemy bases. Hits the ship, blocked by the shield.

class EnemyShot: SKSpriteNode {

  static let NAME = "enemyShot"
  static let speed: CGFloat = 160

  init(angle: CGFloat) {
    super.init(texture: nil, color: Colors.enemyShot, size: CGSize(width: 5, height: 5))

    name = EnemyShot.NAME
    zRotation = angle

    physicsBody = SKPhysicsBody(circleOfRadius: 2.5)
    physicsBody!.categoryBitMask = PhysicsCategory.EnemyShot
    physicsBody!.collisionBitMask = PhysicsCategory.None
    physicsBody!.contactTestBitMask = PhysicsCategory.Ship | PhysicsCategory.Shield | PhysicsCategory.OuterEdge
    physicsBody!.linearDamping = 0
    physicsBody!.velocity = CGVector(dx: cos(angle) * EnemyShot.speed, dy: sin(angle) * EnemyShot.speed)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
