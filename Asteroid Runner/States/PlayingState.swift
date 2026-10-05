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
    scene.itemsThisWave = 0
    scene.makeAsteroids()
    // Waves last longer as the stages go up
    var duration = Tuning.Stages.waveDuration(level: scene.level)
    if scene.asteroidSize == .bosstroid {
      duration *= Tuning.Hazards.bosstroidWaveShare
    }
    scene.run(SKAction.sequence([.wait(forDuration: duration),.run({
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
    // Check until the last asteroid is gone, giving up after a while. Before
    // a station, also wait for enemy shots, and give it longer, so the ship
    // doesn't dock through a field of rocks.
    let stationNext = scene.stationRoute.stationAfterThisWave
    let maxWait = stationNext ? Tuning.Stations.maxClearWait : Tuning.Stages.maxClearWait
    let maxChecks = Int(maxWait / Tuning.Stages.clearCheckInterval)
    var checks = 0
    let check = SKAction.run {
      checks += 1
      let clear = self.scene.asteroidCount == 0 && (!stationNext || self.scene.enemyShotCount == 0)
      if clear || checks >= maxChecks {
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
    scene.coins += Tuning.Stations.stageClearCoins
    scene.addText(message: "Stage Clear +\(bonus)")
    scene.run(.sequence([.wait(forDuration: Tuning.Stages.stageClearPause), .run {
      self.startNextLevel()
    }]), withKey: GameScene.FLOW)
  }
  
  
  // ---------------------------------
  // Dock at a station if one is here,
  // otherwise start the next wave
  // ---------------------------------
  
  func startNextLevel() {
    if let station = scene.stationRoute.waveCleared(),
       let docking = scene.gameState.state(forClass: StationState.self) {
      docking.station = station
      scene.gameState.enter(StationState.self)
    } else {
      scene.gameState.enter(NextLevelState.self)
    }
  }
  
  
  // ---------------------------------
  // Is Valid State next state
  // ---------------------------------
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    if stateClass == GameEndingState.self || stateClass == NextLevelState.self || stateClass == StationState.self {
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
