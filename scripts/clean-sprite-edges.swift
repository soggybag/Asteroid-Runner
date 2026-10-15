#!/usr/bin/env swift
// Cleans scanned or hand-drawn sprite art: makes everything outside the
// drawing fully transparent. Faint leftovers (paper, scan haze, selection
// edges, stray specks) show in the game as a box around the sprite.
//
//   swift scripts/clean-sprite-edges.swift path/to/*.png
//
// Rewrites each PNG in place. The drawing is every solid shape (alpha at
// least half) bigger than 1% of the largest one, plus anything enclosed by
// them, plus a 1-pixel soft edge. Everything else is cleared. Safe to run
// again on art that's already clean.

import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers

func clean(_ path: String) {
  let url = URL(fileURLWithPath: path)
  guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    print("\(path): can't read")
    return
  }
  let w = image.width, h = image.height
  let space = CGColorSpace(name: CGColorSpace.sRGB)!
  var px = [UInt8](repeating: 0, count: w * h * 4)
  guard let context = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                                space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
  context.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))

  func alpha(_ i: Int) -> UInt8 { px[i * 4 + 3] }
  func neighbours(_ i: Int) -> [Int] {
    let x = i % w, y = i / w
    var result = [Int]()
    for dy in -1 ... 1 {
      for dx in -1 ... 1 where dx != 0 || dy != 0 {
        let nx = x + dx, ny = y + dy
        if nx >= 0, ny >= 0, nx < w, ny < h { result.append(ny * w + nx) }
      }
    }
    return result
  }

  // Solid shapes, by connected pixels
  var shape = [Int](repeating: -1, count: w * h)
  var sizes = [Int]()
  for start in 0 ..< w * h where alpha(start) >= 128 && shape[start] < 0 {
    let id = sizes.count
    var stack = [start]
    shape[start] = id
    var count = 0
    while let i = stack.popLast() {
      count += 1
      for n in neighbours(i) where alpha(n) >= 128 && shape[n] < 0 {
        shape[n] = id
        stack.append(n)
      }
    }
    sizes.append(count)
  }
  guard let largest = sizes.max() else {
    print("\(path): nothing solid, left alone")
    return
  }
  let kept = Set(sizes.indices.filter { sizes[$0] * 100 >= largest })
  let isDrawing = (0 ..< w * h).map { shape[$0] >= 0 && kept.contains(shape[$0]) }

  // Outside: reachable from the border without crossing the drawing
  var outside = [Bool](repeating: false, count: w * h)
  var stack = [Int]()
  for x in 0 ..< w { stack.append(x); stack.append((h - 1) * w + x) }
  for y in 0 ..< h { stack.append(y * w); stack.append(y * w + w - 1) }
  while let i = stack.popLast() {
    if outside[i] || isDrawing[i] { continue }
    outside[i] = true
    stack.append(contentsOf: neighbours(i))
  }

  var cleared = 0
  for i in 0 ..< w * h where outside[i] && alpha(i) > 0 {
    // Keep a soft edge right against the drawing
    if neighbours(i).contains(where: { isDrawing[$0] }) { continue }
    px[i * 4] = 0; px[i * 4 + 1] = 0; px[i * 4 + 2] = 0; px[i * 4 + 3] = 0
    cleared += 1
  }

  guard cleared > 0 else {
    print("\(path): already clean")
    return
  }
  guard let out = context.makeImage(),
        let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
  CGImageDestinationAddImage(dest, out, nil)
  CGImageDestinationFinalize(dest)
  print("\(path): cleared \(cleared) pixels, kept \(kept.count) shape(s)")
}

for path in CommandLine.arguments.dropFirst() {
  clean(path)
}
