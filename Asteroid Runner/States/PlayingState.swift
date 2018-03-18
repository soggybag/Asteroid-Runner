//
//  Ready.swift
//  StateMachine2
//
//  Created by mitchell hudson on 6/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import GameplayKit
import SpriteKit

class PlayingState: GKState {
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
  }
  
  override func didEnter(from previousState: GKState?) {
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    // PlayingState can only transition to GameOverState. 
    if stateClass == GameOverState.self {
      return true
    }
    return false
  }
  
  override func willExit(to nextState: GKState) {
    //
  }
  
  
  // This method is called by the state machine when this is the current state.
  override func update(deltaTime seconds: TimeInterval) {
    // print("Playing State update:\(seconds)")
    
    
  }
}
