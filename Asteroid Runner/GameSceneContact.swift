//
//  GameSceneContact.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/24/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

extension GameScene {
  func didBegin(_ contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

    // Sort the bodies so the lower category is always first
    let (first, second) = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
      ? (contact.bodyA, contact.bodyB)
      : (contact.bodyB, contact.bodyA)

    // A node can be removed by an earlier contact in the same frame
    guard let firstNode = first.node, let secondNode = second.node else { return }

    switch collision {

    // -----------------------------
    // *** Missile Hits Asteroid ***
    // -----------------------------

    case PhysicsCategory.Missile | PhysicsCategory.Asteroid:
      guard let asteroid = firstNode as? Asteroid, secondNode.parent != nil else { return }
      secondNode.removeFromParent()
      hit(asteroid: asteroid, missileType: Missile.missilePower)


    // --------------------------
    // *** Asteroid Hits Ship ***
    // --------------------------

    case PhysicsCategory.Asteroid | PhysicsCategory.Ship:
      shipHit()


    // ---------------------------------------------------
    // *** Asteroid, Missile or Powerup Hits Outer Edge ***
    // ---------------------------------------------------

    case PhysicsCategory.OuterEdge | PhysicsCategory.Asteroid,
         PhysicsCategory.OuterEdge | PhysicsCategory.Missile,
         PhysicsCategory.OuterEdge | PhysicsCategory.PowerUp:
      let other = first.categoryBitMask == PhysicsCategory.OuterEdge ? secondNode : firstNode
      other.removeFromParent()


    // -------------------------
    // *** Ship Hits Powerup ***
    // -------------------------

    case PhysicsCategory.Ship | PhysicsCategory.PowerUp:
      let powerup = secondNode
      guard !ship.isHidden, powerup.parent != nil else { return }

      let points = 100
      score += points
      show(points: points, at: powerup.position)
      powerup.removeFromParent()
      lightImpact.impactOccurred()

      switch powerup.name {
      case PowerUp.PU_BOMB:
        impact.impactOccurred()
        shakeScreen(hitAsteroids: true)
      case PowerUp.PU_SHIELD:
        shield.activate()
      case PowerUp.PU_MISSILE_2:
        missilePowerUp(mode: MissileMode.randomPowerup())
      case PowerUp.PU_MISSILE_RAPID:
        missileRapid()
      default:
        break
      }

    default:
      return
    }
  }
}
