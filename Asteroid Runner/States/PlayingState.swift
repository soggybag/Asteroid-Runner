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

class PlayingState: GKState {
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
  }
  
  
  // Did Enter State
  
  override func didEnter(from previousState: GKState?) {
    // print("Enter Playing State")
    scene.makeAsteroids()
    scene.run(SKAction.sequence([.wait(forDuration: 10),.run({
      self.stopAsteroidsAndWaitForScreenToClear()
    })]))
  }
  
  func stopAsteroidsAndWaitForScreenToClear() {
    scene.stopAsteroids()
    scene.run(SKAction.sequence([.wait(forDuration: 10), .run {
      self.startNextLevel()
    }]))
  }
  
  func startNextLevel() {
    scene.gameState.enter(NextLevelState.self)
  }
  
  // Is Valid State next state
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    if stateClass == GameEndingState.self || stateClass == NextLevelState.self {
      return true
    }
    return false
  }
  
  
  // Will Exit to State
  
  override func willExit(to nextState: GKState) {
    // print("Playing state will exit")
    scene.stopAsteroids()
    // scene.removeAllActions() // ???
  }
  
  
  // --------------------------------------
  
  // Update
  
  // --------------------------------------
  
  override func update(deltaTime seconds: TimeInterval) {
    // 
  }

}
