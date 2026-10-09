import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

/// A small, immutable bitmap of QR modules, generated before we hand a
/// snippet view to the system. No CGImage / CIContext work runs in View.body.
struct QRCodeMatrix: Sendable {
    let side: Int
    let dark: [Bool]

    static func encode(_ payload: String) -> QRCodeMatrix? {
        guard !payload.isEmpty else { return nil }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }

        let bounds = output.extent.integral
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        guard width == height, width >= 21, width <= 177 else { return nil }

        let bytesPerRow = width * 4
        var rgba = [UInt8](repeating: 255, count: bytesPerRow * height)
        let context = CIContext()
        rgba.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            context.render(
                output,
                toBitmap: baseAddress,
                rowBytes: bytesPerRow,
                bounds: bounds,
                format: .RGBA8,
                colorSpace: CGColorSpaceCreateDeviceRGB()
            )
        }

        // Black QR cells have near-zero RGB, white cells have near-255 RGB.
        var cells: [Bool] = []
        cells.reserveCapacity(width * height)
        for row in 0 ..< height {
            for col in 0 ..< width {
                cells.append(rgba[row * bytesPerRow + col * 4] < 128)
            }
        }
        return QRCodeMatrix(side: width, dark: cells)
    }
}

/// QR modules are drawn as one SwiftUI Shape rather than an Image backed by
/// a dynamically created CGImage. Four modules of quiet zone are retained.
struct QRCodeModulesShape: Shape {
    let matrix: QRCodeMatrix

    func path(in rect: CGRect) -> Path {
        let quietZone = 4
        let cellsPerSide = matrix.side + quietZone * 2
        let moduleLength = floor(min(rect.width, rect.height) / CGFloat(cellsPerSide))
        guard moduleLength > 0 else { return Path() }

        let paintedLength = moduleLength * CGFloat(cellsPerSide)
        let left = rect.midX - paintedLength / 2
        let top = rect.midY - paintedLength / 2
        var path = Path()

        for row in 0 ..< matrix.side {
            for col in 0 ..< matrix.side {
                guard matrix.dark[row * matrix.side + col] else { continue }
                path.addRect(
                    CGRect(
                        x: left + CGFloat(col + quietZone) * moduleLength,
                        y: top + CGFloat(row + quietZone) * moduleLength,
                        width: moduleLength,
                        height: moduleLength
                    )
                )
            }
        }
        return path
    }
}

/// Narrow, stable snippet layout. Snippet overlays are placed by iOS; this
/// view only defines their contents and never draws glass over QR modules.
struct VectorTransitCodeSnippetView: View {
    let matrix: QRCodeMatrix
    let demo: Bool

    var body: some View {
        VStack(spacing: 9) {
            // Avoid interactive glass in a Snippet View archive.
            // On-device logs reported UIPlatformGlassInteractionRepresentable
            // archive encoding failure when the main app was already running.
            Image(systemName: "tram.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(Color.primary.opacity(0.10))
                }
                .accessibilityLabel("天府通乘车码")
                .frame(maxWidth: .infinity, alignment: .center)

            QRCodeModulesShape(matrix: matrix)
                .fill(Color.black)
                .frame(width: 228, height: 228)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: .infinity)
                .accessibilityLabel(demo ? "不能用于乘车的演示二维码" : "天府通乘车二维码")

            if demo {
                Label("离线演示 · 不可乘车", systemImage: "checkmark.shield")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(12)
        .frame(maxWidth: 320)
    }
}
