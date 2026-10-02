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
    // The explosion is made by the scene when the ship is hit
    // Hide the ship.
    scene.ship.hide()
    scene.shield.deactivate()
    // Show a message on the menu
    scene.menu.message = "Your score is: \(scene.score)"
    let isNewBest = HighScore.submit(scene.score)
    scene.menu.show(best: HighScore.best, isNew: isNewBest)
    // Stop the waves
    scene.stopAsteroids()
    // Wait then go to Game over. Replaces any pending wave action.
    scene.run(SKAction.sequence([
      SKAction.wait(forDuration: 3),
      SKAction.run({
        self.scene.gameState.enter(GameOverState.self)
      })]), withKey: GameScene.FLOW)
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
