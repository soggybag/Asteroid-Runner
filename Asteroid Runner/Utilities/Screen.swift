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
  var safeArea = UIEdgeInsets.zero

  // Height of the score strip at the top of the screen. Grows to clear
  // the notch / Dynamic Island on devices that have one.
  var hudScoreHeight: CGFloat {
    get {
      return 40 + safeArea.top
    }
  }

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

  // Resting height of the ship, clear of the home indicator
  var shipY: CGFloat {
    get {
      return 60 + safeArea.bottom
    }
  }

  static let sharedInstance = Screen()

  func setSize(size: CGSize, safeArea: UIEdgeInsets) {
    self.size = size
    self.safeArea = safeArea

    self.width = size.width
    self.height = size.height

    self.centerX = size.width * 0.5
    self.centerY = size.height * 0.5

    self.center = CGPoint(x: self.centerX, y: self.centerY)
  }
}
