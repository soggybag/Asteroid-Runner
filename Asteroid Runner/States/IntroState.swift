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
    
    // The story lives in Data/intro.json
    let intro = IntroText.load()
    
    let wait = SKAction.wait(forDuration: intro.lineDelay)
    var array = [SKAction]()
    for message in intro.lines {
      array.append(wait)
      array.append(.run { self.scene.addText(message: message)})
    }
    
    array.append( .run {
      self.scene.gameState.enter(ReadyState.self)
    })
    
    scene.run(.sequence(array), withKey: GameScene.FLOW)
    
    let hint = PopupLabelNode(message: "Tap to skip", location: CGPoint(x: Screen.sharedInstance.centerX, y: Screen.sharedInstance.shipY), fontSize: 14, time: 4)
    scene.addChild(hint)
  }
  
  // Jump straight to the game
  
  func skip() {
    scene.removeAction(forKey: GameScene.FLOW)
    scene.gameState.enter(ReadyState.self)
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
