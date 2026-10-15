//
//  Colors.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// Pen and marker on cream notebook paper, after the paper sketches in
// art/. Graphite for most text and lines, then red, blue and green pens
// and a few marker colors. Light colors vanish on the paper, so keep new
// ones dark or strong.

struct Colors {
  static let clear = UIColor.clear

  // The paper and its dot grid
  static let paper = UIColor(r: 244, g: 238, b: 222)
  static let paperDot = UIColor(r: 196, g: 180, b: 165)

  // Pens
  static let ink = UIColor(r: 50, g: 50, b: 60)
  static let redPen = UIColor(r: 200, g: 55, b: 45)
  static let bluePen = UIColor(r: 40, g: 90, b: 185)
  static let greenPen = UIColor(r: 30, g: 135, b: 70)

  static let powerupBomb   = UIColor(r: 200, g: 40, b: 140)
  static let powerupPoints = UIColor(r: 0, g: 140, b: 160)
  static let powerupShield = UIColor(r: 225, g: 115, b: 0)
  static let powerupMissile = UIColor(r: 30, g: 150, b: 60)
  static let powerupRapid = UIColor(r: 100, g: 160, b: 0)

  // Missiles by weapons power, weakest to strongest: pencil to red ink
  static let missileWeak = UIColor(r: 150, g: 145, b: 130)
  static let missileLow = UIColor(r: 90, g: 90, b: 100)
  static let missile = bluePen
  static let missileHigh = UIColor(r: 215, g: 100, b: 20)
  static let missileMax = redPen

  static let highScore = UIColor(r: 220, g: 120, b: 15)
  static let coin = UIColor(r: 190, g: 135, b: 0)
  static let enemyShot = UIColor(r: 215, g: 35, b: 35)
  static let gasExplosion = UIColor(r: 90, g: 170, b: 40)
  static let station = bluePen
  static let mazeWall = UIColor(r: 90, g: 95, b: 110)
  static let engines = greenPen

  // Station screens: a sheet of paper over the game, in blue pen
  static let stationPanel = UIColor(r: 250, g: 246, b: 234, alpha: 0.97)
  static let stationText = ink
  static let buy = UIColor(r: 185, g: 125, b: 0)
  static let sell = redPen
  static let upgrade = UIColor(r: 120, g: 70, b: 180)

  static let shipBlue = UIColor(red: 46 / 255, green: 153 / 255, blue: 252 / 255, alpha: 0.5)

  static let shieldStrokeColor = UIColor(r: 0, g: 140, b: 170)
  static let shieldFillColor = UIColor(r: 0, g: 140, b: 170, alpha: 0.15)

  // The ship's HUD and buttons: graphite. Buttons fill faintly when
  // selected so the label still reads.
  static let buttonColorNormal   = ink
  static let buttonColorActive   = UIColor(r: 95, g: 95, b: 105)
  static let buttonColorSelected = UIColor(r: 50, g: 50, b: 60, alpha: 0.15)

  static let buttonLabelColor = ink

  static func randomAsteroidColor() -> UIColor {
    let r = CGFloat.random(in: 100 ... 140)
    let g = CGFloat.random(in: 70 ... 110)
    let b = CGFloat.random(in: 20 ... 40)

    return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
  }
}
