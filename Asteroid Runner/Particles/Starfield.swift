//
//  Starfield.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Starfield: SKNode {
  
  var starfield: SKEmitterNode!
  let size: CGSize!
  
  init(size: CGSize) {
    self.size = size
    
    super.init()
    
    setupStarfield()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupStarfield() {
    starfield = SKEmitterNode(fileNamed: "Starfield")
    starfield.position = CGPoint(x: size.width / 2, y: size.height)
    starfield.advanceSimulationTime(60)
    addChild(starfield)
    starfield.zPosition = -1
  }
}
