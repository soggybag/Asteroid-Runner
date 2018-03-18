//
//  Button.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
  
  var buttonAction = {
    print("Button Action")
  }
  
  init() {
    
    let size = CGSize(width: 60, height: 40)
    
    super.init(texture: nil, color: .red, size: size)
    
    isUserInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    buttonAction()
  }
}
