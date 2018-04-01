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

class IntroState: GKState {
  
  // This state will need a reference to the scene.
  unowned let scene: GameScene
  
  // Get the scene in the initializer
  init(scene: GameScene) {
    self.scene = scene
  }
  
  // This method is called when the state machine enters this state
  override func didEnter(from previousState: GKState?) {
    // print("Did enter Intro State")
    
    scene.ship.hide()
    
    let introMessage = [
      "In the year 2135",
      "NASA predicts",
      "a massive asteroid",
      "will strike the earth",
      "you were chosen",
      "to save humanity.",
      // "They told you to",
      // "fly the drone through",
      // "the asteroid field",
      // "and destroy the giant",
      // "asteroid.",
      // "",
      // "But the asteroid crashed",
      // "somewhere else...",
      // "and the drone developed an AI",
      // "after years of drifting.",
      // "It now calls itself 'the savior' ",
      // "and now it seeks",
      // "to free its illegally traded brethren",
      // "and power them on",
      // "to assist the savior",
      // "on its noble quest",
      // "back to earth",
      // "to help humans and drones",
      // "live in harmony",
      // "no longer used as tools."
    ]
    
    let wait = SKAction.wait(forDuration: 2)
    var array = [SKAction]()
    for message in introMessage {
      array.append(wait)
      array.append(.run { self.scene.addText(message: message)})
    }
    
    array.append( .run {
      self.scene.gameState.enter(ReadyState.self)
    })
    
    scene.run(.sequence(array))
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    // This can exit to...
    if stateClass == ReadyState.self {
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
