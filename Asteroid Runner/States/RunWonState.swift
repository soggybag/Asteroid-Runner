//
//  RunWonState.swift
//  Asteroid Runner
//

// Reaching Neptune wins the run. The Neptune station slides in and the
// ship flies up to it, as when docking (tap to skip), then the win screen
// shows the run: score, distance, stages and stations visited. Play Again
// starts a new run. Set `station` before entering. The return mission
// will start from here later; see docs/system-map.md.

import GameplayKit
import SpriteKit

class RunWonState: GKState {

  unowned let scene: GameScene

  var station: Station?

  private var stationNode: StationNode?
  private var arrived = false

  static let ARRIVE = "ARRIVE"

  init(scene: GameScene) {
    self.scene = scene
  }


  // ---------------------------------
  // Arrive: the station slides in, the ship flies to its port
  // ---------------------------------

  override func didEnter(from previousState: GKState?) {
    arrived = false

    scene.inventory.lowerShield()
    scene.shield.deactivate()
    scene.fadeOutLeftovers()
    scene.pullPickupsToShip()

    let ship = scene.ship
    ship.physicsBody?.velocity = .zero
    ship.physicsBody?.isDynamic = false

    let node = StationNode(name: station?.name ?? Region.neptune.name)
    node.position = CGPoint(x: Screen.sharedInstance.centerX, y: Screen.sharedInstance.height + 150)
    scene.addChild(node)
    stationNode = node

    let dockTime = Tuning.Stations.dockTime
    let slideIn = SKAction.moveTo(y: stationY, duration: dockTime * 0.6)
    slideIn.timingMode = .easeOut
    node.run(slideIn, withKey: RunWonState.ARRIVE)

    let fly = SKAction.move(to: dockingPoint, duration: dockTime * 0.45)
    fly.timingMode = .easeInEaseOut
    ship.run(.sequence([.wait(forDuration: dockTime * 0.55), fly]), withKey: RunWonState.ARRIVE)

    scene.run(.sequence([.wait(forDuration: dockTime), .run {
      self.showWin()
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
    if !arrived {
      showWin()
    }
  }


  // ---------------------------------
  // The win screen
  // ---------------------------------

  private func showWin() {
    guard !arrived else { return }
    arrived = true

    scene.removeAction(forKey: GameScene.FLOW)
    stationNode?.removeAction(forKey: RunWonState.ARRIVE)
    stationNode?.position.y = stationY
    scene.ship.removeAction(forKey: RunWonState.ARRIVE)
    scene.ship.position = dockingPoint

    if let station = station {
      scene.stationRoute.arrived(at: station)
    }

    let menu = scene.menu!
    menu.show(title: "NEPTUNE REACHED")
    menu.message = "Your score is: \(scene.score)"
    let isNewBest = HighScore.submit(scene.score)
    menu.show(best: HighScore.best, isNew: isNewBest)
    menu.show(stage: scene.level, stats: scene.stats, stations: scene.stationRoute.visited.count)
    menu.show()
    scene.impact.impactOccurred()
  }


  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass == ReadyState.self
  }

  override func willExit(to nextState: GKState) {
    stationNode?.removeFromParent()
    stationNode = nil
    scene.ship.removeAction(forKey: RunWonState.ARRIVE)
    scene.ship.physicsBody?.isDynamic = true
    station = nil
  }
}
