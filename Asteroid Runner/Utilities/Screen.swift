//
//  Screen.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Screen {
  var width: CGFloat = 0
  var height: CGFloat = 0
  var centerX: CGFloat = 0
  var centerY: CGFloat = 0
  var size = CGSize()
  var center = CGPoint()
  var hudScoreHeight: CGFloat = 40
  
  var deviceType = ""
  
  var hudHeight: CGFloat {
    get {
      return height + hudScoreHeight
    }
  }
  var hudYHidden: CGFloat {
    get {
      return height - hudScoreHeight
    }
  }
  
  static let sharedInstance = Screen()
  
  init() {
    detectDevice()
  }
  
  func setSize(size: CGSize) {
    self.size = size
    
    self.width = size.width
    self.height = size.height
    
    self.centerX = size.width * 0.5
    self.centerY = size.height * 0.5
    
    self.center = CGPoint(x: self.centerX, y: self.centerY)
    
    if deviceType == "iPhone X" {
      hudScoreHeight = 80
    }
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
