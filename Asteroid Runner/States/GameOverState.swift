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
  
  override func didEnter(from previousState: GKState?) {
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    
    return true
  }
  
  override func willExit(to nextState: GKState) {
    
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    print("Game over State update")
  }
}
