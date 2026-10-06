//
//  PowerPanel.swift
//  Asteroid Runner
//

// The power HUD: swipe up to open it mid-flight. Shows the reactor and a
// bar for each system with + and - buttons. Raising one system when the
// reactor is maxed takes a unit from the system with the most. The panel
// only draws and reports taps; GameScene changes the power.

import SpriteKit

class PowerPanel: SKNode {

  var onRaise: (ShipSystem) -> Void = { _ in }
  var onLower: (ShipSystem) -> Void = { _ in }
  var onAutoFire: () -> Void = {}

  static let height: CGFloat = 316

  let size: CGSize

  private var bars = [ShipSystem: [SKShapeNode]]()
  private var levelLabels = [ShipSystem: SKLabelNode]()
  private var reactorPips = [SKShapeNode]()
  private let autoFireButton: ShopButton
  private let autoFireLabel: SKLabelNode

  private static let segment = CGSize(width: 44, height: 12)

  static func color(_ system: ShipSystem) -> UIColor {
    switch system {
    case .engines: return Colors.engines
    case .shields: return Colors.shieldStrokeColor
    case .weapons: return Colors.missile
    }
  }

  init(width: CGFloat, maxLevel: Int, reactor: Int) {
    size = CGSize(width: width, height: PowerPanel.height)
    autoFireButton = ShopButton(title: "", color: Colors.buttonLabelColor)
    autoFireLabel = SKLabelNode()
    super.init()

    zPosition = 1500

    let back = SKShapeNode(rect: CGRect(origin: .zero, size: size), cornerRadius: 12)
    back.fillColor = Colors.backgroundBlack.withAlphaComponent(0.75)
    back.strokeColor = Colors.buttonColorActive
    back.lineWidth = 2
    addChild(back)

    let top = size.height

    let title = label("POWER", size: 16, color: Colors.buttonLabelColor)
    title.horizontalAlignmentMode = .left
    title.position = CGPoint(x: 16, y: top - 30)
    addChild(title)

    // One pip per reactor unit; lit pips are in use
    let pipSize = CGSize(width: 14, height: 10)
    for i in 0 ..< reactor {
      let pip = SKShapeNode(rectOf: pipSize, cornerRadius: 2)
      pip.position = CGPoint(x: size.width - 16 - pipSize.width / 2 - CGFloat(reactor - 1 - i) * (pipSize.width + 4), y: top - 25)
      pip.strokeColor = Colors.buttonLabelColor
      pip.lineWidth = 1
      addChild(pip)
      reactorPips.append(pip)
    }

    for (column, system) in ShipSystem.allCases.enumerated() {
      let x = size.width * (CGFloat(column) * 2 + 1) / 6
      let color = PowerPanel.color(system)

      let name = label(system.name, size: 14, color: color)
      name.position = CGPoint(x: x, y: top - 62)
      addChild(name)

      let plus = ShopButton(title: "+", color: color, width: 64)
      plus.position = CGPoint(x: x, y: top - 92)
      plus.tapped = { self.onRaise(system) }
      addChild(plus)

      // Segments fill from the bottom up
      var segments = [SKShapeNode]()
      for i in 0 ..< maxLevel {
        let seg = SKShapeNode(rectOf: PowerPanel.segment, cornerRadius: 2)
        seg.position = CGPoint(x: x, y: top - 182 + CGFloat(i) * (PowerPanel.segment.height + 4))
        seg.strokeColor = color
        seg.lineWidth = 1
        addChild(seg)
        segments.append(seg)
      }
      bars[system] = segments

      let level = label("", size: 12, color: color)
      level.position = CGPoint(x: x + PowerPanel.segment.width / 2 + 12, y: top - 140)
      level.horizontalAlignmentMode = .left
      addChild(level)
      levelLabels[system] = level

      let minus = ShopButton(title: "\u{2212}", color: color, width: 64)
      minus.position = CGPoint(x: x, y: top - 212)
      minus.tapped = { self.onLower(system) }
      addChild(minus)
    }

    autoFireButton.position = CGPoint(x: size.width / 2, y: 48)
    autoFireButton.tapped = { self.onAutoFire() }
    addChild(autoFireButton)
    autoFireLabel.fontName = Fonts.fontName
    autoFireLabel.fontSize = 13
    autoFireLabel.fontColor = Colors.buttonLabelColor
    autoFireLabel.verticalAlignmentMode = .center
    autoFireButton.addChild(autoFireLabel)

    let hint = label("Swipe down to close", size: 11, color: Colors.buttonColorActive)
    hint.position = CGPoint(x: size.width / 2, y: 14)
    addChild(hint)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(grid: PowerGrid, autoFire: Bool) {
    for (i, pip) in reactorPips.enumerated() {
      pip.fillColor = i < grid.used ? Colors.buttonLabelColor : .clear
    }
    for system in ShipSystem.allCases {
      let level = grid.level(system)
      let color = PowerPanel.color(system)
      for (i, seg) in (bars[system] ?? []).enumerated() {
        seg.fillColor = i < level ? color : .clear
      }
      levelLabels[system]?.text = "\(level)"
    }
    autoFireLabel.text = autoFire ? "Auto fire ON" : "Hold to fire"
  }

  private func label(_ text: String, size: CGFloat, color: UIColor) -> SKLabelNode {
    let node = SKLabelNode(text: text)
    node.fontName = Fonts.fontName
    node.fontSize = size
    node.fontColor = color
    node.verticalAlignmentMode = .baseline
    return node
  }
}
