//
//  Menu.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Menu: SKSpriteNode {
  
  var label: SKLabelNode!
  
  var tapToPlay = {
    print("Tap To Play")
  }
  
  init() {
    let color = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    let size = Screen.sharedInstance.size
    super.init(texture: nil, color: color, size: size)
    
    let button = Button()
    addChild(button)
    button.buttonAction = {
      self.tapToPlay()
    }
    
    label = SKLabelNode()
    addChild(label)
    label.position = button.position
    label.position.y = label.position.y - 100
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func hide() {
    isHidden = true
  }
  
  func show() {
    isHidden = false
  }
  
  func show(message: String) {
    label.text = message
    show()
  }
}





//
