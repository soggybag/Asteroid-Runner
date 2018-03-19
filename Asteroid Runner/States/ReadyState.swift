//
//  Ready.swift
//  StateMachine2
//
//  Created by mitchell hudson on 6/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//


// GKState is an abstract class. You need to sub class it. 
// This class represents the ready state. Imagine in this 
// state the game will

import GameplayKit
import SpriteKit

class ReadyState: GKState {
  
  // This state will need a reference to the scene.
  unowned let scene: GameScene
  
  // Get the scene in the initializer
  init(scene: GameScene) {
    self.scene = scene
  }
  
  // This method is called when the state machine enters this state
  override func didEnter(from previousState: GKState?) {
    print("Did enter Ready State")
    
    scene.ship.physicsBody?.isDynamic = false
    scene.ship.position.x = Screen.sharedInstance.centerX
    scene.ship.position.y = -100
    scene.ship.show()
    
    let moveShipIntoView = SKAction.moveTo(y: 60, duration: 2)
    moveShipIntoView.timingMode = .easeOut
    let enterPlayingState = SKAction.run {
      self.scene.ship.physicsBody?.isDynamic = true
      self.scene.gameState.enter(PlayingState.self)
    }
    
    scene.ship.run(SKAction.sequence([moveShipIntoView, enterPlayingState]))
    
    // Hide Ship
    // Show Menu -> should allow to enter playingState
    // scene.gameState.enter(PlayingState.self)
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    if stateClass == PlayingState.self {
      return true
    }
    return false
  }
  
  override func willExit(to nextState: GKState) {
    // print("Will Exit Ready State")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    // print("Ready State update")
  }
}
