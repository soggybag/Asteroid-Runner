//
//  StationState.swift
//  Asteroid Runner
//

// Docked at a space station. The station slides in and the ship flies up
// to its port (tap to skip), the keeper says hello, and the player shops
// until they tap Launch. Then the station drifts away and the next wave
// begins. Set `station` before entering.

import GameplayKit
import SpriteKit

class StationState: GKState {

  unowned let scene: GameScene

  var station: Station?

  private var stationNode: StationNode?
  private var panel: StationPanel?
  private var docked = false

  static let DOCK = "DOCK"

  init(scene: GameScene) {
    self.scene = scene
  }


  // ---------------------------------
  // Arrive: station slides in, ship flies to the port
  // ---------------------------------

  override func didEnter(from previousState: GKState?) {
    guard let station = station else {
      scene.gameState.enter(NextLevelState.self)
      return
    }

    docked = false

    // Shields down while docked, so the charge is saved
    scene.inventory.lowerShield()
    scene.shield.deactivate()

    // Rocks still on screen fade away before the station arrives; pickups
    // are pulled into the ship
    scene.fadeOutLeftovers()
    scene.pullPickupsToShip()

    let ship = scene.ship
    ship.physicsBody?.velocity = .zero
    ship.physicsBody?.isDynamic = false

    let node = StationNode(name: station.name)
    node.position = CGPoint(x: Screen.sharedInstance.centerX, y: Screen.sharedInstance.height + 150)
    scene.addChild(node)
    stationNode = node

    // The station drifts in first, then the ship flies up to its port
    let dockTime = Tuning.Stations.dockTime
    let slideIn = SKAction.moveTo(y: stationY, duration: dockTime * 0.6)
    slideIn.timingMode = .easeOut
    node.run(slideIn, withKey: StationState.DOCK)

    let fly = SKAction.move(to: dockingPoint, duration: dockTime * 0.45)
    fly.timingMode = .easeInEaseOut
    ship.run(.sequence([.wait(forDuration: dockTime * 0.55), fly]), withKey: StationState.DOCK)

    scene.run(.sequence([.wait(forDuration: dockTime), .run {
      self.finishDocking()
    }]), withKey: GameScene.FLOW)
  }

  private var stationY: CGFloat {
    return Screen.sharedInstance.height * 0.75
  }

  private var dockingPoint: CGPoint {
    return CGPoint(x: Screen.sharedInstance.centerX, y: stationY - StationNode.radius - 40)
  }


  // A tap during the approach skips it

  func touched() {
    if !docked {
      finishDocking()
    }
  }


  // ---------------------------------
  // Docked: greet and open the shop
  // ---------------------------------

  private func finishDocking() {
    guard !docked, let station = station else { return }
    docked = true

    scene.removeAction(forKey: GameScene.FLOW)
    stationNode?.removeAction(forKey: StationState.DOCK)
    stationNode?.position.y = stationY
    scene.ship.removeAction(forKey: StationState.DOCK)
    scene.ship.position = dockingPoint

    let situation = StationSituation.pick(
      damaged: scene.lives < scene.maxLives,
      carryingWanted: !scene.inventory.items.isEmpty && station.shop.sellMultiplier > 1,
      visitedBefore: scene.stationRoute.hasVisited(station))
    scene.stationRoute.docked(at: station, nextStage: scene.level + 1)

    let screen = Screen.sharedInstance
    // Clear of the version label in the bottom corner
    let bottom = screen.safeArea.bottom + 24
    let size = CGSize(width: screen.width - 16, height: dockingPoint.y - 30 - bottom)
    let panel = StationPanel(station: station, greeting: station.greeting(for: situation), size: size)
    panel.position = CGPoint(x: 8, y: bottom)
    panel.onBuy = { item in self.buy(item) }
    panel.onRepair = { self.repair() }
    panel.onSell = { slot in self.sell(slot: slot) }
    panel.onUpgrade = { upgrade in self.buy(upgrade) }
    panel.onLaunch = { self.launch() }
    scene.addChild(panel)
    self.panel = panel

    refresh(message: nil)
  }


  // ---------------------------------
  // Shop
  // ---------------------------------

  private func buy(_ item: ItemType) {
    guard let station = station else { return }
    let price = station.buyPrice(item)
    if scene.coins < price {
      refresh(message: "Not enough coins")
    } else if scene.inventory.isFull {
      refresh(message: "Tray is full. Sell something first.")
    } else {
      scene.coins -= price
      scene.inventory.add(item)
      scene.lightImpact.impactOccurred()
      refresh(message: "Bought \(item.name.lowercased())")
    }
  }

  private func sell(slot: Int) {
    guard let station = station, let item = scene.inventory.take(slot: slot) else { return }
    let price = station.sellPrice(item.type)
    scene.coins += price
    scene.lightImpact.impactOccurred()
    refresh(message: "Sold \(item.type.name.lowercased()) for \(price)")
  }

  private func repair() {
    guard let station = station, scene.lives < scene.maxLives else { return }
    if scene.coins < station.repairPrice {
      refresh(message: "Not enough coins")
    } else {
      scene.coins -= station.repairPrice
      scene.lives += 1
      scene.lightImpact.impactOccurred()
      refresh(message: "Hull repaired")
    }
  }

  private func buy(_ upgrade: ShipUpgrade) {
    guard let station = station else { return }
    let tier = scene.upgrades.tier(upgrade) + 1
    guard let price = station.upgradePrice(upgrade, tier: tier) else {
      refresh(message: "\(upgrade.name) is fully upgraded")
      return
    }
    if scene.coins < price {
      refresh(message: "Not enough coins")
    } else {
      scene.coins -= price
      scene.install(upgrade)
      scene.impact.impactOccurred()
      refresh(message: "\(upgrade.name) installed")
    }
  }

  private func refresh(message: String?) {
    panel?.refresh(coins: scene.coins, lives: scene.lives, maxLives: scene.maxLives, upgrades: scene.upgrades,
                   inventory: scene.inventory, message: message)
  }


  // ---------------------------------
  // Launch: station drifts off, ship returns, next wave
  // ---------------------------------

  private func launch() {
    guard let station = station, let node = stationNode else { return }

    panel?.removeFromParent()
    panel = nil
    scene.addText(message: station.farewellLine())

    let launchTime = Tuning.Stations.launchTime
    let slideOut = SKAction.moveTo(y: Screen.sharedInstance.height + 150, duration: launchTime)
    slideOut.timingMode = .easeIn
    node.run(.sequence([slideOut, .removeFromParent()]))
    stationNode = nil

    let back = SKAction.move(to: CGPoint(x: Screen.sharedInstance.centerX, y: Screen.sharedInstance.shipY), duration: launchTime * 0.8)
    back.timingMode = .easeInEaseOut
    scene.ship.run(back, withKey: StationState.DOCK)

    scene.run(.sequence([.wait(forDuration: launchTime), .run {
      self.scene.gameState.enter(NextLevelState.self)
    }]), withKey: GameScene.FLOW)
  }


  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass == NextLevelState.self
  }

  override func willExit(to nextState: GKState) {
    panel?.removeFromParent()
    panel = nil
    stationNode?.removeFromParent()
    stationNode = nil
    scene.ship.removeAction(forKey: StationState.DOCK)
    scene.ship.physicsBody?.isDynamic = true
    station = nil
  }
}
