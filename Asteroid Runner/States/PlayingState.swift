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
  
  
  // ---------------------------------
  // Did Enter State
  // ---------------------------------
  
  override func didEnter(from previousState: GKState?) {
    // print("Enter Playing State")
    // TODO: Balance time for each Stage/Level and time between stages
    
    // Start making asteroids
    scene.makeAsteroids()
    // This wave lasts 10 seconds
    scene.run(SKAction.sequence([.wait(forDuration: Tuning.Stages.waveDuration),.run({
      // Then stop and wait before starting a new wave
      self.stopAsteroidsAndWaitForScreenToClear()
    })]), withKey: GameScene.FLOW)
  }
  
  
  // ---------------------------------
  // Stop making asteroids and wait
  // ---------------------------------
  
  func stopAsteroidsAndWaitForScreenToClear() {
    // Stop making asteroids
    scene.stopAsteroids()
    // Check until the last asteroid is gone, giving up after 10 seconds
    let maxChecks = Int(Tuning.Stages.maxClearWait / Tuning.Stages.clearCheckInterval)
    var checks = 0
    let check = SKAction.run {
      checks += 1
      if self.scene.asteroidCount == 0 || checks >= maxChecks {
        self.scene.removeAction(forKey: GameScene.FLOW)
        self.stageClear()
      }
    }
    let wait = SKAction.wait(forDuration: Tuning.Stages.clearCheckInterval)
    scene.run(.repeatForever(.sequence([wait, check])), withKey: GameScene.FLOW)
  }
  
  
  // ---------------------------------
  // Survived the wave, award a bonus
  // ---------------------------------
  
  func stageClear() {
    let bonus = scene.level * Tuning.Stages.bonusPerStage
    scene.score += bonus
    scene.addText(message: "Stage Clear +\(bonus)")
    scene.run(.sequence([.wait(forDuration: Tuning.Stages.stageClearPause), .run {
      self.startNextLevel()
    }]), withKey: GameScene.FLOW)
  }
  
  
  // ---------------------------------
  // Start next wave with a count down
  // ---------------------------------
  
  func startNextLevel() {
    scene.gameState.enter(NextLevelState.self)
  }
  
  
  // ---------------------------------
  // Is Valid State next state
  // ---------------------------------
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    if stateClass == GameEndingState.self || stateClass == NextLevelState.self {
      return true
    }
    return false
  }
  
  
  // ---------------------------------
  // Will Exit to State
  // ---------------------------------
  
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
