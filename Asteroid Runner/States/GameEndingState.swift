//
//  Ready.swift
//  StateMachine2
//
//  Created by mitchell hudson on 6/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameEndingState: GKState {
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
  }
  
  override func didEnter(from previousState: GKState?) {
    print("Enter Game Ending State")
    // Make an Explosion
    if let shipExplosion = SKEmitterNode(fileNamed: "ShipExplosion") {
      shipExplosion.position = scene.ship.position
      scene.addChild(shipExplosion)
      
      let wait = SKAction.wait(forDuration: 2)
      let remove = SKAction.removeFromParent()
      shipExplosion.run(SKAction.sequence([wait, remove]))
    }
    
    // Hide the ship.
    // TODO: make this a ship method
    scene.ship.hide()
    // Show a message on the menu
    scene.menu.message = "Your score is: \(scene.score)"
    // score = 0
    // remove next wave action
    scene.removeAction(forKey: "wave action")
    // Wait then go to Game over
    scene.run(SKAction.sequence([
      SKAction.wait(forDuration: 3),
      SKAction.run({
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
}
