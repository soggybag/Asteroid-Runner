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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    detectDevice()
    
    if let view = self.view as! SKView? {
      // Load the SKScene from 'GameScene.sks'
      let scene = GameScene(size: view.bounds.size)
      // Set the scale mode to scale to fit the window
      scene.scaleMode = .aspectFill
      
      // Present the scene
      view.presentScene(scene)
      
      view.ignoresSiblingOrder = true
      
      view.showsFPS = true
      view.showsNodeCount = true
      view.showsPhysics = true
    }
    
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
//    if UIDevice.current.userInterfaceIdiom == .phone {
//      return .allButUpsideDown
//    } else {
//      return .all
//    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  func detectDevice() {
    if UIDevice().userInterfaceIdiom == .phone {
      switch UIScreen.main.nativeBounds.height {
      case 1136:
        deviceType = "iPhone 5 or 5S or 5C"
      case 1334:
        deviceType = "iPhone 6/6S/7/8"
      case 1920, 2208:
        deviceType = "iPhone 6+/6S+/7+/8+"
      case 2436:
        deviceType = "iPhone X"
      default:
        deviceType = "unknown"
      }
    }
  }
}

var deviceType = ""
