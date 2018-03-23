//
//  Ready.swift
//  StateMachine2
//
//  Created by mitchell hudson on 6/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

// TODO: Move Object Creation to this class from GameScene

import GameplayKit
import SpriteKit

class PlayingState: GKState, SKPhysicsContactDelegate {
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
  }
  
  
  // Did Enter State
  
  override func didEnter(from previousState: GKState?) {
    // print("Enter Playing State")
    scene.physicsWorld.contactDelegate = self
  }
  
  
  // Is Valid State next state
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    if stateClass == GameEndingState.self {
      return true
    }
    return false
  }
  
  
  // Will Exit to State
  
  override func willExit(to nextState: GKState) {
    // print("Playing state will exit")
    scene.physicsWorld.contactDelegate = nil
  }
  
  
  // --------------------------------------
  
  // Update
  
  // --------------------------------------
  
  override func update(deltaTime seconds: TimeInterval) {
    if let accelerationData = MotionManager.sharedInstance.accelerometer {
      let x = CGFloat(accelerationData.acceleration.x)
      scene.ship.moveForce(x: x * 100)
    }
    
    if scene.autoFireOn {
      scene.timeSinceLastMissile += seconds
      
      if scene.timeSinceLastMissile > 0.30 {
        scene.timeSinceLastMissile = 0
        scene.shootMissile()
      }
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    let bodyA = contact.bodyA
    let bodyB = contact.bodyB
    let nodeA = bodyA.node
    let nodeB = bodyB.node
    
    // print("Begin Contact", contact.bodyA.node?.name, contact.bodyB.node?.name)
    
    switch collision {
    
      // * Missile Hits Asteroid *
    case PhysicsCategory.Missile | PhysicsCategory.Asteroid:
      // print(contact.collisionImpulse)
      if bodyA.categoryBitMask == PhysicsCategory.Missile {
        let missile = nodeA as! Missile
        let asteroid = nodeB as! Asteroid
        missile.removeFromParent()
        print("Removing Missile 1: \(missile)")
        scene.hit(asteroid: asteroid, missileType: Missile.missileType)
      } else {
        let missile = nodeB as! Missile
        let asteroid = nodeA as! Asteroid
        missile.removeFromParent()
        print("Removing Missile 2: \(missile)")
        scene.hit(asteroid: asteroid, missileType: Missile.missileType)
      }
      
      // * Asteroid Hits Ship *
    case PhysicsCategory.Asteroid | PhysicsCategory.Ship:
      // print("Asteroid Hits Ship")
      
      if scene.ship.shieldActive {
        return 
      }
      
      guard let shipExplosion = SKEmitterNode(fileNamed: "ShipExplosion") else { return }
      
      shipExplosion.position = scene.ship.position
      scene.addChild(shipExplosion)
      
      let wait = SKAction.wait(forDuration: 2)
      let remove = SKAction.removeFromParent()
      shipExplosion.run(SKAction.sequence([wait, remove]))
      
      scene.ship.hide()
      scene.menu.message = "Your score is: \(scene.score)"
      scene.score = 0
      // Enter Game Ending State
      scene.gameState.enter(GameEndingState.self)
      
      // * Asteroid Hits Outer Edge *
    case PhysicsCategory.OuterEdge | PhysicsCategory.Asteroid:
      // print("Asteroid hit Edge")
      if bodyA.categoryBitMask == PhysicsCategory.Asteroid {
        nodeA?.removeFromParent()
      } else {
        nodeB?.removeFromParent()
      }
      
      // * Missile Hits Outer Edge *
    case PhysicsCategory.OuterEdge | PhysicsCategory.Missile:
      // print("Missile hit Edge")
      if bodyA.categoryBitMask == PhysicsCategory.Missile {
        nodeA?.removeFromParent()
      } else {
        nodeB?.removeFromParent()
      }
      
      // * Powerup Hits Outer Edge *
    case PhysicsCategory.OuterEdge | PhysicsCategory.PowerUp:
      // print("Powerup hit edge")
      if bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        nodeA?.removeFromParent()
      } else {
        nodeB?.removeFromParent()
      }
      
      // * Ship Hits Powerup *
    case PhysicsCategory.Ship | PhysicsCategory.PowerUp:
      // print("Ship hit Powerup")
      let points = 100
      scene.score += points
      
      if bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        scene.show(points: points, at: nodeA!.position)
        nodeA?.removeFromParent()
      } else {
        scene.show(points: points, at: nodeB!.position)
        nodeB?.removeFromParent()
      }
      
      if nodeA?.name == PowerUp.PU_NAME_BOMB || nodeB?.name == PowerUp.PU_NAME_BOMB {
        scene.destroyAllAsteroids()
      } else if nodeA?.name == PowerUp.PU_NAME_SHIELD || nodeB?.name == PowerUp.PU_NAME_SHIELD {
        scene.ship.activateShield()
      } else if nodeA?.name == PowerUp.PU_NAME_MISSILE_2 || nodeB?.name == PowerUp.PU_NAME_MISSILE_2 {
        scene.missilePowerUp(n: Int.random(n: 3))
      } else if nodeA?.name == PowerUp.PU_NAME_MISSILE_RAPID || nodeB?.name == PowerUp.PU_NAME_MISSILE_RAPID {
        scene.missileRapid()
      }
      
    default:
      return
    }
  }

}
