//
//  Ready.swift
//  StateMachine2
//
//  Created by mitchell hudson on 6/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameEndingState: GKState, SKPhysicsContactDelegate {
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
  }
  
  override func didEnter(from previousState: GKState?) {
    print("Enter Game Ending State")
    scene.physicsWorld.contactDelegate = self
    // Wait then go to Game over
    scene.run(SKAction.sequence([
      SKAction.wait(forDuration: 3),
      SKAction.run({
        print("????")
        self.scene.gameState.enter(GameOverState.self)
      })]))
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    // print("Game Ending is valid next state: \(stateClass)")
    if stateClass == GameOverState.self {
      return true
    }
    return false
  }
  
  override func willExit(to nextState: GKState) {
    // print("Game Ending will exit")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    // print("Game over State update")
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
      
    default:
      return
    }
  }
}
