import AppKit
import CoreGraphics
import Foundation

// Original, reproducible artwork for the TianfuGlass app icon.
// Flat vector shapes are intentionally readable at Dynamic Island size.
// The system applies the final app-icon corner mask and appearance effects.
let size = 1024
let destination = URL(fileURLWithPath: "Sources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)

guard let context = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Cannot create AppIcon bitmap context")
}

func rgba(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    CGColor(
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        components: [
            CGFloat((hex >> 16) & 0xff) / 255,
            CGFloat((hex >> 8) & 0xff) / 255,
            CGFloat(hex & 0xff) / 255,
            alpha
        ]
    )!
}

func linearGradient(_ colors: [CGColor], start: CGPoint, end: CGPoint) {
    let stops = (0..<colors.count).map { CGFloat($0) / CGFloat(colors.count - 1) }
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: colors as CFArray, locations: stops)!
    context.drawLinearGradient(gradient, start: start, end: end, options: [])
}

func roundedRect(_ rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func fillPath(_ path: CGPath, color: CGColor) {
    context.addPath(path)
    context.setFillColor(color)
    context.fillPath()
}

// Cool cyan-to-blue fill. Do not bake an iOS rounded-rect mask into the art.
linearGradient(
    [rgba(0x91EAF5), rgba(0x47B5F5), rgba(0x1479EC)],
    start: CGPoint(x: 45, y: 990),
    end: CGPoint(x: 945, y: 45)
)

// A single restrained frosted-glass lens behind the train, not an extra icon border.
let lens = CGPath(ellipseIn: CGRect(x: 92, y: 145, width: 840, height: 770), transform: nil)
context.saveGState()
context.addPath(lens)
context.clip()
linearGradient(
    [rgba(0xFFFFFF, alpha: 0.20), rgba(0xFFFFFF, alpha: 0.055)],
    start: CGPoint(x: 280, y: 890),
    end: CGPoint(x: 775, y: 165)
)
context.restoreGState()
context.setStrokeColor(rgba(0xFFFFFF, alpha: 0.22))
context.setLineWidth(3)
context.addPath(lens)
context.strokePath()

// Rails sit behind the train body. Make them large enough to survive 30px scaling.
context.setStrokeColor(rgba(0xFFFFFF, alpha: 0.97))
context.setLineCap(.round)
context.setLineWidth(48)
context.move(to: CGPoint(x: 415, y: 345))
context.addLine(to: CGPoint(x: 349, y: 231))
context.move(to: CGPoint(x: 609, y: 345))
context.addLine(to: CGPoint(x: 675, y: 231))
context.strokePath()

context.setLineWidth(33)
context.move(to: CGPoint(x: 409, y: 243))
context.addLine(to: CGPoint(x: 615, y: 243))
context.strokePath()

// Our own compact front-facing train pictogram (not a copied SF Symbol asset).
let trainBody = roundedRect(CGRect(x: 300, y: 294, width: 424, height: 476), radius: 98)
context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -8), blur: 20, color: rgba(0x0E58B8, alpha: 0.15))
fillPath(trainBody, color: rgba(0xFFFFFF, alpha: 0.98))
context.restoreGState()

// Window: negative-looking recess with the blue backdrop visible through.
let window = roundedRect(CGRect(x: 342, y: 468, width: 340, height: 210), radius: 55)
context.saveGState()
context.addPath(window)
context.clip()
linearGradient(
    [rgba(0x98E9F4), rgba(0x37A4EF)],
    start: CGPoint(x: 350, y: 685),
    end: CGPoint(x: 665, y: 470)
)
context.restoreGState()

// Route display above the windscreen, intentionally without text.
fillPath(roundedRect(CGRect(x: 430, y: 711, width: 164, height: 35), radius: 17),
         color: rgba(0x55C6F7))

// Symmetric round lights; dark enough relative to the white body.
fillPath(CGPath(ellipseIn: CGRect(x: 364, y: 358, width: 69, height: 69), transform: nil),
         color: rgba(0x328EEE))
fillPath(CGPath(ellipseIn: CGRect(x: 591, y: 358, width: 69, height: 69), transform: nil),
         color: rgba(0x328EEE))

guard let image = context.makeImage() else {
    fatalError("Failed to rasterize icon")
}
let representation = NSBitmapImageRep(cgImage: image)
guard let pngData = representation.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode icon PNG")
}
try pngData.write(to: destination, options: .atomic)
print("Generated 1024x1024 AppIcon: \(destination.path) (\(pngData.count) bytes)")
