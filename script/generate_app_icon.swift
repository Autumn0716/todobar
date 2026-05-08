import AppKit
import Foundation

let outputPath = CommandLine.arguments.dropFirst().first ?? "Resources/AppIcon.iconset"
let outputURL = URL(fileURLWithPath: outputPath)

try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

let icons: [(points: Int, scale: Int, name: String)] = [
    (16, 1, "icon_16x16.png"),
    (16, 2, "icon_16x16@2x.png"),
    (32, 1, "icon_32x32.png"),
    (32, 2, "icon_32x32@2x.png"),
    (128, 1, "icon_128x128.png"),
    (128, 2, "icon_128x128@2x.png"),
    (256, 1, "icon_256x256.png"),
    (256, 2, "icon_256x256@2x.png"),
    (512, 1, "icon_512x512.png"),
    (512, 2, "icon_512x512@2x.png")
]

for icon in icons {
    let pixels = CGFloat(icon.points * icon.scale)
    let image = NSImage(size: NSSize(width: pixels, height: pixels))

    image.lockFocus()
    drawIcon(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not render \(icon.name)")
    }

    try data.write(to: outputURL.appendingPathComponent(icon.name))
}

private func drawIcon(in rect: NSRect) {
    NSColor.clear.setFill()
    rect.fill()

    let size = rect.width
    let tile = NSRect(x: size * 0.14, y: size * 0.12, width: size * 0.72, height: size * 0.76)
    let panel = NSRect(x: size * 0.33, y: size * 0.20, width: size * 0.28, height: size * 0.60)
    let panelRadius = size * 0.105
    let handle = NSRect(x: size * 0.58, y: size * 0.44, width: size * 0.10, height: size * 0.12)
    let handleRadius = size * 0.045

    NSColor.black.withAlphaComponent(0.18).setFill()
    NSBezierPath(
        roundedRect: tile.offsetBy(dx: size * 0.018, dy: -size * 0.022),
        xRadius: size * 0.18,
        yRadius: size * 0.18
    ).fill()

    NSColor.white.setFill()
    NSBezierPath(roundedRect: tile, xRadius: size * 0.18, yRadius: size * 0.18).fill()

    NSColor.black.setFill()
    NSBezierPath(roundedRect: panel, xRadius: panelRadius, yRadius: panelRadius).fill()
    NSBezierPath(roundedRect: handle, xRadius: handleRadius, yRadius: handleRadius).fill()

    NSColor.white.setStroke()
    let check = NSBezierPath()
    check.lineWidth = max(1.5, size * 0.052)
    check.lineCapStyle = .round
    check.lineJoinStyle = .round
    check.move(to: NSPoint(x: size * 0.39, y: size * 0.58))
    check.line(to: NSPoint(x: size * 0.46, y: size * 0.51))
    check.line(to: NSPoint(x: size * 0.56, y: size * 0.66))
    check.stroke()

    NSColor.white.withAlphaComponent(0.88).setFill()
    drawLine(x: size * 0.39, y: size * 0.40, width: size * 0.14, height: size * 0.026, radius: size * 0.013)
    drawLine(x: size * 0.39, y: size * 0.34, width: size * 0.10, height: size * 0.026, radius: size * 0.013)
}

private func drawLine(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat) {
    NSBezierPath(
        roundedRect: NSRect(x: x, y: y, width: width, height: height),
        xRadius: radius,
        yRadius: radius
    ).fill()
}
