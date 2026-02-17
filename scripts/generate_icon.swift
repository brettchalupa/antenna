#!/usr/bin/env swift

import AppKit
import Foundation

// FontAwesome Free radio icon - MIT licensed
// https://fontawesome.com/license/free
let svgTemplate = """
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 560" width="%d" height="%d">
    <path fill="white" d="M558.8 79C571.5 75.3 578.8 61.9 575.1 49.2C571.4 36.5 558 29.2 545.3 \
  33L115.8 158.9C106.4 161.6 97.9 166.1 90.6 172C74.5 183.7 64 202.6 64 224L64 480C64 515.3 92.7 \
  544 128 544L512 544C547.3 544 576 515.3 576 480L576 224C576 188.7 547.3 160 512 160L282.5 \
  160L558.8 79zM432 272C476.2 272 512 307.8 512 352C512 396.2 476.2 432 432 432C387.8 432 352 \
  396.2 352 352C352 307.8 387.8 272 432 272zM128 312C128 298.7 138.7 288 152 288L264 288C277.3 \
  288 288 298.7 288 312C288 325.3 277.3 336 264 336L152 336C138.7 336 128 325.3 128 312zM128 \
  408C128 394.7 138.7 384 152 384L264 384C277.3 384 288 394.7 288 408C288 421.3 277.3 432 264 \
  432L152 432C138.7 432 128 421.3 128 408z"/>
  </svg>
  """

func generateIcon(pixelSize: Int) -> NSBitmapImageRep {
  let s = CGFloat(pixelSize)
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: pixelSize,
    pixelsHigh: pixelSize,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  )!
  rep.size = NSSize(width: pixelSize, height: pixelSize)

  let ctx = NSGraphicsContext(bitmapImageRep: rep)!
  NSGraphicsContext.current = ctx
  let cg = ctx.cgContext

  // Background: rounded rect with gradient, inset ~10% per Apple HIG
  let inset = s * 0.1
  let iconBody = s - inset * 2
  let cornerRadius = iconBody * 0.22
  let bgPath = CGPath(
    roundedRect: CGRect(x: inset, y: inset, width: iconBody, height: iconBody),
    cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
  cg.addPath(bgPath)
  cg.clip()

  let colorSpace = CGColorSpaceCreateDeviceRGB()
  let colors = [
    CGColor(red: 0.08, green: 0.75, blue: 0.72, alpha: 1.0),
    CGColor(red: 0.05, green: 0.25, blue: 0.55, alpha: 1.0),
  ] as CFArray
  let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
  cg.drawLinearGradient(
    gradient, start: CGPoint(x: inset, y: s - inset),
    end: CGPoint(x: s - inset, y: inset), options: [])

  // Draw FontAwesome radio icon (white SVG) centered on the gradient
  let iconPixelSize = Int(iconBody * 0.6)
  let svgString = String(format: svgTemplate, iconPixelSize, iconPixelSize)
  if let svgData = svgString.data(using: .utf8),
    let svgImage = NSImage(data: svgData)
  {
    let iconSize = CGFloat(iconPixelSize)
    let x = (s - iconSize) / 2
    let y = (s - iconSize) / 2
    svgImage.draw(
      in: NSRect(x: x, y: y, width: iconSize, height: iconSize),
      from: .zero,
      operation: .sourceOver,
      fraction: 1.0)
  }

  NSGraphicsContext.current = nil
  return rep
}

func savePNG(_ rep: NSBitmapImageRep, to path: String) {
  guard let pngData = rep.representation(using: .png, properties: [:]) else {
    print("Failed to generate PNG for \(path)")
    return
  }
  try! pngData.write(to: URL(fileURLWithPath: path))
  print("Wrote \(path) (\(rep.pixelsWide)x\(rep.pixelsHigh))")
}

let sizes: [(Int, String)] = [
  (16, "icon_16x16.png"),
  (32, "icon_16x16@2x.png"),
  (32, "icon_32x32.png"),
  (64, "icon_32x32@2x.png"),
  (128, "icon_128x128.png"),
  (256, "icon_128x128@2x.png"),
  (256, "icon_256x256.png"),
  (512, "icon_256x256@2x.png"),
  (512, "icon_512x512.png"),
  (1024, "icon_512x512@2x.png"),
]

let outputDir =
  CommandLine.arguments.count > 1
  ? CommandLine.arguments[1]
  : "Antenna/Resources/Assets.xcassets/AppIcon.appiconset"

for (pixelSize, filename) in sizes {
  let rep = generateIcon(pixelSize: pixelSize)
  savePNG(rep, to: "\(outputDir)/\(filename)")
}

print("Done!")
