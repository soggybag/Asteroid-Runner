//
//  Ready.swift
//  StateMachine2
//
//  Created by mitchell hudson on 6/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameOverState: GKState {
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
  }
  
  
  // -----------------------------------
  // Did enter Game Over State
  // -----------------------------------
  
  override func didEnter(from previousState: GKState?) {
    // print("Enter Game Over State")
    scene.menu.show()
  }
  
  
  // -----------------------------------
  // Is Valid Next State
  // -----------------------------------
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    // print("Game Over is valid next state")
    if stateClass == ReadyState.self {
      // print("\(stateClass) is valid next state")
      return true
    }
    // print("\(stateClass) is NOT valid next state")
    return false
  }
  
  
  // -----------------------------------
  // Will Exit to State
  // -----------------------------------
  
  override func willExit(to nextState: GKState) {
    
  }
  
  
  // -----------------------------------
  // Update State
  // -----------------------------------
  
  override func update(deltaTime seconds: TimeInterval) {
    // print("Game over State update")
  }
}
