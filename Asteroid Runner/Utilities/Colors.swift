//
//  Colors.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

struct Colors {
  static let clear = UIColor.clear
  
  static let backgroundBlack = UIColor(r: 0, g: 3, b: 33)
  
  static let powerupBomb   = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
  static let powerupPoints = UIColor.cyan
  static let powerupShield = UIColor.orange
  static let powerupMissile = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
  static let powerupRapid = UIColor(red: 0.25, green: 1, blue: 0, alpha: 1)
  
  static let missile = UIColor.yellow
  
  static let shipBlue = UIColor(red: 46 / 255, green: 153 / 255, blue: 252 / 255, alpha: 0.5)
  
  static let shieldStrokeColor = UIColor(r: 0, g: 255, b: 255)
  static let shieldFillColor = UIColor(r: 0, g: 255, b: 255, alpha: 0.2)
  
  static let buttonColorNormal   = UIColor(red: 0, green: 100 / 255, blue: 0, alpha: 1)
  static let buttonColorActive   = UIColor(red: 0, green: 150 / 255, blue: 0, alpha: 1)
  static let buttonColorSelected = UIColor(red: 0, green: 150 / 255, blue: 0, alpha: 1)
  
  static let buttonLabelColor = UIColor(red: 0, green: 255 / 255, blue: 0, alpha: 1)
  
  static func randomAsteroidColor() -> UIColor {
    let r = CGFloat.random(min: 100, max: 140)
    let g = CGFloat.random(min: 70, max: 110)
    let b = CGFloat.random(min: 20, max: 40)
    
    return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
  }
}
