//
//  PublicExtension.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

// Random numbers now come from the standard library: Int.random(in:),
// CGFloat.random(in:), Bool.random() and Array.randomElement().

import Foundation
import CoreGraphics
import SpriteKit

public extension CGVector {
  /**
   * Adds two CGVector values and returns the result as a new CGVector.
   */
  static func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
  }
}

public extension CGPoint {
  /**
   * Adds two CGPoint values and returns the result as a new CGPoint.
   */
  static func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
  }
}

extension UIColor {
  // Extension on colors to make RGB easier to read
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
  }

  convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
  }
}
