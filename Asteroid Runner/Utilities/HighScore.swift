//
//  HighScore.swift
//  Asteroid Runner
//

import Foundation

// Best score, saved between launches

struct HighScore {
  static let KEY = "HIGH_SCORE"

  static var best: Int {
    return UserDefaults.standard.integer(forKey: KEY)
  }

  // Saves the score if it beats the best. Returns true if it did.

  @discardableResult
  static func submit(_ score: Int) -> Bool {
    guard score > best else { return false }
    UserDefaults.standard.set(score, forKey: KEY)
    return true
  }
}
