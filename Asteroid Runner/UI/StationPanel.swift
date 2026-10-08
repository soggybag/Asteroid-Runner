//
//  StationPanel.swift
//  Asteroid Runner
//

// The station screen shown while docked. It has its own look, navy and
// station blue, so it doesn't read as the ship's green HUD. The keeper's
// greeting sits on top; below it Buy, Sell, Repair and Upgrade tabs show
// one list at a time, so buying and selling can't be mixed up; each row has its
// own clearly labeled button. The panel only draws and reports taps;
// StationState does the buying and selling and calls refresh.

import SpriteKit

class StationPanel: SKNode {

  enum Tab: CaseIterable {
    case buy, sell, repair, upgrade

    var title: String {
      switch self {
      case .buy: return "BUY"
      case .sell: return "SELL"
      case .repair: return "REPAIR"
      case .upgrade: return "UPGRADE"
      }
    }
  }

  var onBuy: (ItemType) -> Void = { _ in }
  var onRepair: () -> Void = {}
  var onSell: (Int) -> Void = { _ in }
  var onUpgrade: (ShipUpgrade) -> Void = { _ in }
  var onLaunch: () -> Void = {}

  let station: Station
  let size: CGSize

  private(set) var tab = Tab.buy

  // Rebuilt by refresh
  private let content = SKNode()
  private var tabButtons = [Tab: TabButton]()

  // The last state shown, so a tab change can redraw without the scene
  private var last: (coins: Int, lives: Int, maxLives: Int, upgrades: ShipUpgrades, inventory: Inventory)?

  private let pad: CGFloat = 16
  private let rowHeight: CGFloat = 40

