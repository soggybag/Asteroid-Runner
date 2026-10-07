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
  
  private var scanner: ScannerPanel?

  // Plan the wave and show the scanner briefing, then start the wave
  override func didEnter(from previousState: GKState?) {
    scene.level += 1
    scene.planWave()

    let route = scene.stationRoute
    let stationAhead = route.stationAfterThisWave ? route.next?.name : nil

    let screen = Screen.sharedInstance
    let panel = ScannerPanel(wave: scene.wave, stationAhead: stationAhead, width: screen.width - 32)
    panel.position = CGPoint(x: 16, y: screen.height - screen.hudScoreHeight - 44 - ScannerPanel.height)
    panel.alpha = 0
    panel.onTap = { [weak self] in self?.startWave() }
    scene.addChild(panel)
    panel.run(.fadeIn(withDuration: 0.3))
    scanner = panel

    scene.run(.sequence([.wait(forDuration: Tuning.Stages.briefingTime), .run {
      self.scene.gameState.enter(PlayingState.self)
    }]), withKey: GameScene.FLOW)
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    // Asteroids from the last wave can still hit the ship here
    if stateClass == PlayingState.self || stateClass == GameEndingState.self {
      return true
    }
    return false
  }
  
  // Tapping the scanner skips the rest of the briefing

  func startWave() {
    guard scene.gameState.currentState === self else { return }
    scene.removeAction(forKey: GameScene.FLOW)
    scene.gameState.enter(PlayingState.self)
  }

  // The briefing fades as the wave begins
  override func willExit(to nextState: GKState) {
    scanner?.run(.sequence([.fadeOut(withDuration: 0.6), .removeFromParent()]))
    scanner = nil
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    // print("Intro State update")
  }
}
