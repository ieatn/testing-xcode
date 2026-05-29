#!/usr/bin/env swift

import AppKit

let outputDir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : FileManager.default.currentDirectoryPath + "/testing-xcode/Assets.xcassets/AppIcon.appiconset"

let sizes: [(name: String, size: Int)] = [
    ("Icon-20@2x.png", 40),
    ("Icon-20@3x.png", 60),
    ("Icon-29@2x.png", 58),
    ("Icon-29@3x.png", 87),
    ("Icon-40@2x.png", 80),
    ("Icon-40@3x.png", 120),
    ("Icon-60@2x.png", 120),
    ("Icon-60@3x.png", 180),
    ("Icon-76.png", 76),
    ("Icon-76@2x.png", 152),
    ("Icon-83.5@3x.png", 167),
    ("Icon-1024.png", 1024),
]

func drawIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    let top = NSColor(calibratedRed: 0.22, green: 0.48, blue: 0.96, alpha: 1)
    let bottom = NSColor(calibratedRed: 0.36, green: 0.28, blue: 0.92, alpha: 1)
    let gradient = NSGradient(starting: top, ending: bottom)!
    gradient.draw(in: rect, angle: 135)

    let inset = CGFloat(size) * 0.18
    let checkRect = rect.insetBy(dx: inset, dy: inset)

    let path = NSBezierPath()
    let start = NSPoint(x: checkRect.minX + checkRect.width * 0.18, y: checkRect.minY + checkRect.height * 0.52)
    let mid = NSPoint(x: checkRect.minX + checkRect.width * 0.42, y: checkRect.minY + checkRect.height * 0.24)
    let end = NSPoint(x: checkRect.minX + checkRect.width * 0.82, y: checkRect.minY + checkRect.height * 0.78)
    path.move(to: start)
    path.line(to: mid)
    path.line(to: end)
    path.lineWidth = max(2, CGFloat(size) * 0.09)
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    NSColor.white.setStroke()
    path.stroke()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to url: URL, size: Int) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff) else { return }
    rep.size = NSSize(width: size, height: size)
    guard let data = rep.representation(using: .png, properties: [:]) else { return }
    try? data.write(to: url)
}

try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
for entry in sizes {
    let url = URL(fileURLWithPath: outputDir).appendingPathComponent(entry.name)
    savePNG(drawIcon(size: entry.size), to: url, size: entry.size)
    print("Wrote \(entry.name)")
}
