//
//  GameViewController.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Entry for game. Wait for layout so the scene gets the real screen
    // size and safe area rather than the storyboard's placeholder size.
    guard let view = self.view as? SKView, view.scene == nil else { return }

    let scene = GameScene(size: view.bounds.size)
    scene.safeArea = view.safeAreaInsets
    // Scene matches the view exactly
    scene.scaleMode = .resizeFill

    // Present the scene
    view.presentScene(scene)

    view.ignoresSiblingOrder = true

    #if DEBUG
    view.showsFPS = true
    view.showsNodeCount = true
    #endif
  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  // Leave the home indicator showing (it dims during play). When it's set
  // to hide, iOS doesn't defer swipes at the bottom edge, and a steering
  // drag there can switch apps.
  override var prefersHomeIndicatorAutoHidden: Bool {
    return false
  }

  // Keep edge swipes from pulling down Control Center or Notification
  // Center, or switching apps, mid-game. The user swipes twice to get them.
  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    return [.top, .bottom]
  }

}
