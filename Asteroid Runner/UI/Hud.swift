//
//  Hud.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

// TODO: Add a scanline fill to background

// The HUD is a panel the size of the screen plus a strip. Normally only the
// strip, showing score and lives, peeks in at the top of the screen. When
// the config panel is shown the whole thing slides down over the screen.

import SpriteKit

class Hud: SKSpriteNode {

  let scoreLabel = SKLabelNode()
  let coinLabel = SKLabelNode()
  let livesNode = SKNode()
  var showAction: SKAction!
  var hideAction: SKAction!

  var button1Action = {
    print("Button 1 Activated from Game Scene")
  }

  var button2Action = {
    print("Button 2 Activated from Game Scene")
  }

  var button3Action = {
    print("Button 3 Activated from Game Scene")
  }

  var autoFireButtonAction: (Bool) -> Void = { autoFire in
    print("Auto fire button: \(autoFire)")
  }

  var autoFire = true

  let tray = ItemTray(capacity: Tuning.Items.slots)

  var button1 = Button()
  var button2 = Button()
  var button3 = Button()
  var autoFireButton = Button()

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
    setupActions()
    setupButtons()
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

  func setupActions() {
    showAction = SKAction.moveTo(y: 0, duration: 0.2)
    hideAction = SKAction.moveTo(y: Screen.sharedInstance.hudYHidden, duration: 0.2)
  }

  func setupButtons() {
    addChild(button2)
    button2.select()
    button2.title = "Speed = Power"
    button2.position.x = Screen.sharedInstance.centerX
    button2.position.y = size.height / 2
    button2.buttonAction = {
      self.button2Action()
      self.button1.deselect()
      self.button2.select()
      self.button3.deselect()
    }

    addChild(button1)
    button1.title = "Speed > Power"
    button1.position.x = Screen.sharedInstance.centerX
    button1.position.y = button2.position.y + 100
    button1.buttonAction = {
      self.button1Action()
      self.button1.select()
      self.button2.deselect()
      self.button3.deselect()
    }

    addChild(button3)
    button3.title = "Speed < Power"
    button3.position.x = Screen.sharedInstance.centerX
    button3.position.y = button2.position.y - 100
    button3.buttonAction = {
      self.button3Action()
      self.button1.deselect()
      self.button2.deselect()
      self.button3.select()
    }

    addChild(autoFireButton)
    autoFireButton.title = "Auto Fire ON"
    autoFireButton.select()
    autoFireButton.position.x = Screen.sharedInstance.centerX
    autoFireButton.position.y = button3.position.y - 120
    autoFireButton.buttonAction = {
      self.autoFire = !self.autoFire
      self.autoFireButton.title = self.autoFire ? "Auto Fire ON" : "Tap to Fire"
      self.autoFireButton.toggle()
      self.autoFireButtonAction(self.autoFire)
    }
  }

  // Slide the config panel down over the screen, or back up out of the way

  func showConfig(show: Bool) {
    removeAllActions()
    if show {
      run(showAction)
    } else {
      run(hideAction)
    }
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
