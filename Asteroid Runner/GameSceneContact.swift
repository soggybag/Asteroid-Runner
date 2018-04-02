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
    
    let bodyA = contact.bodyA
    let bodyB = contact.bodyB
    let nodeA = bodyA.node
    let nodeB = bodyB.node
    
    // print("Begin Contact", contact.bodyA.node?.name, contact.bodyB.node?.name)
    
    switch collision {
    
    // -----------------------------
    // *** Missile Hits Asteroid ***
    // -----------------------------
      
    case PhysicsCategory.Missile | PhysicsCategory.Asteroid:
      // print(contact.collisionImpulse)
      if bodyA.categoryBitMask == PhysicsCategory.Missile {
        let missile = nodeA as! Missile
        let asteroid = nodeB as! Asteroid
        missile.removeFromParent()
        // print("Removing Missile 1: \(missile)")
        hit(asteroid: asteroid, missileType: Missile.missilePower)
      } else {
        let missile = nodeB as! Missile
        let asteroid = nodeA as! Asteroid
        missile.removeFromParent()
        // print("Removing Missile 2: \(missile)")
        hit(asteroid: asteroid, missileType: Missile.missilePower)
      }
      
    
    // --------------------------
    // *** Asteroid Hits Ship ***
    // --------------------------
      
    case PhysicsCategory.Asteroid | PhysicsCategory.Ship:
      if gameState.currentState is GameOverState || gameState.currentState is GameEndingState  {
        return
      }
      print("Asteroid Hits Ship")
      
      // Make an Explosion
      if let shipExplosion = SKEmitterNode(fileNamed: "ShipExplosion") {
        shipExplosion.position = ship.position
        addChild(shipExplosion)
        
        let wait = SKAction.wait(forDuration: 2)
        let remove = SKAction.removeFromParent()
        shipExplosion.run(SKAction.sequence([wait, remove]))
      }
      
      // Hide the ship.
      // TODO: make this a ship method
      ship.hide()
      // Show a message on the menu
      menu.message = "Your score is: \(score)"
      score = 0
      // Enter Game Ending State
      gameState.enter(GameEndingState.self)
      
      
    // --------------------------------
    // *** Asteroid Hits Outer Edge ***
    // --------------------------------
      
    case PhysicsCategory.OuterEdge | PhysicsCategory.Asteroid:
      // print("Asteroid hit Edge")
      if bodyA.categoryBitMask == PhysicsCategory.Asteroid {
        nodeA?.removeFromParent()
      } else {
        nodeB?.removeFromParent()
      }
      
      
    // -------------------------------
    // *** Missile Hits Outer Edge ***
    // -------------------------------
      
    case PhysicsCategory.OuterEdge | PhysicsCategory.Missile:
      // print("Missile hit Edge")
      if bodyA.categoryBitMask == PhysicsCategory.Missile {
        nodeA?.removeFromParent()
      } else {
        nodeB?.removeFromParent()
      }
      
    // -------------------------------
    // *** Powerup Hits Outer Edge ***
    // -------------------------------
      
    case PhysicsCategory.OuterEdge | PhysicsCategory.PowerUp:
      // print("Powerup hit edge")
      if bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        nodeA?.removeFromParent()
      } else {
        nodeB?.removeFromParent()
      }
      
    // -------------------------
    // *** Ship Hits Powerup ***
    // -------------------------
      
    case PhysicsCategory.Ship | PhysicsCategory.PowerUp:
      // print("Ship hit Powerup")
      let points = 100
      score += points
      
      if bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        show(points: points, at: nodeA!.position)
        nodeA?.removeFromParent()
      } else {
        show(points: points, at: nodeB!.position)
        nodeB?.removeFromParent()
      }
      
      if nodeA?.name == PowerUp.PU_BOMB || nodeB?.name == PowerUp.PU_BOMB {
        // destroyAllAsteroids()
        shakeScreen()
      } else if nodeA?.name == PowerUp.PU_SHIELD || nodeB?.name == PowerUp.PU_SHIELD {
        shield.activate()
      } else if nodeA?.name == PowerUp.PU_MISSILE_2 || nodeB?.name == PowerUp.PU_MISSILE_2 {
        missilePowerUp(mode: MissileMode.randomPowerup())
      } else if nodeA?.name == PowerUp.PU_MISSILE_RAPID || nodeB?.name == PowerUp.PU_MISSILE_RAPID {
        missileRapid()
      }
      
    default:
      return
    }
  }
}
