//
//  MotionManager.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/18/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import CoreMotion

class MotionManager {
  static let sharedInstance = MotionManager()
  
  let motion = CMMotionManager()
  var accelerometer: CMAccelerometerData? {
    get {
      return motion.accelerometerData
    }
  }
  
  init() {
    motion.startAccelerometerUpdates()
  }
}
