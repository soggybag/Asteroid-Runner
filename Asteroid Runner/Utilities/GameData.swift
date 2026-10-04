//
//  GameData.swift
//  Asteroid Runner
//

// Text and settings the game reads from JSON files in the Data folder,
// so story and dialog can be edited without touching code.

import Foundation

enum GameData {

  // Decode Data/<name>.json from the app bundle. Returns nil, and logs
  // why, if the file is missing or doesn't match the type.
  static func load<T: Decodable>(_ type: T.Type, from name: String, bundle: Bundle = .main) -> T? {
    guard let url = bundle.url(forResource: name, withExtension: "json") else {
      print("GameData: \(name).json is missing from the bundle")
      return nil
    }
    do {
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      print("GameData: couldn't read \(name).json: \(error)")
      return nil
    }
  }
}


// The opening story, from Data/intro.json

struct IntroText: Decodable {
  let lineDelay: TimeInterval
  let lines: [String]

  // Shown if intro.json is missing or broken
  static let fallback = IntroText(lineDelay: 2, lines: ["Asteroid Runner"])

  static func load() -> IntroText {
    return GameData.load(IntroText.self, from: "intro") ?? fallback
  }
}


// Version, build and commit, shown in the corner of the screen. The build
// number and commit are stamped in by scripts/stamp-version.sh at build time.

enum AppVersion {
  static var label: String {
    let info = Bundle.main.infoDictionary ?? [:]
    let version = info["CFBundleShortVersionString"] as? String ?? "?"
    let build = info["CFBundleVersion"] as? String ?? "?"
    let commit = info["GitCommit"] as? String ?? ""
    return "v\(version) (\(build)) \(commit)".trimmingCharacters(in: .whitespaces)
  }
}
