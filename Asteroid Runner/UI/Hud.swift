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
  let distanceLabel = SKLabelNode()
  let livesNode = SKNode()
  private(set) var tray = ItemTray(capacity: Tuning.Items.slots)

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

    // Distance traveled, under the coins
    addChild(distanceLabel)
    distanceLabel.fontSize = 12
    distanceLabel.fontName = Fonts.fontName
    distanceLabel.fontColor = Colors.station
    distanceLabel.horizontalAlignmentMode = .right
    distanceLabel.verticalAlignmentMode = .top
    distanceLabel.position = CGPoint(x: Screen.sharedInstance.width - 10, y: -22)
    update(distance: RunStats().distanceText)
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

  // Rebuild the tray with more or fewer slots, keeping its tap handler
  func setTrayCapacity(_ capacity: Int) {
    let handler = tray.slotTapped
    tray.removeFromParent()
    tray = ItemTray(capacity: capacity)
    tray.slotTapped = handler
    setupTray()
  }

  func update(score: Int) {
    scoreLabel.text = "\(score)"
  }

  func update(coins: Int) {
    coinLabel.text = "COINS \(coins)"
  }

  func update(distance: String) {
    distanceLabel.text = distance
  }

  // Draw one small ship for each remaining life

  // One small ship per life, up to three. With more (from hull plating),
  // one ship and a count, so the strip has room for the tray.
  func update(lives: Int) {
    livesNode.removeAllChildren()
    let texture = SKTexture(imageNamed: "Satellite_4_1.png")
    let icons = lives > 3 ? 1 : max(lives, 0)
    for i in 0 ..< icons {
      let icon = SKSpriteNode(texture: texture)
      icon.size = CGSize(width: 22, height: 22)
      icon.position.x = CGFloat(i) * 26
      livesNode.addChild(icon)
    }
    if lives > 3 {
      let count = SKLabelNode(text: "×\(lives)")
      count.fontName = Fonts.fontName
      count.fontSize = 16
      count.fontColor = Colors.buttonLabelColor
      count.horizontalAlignmentMode = .left
      count.verticalAlignmentMode = .center
      count.position.x = 16
      livesNode.addChild(count)
    }
  }
}
