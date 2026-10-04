//
//  StationNode.swift
//  Asteroid Runner
//

// Placeholder station art: a slowly turning ring with spokes and a
// docking port, with the station's name underneath. Swap in a sprite
// when the art is ready.

import SpriteKit

class StationNode: SKNode {

  static let radius: CGFloat = 70

  init(name stationName: String) {
    super.init()

    zPosition = 50

    let wheel = SKNode()
    addChild(wheel)

    let ring = SKShapeNode(circleOfRadius: StationNode.radius)
    ring.strokeColor = Colors.station
    ring.lineWidth = 6
    ring.fillColor = Colors.station.withAlphaComponent(0.08)
    wheel.addChild(ring)

    let hub = SKShapeNode(circleOfRadius: 18)
    hub.strokeColor = Colors.station
    hub.lineWidth = 3
    hub.fillColor = Colors.station.withAlphaComponent(0.3)
    wheel.addChild(hub)

    for i in 0 ..< 4 {
      let angle = CGFloat(i) * .pi / 2
      let path = CGMutablePath()
      path.move(to: CGPoint(x: cos(angle) * 18, y: sin(angle) * 18))
      path.addLine(to: CGPoint(x: cos(angle) * StationNode.radius, y: sin(angle) * StationNode.radius))
      let spoke = SKShapeNode(path: path)
      spoke.strokeColor = Colors.station
      spoke.lineWidth = 2
      wheel.addChild(spoke)
    }

    wheel.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 30)))

    // The ship docks here, under the station
    let port = SKShapeNode(rectOf: CGSize(width: 26, height: 14), cornerRadius: 3)
    port.position.y = -StationNode.radius - 6
    port.strokeColor = Colors.station
    port.fillColor = Colors.backgroundBlack
    port.lineWidth = 2
    addChild(port)

    let label = SKLabelNode(text: stationName.uppercased())
    label.fontName = Fonts.fontName
    label.fontSize = 18
    label.fontColor = Colors.buttonLabelColor
    label.position.y = StationNode.radius + 16
    addChild(label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