  init(station: Station, greeting: String, size: CGSize) {
    self.station = station
    self.size = size
    super.init()

    zPosition = 2000

    let back = SKShapeNode(rect: CGRect(origin: .zero, size: size), cornerRadius: 14)
    back.fillColor = Colors.stationPanel
    back.strokeColor = Colors.station
    back.lineWidth = 2
    addChild(back)

    // A header band with the keeper and their greeting
    let headerHeight: CGFloat = 78
    let header = SKShapeNode(rect: CGRect(x: 2, y: size.height - headerHeight - 2, width: size.width - 4, height: headerHeight),
                             cornerRadius: 12)
    header.fillColor = Colors.station.withAlphaComponent(0.12)
    header.strokeColor = .clear
    addChild(header)

    let keeper = label("\(station.keeper.name.uppercased())  ·  \(station.keeper.title)", size: 13, color: Colors.station)
    keeper.position = CGPoint(x: pad, y: size.height - pad)
    keeper.verticalAlignmentMode = .top
    addChild(keeper)

    let words = label("\u{201C}\(greeting)\u{201D}", size: 15, color: Colors.stationText)
    words.numberOfLines = 2
    words.preferredMaxLayoutWidth = size.width - pad * 2
    words.lineBreakMode = .byWordWrapping
    words.verticalAlignmentMode = .top
    words.position = CGPoint(x: pad, y: size.height - pad - 20)
    addChild(words)

    // Tabs under the header
    let tabY = size.height - headerHeight - 54
    let tabCount = CGFloat(Tab.allCases.count)
    let tabWidth = (size.width - pad * 2 - 8 * (tabCount - 1)) / tabCount
    for (i, t) in Tab.allCases.enumerated() {
      let button = TabButton(title: t.title, width: tabWidth)
      button.position = CGPoint(x: pad + tabWidth / 2 + CGFloat(i) * (tabWidth + 8), y: tabY)
      button.tapped = { self.select(t) }
      addChild(button)
      tabButtons[t] = button
    }

    addChild(content)

    let launch = TabButton(title: "LAUNCH", width: 160)
    launch.isSelected = true
    launch.position = CGPoint(x: size.width / 2, y: pad + 20)
    launch.tapped = { self.onLaunch() }
    addChild(launch)

    select(.buy)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var tabY: CGFloat {
    return size.height - 78 - 54
  }

  func select(_ tab: Tab) {
    self.tab = tab
    for (t, button) in tabButtons {
      button.isSelected = t == tab
    }
    if let last = last {
      refresh(coins: last.coins, lives: last.lives, maxLives: last.maxLives, upgrades: last.upgrades,
              inventory: last.inventory, message: nil)
    }
  }


  // Redraw the wallet line and the open tab's list

  func refresh(coins: Int, lives: Int, maxLives: Int, upgrades: ShipUpgrades, inventory: Inventory, message: String?) {
    last = (coins, lives, maxLives, upgrades, inventory)
    content.removeAllChildren()

    let wallet = label("Coins \(coins)     Hull \(lives)/\(maxLives)     Tray \(inventory.items.count)/\(inventory.capacity)",
                       size: 14, color: Colors.coin)
    wallet.position = CGPoint(x: pad, y: tabY + 30)
    content.addChild(wallet)

    var y = tabY - 40
    func row(_ name: String, detail: String?, action: ShopButton, detailOnNewLine: Bool = false) {
      let nameLabel = label(name, size: 15, color: Colors.stationText)
      nameLabel.position = CGPoint(x: pad, y: detailOnNewLine ? y + 1 : y - 5)
      content.addChild(nameLabel)
      if let detail = detail {
        let detailLabel = label(detail, size: 12, color: Colors.station)
        detailLabel.position = detailOnNewLine ? CGPoint(x: pad, y: y - 14) : CGPoint(x: pad + 110, y: y - 5)
        content.addChild(detailLabel)
      }
      action.position = CGPoint(x: size.width - pad - ShopButton.size.width / 2, y: y)
      content.addChild(action)
      y -= rowHeight
    }

    switch tab {
    case .buy:
      let items = station.itemsForSale
      if items.isEmpty {
        addNote("Nothing for sale here", y: y)
      }
      for item in items {
        let price = station.buyPrice(item)
        let button = ShopButton(title: "Buy  ·  \(price)", color: Colors.buy)
        button.isEnabled = coins >= price && !inventory.isFull
        button.tapped = { self.onBuy(item) }
        row(item.name, detail: nil, action: button)
      }

    case .sell:
      if inventory.items.isEmpty {
        addNote("Your tray is empty", y: y)
      }
      for (slot, item) in inventory.items.enumerated() {
        let button = ShopButton(title: "Sell  +\(station.sellPrice(item.type))", color: Colors.sell)
        button.tapped = { self.onSell(slot) }
        row(item.type.name, detail: "in your tray", action: button)
      }

    case .upgrade:
      let upgradesHere = station.upgradesForSale
      if upgradesHere.isEmpty {
        addNote("No upgrades fitted here", y: y)
      }
      for upgrade in upgradesHere {
        let tier = upgrades.tier(upgrade)
        let detail = "\(upgrade.effect)  ·  \(tier)/\(upgrade.maxTier)"
        let button: ShopButton
        if let price = station.upgradePrice(upgrade, tier: tier + 1) {
          button = ShopButton(title: "Fit  ·  \(price)", color: Colors.upgrade)
          button.isEnabled = coins >= price
          button.tapped = { self.onUpgrade(upgrade) }
        } else {
          button = ShopButton(title: "Maxed", color: Colors.upgrade)
          button.isEnabled = false
        }
        row(upgrade.name, detail: detail, action: button, detailOnNewLine: true)
      }

    case .repair:
      if lives < maxLives {
        let button = ShopButton(title: "Repair  ·  \(station.repairPrice)", color: Colors.station)
        button.isEnabled = coins >= station.repairPrice
        button.tapped = { self.onRepair() }
        row("Hull", detail: "\(lives)/\(maxLives)", action: button)
      } else {
        addNote("Hull is in one piece", y: y)
      }
    }

    if let message = message {
      let note = label(message, size: 14, color: Colors.highScore)
      note.horizontalAlignmentMode = .center
      note.position = CGPoint(x: size.width / 2, y: pad + 52)
      content.addChild(note)
    }
  }

  private func addNote(_ text: String, y: CGFloat) {
    let note = label(text, size: 14, color: Colors.station)
    note.position = CGPoint(x: pad, y: y - 5)
    content.addChild(note)
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


// A tab at the top of the shop. The selected one is filled.

class TabButton: SKSpriteNode {

  var tapped = {}

  private let shape: SKShapeNode
  private let label = SKLabelNode()

  var isSelected = false {
    didSet {
      shape.fillColor = isSelected ? Colors.station : .clear
      label.fontColor = isSelected ? Colors.stationPanel : Colors.station
    }
  }

  init(title: String, width: CGFloat) {
    let s = CGSize(width: width, height: 34)
    shape = SKShapeNode(rect: CGRect(x: -s.width / 2, y: -s.height / 2, width: s.width, height: s.height), cornerRadius: 17)
    super.init(texture: nil, color: .clear, size: s)
    isUserInteractionEnabled = true

    shape.strokeColor = Colors.station
    shape.lineWidth = 2
    addChild(shape)

    label.text = title
    label.fontName = Fonts.fontName
    label.fontSize = 13
    label.verticalAlignmentMode = .center
    addChild(label)

    isSelected = false
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    tapped()
  }
}


// A small button for one thing in the shop, also used by the power HUD.
// Dimmed when it can't be used, but still tappable so the game can say why.

class ShopButton: SKSpriteNode {

  static let size = CGSize(width: 112, height: 36)

  var tapped = {}

  var isEnabled = true {
    didSet {
      alpha = isEnabled ? 1 : 0.4
    }
  }

  init(title: String, color: UIColor, width: CGFloat = ShopButton.size.width) {
    let s = CGSize(width: width, height: ShopButton.size.height)
    super.init(texture: nil, color: .clear, size: s)
    isUserInteractionEnabled = true

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
