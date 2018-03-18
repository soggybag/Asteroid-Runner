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
  
  static let sharedInstance = Screen()
  
  func setSize(size: CGSize) {
    self.size = size
    
    self.width = size.width
    self.height = size.height
    
    self.centerX = size.width * 0.5
    self.centerY = size.height * 0.5
    
    self.center = CGPoint(x: self.centerX, y: self.centerY)
  }
}
