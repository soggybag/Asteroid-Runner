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
    // print("Enter Game Ending State")
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
}
