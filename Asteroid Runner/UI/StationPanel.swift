//
//  StationPanel.swift
//  Asteroid Runner
//

// The station screen shown while docked: the keeper's greeting, coins and
// hull, a shop to buy items and repairs, the tray's items to sell, and a
// Launch button. The panel only draws and reports taps; StationState
// does the buying and selling and calls refresh.

import SpriteKit

class StationPanel: SKNode {

  var onBuy: (ItemType) -> Void = { _ in }
  var onRepair: () -> Void = {}
  var onSell: (Int) -> Void = { _ in }
  var onLaunch: () -> Void = {}

  let station: Station
  let size: CGSize

  // Rebuilt by refresh
  private let shopNode = SKNode()

  private let pad: CGFloat = 16
  private let rowHeight: CGFloat = 44

  init(station: Station, greeting: String, size: CGSize) {
    self.station = station
    self.size = size
    super.init()

    zPosition = 2000

    let back = SKShapeNode(rect: CGRect(origin: .zero, size: size), cornerRadius: 12)
    back.fillColor = Colors.backgroundBlack.withAlphaComponent(0.92)
    back.strokeColor = Colors.station
    back.lineWidth = 2
    addChild(back)

    let keeper = label("\(station.keeper.name) · \(station.keeper.title)", size: 14, color: Colors.station)
    keeper.position = CGPoint(x: pad, y: size.height - pad)
    keeper.verticalAlignmentMode = .top
    addChild(keeper)

    let words = label("\u{201C}\(greeting)\u{201D}", size: 16, color: Colors.buttonLabelColor)
    words.numberOfLines = 3
    words.preferredMaxLayoutWidth = size.width - pad * 2
    words.lineBreakMode = .byWordWrapping
    words.verticalAlignmentMode = .top
    words.position = CGPoint(x: pad, y: size.height - pad - 24)
    addChild(words)

    addChild(shopNode)

    let launch = Button()
    launch.title = "Launch"
    launch.select()
    launch.position = CGPoint(x: size.width / 2, y: pad + 20)
    launch.buttonAction = { self.onLaunch() }
    addChild(launch)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // Redraw coins, hull, what's for sale and what can be sold

  func refresh(coins: Int, lives: Int, maxLives: Int, inventory: Inventory, message: String?) {
    shopNode.removeAllChildren()

    var y = size.height - pad - 104

    let status = label("Coins \(coins)     Hull \(lives)/\(maxLives)     Tray \(inventory.items.count)/\(inventory.capacity)", size: 15, color: Colors.coin)
    status.position = CGPoint(x: pad, y: y)
    shopNode.addChild(status)
    y -= 26

    // Buy: items for sale, then repairs
    shopNode.addChild(header("BUY", y: y))
    y -= 12
    var cells = [ShopButton]()
    for item in station.itemsForSale {
      let price = station.buyPrice(item)
      let cell = ShopButton(title: "\(item.name) · \(price)", color: item.color)
      cell.isEnabled = coins >= price && !inventory.isFull
      cell.tapped = { self.onBuy(item) }
      cells.append(cell)
    }
    if lives < maxLives {
      let cell = ShopButton(title: "Repair · \(station.repairPrice)", color: Colors.station)
      cell.isEnabled = coins >= station.repairPrice
      cell.tapped = { self.onRepair() }
      cells.append(cell)
    }
    y = layout(cells, top: y)

    // Sell: what's in the tray
    shopNode.addChild(header("SELL", y: y))
    y -= 12
    if inventory.items.isEmpty {
      let none = label("Tray is empty", size: 13, color: Colors.buttonColorActive)
      none.position = CGPoint(x: pad, y: y - 10)
      shopNode.addChild(none)
      y -= rowHeight
    } else {
      var sells = [ShopButton]()
      for (slot, item) in inventory.items.enumerated() {
        let cell = ShopButton(title: "\(item.type.name) · \(station.sellPrice(item.type))", color: item.type.color)
        cell.tapped = { self.onSell(slot) }
        sells.append(cell)
      }
      y = layout(sells, top: y)
    }

    if let message = message {
      let note = label(message, size: 14, color: Colors.highScore)
      note.horizontalAlignmentMode = .center
      note.position = CGPoint(x: size.width / 2, y: y - 8)
      shopNode.addChild(note)
    }
  }


  // Lay cells out three to a row, top down. Returns where the next
  // heading's baseline goes, a little below the last row.

  private func layout(_ cells: [ShopButton], top: CGFloat) -> CGFloat {
    let columns = 3
    let gap: CGFloat = 8
    let step = ShopButton.size.width + gap
    let firstX = size.width / 2 - step
    var y = top
    for (i, cell) in cells.enumerated() {
      if i > 0 && i % columns == 0 {
        y -= rowHeight
      }
      cell.position = CGPoint(x: firstX + step * CGFloat(i % columns), y: y - ShopButton.size.height / 2)
      shopNode.addChild(cell)
    }
    return y - rowHeight - 16
  }

  private func header(_ text: String, y: CGFloat) -> SKLabelNode {
    let node = label(text, size: 12, color: Colors.buttonColorActive)
    node.position = CGPoint(x: pad, y: y)
    return node
  }

  private func label(_ text: String, size: CGFloat, color: UIColor) -> SKLabelNode {
    let node = SKLabelNode(text: text)
    node.fontName = Fonts.fontName
    node.fontSize = size
    node.fontColor = color
    node.horizontalAlignmentMode = .left
    node.verticalAlignmentMode = .baseline
    return node
  }
}


// A small button for one thing in the shop. Dimmed when it can't be
// afforded, but still tappable so the station can say why.

class ShopButton: SKSpriteNode {

  static let size = CGSize(width: 112, height: 36)

  var tapped = {}

  var isEnabled = true {
    didSet {
      alpha = isEnabled ? 1 : 0.4
    }
  }

  init(title: String, color: UIColor) {
    super.init(texture: nil, color: .clear, size: ShopButton.size)
    isUserInteractionEnabled = true

    let s = ShopButton.size
    let shape = SKShapeNode(rect: CGRect(x: -s.width / 2, y: -s.height / 2, width: s.width, height: s.height), cornerRadius: 8)
    shape.strokeColor = color
    shape.fillColor = color.withAlphaComponent(0.15)
    shape.lineWidth = 2
    addChild(shape)

    let label = SKLabelNode(text: title)
    label.fontName = Fonts.fontName
    label.fontSize = 13
    label.fontColor = color
    label.verticalAlignmentMode = .center
    addChild(label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    tapped()
  }
}
