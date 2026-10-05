//
//  Hud.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

// TODO: Add a scanline fill to background

// The HUD is the strip at the top of the screen: lives, the item tray and
// score, with coins just below. The power controls are in PowerPanel.

import SpriteKit

class Hud: SKSpriteNode {

  let scoreLabel = SKLabelNode()
  let coinLabel = SKLabelNode()
  let livesNode = SKNode()
  let tray = ItemTray(capacity: Tuning.Items.slots)

  init() {
    let color = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2)
    let w = Screen.sharedInstance.width
    let h = Screen.sharedInstance.hudHeight
    let size = CGSize(width: w, height: h)
    super.init(texture: nil, color: color, size: size)

    anchorPoint = CGPoint(x: 0, y: 0)
    zPosition = 999
    position.y = Screen.sharedInstance.hudYHidden

    setupLabel()
    setupCoins()
    setupLives()
    setupTray()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupLabel() {
    addChild(scoreLabel)
    scoreLabel.fontSize = 24
    scoreLabel.position.x = Screen.sharedInstance.width - 10
    scoreLabel.position.y = 5
    scoreLabel.horizontalAlignmentMode = .right
    scoreLabel.verticalAlignmentMode = .bottom
    scoreLabel.text = "0"
    scoreLabel.fontColor = Colors.buttonLabelColor
    scoreLabel.fontName = Fonts.fontName
  }

  // Coins sit just under the strip, below the score

  func setupCoins() {
    addChild(coinLabel)
    coinLabel.fontSize = 14
    coinLabel.fontName = Fonts.fontName
    coinLabel.fontColor = Colors.coin
    coinLabel.horizontalAlignmentMode = .right
    coinLabel.verticalAlignmentMode = .top
    coinLabel.position = CGPoint(x: Screen.sharedInstance.width - 10, y: -4)
    update(coins: 0)
  }

  func setupLives() {
    addChild(livesNode)
    livesNode.position = CGPoint(x: 18, y: 18)
  }

  // Items sit in the middle of the score strip, between lives and score

  func setupTray() {
    addChild(tray)
    tray.position = CGPoint(x: Screen.sharedInstance.centerX, y: 20)
  }

  func update(score: Int) {
    scoreLabel.text = "\(score)"
  }

  func update(coins: Int) {
    coinLabel.text = "COINS \(coins)"
  }

  // Draw one small ship for each remaining life

  func update(lives: Int) {
    livesNode.removeAllChildren()
    let texture = SKTexture(imageNamed: "Satellite_4_1.png")
    for i in 0 ..< max(lives, 0) {
      let icon = SKSpriteNode(texture: texture)
      icon.size = CGSize(width: 22, height: 22)
      icon.position.x = CGFloat(i) * 26
      livesNode.addChild(icon)
    }
  }
}
