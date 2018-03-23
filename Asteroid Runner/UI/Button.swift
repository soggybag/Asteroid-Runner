//
//  Button.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

// TODO: Add custom rounded ends to button

import SpriteKit

class Button: SKSpriteNode {
  
  let label       = SKLabelNode()
  let strokeNode  = SKShapeNode()
  let fillNode    = SKShapeNode()
  
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
    
    super.init(texture: nil, color: .clear, size: size)
    
    isUserInteractionEnabled = true
    
    setupShape()
    setupLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    buttonAction()
  }
  
  func setupShape() {
    
    
    
    
    //// StrokePath Drawing
    let strokePath = UIBezierPath(roundedRect: CGRect(x: -70, y: -20, width: 140, height: 40), cornerRadius: 20)
    
    strokeNode.path = strokePath.cgPath
    strokeNode.lineWidth = 3
    strokeNode.strokeColor = Colors.buttonColorNormal
    
    
    //// fillPath Drawing
    let fillPath = UIBezierPath(roundedRect: CGRect(x: -65, y: -15, width: 130, height: 30), cornerRadius: 15)
    fillNode.path = fillPath.cgPath
    fillNode.fillColor = Colors.buttonColorNormal
    fillNode.strokeColor = UIColor.clear
    
    addChild(strokeNode)
    addChild(fillNode)
    
    deselect()
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
    fillNode.isHidden = false
  }
  
  func deselect() {
    fillNode.isHidden = true
  }
  
  func toggle() {
    fillNode.isHidden = !fillNode.isHidden
  }
}
