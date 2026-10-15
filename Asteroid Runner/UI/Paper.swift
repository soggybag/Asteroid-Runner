//
//  Paper.swift
//  Asteroid Runner
//

// The game's background: cream notebook paper with a dot grid, like the
// paper the art is drawn on. The grid scrolls down as the ship flies up,
// which is how the game shows speed (it was a starfield).

import SpriteKit

class Paper: SKNode {

  // Space between dots, and how fast the grid scrolls, in points
  static let spacing: CGFloat = 20
  static let speed: CGFloat = 24
  static let dotRadius: CGFloat = 1.1

  init(size: CGSize) {
    super.init()

    // Two tiles, one above the other, slide down one tile's height and
    // jump back. A tile is a whole number of rows so the jump can't be seen.
    let rows = (size.height / Paper.spacing).rounded(.up) + 1
    let tileSize = CGSize(width: size.width, height: rows * Paper.spacing)
    let texture = SKTexture(image: Paper.dotGrid(size: tileSize))
    let scroll = SKNode()
    for i in 0 ..< 2 {
      let tile = SKSpriteNode(texture: texture, size: tileSize)
      tile.anchorPoint = .zero
      tile.position.y = CGFloat(i) * tileSize.height
      scroll.addChild(tile)
    }
    addChild(scroll)

    let h = tileSize.height
    let slide = SKAction.moveBy(x: 0, y: -h, duration: TimeInterval(h / Paper.speed))
    scroll.run(.repeatForever(.sequence([slide, .moveBy(x: 0, y: h, duration: 0)])))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // Paper with dots, centered across the width
  static func dotGrid(size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
      Colors.paper.setFill()
      context.fill(CGRect(origin: .zero, size: size))

      Colors.paperDot.setFill()
      let left = (size.width.truncatingRemainder(dividingBy: spacing) + spacing) / 2
      var y = spacing / 2
      while y < size.height {
        var x = left
        while x < size.width {
          context.cgContext.fillEllipse(in: CGRect(x: x - dotRadius, y: y - dotRadius,
                                                   width: dotRadius * 2, height: dotRadius * 2))
          x += spacing
        }
        y += spacing
      }
    }
  }
}
