import SwiftUI
import AppIntents
import CoreImage
import CoreImage.CIFilterBuiltins

@main
struct TianfuGlassApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Label("天府通 · Glass v0.3.1", systemImage: "tram.fill")
                            .font(.title2.bold())

                        Text("此页面只显示离线演示二维码，不需要网络或账号。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TransitCodeSnippetView(
                            payload: "TIANFU-GLASS-V3-TEST-ONLY-NOT-VALID-FOR-TRAVEL",
                            lifetime: 60,
                            demo: true
                        )
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("快捷指令诊断步骤").font(.headline)
                            Text("1. 新建空白快捷指令，单独运行「Glass 诊断 A · 纯文字」。")
                            Text("2. 如果能看见文字，再运行「Glass 诊断 B · 测试二维码」。")
                            Text("3. 两项都成功后，再把 result.code 传入「显示天府通乘车码 V3」。")
                            Text("如果顶部只有 Done，请保留截图和 iOS 版本，不要先输入真实凭证。")
                        }
                        .font(.subheadline)
                        .padding(16)
                        .glassEffect(.regular, in: .rect(cornerRadius: 20))
                    }
                    .padding(20)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
    }
}

enum QRCodeRenderer {
    static func makeCGImage(_ payload: String) -> CGImage? {
        let generator = CIFilter.qrCodeGenerator()
        generator.message = Data(payload.utf8)
        generator.correctionLevel = "M"
        guard let output = generator.outputImage else { return nil }
        return CIContext().createCGImage(output, from: output.extent.integral)
    }
}

struct TransitCodeSnippetView: View {
    let payload: String
    let lifetime: Int
    let demo: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "tram.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 30, height: 30)
                    .glassEffect(.regular, in: .circle)
                Text(demo ? "天府通 · 演示二维码" : "天府通乘车码")
                    .font(.system(size: 16, weight: .semibold))
                Spacer(minLength: 0)
            }

            if let image = QRCodeRenderer.makeCGImage(payload) {
                Image(decorative: image, scale: 1, orientation: .up)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 196, height: 196)
                    .padding(22)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(demo ? "演示二维码，不能用于乘车" : "天府通乘车二维码")
            } else {
                Label("二维码生成失败", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .frame(height: 196)
            }

            HStack(spacing: 6) {
                Image(systemName: demo ? "checkmark.shield" : "clock")
                Text(demo ? "演示数据 · 不能用于乘车" : "有效期约 \(lifetime) 秒")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .frame(maxWidth: 320)
    }
}
