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

class NextLevelState: GKState {
  
  // This state will need a reference to the scene.
  unowned let scene: GameScene
  
  // Get the scene in the initializer
  init(scene: GameScene) {
    self.scene = scene
  }
  
  // This method is called when the state machine enters this state
  override func didEnter(from previousState: GKState?) {
    // print("Did enter Intro State")
    
    scene.level += 1
    
    let introMessage = [
      "Prepare for",
      "Stage: \(scene.level)"
    ]
    
    let wait = SKAction.wait(forDuration: 2)
    var array = [SKAction]()
    for message in introMessage {
      array.append(wait)
      array.append(.run { self.scene.addText(message: message)})
    }
    
    array.append( .run {
      self.scene.gameState.enter(PlayingState.self)
    })
    
    scene.run(.sequence(array))
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    if PlayingState.self == stateClass {
      return true
    }
    return false
  }
  
  override func willExit(to nextState: GKState) {
    // print("Will Exit Intro State")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    // print("Intro State update")
  }
}
