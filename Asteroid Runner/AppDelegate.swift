//
//  AppDelegate.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // --------------------------------------------
    // Disable sleep
    // --------------------------------------------
    UIApplication.shared.isIdleTimerDisabled = true

    return true
  }

  // The window comes from SceneDelegate, with Main.storyboard
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

}
