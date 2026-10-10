//
//  MapPanel.swift
//  Asteroid Runner
//

// The system map, shown when the player taps Launch at a station. The sun
// is at the bottom and Neptune at the top, so the ship flies up the map
// the way it flies up the screen. Stations reached are ticked, the one
// docked at is ringed, and lines lead to the stations in the next region
// out. Tap a station or a route tab to see its card, then Set course.
// The panel only draws and reports taps; StationState sets the course.

import SpriteKit

class MapPanel: SKNode {

  var onSetCourse: (LegOffer) -> Void = { _ in }
  var onBack: () -> Void = {}

  let map: SystemMap
  let current: MapStation
  let offers: [LegOffer]
  let visited: Set<String>
  let size: CGSize

  private(set) var selected = 0

  private let pad: CGFloat = 16
  private let titleHeight: CGFloat = 40
  private let rowHeight: CGFloat = 34
  // Rows spread out to fill the space, up to this far apart
  private let maxRowStep: CGFloat = 64
  private let cardHeight: CGFloat = 112

  // Redrawn when the selection changes
  private let routeLines = SKNode()
  private let card = SKNode()
  private var targets = [String: MapStationButton]()
  private var tabs = [TabButton]()

  init(map: SystemMap, current: MapStation, offers: [LegOffer], visited: Set<String>,
       selected: Int, size: CGSize) {
    self.map = map
    self.current = current
    self.offers = offers
    self.visited = visited
    self.size = size
    super.init()

    zPosition = 2000

    let back = SKShapeNode(rect: CGRect(origin: .zero, size: size), cornerRadius: 14)
    back.fillColor = Colors.stationPanel
    back.strokeColor = Colors.station
    back.lineWidth = 2
    addChild(back)

    let title = label("SYSTEM MAP", size: 13, color: Colors.station)
    title.position = CGPoint(x: pad, y: size.height - pad)
    title.verticalAlignmentMode = .top
    addChild(title)

    let here = label("At \(current.station.name)  ·  \(current.region.name)", size: 13, color: Colors.stationText)
    here.horizontalAlignmentMode = .right
    here.verticalAlignmentMode = .top
    here.position = CGPoint(x: size.width - pad, y: size.height - pad)
    addChild(here)

    addChild(routeLines)
    drawRegions()

    // A tab per route, by danger, safest first
    let tabY = cardTop + 26
    let count = CGFloat(max(offers.count, 1))
    let tabWidth = (size.width - pad * 2 - 8 * (count - 1)) / count
    for (i, offer) in offers.enumerated() {
      let tab = TabButton(title: offer.route.danger.name.uppercased(), width: tabWidth)
      tab.position = CGPoint(x: pad + tabWidth / 2 + CGFloat(i) * (tabWidth + 8), y: tabY)
      tab.tapped = { self.select(i) }
      addChild(tab)
      tabs.append(tab)
    }

    addChild(card)

    let backButton = TabButton(title: "BACK", width: 100)
    backButton.position = CGPoint(x: pad + 50, y: pad + 20)
    backButton.tapped = { self.onBack() }
    addChild(backButton)

    let setCourse = TabButton(title: "SET COURSE", width: 160)
    setCourse.isSelected = true
    setCourse.position = CGPoint(x: size.width - pad - 80, y: pad + 20)
    setCourse.tapped = {
      guard self.offers.indices.contains(self.selected) else { return }
      self.onSetCourse(self.offers[self.selected])
    }
    addChild(setCourse)

    select(min(max(selected, 0), max(offers.count - 1, 0)))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: Layout

  // The card's top edge; the route tabs sit just above it
  private var cardTop: CGFloat {
    return pad + 40 + 12 + cardHeight
  }

  // The map fills the space between the title and the route tabs
  private var mapBottom: CGFloat {
    return cardTop + 26 + 17 + 40
  }

  private func rowY(_ region: Region) -> CGFloat {
    let top = size.height - titleHeight - rowHeight / 2
    let step = min(maxRowStep, (top - mapBottom - rowHeight / 2) / CGFloat(Region.allCases.count - 1))
    return top - CGFloat(Region.allCases.count - 1 - region.rawValue) * step
  }

  private func stationPoint(_ station: MapStation) -> CGPoint {
    let inRegion = map.stations(in: station.region)
    let index = CGFloat(inRegion.firstIndex(of: station) ?? 0)
    let left: CGFloat = 132
    let span = size.width - left - pad - 40
    let x = inRegion.count > 1 ? left + span * index / CGFloat(inRegion.count - 1) : left + span / 2
    return CGPoint(x: x, y: rowY(station.region))
  }


  // MARK: Drawing

  // A row per region with its stations. Unvisited stations further out
  // are plain dots without names.
  private func drawRegions() {
    let targetIds = Set(offers.map(\.station.id))

    let sun = SKShapeNode(circleOfRadius: 7)
    sun.fillColor = Colors.highScore
    sun.strokeColor = .clear
    sun.position = CGPoint(x: pad + 7, y: rowY(.earth) - rowHeight * 0.55)
    addChild(sun)

    for region in Region.allCases {
      let y = rowY(region)
      let name = label(region.name.uppercased(), size: 10, color: Colors.station.withAlphaComponent(0.7))
      name.verticalAlignmentMode = .center
      name.position = CGPoint(x: pad, y: y)
      addChild(name)

      for station in map.stations(in: region) {
        let point = stationPoint(station)
        if targetIds.contains(station.id) {
          let button = MapStationButton(name: station.station.name)
          button.position = point
          button.tapped = { [weak self] in
            guard let self = self,
                  let i = self.offers.firstIndex(where: { $0.station.id == station.id }) else { return }
            self.select(i)
          }
          addChild(button)
          targets[station.id] = button
        } else if station.id == current.id {
          let ring = SKShapeNode(circleOfRadius: 8)
          ring.strokeColor = Colors.stationText
          ring.lineWidth = 2
          ring.fillColor = Colors.station
          ring.position = point
          addChild(ring)
          addName(station.station.name, at: point, color: Colors.stationText)
        } else if visited.contains(station.id) {
          let dot = SKShapeNode(circleOfRadius: 4)
          dot.fillColor = Colors.station.withAlphaComponent(0.6)
          dot.strokeColor = .clear
          dot.position = point
          addChild(dot)
          addName("✓ \(station.station.name)", at: point, color: Colors.station.withAlphaComponent(0.6))
        } else {
          let dot = SKShapeNode(circleOfRadius: 3)
          dot.fillColor = .clear
          dot.strokeColor = Colors.station.withAlphaComponent(0.35)
          dot.lineWidth = 1
          dot.position = point
          addChild(dot)
        }
      }
    }
  }

  private func addName(_ text: String, at point: CGPoint, color: UIColor) {
    let name = label(text, size: 10, color: color)
    name.horizontalAlignmentMode = .center
    name.position = CGPoint(x: point.x, y: point.y - 18)
    addChild(name)
  }

  // Lines from here to each route's station, the chosen one bright
  private func drawRouteLines() {
    routeLines.removeAllChildren()
    let from = stationPoint(current)
    for (i, offer) in offers.enumerated() {
      let path = CGMutablePath()
      path.move(to: from)
      path.addLine(to: stationPoint(offer.station))
      let line = SKShapeNode(path: path)
      let chosen = i == selected
      line.strokeColor = MapPanel.color(offer.route.danger).withAlphaComponent(chosen ? 1 : 0.35)
      line.lineWidth = chosen ? 3 : 1.5
      routeLines.addChild(line)
    }
  }

  // The chosen route's card: where it goes, how long and hard, what's on
  // the way, and what the station sells
  private func drawCard() {
    card.removeAllChildren()
    guard offers.indices.contains(selected) else {
      let none = label("No routes from here", size: 14, color: Colors.station)
      none.position = CGPoint(x: pad, y: cardTop - 24)
      card.addChild(none)
      return
    }
    let offer = offers[selected]
    let station = offer.station.station
    let x = pad
    var y = cardTop - 18

    let kind = station.kindName.isEmpty ? "" : "  ·  \(station.kindName)"
    card.addChild(label("To \(station.name)\(kind)", size: 15, color: Colors.stationText, at: CGPoint(x: x, y: y)))
    y -= 22

    let danger = offer.route.danger
    let marks = String(repeating: "▲", count: RouteDanger.allCases.firstIndex(of: danger)! + 1)
    let stages = "\(offer.route.length) stage\(offer.route.length == 1 ? "" : "s")"
    card.addChild(label("\(stages)  ·  \(danger.name) \(marks)  ·  \(offer.station.region.name)",
                        size: 13, color: MapPanel.color(danger), at: CGPoint(x: x, y: y)))
    y -= 20

    let waves = offer.recipes.map(\.name).joined(separator: ", ")
    card.addChild(label("On the way: \(waves)", size: 13, color: Colors.station, at: CGPoint(x: x, y: y)))
    y -= 20

    let items = station.itemsForSale.map(\.name)
    let upgrades = station.upgradesForSale.map(\.name)
    var sells = items.isEmpty ? "nothing" : items.joined(separator: ", ")
    if !upgrades.isEmpty {
      sells += "  ·  Fits: " + upgrades.joined(separator: ", ")
    }
    let sellsLabel = label("Sells: \(sells)", size: 12, color: Colors.station, at: CGPoint(x: x, y: y))
    sellsLabel.numberOfLines = 2
    sellsLabel.preferredMaxLayoutWidth = size.width - pad * 2
    sellsLabel.lineBreakMode = .byWordWrapping
    sellsLabel.verticalAlignmentMode = .top
    sellsLabel.position.y += 10
    card.addChild(sellsLabel)
  }

  func select(_ index: Int) {
    selected = index
    for (i, tab) in tabs.enumerated() {
      tab.isSelected = i == index
    }
    for (i, offer) in offers.enumerated() {
      targets[offer.station.id]?.isSelected = i == index
    }
    drawRouteLines()
    drawCard()
  }

  // Safe routes green, normal station blue, risky red
  static func color(_ danger: RouteDanger) -> UIColor {
    switch danger {
    case .safe: return Colors.engines
    case .normal: return Colors.station
    case .risky: return Colors.sell
    }
  }

  private func label(_ text: String, size: CGFloat, color: UIColor, at point: CGPoint = .zero) -> SKLabelNode {
    let node = SKLabelNode(text: text)
    node.fontName = Fonts.fontName
    node.fontSize = size
    node.fontColor = color
    node.horizontalAlignmentMode = .left
    node.verticalAlignmentMode = .baseline
    node.position = point
    return node
  }
}


// A station the ship can fly to next: a dot with its name above, big
// enough to tap. The chosen one is filled.

class MapStationButton: SKSpriteNode {

  var tapped = {}

  private let dot = SKShapeNode(circleOfRadius: 7)
  private let nameLabel = SKLabelNode()

  var isSelected = false {
    didSet {
      dot.fillColor = isSelected ? Colors.stationText : Colors.stationPanel
      nameLabel.fontColor = isSelected ? Colors.stationText : Colors.station
    }
  }

  init(name text: String) {
    super.init(texture: nil, color: .clear, size: CGSize(width: 88, height: 44))
    isUserInteractionEnabled = true

    dot.strokeColor = Colors.stationText
    dot.lineWidth = 2
    addChild(dot)

    nameLabel.text = text
    nameLabel.fontName = Fonts.fontName
    nameLabel.fontSize = 11
    nameLabel.horizontalAlignmentMode = .center
    nameLabel.verticalAlignmentMode = .baseline
    // Above the dot, clear of the route line coming up from below
    nameLabel.position = CGPoint(x: 0, y: 12)
    addChild(nameLabel)

    isSelected = false
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    tapped()
  }
}
