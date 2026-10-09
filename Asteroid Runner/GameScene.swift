//
//  GameScene.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

// TODO: Move makeAsteroids to PlayingState


import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

  // MARK: Public properties

  let MAKE_ASTEROIDS = "MAKE_ASTEROIDS" // Key for Make Asteroids Actions

  // Key for the timed sequences that move the state machine along. Every
  // state runs its sequence with this key so a new one always replaces the
  // last, and ending the game can cancel whatever is pending.
  static let FLOW = "FLOW"

  let MISSILE_MODE_TIMER = "MISSILE_MODE_TIMER"
  let RAPID_FIRE_TIMER = "RAPID_FIRE_TIMER"

  var missileMode = MissileMode.normal

  var rapidFireOn = false

  // With auto fire off, the ship fires while a finger is held down
  var activeTouches = Set<UITouch>()

  var autoFireOn = true {
    didSet {
      powerPanel.update(grid: power, autoFire: autoFireOn)
    }
  }

  // Seconds between shots, from weapons power and rapid fire
  var missileFireTime: TimeInterval {
    let base = Tuning.Power.value(Tuning.Power.weaponFireTime, level: power.level(.weapons))
    return rapidFireOn ? base * Tuning.Weapons.rapidFireFactor : base
  }

  var level = 0
  var timeSinceLastMissile: TimeInterval = 0

  // Items that have drifted in this wave, capped by Tuning.PowerUps.maxItemsPerWave
  var itemsThisWave = 0

  // Counts for the game over screen
  var stats = RunStats() {
    didSet {
      hud.update(distance: stats.distanceText)
    }
  }

  // The wave being flown, or about to be: its recipe, sizes, speed and difficulty
  var wave = WavePlan.make(stage: 1, progress: 0, previous: nil)

  // Lanes and maze waves keep track of where rocks go
  var activeLanes = WavePlan.activeLanes()
  var laneRocks = 0
  var mazeGapCenter: CGFloat = 0

  var gameState: GKStateMachine!

  let ship = Ship()

  var menu: Menu!
  var hud: Hud!
  var starfield: Starfield!
  let pauseLabel = SKLabelNode()

  // Set by the view controller before the scene is presented
  var safeArea = UIEdgeInsets.zero

  let swipeDown   = UISwipeGestureRecognizer()
  let swipeUp     = UISwipeGestureRecognizer()

  let impact = UIImpactFeedbackGenerator(style: .heavy)
  let lightImpact = UIImpactFeedbackGenerator(style: .light)

  var gamePaused = false


  // -----------------------------------
  // Computed properties
  // -----------------------------------

  var score: Int = 0 {
    didSet {
      hud.update(score: score)
    }
  }

  var lives: Int = Tuning.Player.startingLives {
    didSet {
      hud.update(lives: lives)
    }
  }

  var coins: Int = 0 {
    didSet {
      hud.update(coins: coins)
    }
  }

  // Every station from Data/stations.json, and this run's route between them
  let allStations = StationList.load()
  let mapNames = StationList.loadMapNames()
  lazy var stationRoute = StationRoute(stations: allStations, names: mapNames)

  // Items the player is carrying, shown in the HUD tray
  var inventory = Inventory() {
    didSet {
      hud.tray.update(with: inventory)
    }
  }

  // Upgrades bought at stations this run
  var upgrades = ShipUpgrades()

  var maxLives: Int {
    return upgrades.maxLives
  }

  // Reactor power shared between engines, shields and weapons
  var power = PowerGrid() {
    didSet {
      applyPower()
    }
  }

  // Charge in the powered shield, one hit per point
  var shieldCharge = ShieldCharge(level: Tuning.Power.startingLevel)

  // The power HUD, opened with a swipe up
  var powerPanel: PowerPanel!
  var powerPanelOpen = false

  // Where a dragging finger wants the ship; the ship follows at engine speed
  var dragTargetX: CGFloat?

  // True while the player is flying and can score or be hit
  var shipInPlay: Bool {
    let state = gameState.currentState
    return !ship.isHidden && (state is PlayingState || state is NextLevelState)
  }


  // --------------------------------------
  // MARK: View Lifecycle
  // --------------------------------------

  override func didMove(to view: SKView) {
    Screen.sharedInstance.setSize(size: size, safeArea: safeArea)

    name = "Scene"
    backgroundColor = Colors.backgroundBlack

    setupMenu()
    setupStateMachine()
    setupCamera()
    setupGestures()
    setupPhysicsWorld()
    setupStarfield()
    setupship()
    setupHud()
    setupPause()

    physicsWorld.contactDelegate = self

    showVersion()

    gameState.enter(IntroState.self)
  }


  // ---------------------------------
  //
  // MARK: Public Methods
  //
  // ---------------------------------


  // ---------------------------------
  // Setup Menu
  // ---------------------------------

  func setupMenu() {
    menu = Menu()
    addChild(menu)
    menu.zPosition = 9999
    menu.position = Screen.sharedInstance.center
    menu.hide()

    // Tap the Play again button on the game over menu
    menu.tapToPlay = {
      self.resetGame()
      self.gameState.enter(ReadyState.self)
    }
  }


  // --------------------------------
  // Setup State Machine
  // --------------------------------

  func setupStateMachine() {
    let readyState = ReadyState(scene: self)
    let playingState = PlayingState(scene: self)
    let gameOverState = GameOverState(scene: self)
    let countDownState = CountDownState(scene: self)
    let gameEndingState = GameEndingState(scene: self)
    let introState = IntroState(scene: self)
    let nextLevel = NextLevelState(scene: self)
    let station = StationState(scene: self)

    gameState = GKStateMachine(states: [
      introState, readyState, playingState,
      gameOverState, countDownState, gameEndingState, nextLevel, station
    ])
  }


  // --------------------------------
  // Setup Camera
  // --------------------------------

  func setupCamera() {
    let cam = SKCameraNode()
    camera = cam
    cam.position = Screen.sharedInstance.center
    addChild(cam)
  }


  // --------------------------------
  // Setup Physics World
  // --------------------------------

  func setupPhysicsWorld() {
    // Gravity
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)

    // Inner edge - keeps ship within the bounds of the screen
    let screenRect = CGRect(origin: .zero, size: size)
    physicsBody = SKPhysicsBody(edgeLoopFrom: screenRect)

    physicsBody?.categoryBitMask = PhysicsCategory.Edge
    physicsBody?.collisionBitMask = PhysicsCategory.Ship
    physicsBody?.contactTestBitMask = PhysicsCategory.None

    // Outer edge - Objects that hit this boundary are removed
    let outerHitBox = SKNode()
    addChild(outerHitBox)

    let outerHitBoxRect = screenRect.insetBy(dx: -121, dy: -161)

    outerHitBox.position.y += 80
    outerHitBox.physicsBody = SKPhysicsBody(edgeLoopFrom: outerHitBoxRect)
    outerHitBox.physicsBody?.categoryBitMask = PhysicsCategory.OuterEdge
    outerHitBox.physicsBody?.collisionBitMask = PhysicsCategory.None
    outerHitBox.physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Missile | PhysicsCategory.PowerUp
  }


  // ------------------------------------
  // Setup Ship
  // ------------------------------------

  let shield = ShipShield()

  func setupship() {
    addChild(ship)
    ship.position.x = Screen.sharedInstance.centerX
    ship.position.y = Screen.sharedInstance.shipY
    ship.setEngine(level: power.level(.engines))

    addChild(shield)
    ship.shield = shield
  }


  // ----------------------------------
  // Setup Starfield
  // ----------------------------------

  func setupStarfield() {
    starfield = Starfield(size: size)
    addChild(starfield)
    starfield.zPosition = -1
  }


  // ---------------------------------
  // Setup HUD
  // ---------------------------------

  func setupHud() {
    hud = Hud()
    addChild(hud)

    hud.tray.slotTapped = { slot in
      self.useItem(slot: slot)
    }

    lives = Tuning.Player.startingLives
    setupPowerPanel()
  }


  // ---------------------------------
  // Setup the power HUD
  // ---------------------------------

  func setupPowerPanel() {
    let screen = Screen.sharedInstance
    let wasOpen = powerPanelOpen
    closePowerPanel()
    powerPanel = PowerPanel(width: screen.width - 16, maxLevel: power.maxLevel, reactor: power.reactor)
    powerPanel.position = CGPoint(x: 8, y: screen.shipY + 40)
    powerPanel.onRaise = { system in
      if self.power.raise(system) { self.lightImpact.impactOccurred() }
    }
    powerPanel.onLower = { system in
      if self.power.lower(system) { self.lightImpact.impactOccurred() }
    }
    powerPanel.onAutoFire = {
      self.autoFireOn.toggle()
    }
    powerPanel.update(grid: power, autoFire: autoFireOn)
    if wasOpen {
      openPowerPanel()
    }
  }


  // ---------------------------------
  // Install a ship upgrade, then make the
  // ship match: reactor, tray, hull, and
  // the boosts power levels pick up
  // ---------------------------------

  func install(_ upgrade: ShipUpgrade) {
    guard upgrades.install(upgrade) else { return }
    if upgrade == .hullPlating {
      // New plating comes fitted
      lives += 1
    }
    applyUpgrades()
  }

  func applyUpgrades() {
    if power.reactor != upgrades.reactorUnits {
      power = power.withReactor(upgrades.reactorUnits)
      setupPowerPanel()
    }
    if inventory.capacity != upgrades.traySlots {
      inventory.setCapacity(upgrades.traySlots)
      hud.setTrayCapacity(upgrades.traySlots)
      hud.tray.update(with: inventory)
    }
    applyPower()
  }


  // ---------------------------------
  // Open and close the power HUD. Time slows
  // and steering locks while it's open.
  // ---------------------------------

  func openPowerPanel() {
    guard !powerPanelOpen, shipInPlay, !gamePaused else { return }
    powerPanelOpen = true
    dragTargetX = nil
    let scale = Tuning.Power.hudTimeScale
    speed = scale
    physicsWorld.speed = scale
    // The panel's own animations run at full speed
    powerPanel.speed = 1 / scale
    powerPanel.alpha = 0
    addChild(powerPanel)
    powerPanel.run(.fadeIn(withDuration: 0.12))
  }

  func closePowerPanel() {
    guard powerPanelOpen else { return }
    powerPanelOpen = false
    speed = 1
    physicsWorld.speed = 1
    powerPanel.removeAllActions()
    powerPanel.removeFromParent()
  }


  // ---------------------------------
  // Apply power levels to the ship
  // ---------------------------------

  func applyPower() {
    ship.setEngine(level: power.level(.engines), boost: upgrades.maneuverScale)
    shieldCharge.setLevel(power.level(.shields), bonus: upgrades.extraShieldCharges)
    ship.showBarrier(charge: shieldCharge.charge, capacity: shieldCharge.capacity)
    powerPanel?.update(grid: power, autoFire: autoFireOn)
  }


  // ---------------------------------
  // Setup Pause
  // ---------------------------------

  func setupPause() {
    addChild(pauseLabel)
    pauseLabel.text = "Paused - Tap to Resume"
    pauseLabel.fontName = Fonts.fontName
    pauseLabel.fontSize = 24
    pauseLabel.fontColor = Colors.buttonLabelColor
    pauseLabel.position = Screen.sharedInstance.center
    pauseLabel.zPosition = 9999
    pauseLabel.isHidden = true

    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    center.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }

  @objc func appWillResignActive() {
    pauseGame()
  }

  @objc func appDidBecomeActive() {
    // SKView unpauses the scene when the app comes back. Stay paused
    // until the player taps.
    if gamePaused {
      isPaused = true
    }
  }

  func pauseGame() {
    let state = gameState.currentState
    guard !gamePaused, state is PlayingState || state is NextLevelState || state is ReadyState || state is StationState else { return }
    gamePaused = true
    pauseLabel.isHidden = false
    isPaused = true
  }

  func resumeGame() {
    gamePaused = false
    pauseLabel.isHidden = true
    isPaused = false
    lastUpdateTime = 0
  }


  // ---------------------------------
  // Reset everything for a new game
  // ---------------------------------

  func resetGame() {
    removeAction(forKey: GameScene.FLOW)
    removeAction(forKey: MISSILE_MODE_TIMER)
    removeAction(forKey: RAPID_FIRE_TIMER)
    stopAsteroids()
    clearScreen()
    menu.hide()
    ship.clearInvulnerable()
    shield.deactivate()
    missileMode = .normal
    rapidFireOn = false
    closePowerPanel()
    upgrades = ShipUpgrades()
    inventory = Inventory()
    hud.setTrayCapacity(upgrades.traySlots)
    power = PowerGrid()
    setupPowerPanel()
    shieldCharge = ShieldCharge(level: power.level(.shields))
    ship.showBarrier(charge: shieldCharge.charge, capacity: shieldCharge.capacity)
    level = 0
    lives = Tuning.Player.startingLives
    inventory.removeAll()
  }


  // ------------------------------------
  // Add text message to screen at point
  // ------------------------------------

  func addText(message: String) {
    let pos = Screen.sharedInstance.center
    let text = PopupLabelNode(message: message, location: pos, fontSize: 24)
    self.addChild(text)
  }

  // ------------------------------------------------------------
  // The next wave, planned with its leg when the station was picked.
  // Difficulty eases after a station and builds toward the next one.
  // ------------------------------------------------------------

  func planWave() {
    wave = stationRoute.wave(forStage: level)
      ?? WavePlan.make(stage: level, progress: stationRoute.legProgress, previous: wave.recipe)
    stats.wavesSeen[wave.recipe, default: 0] += 1
  }


  // ------------------------------------------------------------
  // Start making asteroids. Each spawn schedules the next, so the gap
  // can follow the size of the last rock or the wave's layout.
  // ------------------------------------------------------------

  func makeAsteroids() {
    switch wave.recipe.layout {
    case .scatter:
      if wave.recipe == .bosstroidField {
        // The centerpiece arrives first
        makeRock(size: .bosstroid)
        scheduleSpawn(after: wave.baseInterval * Tuning.Stages.sizeSpacing(.bosstroid))
      } else if wave.recipe.usesFeatured && wave.featured.entersFromTop {
        // The scanner warned of shooters, so one comes first
        makeRock(size: wave.randomSize(), type: wave.featured)
        scheduleSpawn(after: wave.baseInterval)
      } else {
        scheduleSpawn(after: wave.baseInterval)
      }
    case .lanes:
      activeLanes = WavePlan.activeLanes()
      laneRocks = 0
      scheduleSpawn(after: Tuning.Waves.laneGap)
    case .maze:
      mazeGapCenter = size.width / 2
      scheduleSpawn(after: 0)
    }
  }

  private func scheduleSpawn(after gap: TimeInterval) {
    run(.sequence([.wait(forDuration: gap), .run { self.spawnNext() }]), withKey: MAKE_ASTEROIDS)
  }

  private func spawnNext() {
    let gap: TimeInterval
    switch wave.recipe.layout {
    case .scatter:
      gap = makeAsteroid()
    case .lanes:
      makeLaneRock()
      gap = Tuning.Waves.laneGap
    case .maze:
      makeMazeRow()
      gap = Tuning.Waves.mazeRowTime
    }
    scheduleSpawn(after: gap)
  }


  // ------------------------------------------------------------
  // Stop Making Asteroids
  // ------------------------------------------------------------

  func stopAsteroids() {
    removeAction(forKey: MAKE_ASTEROIDS)
  }


  // ------------------------------------------------------------
  // Number of asteroids still on screen
  // ------------------------------------------------------------

  var asteroidCount: Int {
    return children.filter { $0 is Asteroid }.count
  }

  var enemyShotCount: Int {
    return children.filter { $0 is EnemyShot }.count
  }


  // Fade out rocks and enemy shots still flying around, for a clean screen

  func fadeOutLeftovers() {
    for node in children where node is Asteroid || node is EnemyShot {
      node.physicsBody = nil
      node.run(.sequence([.fadeOut(withDuration: 0.5), .removeFromParent()]))
    }
  }


  // Before docking, pickups still on screen are pulled into the ship,
  // so nothing the player could see is lost

  func pullPickupsToShip() {
    for case let powerup as PowerUp in children {
      powerup.physicsBody = nil
      let pull = SKAction.move(to: ship.position, duration: 0.6)
      pull.timingMode = .easeIn
      powerup.run(.sequence([pull, .run { self.collect(powerup) }]))
    }
  }


  // ------------------------------------------------------------
  // Collect a pickup: points, coins, or an item for the tray
  // ------------------------------------------------------------

  func collect(_ powerup: PowerUp) {
    guard powerup.parent != nil else { return }

    let points = powerup.name == PowerUp.PU_COIN ? Tuning.PowerUps.coinPoints : Tuning.PowerUps.points
    score += points
    if powerup.name == PowerUp.PU_COIN {
      coins += Tuning.Stations.coinPickup
    }
    show(points: points, at: powerup.position)
    powerup.removeFromParent()
    lightImpact.impactOccurred()

    // Items go into the tray to be used later. A full tray loses them.
    if let item = ItemType(powerupName: powerup.name), !inventory.add(item) {
      addChild(PopupLabelNode(message: "FULL", location: powerup.position + CGPoint(x: 0, y: 20)))
    }
  }


  // ------------------------------------------------------------
  // Make an asteroid or power up. Returns the time until the next spawn:
  // longer after a big rock, so a wave covers about the same amount of
  // screen whatever its sizes.
  // ------------------------------------------------------------

  func makeAsteroid() -> TimeInterval {
    // Now and then a pickup instead of a rock. Items are capped per wave.
    if Double.random(in: 0 ..< 1) < Tuning.PowerUps.pickupChance {
      let pickup = Pickup.random()
      if !pickup.isItem || itemsThisWave < Tuning.PowerUps.maxItemsPerWave {
        if pickup.isItem {
          itemsThisWave += 1
        }
        let powerup = pickup.make()
        addChild(powerup)
        powerup.position.x = CGFloat.random(in: 0 ... Screen.sharedInstance.width)
        powerup.position.y = size.height
        return wave.baseInterval
      }
    }

    // Later stages sometimes send smaller rocks in pairs. Spacing goes by
    // the rock's real size: brass in a swarm is large, not tiny.
    let type = wave.randomType()
    let rockSize = type.adjust(size: wave.randomSize())
    let pairsAllowed = rockSize.rawValue < Tuning.Stages.noPairsFrom.rawValue
    let count = pairsAllowed && Double.random(in: 0 ..< 1) < wave.pairChance ? 2 : 1
    for i in 0 ..< count {
      if i == 0 {
        makeRock(size: rockSize, type: type)
      } else {
        makeRock(size: wave.randomSize())
      }
    }
    return wave.baseInterval * Tuning.Stages.sizeSpacing(rockSize)
  }

  // A rock from the wave's direction, sometimes of its featured type,
  // faster in later stages

  func makeRock(size rockSize: AsteroidSize, type forcedType: AsteroidType? = nil) {
    let type = forcedType ?? wave.randomType()
    // Bosstroids always come from the top: from the side they drift in so
    // slowly they can stay off screen for the whole wave
    let direction = rockSize == .bosstroid || type.entersFromTop ? .top : wave.direction
    let asteroid = Asteroid(asteroidSize: rockSize, speed: wave.speed, direction: direction, type: type)
    if let velocity = asteroid.physicsBody?.velocity {
      let scale = wave.speedScale
      asteroid.physicsBody?.velocity = CGVector(dx: velocity.dx * scale, dy: velocity.dy * scale)
    }
    asteroid.setFireStage(wave.difficulty)
    addChild(asteroid)
    asteroid.trail?.targetNode = self
  }

  // Lanes: fast rocks straight down the busy lanes. Every so often the
  // busy lanes change, so the player has to move.

  func makeLaneRock() {
    laneRocks += 1
    if laneRocks % Tuning.Waves.laneSwitchEvery == 0 {
      activeLanes = WavePlan.activeLanes()
    }
    guard let lane = activeLanes.randomElement() else { return }
    let asteroid = Asteroid(asteroidSize: wave.randomSize())
    asteroid.position = CGPoint(x: WavePlan.laneX(lane, width: size.width) + CGFloat.random(in: -6 ... 6),
                                y: size.height + asteroid.size.height)
    asteroid.physicsBody?.velocity = CGVector(dx: 0, dy: -Tuning.Waves.laneSpeed * wave.speedScale)
    addChild(asteroid)
  }

  // Maze: a row of unbreakable rocks with a gap, the gap a step left or
  // right of the last row's

  func makeMazeRow() {
    mazeGapCenter = WavePlan.nextMazeGap(after: mazeGapCenter, width: size.width)
    // Same layout every row, but each rock is nudged, turned and sized a
    // little differently so the walls look natural
    let jitter = Tuning.Waves.mazeJitter
    let lift = Tuning.Waves.mazeVerticalJitter
    let turn = Tuning.Waves.mazeTurn
    for x in WavePlan.mazeRow(gapCenter: mazeGapCenter, width: size.width) {
      let rock = Asteroid(asteroidSize: Bool.random() ? .large : .average)
      rock.position = CGPoint(x: x + CGFloat.random(in: -jitter ... jitter),
                              y: size.height + rock.size.height + CGFloat.random(in: -lift ... lift))
      rock.zRotation = CGFloat.random(in: -turn ... turn)
      addChild(rock)
      rock.makeWall(speed: Tuning.Waves.mazeSpeed)
    }
  }


  // Turrets and enemy bases drop an item when destroyed: a reward for
  // taking on the enemies that shoot back

  func dropItem(at point: CGPoint) {
    let powerup = Pickup.random(itemsOnly: true).make()
    powerup.position = point
    addChild(powerup)
  }


  // ---------------------------------
  // Sparks where a shot hits, more and
  // brighter with weapons power
  // ---------------------------------

  func sparks(at point: CGPoint, level: Int, color: UIColor) {
    let emitter = SKEmitterNode()
    emitter.particleTexture = SKTexture(imageNamed: "spark")
    emitter.position = point
    emitter.zPosition = 20
    emitter.particleBirthRate = 400
    emitter.numParticlesToEmit = 4 + level * 3
    emitter.particleLifetime = 0.25
    emitter.particleLifetimeRange = 0.1
    emitter.particleSpeed = 60 + CGFloat(level) * 25
    emitter.particleSpeedRange = 40
    emitter.emissionAngleRange = .pi * 2
    emitter.particleScale = 0.08 + CGFloat(level) * 0.02
    emitter.particleScaleSpeed = -0.3
    emitter.particleAlphaSpeed = -3
    emitter.particleColor = color
    emitter.particleColorBlendFactor = 1
    emitter.particleBlendMode = .add
    addChild(emitter)
    emitter.run(.sequence([.wait(forDuration: 0.5), .removeFromParent()]))
  }


  // ---------------------------------
  // Shoot missile
  // ---------------------------------

  func shootMissile() {
    let points = missileMode.getPoints()

    for point in points {
      let missile = Missile(level: power.level(.weapons), damageScale: upgrades.damageScale)
      addChild(missile)
      missile.position = ship.position + point
    }
  }


  // ---------------------------------
  // Set the mode for missiles
  // ---------------------------------

  func missilePowerUp(mode: MissileMode) {
    missileMode = mode
    run(.sequence([.wait(forDuration: PowerUp.powerup_duration), .run({
      self.missileMode = .normal
    })]), withKey: MISSILE_MODE_TIMER)
  }


  // ---------------------------------
  // Start rapid fire mode
  // ---------------------------------

  func missileRapid() {
    rapidFireOn = true
    run(.sequence([.wait(forDuration: PowerUp.powerup_duration), .run({
      self.rapidFireOn = false
    })]), withKey: RAPID_FIRE_TIMER)
  }


  // ---------------------------------
  // Use an item from the tray
  // ---------------------------------

  func useItem(slot: Int) {
    // A tap on the tray still resumes or skips like a tap anywhere else
    if gamePaused {
      resumeGame()
      return
    }

    if let intro = gameState.currentState as? IntroState {
      intro.skip()
      return
    }

    guard shipInPlay else { return }

    switch inventory.tap(slot: slot) {
    case .use(.bomb):
      impact.impactOccurred()
      shakeScreen(hitAsteroids: true, count: Tuning.PowerUps.bombPulses)
    case .use(.multiShot):
      missilePowerUp(mode: MissileMode.randomPowerup())
    case .use(.rapidFire):
      missileRapid()
    case .shieldOn:
      shield.activate()
    case .shieldOff:
      shield.deactivate()
    case .use(.shield), .none:
      return
    }
    lightImpact.impactOccurred()
  }


  // ---------------------------------
  // Recharge the powered shield
  // ---------------------------------

  func updateShieldCharge(seconds: TimeInterval) {
    guard shipInPlay, !gamePaused else { return }
    let before = shieldCharge.charge
    shieldCharge.update(seconds: seconds)
    if shieldCharge.charge != before {
      ship.showBarrier(charge: shieldCharge.charge, capacity: shieldCharge.capacity)
    }
  }


  // ---------------------------------
  // Drain the shield while it's up
  // ---------------------------------

  func updateShield(seconds: TimeInterval) {
    guard inventory.shieldIsOn, shipInPlay, !gamePaused else { return }
    if inventory.drainShield(seconds: seconds) {
      shield.deactivate()
    } else {
      shield.flicker(inventory.shieldCharge < Tuning.Items.shieldWarning)
    }
  }


  // ----------------------------------
  // Touch Events
  // ----------------------------------

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gamePaused {
      resumeGame()
      return
    }

    if let intro = gameState.currentState as? IntroState {
      intro.skip()
      return
    }

    if let station = gameState.currentState as? StationState {
      station.touched()
      return
    }

    activeTouches.formUnion(touches)
  }

  // Drag anywhere to steer the ship

  // Drag anywhere to steer. The finger sets a target and the ship follows
  // as fast as its engines allow (see followDrag). Locked while the power
  // HUD is open.

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, !gamePaused, !ship.isHidden, !powerPanelOpen,
          !(gameState.currentState is StationState) else { return }
    let dx = touch.location(in: self).x - touch.previousLocation(in: self).x
    let halfWidth = ship.size.width / 2
    let x = (dragTargetX ?? ship.position.x) + dx
    dragTargetX = min(max(x, halfWidth), size.width - halfWidth)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    activeTouches.subtract(touches)
    if activeTouches.isEmpty {
      dragTargetX = nil
    }
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesEnded(touches, with: event)
  }

  // Move the ship toward the drag target at engine speed

  func followDrag(seconds: TimeInterval) {
    guard let target = dragTargetX else { return }
    let step = ship.dragSpeed * CGFloat(seconds)
    let dx = target - ship.position.x
    ship.position.x += abs(dx) <= step ? dx : (dx > 0 ? step : -step)
  }


  // ---------------------------------
  // Clear all objects on screen
  // ---------------------------------

  func clearScreen() {
    let names = [Asteroid.NAME, PowerUp.PU_BOMB, PowerUp.PU_MISSILE_2, PowerUp.PU_MISSILE_3, PowerUp.PU_MISSILE_RAPID, PowerUp.PU_POINTS, PowerUp.PU_SHIELD, PowerUp.PU_COIN, Missile.NAME, EnemyShot.NAME]
    for name in names {
      enumerateChildNodes(withName: name, using: { (node, stop) in
        node.removeFromParent()
      })
    }
  }


  // ---------------------------------
  // Destroy all asteroids on screen
  // ---------------------------------

  func destroyAllAsteroids() {
    self.enumerateChildNodes(withName: Asteroid.NAME) { (asteroid, stop) in
      asteroid.removeFromParent()
      self.score += 1
    }
    shakeScreen()
  }


  // -------------------------------
  // Shake Screen
  // -------------------------------

  // TODO: Fine tune hitAllAsteroids against time and count for screen shake
  //       May need to balance with damage valeu below in hitAllAsteroids.

  func shakeScreen(hitAsteroids: Bool = false, count: Int = 10) {
    let wait = 0.06
    let offset: CGFloat = 8

    let waitAction = SKAction.wait(forDuration: wait)
    let wiggle = SKAction.run {
      guard let camera = self.camera else { return }
      let cx = Screen.sharedInstance.centerX
      let cy = Screen.sharedInstance.centerY
      let dx = cx + CGFloat.random(in: -offset ... offset)
      let dy = cy + CGFloat.random(in: -offset ... offset)
      camera.position = CGPoint(x: dx, y: dy)
      if hitAsteroids {
        self.hitAllAsteroids()
      }
    }
    let seq = SKAction.sequence([waitAction, wiggle])
    let rep = SKAction.repeat(seq, count: count)
    let resetPosition = SKAction.run {
      self.camera?.position = Screen.sharedInstance.center
    }
    let seq2 = SKAction.sequence([rep, resetPosition])
    run(seq2)
  }


  // -------------------------------------
  // Handle a hit on an Asteroid
  // -------------------------------------

  func hit(asteroid: Asteroid, damage: CGFloat) {
    // Already destroyed by another contact this frame
    guard asteroid.parent != nil else { return }

    if let debris = asteroid.hitAsteroid(value: damage) {
      let points = Int(asteroid.asteroidSize.rawValue) * asteroid.type.pointMultiplier

      if shipInPlay {
        score += points
        show(points: points, at: asteroid.position)
        stats.asteroidsDestroyed += 1
        if asteroid.type == .turret || asteroid.type == .base {
          stats.turretsDestroyed += 1
        }
      }

      asteroid.removeFromParent()

      if asteroid.type == .turret || asteroid.type == .base {
        dropItem(at: asteroid.position)
      }

      for rock in debris {
        addChild(rock)
      }

      switch asteroid.type {
      case .glass:
        shatter(at: asteroid.position, size: asteroid.size.width)
      case .gas:
        gasExplosion(at: asteroid.position, radius: max(Tuning.Hazards.gasMinRadius, asteroid.size.width * Tuning.Hazards.gasRadiusScale))
      default:
        break
      }
    }
  }


  // -------------------------------------
  // Glassteroid shards, just for show
  // -------------------------------------

  func shatter(at point: CGPoint, size: CGFloat) {
    for _ in 0 ..< 8 {
      let shard = SKSpriteNode(color: AsteroidType.glass.color(), size: CGSize(width: 4, height: 7))
      shard.position = point
      shard.zRotation = CGFloat.random(in: 0 ... .pi)
      addChild(shard)
      let angle = CGFloat.random(in: 0 ... .pi * 2)
      let distance = size + CGFloat.random(in: 10 ... 40)
      let move = SKAction.moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.5)
      move.timingMode = .easeOut
      let spin = SKAction.rotate(byAngle: CGFloat.random(in: -6 ... 6), duration: 0.5)
      shard.run(.sequence([.group([move, spin, .fadeOut(withDuration: 0.5)]), .removeFromParent()]))
    }
  }


  // -------------------------------------
  // Gasteroid explosion. Damages every asteroid in range, and the ship.
  // -------------------------------------

  func gasExplosion(at point: CGPoint, radius: CGFloat) {
    explode(at: point)

    let ring = SKShapeNode(circleOfRadius: radius)
    ring.position = point
    ring.strokeColor = Colors.gasExplosion
    ring.fillColor = Colors.gasExplosion.withAlphaComponent(0.25)
    ring.lineWidth = 3
    ring.setScale(0.2)
    addChild(ring)
    ring.run(.sequence([.group([.scale(to: 1, duration: 0.25), .fadeOut(withDuration: 0.4)]), .removeFromParent()]))

    // Collect targets first, an explosion can set off other gasteroids
    let inRange = children.compactMap { $0 as? Asteroid }.filter {
      hypot($0.position.x - point.x, $0.position.y - point.y) < radius + $0.size.width / 2
    }
    for asteroid in inRange {
      hit(asteroid: asteroid, damage: Tuning.Hazards.gasDamage)
    }

    if hypot(ship.position.x - point.x, ship.position.y - point.y) < radius {
      shipHit()
    }
  }


  // ---------------------------------
  // Hit all asteroids
  // ---------------------------------

  func hitAllAsteroids() {
    enumerateChildNodes(withName: Asteroid.NAME) { (node, stop) in
      if let asteroid = node as? Asteroid {
        self.hit(asteroid: asteroid, damage: Tuning.PowerUps.bombDamage)
      }
    }
  }


  // ---------------------------------
  // Ship was hit by an asteroid
  // ---------------------------------

  func shipHit() {
    guard shipInPlay, ship.canBeHit else { return }

    // Powered shields take the hit if they have charge
    if shieldCharge.absorb() {
      ship.flashBarrier()
      ship.showBarrier(charge: shieldCharge.charge, capacity: shieldCharge.capacity)
      lightImpact.impactOccurred()
      ship.makeInvulnerable(duration: Tuning.Power.shieldHitInvulnerable)
      return
    }

    lives -= 1
    explode(at: ship.position)
    impact.impactOccurred()

    if lives <= 0 {
      gameState.enter(GameEndingState.self)
    } else {
      shakeScreen(count: 5)
      ship.makeInvulnerable()
    }
  }


  // ---------------------------------
  // Make an explosion
  // ---------------------------------

  func explode(at point: CGPoint) {
    guard let shipExplosion = SKEmitterNode(fileNamed: "ShipExplosion") else { return }
    shipExplosion.position = point
    addChild(shipExplosion)

    let wait = SKAction.wait(forDuration: 2)
    let remove = SKAction.removeFromParent()
    shipExplosion.run(SKAction.sequence([wait, remove]))
  }


  // ----------------------------------------
  // Show text message on screen
  // ----------------------------------------

  func show(points: Int, at location: CGPoint) {
    let label = PopupLabelNode(message: "\(points)", location: location)
    addChild(label)
  }


  // ---------------------------------------
  // Update
  // ---------------------------------------

  var lastUpdateTime: TimeInterval = 0
  override func update(_ currentTime: TimeInterval) {
    // Clamp so a stall or a pause doesn't produce one huge step
    let frameTime = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1 / 20)
    lastUpdateTime = currentTime
    // Game time runs slow while the power HUD is open
    let deltaTime = frameTime * TimeInterval(speed)

    if powerPanelOpen && !shipInPlay {
      closePowerPanel()
    }

    gameState.update(deltaTime: deltaTime)
    handleUpdate(seconds: deltaTime)

    // The voyage goes on while the ship flies the waves
    if shipInPlay && !gamePaused {
      stats.distance += deltaTime * Tuning.Travel.auPerSecond
    }

    shield.position = ship.position
    updateShield(seconds: deltaTime)
    updateShieldCharge(seconds: deltaTime)

    let screenRect = CGRect(origin: .zero, size: size)
    for case let asteroid as Asteroid in children where asteroid.type == .elastic && !asteroid.edgeArmed {
      asteroid.armBounceIfOnScreen(in: screenRect)
    }
  }


  // ---------------------------------
  // Handle updates
  // ---------------------------------

  func handleUpdate(seconds: TimeInterval) {
    followDrag(seconds: seconds)

    if !powerPanelOpen, let accelerationData = MotionManager.sharedInstance.accelerometer {
      let x = CGFloat(accelerationData.acceleration.x)
      ship.moveForce(x: x * Tuning.Player.tiltForce)
    }

    // Fire on auto, or while a finger is held down, at the weapon's rate.
    // Hold fire while docked.
    timeSinceLastMissile = min(timeSinceLastMissile + seconds, missileFireTime)
    let firing = autoFireOn || !activeTouches.isEmpty
    if firing && !(gameState.currentState is StationState) && timeSinceLastMissile >= missileFireTime {
      timeSinceLastMissile = 0
      if !ship.isHidden {
        shootMissile()
      }
    }
  }



}


