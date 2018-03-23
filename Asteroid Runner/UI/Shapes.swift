//
//  Shapes.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/19/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Triangle: SKShapeNode {
  override init() {
    super.init()
    
    //// Polygon Drawing
    let polygonPath = UIBezierPath()
    polygonPath.move(to: CGPoint(x: 46, y: 19))
    polygonPath.addLine(to: CGPoint(x: 67.65, y: 56.5))
    polygonPath.addLine(to: CGPoint(x: 24.35, y: 56.5))
    polygonPath.close()
    
    path = polygonPath.cgPath
    
    strokeColor = UIColor.yellow
    fillColor = UIColor.yellow
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class Circle: SKShapeNode {
  override init() {
    super.init()
    
    //// Oval Drawing
    let ovalPath = UIBezierPath(ovalIn: CGRect(x: 91, y: 61, width: 50, height: 50))
    path = ovalPath.cgPath
    
    strokeColor = UIColor.blue
    fillColor = UIColor.blue
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class Square: SKShapeNode {
  override init() {
    super.init()
    
    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(rect: CGRect(x: 163, y: 20, width: 50, height: 50))
    
    path = rectanglePath.cgPath
    
    strokeColor = UIColor.red
    fillColor = UIColor.red
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

