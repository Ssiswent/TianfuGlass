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

// No inner white disc or translucent ellipse: the train itself is
// the sole focal element. A subtle body gradient provides depth.
func gradientFill(_ path: CGPath, colors: [CGColor], start: CGPoint, end: CGPoint) {
    context.saveGState()
    context.addPath(path)
    context.clip()
    linearGradient(colors, start: start, end: end)
    context.restoreGState()
}

// The v0.7.1 glyph occupied too little of the icon. Scale the artwork
// (but never the full-bleed blue background) by 20% around the canvas center.
context.saveGState()
context.translateBy(x: 512, y: 512)
context.scaleBy(x: 1.20, y: 1.20)
context.translateBy(x: -512, y: -512)

// Rails sit behind the body and survive scaling to the Dynamic Island.
context.saveGState()
context.setStrokeColor(rgba(0xFFFFFF, alpha: 0.91))
context.setLineCap(.round)
context.setLineJoin(.round)
context.setLineWidth(43)
context.move(to: CGPoint(x: 414, y: 335))
context.addLine(to: CGPoint(x: 351, y: 224))
context.move(to: CGPoint(x: 610, y: 335))
context.addLine(to: CGPoint(x: 673, y: 224))
context.strokePath()
context.setLineWidth(29)
context.move(to: CGPoint(x: 414, y: 232))
context.addLine(to: CGPoint(x: 610, y: 232))
context.strokePath()
context.restoreGState()

// One rounded, front-facing train silhouette with a soft true drop shadow.
let trainBody = roundedRect(CGRect(x: 300, y: 294, width: 424, height: 476), radius: 96)
context.saveGState()
context.setShadow(
    offset: CGSize(width: 0, height: -11),
    blur: 30,
    color: rgba(0x064FA9, alpha: 0.27)
)
fillPath(trainBody, color: rgba(0xFFFFFF))
context.restoreGState()

gradientFill(
    trainBody,
    colors: [rgba(0xFFFFFF), rgba(0xF4FBFF), rgba(0xCFE8FC)],
    start: CGPoint(x: 495, y: 776),
    end: CGPoint(x: 531, y: 292)
)
// A thin specular rim makes the white body feel gently embossed at small sizes.
context.setStrokeColor(rgba(0xFFFFFF, alpha: 0.86))
context.setLineWidth(4)
context.addPath(trainBody)
context.strokePath()

// Narrow glossy rim on the upper shell. No extra backing disc.
let shellHighlight = roundedRect(CGRect(x: 332, y: 732, width: 360, height: 18), radius: 9)
gradientFill(
    shellHighlight,
    colors: [rgba(0xFFFFFF, alpha: 0.48), rgba(0xFFFFFF, alpha: 0.06)],
    start: CGPoint(x: 348, y: 752),
    end: CGPoint(x: 683, y: 730)
)

// A compact destination strip without text.
let routeBar = roundedRect(CGRect(x: 427, y: 715, width: 170, height: 35), radius: 17)
gradientFill(
    routeBar,
    colors: [rgba(0x98E8FF), rgba(0x45B6F8)],
    start: CGPoint(x: 475, y: 750),
    end: CGPoint(x: 550, y: 715)
)

// Recessed windscreen with a restrained glass reflection.
let window = roundedRect(CGRect(x: 342, y: 465, width: 340, height: 215), radius: 57)
gradientFill(
    window,
    colors: [rgba(0xA4EDFC), rgba(0x68CEF9), rgba(0x2E9DEB)],
    start: CGPoint(x: 370, y: 680),
    end: CGPoint(x: 656, y: 462)
)
let glassHighlight = roundedRect(CGRect(x: 365, y: 611, width: 284, height: 42), radius: 21)
gradientFill(
    glassHighlight,
    colors: [rgba(0xFFFFFF, alpha: 0.38), rgba(0xFFFFFF, alpha: 0.00)],
    start: CGPoint(x: 365, y: 650),
    end: CGPoint(x: 650, y: 610)
)

// Simple headlamps with a slight highlight, no extra backing shape.
for cx in [CGFloat(397), CGFloat(627)] {
    let headlight = CGPath(
        ellipseIn: CGRect(x: cx - 34, y: 351, width: 68, height: 68),
        transform: nil
    )
    gradientFill(
        headlight,
        colors: [rgba(0x73DFFC), rgba(0x328FE8)],
        start: CGPoint(x: cx - 18, y: 419),
        end: CGPoint(x: cx + 22, y: 351)
    )
    context.setStrokeColor(rgba(0xF3FCFF, alpha: 0.58))
    context.setLineWidth(2)
    context.addPath(headlight)
    context.strokePath()
}
// Close the foreground-only scaling transform.
context.restoreGState()

guard let image = context.makeImage() else {
    fatalError("Failed to rasterize icon")
}
let representation = NSBitmapImageRep(cgImage: image)
guard let pngData = representation.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode icon PNG")
}
try pngData.write(to: destination, options: .atomic)
print("Generated 1024x1024 AppIcon: \(destination.path) (\(pngData.count) bytes)")
