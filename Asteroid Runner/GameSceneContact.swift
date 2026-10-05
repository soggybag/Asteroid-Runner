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
      guard let asteroid = firstNode as? Asteroid, let missile = secondNode as? Missile, missile.parent != nil else { return }
      missile.removeFromParent()
      sparks(at: contact.contactPoint, level: missile.level, color: missile.color)
      hit(asteroid: asteroid, damage: missile.damage)
      // Low mass asteroids get knocked back up the screen
      if asteroid.type == .lowMass, asteroid.parent != nil {
        asteroid.physicsBody?.velocity.dy += Tuning.Hazards.lowMassKnockback
      }


    // --------------------------
    // *** Asteroid Hits Ship ***
    // --------------------------

    case PhysicsCategory.Asteroid | PhysicsCategory.Ship:
      shipHit()


    // ----------------------------------------
    // *** Asteroid Bounces Off Screen Edge ***
    // ----------------------------------------

    case PhysicsCategory.Asteroid | PhysicsCategory.Edge:
      (firstNode as? Asteroid)?.bounced()


    // ----------------------------
    // *** Enemy Shot Hits Ship ***
    // ----------------------------

    case PhysicsCategory.Ship | PhysicsCategory.EnemyShot:
      guard secondNode.parent != nil else { return }
      secondNode.removeFromParent()
      shipHit()


    // -------------------------------
    // *** Shield Blocks Enemy Shot ***
    // -------------------------------

    case PhysicsCategory.Shield | PhysicsCategory.EnemyShot:
      secondNode.removeFromParent()


    // ---------------------------------------------------
    // *** Anything that flies off past the Outer Edge ***
    // ---------------------------------------------------

    case PhysicsCategory.OuterEdge | PhysicsCategory.Asteroid,
         PhysicsCategory.OuterEdge | PhysicsCategory.Missile,
         PhysicsCategory.OuterEdge | PhysicsCategory.PowerUp,
         PhysicsCategory.OuterEdge | PhysicsCategory.EnemyShot:
      let other = first.categoryBitMask == PhysicsCategory.OuterEdge ? secondNode : firstNode
      other.removeFromParent()


    // -------------------------
    // *** Ship Hits Powerup ***
    // -------------------------

    case PhysicsCategory.Ship | PhysicsCategory.PowerUp:
      let powerup = secondNode
      guard !ship.isHidden, powerup.parent != nil else { return }

      let points = powerup.name == PowerUp.PU_COIN ? Tuning.PowerUps.coinPoints : Tuning.PowerUps.points
      score += points
      if powerup.name == PowerUp.PU_COIN {
        coins += Tuning.Stations.coinPickup
      }
      show(points: points, at: powerup.position)
      powerup.removeFromParent()
      lightImpact.impactOccurred()

      // Items go into the tray to be used later. A full tray loses them.
      if let item = ItemType(powerupName: powerup.name), !inventory.add(item) {
        addChild(PopupLabelNode(message: "FULL", location: powerup.position + CGPoint(x: 0, y: 20)))
      }

    default:
      return
    }
  }
}
