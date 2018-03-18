//
//  GameScene.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var shipSpeed: CGFloat = 5
  
  var gameState: GKStateMachine!
  var readyState: GKState!
  var playingState: GKState!
  var gameOverState: GKState!
  var countDownState: GKState!
  
  let ship = Ship()
  var menu: Menu!
  
  let motion = CMMotionManager()
  var hud: Hud!
  var starfield: Starfield!
  let swipeRight  = UISwipeGestureRecognizer()
  let swipeLeft   = UISwipeGestureRecognizer()
  let swipeDown   = UISwipeGestureRecognizer()
  let swipeUp     = UISwipeGestureRecognizer()
  let tap = UITapGestureRecognizer()
  
  var changeIndex: Int = 100
  
  // ----------
  
  var score: Int = 0 {
    didSet {
      hud.update(score: score)
    }
  }
  
  var hudVisible = false {
    didSet {
      hud.showHud(show: hudVisible)
    }
  }
  
  // ---------
  
  override func didMove(to view: SKView) {
    Screen.sharedInstance.setSize(size: size)
    
    name = "Scene"
    
    setupMenu()
    setupStateMachine()
    setupParticles()
    setupCamera()
    // setupMotion()
    setupGestures()
    setupPhysicsWorld()
    // setupStarfield()
    setupship()
    setupHud()
    makeAsteroids()
  }
  
  // -----------
  
  func setupMenu() {
    menu = Menu()
    addChild(menu)
    menu.zPosition = 9999
    menu.position = Screen.sharedInstance.center
    menu.hide()
    menu.tapToPlay = {
      self.menu.hide()
      self.ship.show()
      self.changeIndex = 100
    }
  }
  
  func setupStateMachine() {
    readyState = ReadyState(scene: self)
    playingState = PlayingState(scene: self)
    gameOverState = GameOverState(scene: self)
    countDownState = CountDownState(scene: self)
    
    gameState = GKStateMachine(states: [readyState, playingState, gameOverState, countDownState])
  }
  
  func setupParticles() {
    
  }
  
  func setupCamera() {
    let cam = SKCameraNode()
    camera = cam
    cam.position = Screen.sharedInstance.center
    addChild(cam)
  }
  
  func setupPhysicsWorld() {
    physicsWorld.contactDelegate = self
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    
    // setup edge loop
    guard let view = view else { return }
    physicsBody = SKPhysicsBody(edgeLoopFrom: view.frame)
    
    physicsBody?.categoryBitMask = PhysicsCategory.Edge
    physicsBody?.collisionBitMask = PhysicsCategory.Ship
    physicsBody?.contactTestBitMask = PhysicsCategory.None
    
    let outerHitBox = SKNode()
    addChild(outerHitBox)
    let outerHitBoxRect = view.frame.insetBy(dx: -40, dy: -40)
    outerHitBox.physicsBody = SKPhysicsBody(edgeLoopFrom: outerHitBoxRect)
    outerHitBox.physicsBody?.categoryBitMask = PhysicsCategory.OuterEdge
    outerHitBox.physicsBody?.collisionBitMask = PhysicsCategory.None
    outerHitBox.physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile
  }
  
  func setupship() {
    addChild(ship)
    ship.position.x = Screen.sharedInstance.centerX
    ship.position.y = 60
    ship.setShipSpeedMed()
  }
  
  func setupStarfield() {
    starfield = Starfield(size: size)
    addChild(starfield)
    starfield.zPosition = -1
  }
  
  func setupHud() {
    hud = Hud()
    addChild(hud)
    
    hud.button1Action = {
      self.ship.setShipSpeedFast()
      Missile.setPowerLow()
    }
    
    hud.button2Action = {
      self.ship.setShipSpeedMed()
      Missile.setPowerMed()
    }
    
    hud.button3Action = {
      self.ship.setShipSpeedSlow()
      Missile.setPowerHi()
    }
  }
  
  //
  
  func makeAsteroids() {
    let wait = SKAction.wait(forDuration: 1)
    let makeAsteroid = SKAction.run {
      self.makeAsteroid()
    }
    let seq = SKAction.sequence([wait, makeAsteroid])
    run(SKAction.repeatForever(seq))
  }
  
  func makeAsteroid() {
    changeIndex -= 0
    if changeIndex < 0 {
      return
    }
    
    score += 1
    let r = Int.random(min: 0, max: 24)
    
    print("Asteroid Type: \(r)")
    
    switch r {
    case 0:
      let powerup = PowerUpBomb()
      addChild(powerup)
      powerup.position.x = CGFloat.random(min: 0, max: Screen.sharedInstance.width)
      powerup.position.y = size.height
      
    case 1:
      let powerup = PowerUp()
      addChild(powerup)
      powerup.position.x = CGFloat.random(min: 0, max: Screen.sharedInstance.width)
      powerup.position.y = size.height
      
    default:
      let asteroidSize = CGFloat.random(min: 1, max: 4) * 10
      let asteroid = Asteroid(size: CGSize(width: asteroidSize, height: asteroidSize))
      addChild(asteroid)
    }
  }
  
  func shootMissile() {
    let missile = Missile()
    addChild(missile)
    missile.position = ship.position
    missile.position.y = 80
  }
  
  //
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // shootMissile()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  // ------------
  
  func didBegin(_ contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    // print("Begin Contact", contact.bodyA.node?.name, contact.bodyB.node?.name)
    
    switch collision {
    case PhysicsCategory.Missile | PhysicsCategory.Asteroid:
      // print("Missile Hits Asteroid")
      // print(contact.collisionImpulse)
      if contact.bodyA.categoryBitMask == PhysicsCategory.Missile {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
    case PhysicsCategory.Asteroid | PhysicsCategory.Ship:
      // print("Asteroid Hits Ship")
      guard let shipExplosion = SKEmitterNode(fileNamed: "ShipExplosion") else { return }
      shipExplosion.position = self.ship.position
      self.addChild(shipExplosion)
      let wait = SKAction.wait(forDuration: 2)
      let remove = SKAction.removeFromParent()
      shipExplosion.run(SKAction.sequence([wait, remove]))
      clearScreen()
      changeIndex = -1
      ship.hide()
      menu.show(message: "Your score is: \(score)")
      score = 0
      
    case PhysicsCategory.OuterEdge | PhysicsCategory.Asteroid:
      // print("Asteroid hit Edge")
      if contact.bodyA.categoryBitMask == PhysicsCategory.Asteroid {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
    case PhysicsCategory.OuterEdge | PhysicsCategory.Missile:
      // print("Missile hit Edge")
      if contact.bodyA.categoryBitMask == PhysicsCategory.Missile {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
    case PhysicsCategory.OuterEdge | PhysicsCategory.PowerUp:
      // print("Powerup hit edge")
      if contact.bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
    case PhysicsCategory.Ship | PhysicsCategory.PowerUp:
      // print("Ship hit Powerup")
      score += 10
      if contact.bodyA.categoryBitMask == PhysicsCategory.PowerUp {
        contact.bodyA.node?.removeFromParent()
      } else {
        contact.bodyB.node?.removeFromParent()
      }
      
      if contact.bodyA.node?.name == "Powerup Bomb" || contact.bodyB.node?.name == "Powerup Bomb" {
        // destroy all rocks
        // print("destroy all asteroids")
        destroyAllAsteroids()
      }
      
    default:
      return
    }
  }
  
  func didEnd(_ contact: SKPhysicsContact) {
    // print("End Contact", contact.bodyA.node?.name, contact.bodyB.node?.name)
  }
  
  //
  
  func clearScreen() {
    enumerateChildNodes(withName: "Asteroid") { (asteroid, stop) in
      asteroid.removeFromParent()
    }
    enumerateChildNodes(withName: "Powerup") { (powerup, stop) in
      powerup.removeFromParent()
    }
    enumerateChildNodes(withName: "Powerup Bomb") { (bomb, stop) in
      bomb.removeFromParent()
    }
    enumerateChildNodes(withName: "Missile") { (missile, stop) in
      missile.removeFromParent()
    }
  }
  
  func destroyAllAsteroids() {
    self.enumerateChildNodes(withName: "Asteroid") { (asteroid, stop) in
      asteroid.removeFromParent()
      self.score += 1
    }
    shakeScreen()
  }
  
  func shakeScreen() {
    let wait = 0.03
    let count = 19
    let offset: CGFloat = 8
    
    let waitAction = SKAction.wait(forDuration: wait)
    let wiggle = SKAction.run {
      guard let camera = self.camera else { return }
      let cx = Screen.sharedInstance.centerX
      let cy = Screen.sharedInstance.centerY
      let dx = cx + CGFloat.random(min: -offset, max: offset)
      let dy = cy + CGFloat.random(min: -offset, max: offset)
      camera.position = CGPoint(x: dx, y: dy)
    }
    let seq = SKAction.sequence([waitAction, wiggle])
    let rep = SKAction.repeat(seq, count: count)
    let resetPosition = SKAction.run {
      self.camera?.position = Screen.sharedInstance.center
    }
    let seq2 = SKAction.sequence([rep, resetPosition])
    run(seq2)
  }
  
  //
  
  override func update(_ currentTime: TimeInterval) {
    // if (hudVisible) {
    //   hud.position.y -= hud.position.y * 0.5
    // } else {
    //   hud.position.y -= (hud.position.y - size.height + 40) * 0.5
    // }
  }
  
}


// - Gestures ------------------------------
extension GameScene {
  func setupGestures() {
    guard let view = view else {
      return
    }
    
    tap.addTarget(self, action: #selector(GameScene.handleTap))
    view.addGestureRecognizer(tap)
    
    swipeDown.addTarget(self, action: #selector(GameScene.handleSwipe))
    swipeDown.direction = .down
    view.addGestureRecognizer(swipeDown)
    
    swipeUp.addTarget(self, action: #selector(GameScene.handleSwipe))
    swipeUp.direction = .up
    view.addGestureRecognizer(swipeUp)
    
    swipeRight.addTarget(self, action: #selector(GameScene.handleSwipe))
    swipeRight.direction = .right
    view.addGestureRecognizer(swipeRight)
    
    swipeLeft.addTarget(self, action: #selector(GameScene.handleSwipe))
    swipeLeft.direction = .left
    view.addGestureRecognizer(swipeLeft)
    
  }
  
  @objc func handleTap(tap: UITapGestureRecognizer) {
    shootMissile()
  }
  
  @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
    switch gesture.direction {
    case .right:
      ship.move(x: shipSpeed)
      
    case .left:
      ship.move(x: -shipSpeed)
      
    case .down:
      // print("Swipe Down")
      hudVisible = false
      
    case .up:
      // print("Swipe Up")
      hudVisible = true
      
    default:
      return
    }
  }
}

// - Motion Manager -----------------------
extension GameScene {
  func setupMotion() {
    // https://www.hackingwithswift.com/read/26/3/tilt-to-move-cmmotionmanager
    if motion.isAccelerometerAvailable {
      motion.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
        // var currentX = self.ship.position.x
        guard let data = data else { return }
        let x = CGFloat(data.acceleration.x)
        let v = CGVector(dx: x, dy: 0)
        self.ship.physicsBody?.applyForce(v)
      })
    }
  }
}










