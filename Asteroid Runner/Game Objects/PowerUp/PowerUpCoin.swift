//
//  PowerUpCoin.swift
//  Asteroid Runner
//

import SpriteKit

// Gold coin, worth extra points

class PowerUpCoin: PowerUp {

  static let points = 250

  override init() {
    super.init()

    name = PowerUp.PU_COIN
    color = .clear

    let coin = SKShapeNode(circleOfRadius: size.width / 2)
    coin.fillColor = Colors.coin
    coin.strokeColor = Colors.highScore
    coin.lineWidth = 2
    addChild(coin)

    // Spin like a coin by squashing it back and forth
    let flip = SKAction.sequence([.scaleX(to: 0.2, duration: 0.3), .scaleX(to: 1, duration: 0.3)])
    run(.repeatForever(flip))

    setupPhysics()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
