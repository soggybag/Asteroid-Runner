//
//  Hud.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Hud: SKSpriteNode {
  
  let scoreLabel = SKLabelNode()
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
  
  var button1 = Button()
  var button2 = Button()
  var button3 = Button()
  
  init() {
    let color = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2)
    let w = Screen.sharedInstance.width
    let h = Screen.sharedInstance.height + 40
    let size = CGSize(width: w, height: h)
    super.init(texture: nil, color: color, size: size)
    
    anchorPoint = CGPoint(x: 0, y: 0)
    zPosition = 999
    
    setupLabel()
    setupActions()
    setupButtons()
    
    showHud(show: true)
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
    scoreLabel.text = "000000"
    scoreLabel.fontColor = Colors.buttonLabelColor
    scoreLabel.fontName = Fonts.fontName
  }
  
  func setupActions() {
    hideAction = SKAction.moveTo(y: 0, duration: 0.2)
    showAction = SKAction.moveTo(y: size.height - 70, duration: 0.2)
  }
  
  func setupButtons() {
    addChild(button2)
    button2.select()
    button2.title = "Speed = Power"
    button2.position.x = size.width / 2
    button2.position.y = size.height / 2
    button2.buttonAction = {
      self.button2Action()
      self.button1.deselect()
      self.button2.select()
      self.button3.deselect()
    }
    
    addChild(button1)
    button1.title = "Speed > Power"
    button1.position.x = size.width / 2
    button1.position.y = button2.position.y + 100
    button1.buttonAction = {
      self.button1Action()
      self.button1.select()
      self.button2.deselect()
      self.button3.deselect()
    }
    
    addChild(button3)
    button3.title = "Speed < Power"
    button3.position.x = size.width / 2
    button3.position.y = button2.position.y - 100
    button3.buttonAction = {
      self.button3Action()
      self.button1.deselect()
      self.button2.deselect()
      self.button3.select()
    }
  }
  
  func showHud(show: Bool) {
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
}
