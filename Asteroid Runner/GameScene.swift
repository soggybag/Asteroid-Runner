//
//  GameScene.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

// TODO: Move makeAsteroids to PlayingState
// TODO: Intro Scene with text:
// NASA predicts an asteroid may hit the earth. We need to train pilots now!


import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  // MARK: Public properties
  
  let MAKE_ASTEROIDS = "MAKE_ASTEROIDS" // Key for Make Asteroids Actions
  
  var missileMode = MissileMode.normal
  
//  let missilePoints = [
//    [CGPoint(x: 0, y: 20)],
//    [CGPoint(x: -10, y: 20), CGPoint(x: 10, y: 20)],
//    [CGPoint(x: -20, y: 20), CGPoint(x: 0, y: 20), CGPoint(x: 20, y: 20)]
//  ]
  
  var missileFireTime: TimeInterval = 0.3
  var shipSpeed: CGFloat = 5
  var autoFireOn = true
  
  var level = 0
  var timeSinceLastMissile: TimeInterval = 0
  
  var asteroidSize = AsteroidSize.average
  var asteroidSpeed = AsteroidSpeed.average
  var asteroidDirection = AsteroidDirection.top
  
  var gameState: GKStateMachine!
  
  let ship = Ship()
  
  var menu: Menu!
  var hud: Hud!
  var starfield: Starfield!
  
  let swipeRight  = UISwipeGestureRecognizer()
  let swipeLeft   = UISwipeGestureRecognizer()
  let swipeDown   = UISwipeGestureRecognizer()
  let swipeUp     = UISwipeGestureRecognizer()
  let tap = UITapGestureRecognizer()
  
  var changeIndex: Int = 100
  
  
  // Computed properties
  
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
  
  
  // MARK: View Lifecycle
  
  override func didMove(to view: SKView) {
    Screen.sharedInstance.setSize(size: size)
    
    name = "Scene"
    backgroundColor = UIColor(white: 0, alpha: 1)
    
    setupMenu()
    setupStateMachine()
    setupCamera()
    setupGestures()
    setupPhysicsWorld()
    // setupStarfield()
    setupship()
    setupHud()
    // makeAsteroids()
    
    gameState.enter(ReadyState.self)
    physicsWorld.contactDelegate = self
    
    showVersion()
  }
  
  // ---------------------------------
  // MARK: Public Methods
  // ---------------------------------
  
  // Setup Menu
  
  func setupMenu() {
    menu = Menu()
    addChild(menu)
    menu.zPosition = 9999
    menu.position = Screen.sharedInstance.center
    menu.hide()
    menu.tapToPlay = {
      self.clearScreen()
      self.menu.hide()
      self.ship.show()
      self.changeIndex = 100
      self.level = 0
      self.gameState.enter(NextLevelState.self)
    }
  }
  
  // Setup State Machine
  
  func setupStateMachine() {
    let readyState = ReadyState(scene: self)
    let playingState = PlayingState(scene: self)
    let gameOverState = GameOverState(scene: self)
    let countDownState = CountDownState(scene: self)
    let gameEndingState = GameEndingState(scene: self)
    let introState = IntroState(scene: self)
    let nextLevel = NextLevelState(scene: self)
    
    gameState = GKStateMachine(states: [
      introState, readyState, playingState,
      gameOverState, countDownState, gameEndingState, nextLevel
    ])
  }
  
  
  // Setup Camera
  
  func setupCamera() {
    let cam = SKCameraNode()
    camera = cam
    cam.position = Screen.sharedInstance.center
    addChild(cam)
  }
  
  
  // Setup Physics World
  
  func setupPhysicsWorld() {
    // Gravity
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    
    // Inner edge - keeps ship within the bounds of the screen
    guard let view = view else { return }
    
    physicsBody = SKPhysicsBody(edgeLoopFrom: view.frame)
    
    physicsBody?.categoryBitMask = PhysicsCategory.Edge
    physicsBody?.collisionBitMask = PhysicsCategory.Ship
    physicsBody?.contactTestBitMask = PhysicsCategory.None
    
    // Outer edge - Objects that hit this boundary are removed
    let outerHitBox = SKNode()
    addChild(outerHitBox)
    
    let outerHitBoxRect = view.frame.insetBy(dx: -121, dy: -161)
    
    // print(outerHitBoxRect)
    
    outerHitBox.position.y += 80
    outerHitBox.physicsBody = SKPhysicsBody(edgeLoopFrom: outerHitBoxRect)
    outerHitBox.physicsBody?.categoryBitMask = PhysicsCategory.OuterEdge
    outerHitBox.physicsBody?.collisionBitMask = PhysicsCategory.None
    outerHitBox.physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile | PhysicsCategory.PowerUp
  }
  
  
  // Setup Ship
  
  let shield = ShipShield()
  
  func setupship() {
    addChild(ship)
    ship.position.x = Screen.sharedInstance.centerX
    ship.position.y = 60
    ship.setShipSpeedMed()
    
    addChild(shield)
    ship.shield = shield
  }
  
  
  // Setup Starfield
  
  func setupStarfield() {
    starfield = Starfield(size: size)
    addChild(starfield)
    starfield.zPosition = -1
  }
  
  
  // Setup HUD
  
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
    
    hud.autoFireButtonAction = {
      
    }
  }
  
  
  // Add text message to screen at point
  
  func addText(message: String) {
    let pos = Screen.sharedInstance.center
    let text = PopupLabelNode(message: message, location: pos, fontSize: 24)
    self.addChild(text)
  }
  
  
  
  // ------------------------------------------------------------
  // Make Asteroids
  // ------------------------------------------------------------
  
  
  // Start making asteroids
  
  func makeAsteroids(interval: TimeInterval = 1) {
    // Set some random params for asteroids
    asteroidSize = .bosstroid // AsteroidSize.random() // *************
    asteroidSpeed = AsteroidSpeed.random()
    asteroidDirection = AsteroidDirection.random()
    
    // TODO: Time between asteroids
    
    let wait = SKAction.wait(forDuration: interval)
    let makeAsteroid = SKAction.run {
      self.makeAsteroid()
    }
    let seq = SKAction.sequence([wait, makeAsteroid])
    run(SKAction.repeatForever(seq), withKey: MAKE_ASTEROIDS)
  }
  
  // ------------------------------------------------------------
  // Stop Making Asteroids
  // ------------------------------------------------------------
  
  func stopAsteroids() {
    removeAction(forKey: MAKE_ASTEROIDS)
  }
  
  
  // ------------------------------------------------------------
  // Make an Asteroid
  // ------------------------------------------------------------
  
  // Make an asteroid or power up
  
  func makeAsteroid() {
    changeIndex -= 0
    if changeIndex < 0 {
      return
    }
    
    let r = Int.random(min: 0, max: 24)
    
    // print("Asteroid Type: \(r)")
    
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
      
    case 2:
      let powerup = PowerUpShield()
      addChild(powerup)
      powerup.position.x = CGFloat.random(min: 0, max: Screen.sharedInstance.width)
      powerup.position.y = size.height
      
    case 3:
      let powerup = PowerUpMissile()
      addChild(powerup)
      powerup.position.x = CGFloat.random(min: 0, max: Screen.sharedInstance.width)
      powerup.position.y = size.height
      
    case 4:
      let powerup = PowerUpRapid()
      addChild(powerup)
      powerup.position.x = CGFloat.random(min: 0, max: Screen.sharedInstance.width)
      powerup.position.y = size.height
      
    default:
      // print("...")
      // let sz = AsteroidSize.random()
      let sz = asteroidSize
      let sp = asteroidSpeed
      
      let asteroid = Asteroid(asteroidSize: sz, speed: sp)
      addChild(asteroid)
    }
  }
  
  
  // ---------------------------------
  // Missiles
  // ---------------------------------
  
  // Shoot missile
  
  func shootMissile() {
    let points = missileMode.getPoints()
    
    for point in points {
      let missile = Missile()
      addChild(missile)
      missile.position = ship.position + point
    }
  }
  
  // Set the mode for missiles 
  
  func missilePowerUp(mode: MissileMode) {
    missileMode = mode
    run(.sequence([.wait(forDuration: PowerUp.powerup_duration), .run({
      self.missileMode = .normal
    })]))
  }

  
  
  func missileRapid() {
    // print("!!! Rapid FIRE !!!")
    missileFireTime = 0.15
    run(.sequence([.wait(forDuration: PowerUp.powerup_duration), .run({
      self.missileFireTime = 0.3
    })]))
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
  
  // ----------
  
  func clearScreen() {
    let names = [Asteroid.NAME, PowerUp.PU_BOMB, PowerUp.PU_MISSILE_2, PowerUp.PU_MISSILE_3, PowerUp.PU_MISSILE_RAPID, PowerUp.PU_POINTS, PowerUp.PU_SHIELD, Missile.NAME]
    for name in names {
      enumerateChildNodes(withName: name, using: { (node, stop) in
        node.removeFromParent()
      })
    }
  }
  
  func destroyAllAsteroids() {
    self.enumerateChildNodes(withName: Asteroid.NAME) { (asteroid, stop) in
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
  var lastUpdateTime: TimeInterval = 0
  override func update(_ currentTime: TimeInterval) {
    let deltaTime = currentTime - lastUpdateTime
    lastUpdateTime = currentTime
    gameState.update(deltaTime: deltaTime)
    handleUpdate(seconds: deltaTime)
    
    shield.position = ship.position
    
  }
  
  
  func handleUpdate(seconds: TimeInterval) {
    if let accelerationData = MotionManager.sharedInstance.accelerometer {
      let x = CGFloat(accelerationData.acceleration.x)
      ship.moveForce(x: x * 100)
    }
    
    if autoFireOn {
      timeSinceLastMissile += seconds
      
      if timeSinceLastMissile > missileFireTime {
        timeSinceLastMissile = 0
        if !ship.isHidden {
          shootMissile()
        }
      }
    }
  }
  
  
  // -------------------------------------
  // Handle a hit on an Asteroid
  func hit(asteroid: Asteroid, missileType: MissilePower) {
    if let debris = asteroid.hitAsteroid(value: missileType.rawValue) {
      let points = Int(asteroid.asteroidSize.rawValue)
      score += points
      show(points: points, at: asteroid.position)
      
      asteroid.removeFromParent()
      // TODO: make some smaller asteroids here...
      for rock in debris {
        addChild(rock)
      }
    }
  }
  
  func show(points: Int, at location: CGPoint) {
    let label = PopupLabelNode(message: "\(points)", location: location)
    addChild(label)
  }
  
  
}


// - Gestures ------------------------------
extension GameScene {
  func setupGestures() {
    guard let view = view else {
      return
    }
    
//    tap.addTarget(self, action: #selector(GameScene.handleTap))
//    view.addGestureRecognizer(tap)
    
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
      // print("Swipe Right")
      ship.move(x: shipSpeed)
      
    case .left:
      // print("Swipe Left")
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


extension GameScene {
  func showVersion() {
    //First get the nsObject by defining as an optional anyObject
    let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    let versionLabel = SKLabelNode()
    addChild(versionLabel)
    versionLabel.verticalAlignmentMode = .bottom
    versionLabel.horizontalAlignmentMode = .left
    versionLabel.fontName = Fonts.fontName
    versionLabel.fontSize = 12
    versionLabel.position = CGPoint(x: 5, y: 5)
    versionLabel.text = version
  }
}
