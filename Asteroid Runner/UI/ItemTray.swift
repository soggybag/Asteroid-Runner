//
//  ItemTray.swift
//  Asteroid Runner
//

// A row of slots showing the items the player is carrying, laid out from
// the left edge of the node. Tapping a slot calls slotTapped with its
// index. Slots catch their own touches, so a tap on the tray doesn't steer
// the ship.

import SpriteKit

class ItemTray: SKNode {

  static let slotSize = CGSize(width: 44, height: 28)
  static let spacing: CGFloat = 4

  var slotTapped: (Int) -> Void = { _ in }

  private var slots = [ItemSlot]()

  init(capacity: Int) {
    super.init()

    let step = ItemTray.slotSize.width + ItemTray.spacing
    for i in 0 ..< capacity {
      let slot = ItemSlot()
      slot.position.x = ItemTray.slotSize.width / 2 + step * CGFloat(i)
      slot.tapped = { self.slotTapped(i) }
      addChild(slot)
      slots.append(slot)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with inventory: Inventory) {
    for (i, slot) in slots.enumerated() {
      let item = inventory.items.indices.contains(i) ? inventory.items[i] : nil
      let isOn = inventory.activeShield == i
      slot.show(item: item, isOn: isOn)
    }
  }
}


class ItemSlot: SKSpriteNode {

  var tapped = {}

  private let outline = SKShapeNode()
  private let chargeBar = SKSpriteNode(color: .white, size: .zero)
  private let label = SKLabelNode()

  init() {
    // A little bigger than the outline to make it easier to hit
    let size = CGSize(width: ItemTray.slotSize.width + ItemTray.spacing, height: ItemTray.slotSize.height + 10)
    super.init(texture: nil, color: .clear, size: size)

    isUserInteractionEnabled = true

    let s = ItemTray.slotSize
    let rect = CGRect(x: -s.width / 2, y: -s.height / 2, width: s.width, height: s.height)
    outline.path = UIBezierPath(roundedRect: rect, cornerRadius: 6).cgPath
    outline.lineWidth = 2
    addChild(outline)

    // Shield charge, along the bottom of the slot
    chargeBar.anchorPoint = CGPoint(x: 0, y: 0)
    chargeBar.position = CGPoint(x: -s.width / 2 + 3, y: -s.height / 2 + 3)
    addChild(chargeBar)

    label.fontName = Fonts.fontName
    label.fontSize = 11
    label.verticalAlignmentMode = .center
    label.horizontalAlignmentMode = .center
    label.position.y = 1
    addChild(label)

    show(item: nil, isOn: false)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    tapped()
  }

  func show(item: Item?, isOn: Bool) {
    guard let item = item else {
      outline.strokeColor = Colors.buttonColorNormal
      outline.fillColor = .clear
      label.text = nil
      chargeBar.isHidden = true
      return
    }

    let color = item.type.color
    outline.strokeColor = color
    outline.fillColor = color.withAlphaComponent(isOn ? 0.6 : 0.15)
    label.text = isOn ? "ON" : item.type.label
    label.fontColor = isOn ? .white : color

    chargeBar.isHidden = item.type != .shield
    let fraction = CGFloat(max(0, item.charge / Tuning.Items.shieldCharge))
    chargeBar.size = CGSize(width: (ItemTray.slotSize.width - 6) * fraction, height: 3)
    chargeBar.color = color
  }
}
