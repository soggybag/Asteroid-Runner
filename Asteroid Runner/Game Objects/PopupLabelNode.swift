//
//  PopupLabelNode.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/20/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class PopupLabelNode: SKLabelNode {
  init(message: String, location: CGPoint, fontSize: CGFloat = 16) {
    super.init()
    
    text = message
    fontName = Fonts.fontName
    self.fontSize = fontSize
    
    position = location
    zPosition = 9999
    
    animate()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func animate() {
    let moveFade = SKAction.group([.moveBy(x: 0, y: 60, duration: 3), .fadeOut(withDuration: 3)])
    run(.sequence([moveFade, .removeFromParent()]))
  }
}
