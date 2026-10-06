//
//  ScannerPanel.swift
//  Asteroid Runner
//

// The stage briefing, shown as the ship's long-range scanner before each
// wave: a radar sweep with contacts, what kind of wave is coming, the
// sizes and speed, anything special, and a hint for the power HUD. It
// stays up until the wave starts.

import SpriteKit

class ScannerPanel: SKNode {

  static let height: CGFloat = 156
  private static let radarRadius: CGFloat = 48

  init(wave: WavePlan, stationAhead: String?, width: CGFloat) {
    super.init()
    zPosition = 1200

    let size = CGSize(width: width, height: ScannerPanel.height)
    let back = SKShapeNode(rect: CGRect(origin: .zero, size: size), cornerRadius: 10)
    back.fillColor = Colors.backgroundBlack.withAlphaComponent(0.7)
    back.strokeColor = Colors.buttonColorActive
    back.lineWidth = 1.5
    addChild(back)

    addRadar(at: CGPoint(x: 16 + ScannerPanel.radarRadius, y: size.height / 2), wave: wave)

    // Text to the right of the radar, top down
    let x = 16 + ScannerPanel.radarRadius * 2 + 16
    var y = size.height - 24

    addLabel("SCANNER  ·  STAGE \(wave.stage)", size: 11, color: Colors.buttonColorActive, at: CGPoint(x: x, y: y))
    y -= 26
    addLabel(wave.recipe.name.uppercased(), size: 20, color: Colors.buttonLabelColor, at: CGPoint(x: x, y: y))
    y -= 22

    let sizes = wave.smallest == wave.largest
      ? wave.smallest.toString()
      : "\(wave.smallest.toString())–\(wave.largest.toString())"
    addLabel("\(sizes)  ·  \(wave.speed.toString())", size: 13, color: Colors.station, at: CGPoint(x: x, y: y))
    y -= 20

    if wave.recipe.usesFeatured && wave.featured != .normal {
      addLabel("Watch for: \(wave.featured.toString())", size: 13, color: Colors.highScore, at: CGPoint(x: x, y: y))
      y -= 20
    }

    let adviceColor = wave.recipe.adviceSystem.map { PowerPanel.color($0) } ?? Colors.buttonLabelColor
    addLabel("Suggest: \(wave.recipe.advice)", size: 13, color: adviceColor, at: CGPoint(x: x, y: y))
    y -= 20

    if let station = stationAhead {
      addLabel("Station ahead: \(station)", size: 13, color: Colors.station, at: CGPoint(x: x, y: y))
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // Rings, a turning sweep, and blips: more of them for busier waves

  private func addRadar(at center: CGPoint, wave: WavePlan) {
    let radar = SKNode()
    radar.position = center
    addChild(radar)

    let r = ScannerPanel.radarRadius
    for scale in [1.0, 0.66, 0.33] {
      let ring = SKShapeNode(circleOfRadius: r * scale)
      ring.strokeColor = Colors.buttonColorNormal
      ring.lineWidth = 1
      radar.addChild(ring)
    }

    let path = CGMutablePath()
    path.move(to: .zero)
    path.addLine(to: CGPoint(x: 0, y: r))
    let sweep = SKShapeNode(path: path)
    sweep.strokeColor = Colors.buttonLabelColor
    sweep.lineWidth = 2
    radar.addChild(sweep)
    sweep.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 2)))

    let blips: Int
    switch wave.recipe {
    case .swarm, .bosstroidField: blips = 9
    case .maze, .lanes: blips = 7
    case .heavy: blips = 3
    default: blips = 5
    }
    for i in 0 ..< blips {
      let big = wave.recipe == .bosstroidField && i == 0
      let blip = SKShapeNode(circleOfRadius: big ? 6 : 2)
      blip.fillColor = big ? Colors.highScore : Colors.buttonLabelColor
      blip.strokeColor = .clear
      let angle = CGFloat.random(in: 0 ..< .pi * 2)
      let distance = CGFloat.random(in: r * 0.2 ... r * 0.9)
      blip.position = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
      radar.addChild(blip)
      blip.run(.repeatForever(.sequence([.fadeAlpha(to: 0.2, duration: 0.8), .fadeAlpha(to: 1, duration: 0.4)])))
    }
  }

  private func addLabel(_ text: String, size: CGFloat, color: UIColor, at point: CGPoint) {
    let label = SKLabelNode(text: text)
    label.fontName = Fonts.fontName
    label.fontSize = size
    label.fontColor = color
    label.horizontalAlignmentMode = .left
    label.verticalAlignmentMode = .baseline
    label.position = point
    addChild(label)
  }
}
