//
//  PopupLabelNode.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/20/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class PopupLabelNode: SKLabelNode {
  init(message: String, location: CGPoint, fontSize: CGFloat = 16, time: TimeInterval = 3) {
    super.init()
    
    text = message
    fontName = Fonts.fontName
    self.fontSize = fontSize
    fontColor = Colors.buttonColorActive
    
    position = location
    zPosition = 9999
    
    let move = SKAction.moveBy(x: 0, y: 60, duration: time)
    move.timingMode = .easeInEaseOut
    let fade = SKAction.fadeOut(withDuration: time)
    fade.timingMode = .easeInEaseOut
    
    let moveFade = SKAction.group([
      move,
      fade
    ])
    
    run(.sequence([
      moveFade,
      .removeFromParent()
    ]))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
