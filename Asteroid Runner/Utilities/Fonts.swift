//
//  Fonts.swift
//  Asteroid Runner
//
//  Created by mitchell hudson on 3/17/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import SpriteKit

// The game's one font. Patrick Hand is printed handwriting to go with the
// pen art; it's bundled in Fonts/ (free, SIL Open Font License) and listed
// under UIAppFonts in Info.plist. DIN Alternate is the font from before,
// built into iOS: set fontName to Fonts.din to compare.

struct Fonts {
  static let handwriting = "PatrickHand-Regular"
  static let din = "DINAlternate-Bold"

  static let fontName = handwriting
}
