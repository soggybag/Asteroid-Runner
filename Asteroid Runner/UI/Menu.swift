//
//  Menu.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

class Menu: SKSpriteNode {

  var label: SKLabelNode!
  var bestLabel: SKLabelNode!
  var stageLabel: SKLabelNode!
  var killsLabel: SKLabelNode!
  var wavesLabel: SKLabelNode!

  var message = "" {
    didSet {
      label.text = message
    }
  }

  var tapToPlay = {
    print("Tap To Play")
  }

  init() {
    let color = UIColor(white: 0, alpha: 0.5)
    let size = Screen.sharedInstance.size
    super.init(texture: nil, color: color, size: size)

    let button = Button()
    addChild(button)
    button.title = "Play Again"
    button.buttonAction = {
      self.tapToPlay()
    }

    label = SKLabelNode()
    addChild(label)
    label.fontColor = Colors.buttonLabelColor
    label.fontName = Fonts.fontName
    label.position = button.position
    label.position.y = label.position.y - 100

    bestLabel = SKLabelNode()
    addChild(bestLabel)
    bestLabel.fontColor = Colors.buttonLabelColor
    bestLabel.fontName = Fonts.fontName
    bestLabel.fontSize = 20
    bestLabel.position = label.position
    bestLabel.position.y = label.position.y - 40

    // How far the run got
    stageLabel = statLabel(y: bestLabel.position.y - 44)
    killsLabel = statLabel(y: stageLabel.position.y - 26)

    // The kinds of wave met, wrapping onto a second line if needed
    wavesLabel = statLabel(y: killsLabel.position.y - 24)
    wavesLabel.fontSize = 13
    wavesLabel.numberOfLines = 3
    wavesLabel.preferredMaxLayoutWidth = Screen.sharedInstance.width - 40
    wavesLabel.verticalAlignmentMode = .top
  }

  private func statLabel(y: CGFloat) -> SKLabelNode {
    let node = SKLabelNode()
    addChild(node)
    node.fontColor = Colors.station
    node.fontName = Fonts.fontName
    node.fontSize = 17
    node.position = CGPoint(x: 0, y: y)
    return node
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func hide() {
    isHidden = true
  }

  func show() {
    isHidden = false
  }

  func show(message: String) {
    self.message = message
    show()
  }

  // Show how far the run got

  func show(stage: Int, stats: RunStats) {
    stageLabel.text = "Stage \(stage)  ·  \(stats.distanceText)"
    killsLabel.text = "Asteroids \(stats.asteroidsDestroyed)  ·  Turrets \(stats.turretsDestroyed)"
    wavesLabel.text = stats.wavesText
  }

  // Show the best score, highlighted when it was just beaten

  func show(best: Int, isNew: Bool) {
    bestLabel.text = isNew ? "New High Score!" : "Best: \(best)"
    bestLabel.fontColor = isNew ? Colors.highScore : Colors.buttonLabelColor
  }
}