// - Gestures ------------------------------
extension GameScene {
  func setupGestures() {
    guard let view = view else {
      return
    }

    // Steering is by drag (see touchesMoved) or tilt. Swipe up opens the
    // power HUD, swipe down closes it.

    swipeDown.addTarget(self, action: #selector(GameScene.handleSwipe))
    swipeDown.direction = .down
    swipeDown.cancelsTouchesInView = false
    view.addGestureRecognizer(swipeDown)

    swipeUp.addTarget(self, action: #selector(GameScene.handleSwipe))
    swipeUp.direction = .up
    swipeUp.cancelsTouchesInView = false
    view.addGestureRecognizer(swipeUp)
  }

  @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
    switch gesture.direction {
    case .up:
      openPowerPanel()

    case .down:
      closePowerPanel()

    default:
      return
    }
  }
}


extension GameScene {
  // Version, build number and commit in the bottom corner, to tell test builds apart

  func showVersion() {
    let versionLabel = SKLabelNode()
    addChild(versionLabel)
    versionLabel.verticalAlignmentMode = .bottom
    versionLabel.horizontalAlignmentMode = .left
    versionLabel.fontName = Fonts.fontName
    versionLabel.fontSize = 12
    versionLabel.position = CGPoint(x: 5, y: 5 + safeArea.bottom)
    versionLabel.fontColor = Colors.buttonLabelColor.withAlphaComponent(0.6)
    versionLabel.zPosition = 9999
    versionLabel.text = AppVersion.label
  }
}
