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
    print("Enter Playing State")
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
    
    // print("Begin Contact", contact.bodyA.node?.name, contact.bodyB.node?.name)
    
    switch collision {
    
      // * Missile Hits Asteroid *
    case PhysicsCategory.Missile | PhysicsCategory.Asteroid:
      // print("Missile Hits Asteroid")
      // print(contact.collisionImpulse)
      if contact.bodyA.categoryBitMask == PhysicsCategory.Missile {
        let missile = contact.bodyA.node as! Missile
        let asteroid = contact.bodyB.node as! Asteroid
        missile.removeFromParent()
        hit(asteroid: asteroid, missileType: Missile.missileType)
      } else {
        let missile = contact.bodyB.node as! Missile
        let asteroid = contact.bodyA.node as! Asteroid
        missile.removeFromParent()
        hit(asteroid: asteroid, missileType: Missile.missileType)
      }
      
      // * Asteroid Hits Ship *
    case PhysicsCategory.Asteroid | PhysicsCategory.Ship:
      // print("Asteroid Hits Ship")
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
      if contact.bodyA.categoryBitMask == PhysicsCategory.Asteroid {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
      // * Missile Hits Outer Edge *
    case PhysicsCategory.OuterEdge | PhysicsCategory.Missile:
      // print("Missile hit Edge")
      if contact.bodyA.categoryBitMask == PhysicsCategory.Missile {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
      // * Powerup Hits Outer Edge *
    case PhysicsCategory.OuterEdge | PhysicsCategory.PowerUp:
      // print("Powerup hit edge")
      if contact.bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
      // * Ship Hits Powerup *
    case PhysicsCategory.Ship | PhysicsCategory.PowerUp:
      // print("Ship hit Powerup")
      scene.score += 10
      if contact.bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
      if contact.bodyA.node?.name == "Powerup Bomb" || contact.bodyB.node?.name == "Powerup Bomb" {
        // destroy all rocks
        // print("destroy all asteroids")
        scene.destroyAllAsteroids()
      }
      
    default:
      return
    }
  }
  
  func hit(asteroid: Asteroid, missileType: MissileType) {
    if let debris = asteroid.hitAsteroid(value: missileType.rawValue) {
      scene.score += Int(asteroid.asteroidSize.rawValue)
      asteroid.removeFromParent()
      // TODO: make some smaller asteroids here...
      for rock in debris {
        scene.addChild(rock)
      }
    }
  }
}
