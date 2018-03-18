//
//  Button.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
  
  let label = SKLabelNode()
  
  var buttonAction = {
    print("Button Action")
  }
  
  var title: String = "Title" {
    didSet {
      label.text = title
    }
  }
  
  init() {
    
    let size = CGSize(width: 140, height: 40)
    
    super.init(texture: nil, color: Colors.buttonColorNormal, size: size)
    
    isUserInteractionEnabled = true
    
    setupLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    buttonAction()
  }
  
  func setupLabel() {
    addChild(label)
    label.fontSize = 16
    label.horizontalAlignmentMode = .center
    label.verticalAlignmentMode = .center
    label.fontColor = Colors.buttonLabelColor
    label.fontName = Fonts.fontName
  }
  
  func select() {
    color = Colors.buttonColorSelected
  }
  
  func deselect() {
    color = Colors.buttonColorNormal
  }
}
