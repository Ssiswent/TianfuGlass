import SwiftUI
import AppIntents
import CoreImage
import CoreImage.CIFilterBuiltins

private let diagnosticPayload = "TIANFU-GLASS-V3-TEST-ONLY-NOT-VALID-FOR-TRAVEL"

@main
struct TianfuGlassApp: App {
    var body: some Scene {
        WindowGroup {
            TianfuGlassHomeView()
        }
    }
}

private enum DiagnosticSheet: String, Identifiable {
    case text, qr
    var id: String { rawValue }
}

private struct TianfuGlassHomeView: View {
    @State private var activeSheet: DiagnosticSheet?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Label("天府通 · Glass v0.7.1", systemImage: "tram.fill")
                        .font(.title2.bold())

                    Text("运行快捷指令即可显示乘车码，无需先打开此 App。真实 Cookie 和接口请求仍留在你自己的快捷指令中。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("快捷指令接入", systemImage: "bolt.fill")
                            .font(.headline)
                        Text("① 请求接口并取得 result.code。")
                        Text("② 添加新版「显示天府通乘车码」，将唯一的「乘车码内容」设为 code。")
                        Text("③ 每次需要新乘车码，重新运行快捷指令即可。旧版 V3 仍然兼容已有快捷指令。")
                        Text("提示：Snippet 的出现位置、Done 按钮和系统动画由 iOS 控制。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 12) {
                        Label("离线测试 · App 原生弹窗", systemImage: "rectangle.on.rectangle")
                            .font(.headline)
                        Text("检验 SwiftUI 渲染。这里是 App 自己展示的 sheet，不代表系统 Snippet 能正常工作。")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button {
                            activeSheet = .text
                        } label: {
                            Label("测试 1 · 打开文字弹窗", systemImage: "text.bubble")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)

                        Button {
                            activeSheet = .qr
                        } label: {
                            Label("测试 2 · 打开二维码弹窗", systemImage: "qrcode")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glass)
                    }
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 12) {
                        Label("离线测试 · App Intent", systemImage: "bolt.horizontal.circle")
                            .font(.headline)
                        Text("尝试由系统呈现 Snippet。按钮运行 Intent，但系统是否展示结果由触发场景决定。")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button(intent: GlassPlainTextDiagnosticIntent()) {
                            Label("测试 3 · SnippetIntent 文字", systemImage: "text.alignleft")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glass)

                        Button(intent: GlassQRDiagnosticIntent()) {
                            Label("测试 4 · SnippetIntent 二维码", systemImage: "qrcode.viewfinder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glass)

                        Button(intent: GlassDirectViewDiagnosticIntent()) {
                            Label("测试 5 · 直接返回视图", systemImage: "rectangle.stack")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glass)
                    }
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("诊断说明").font(.headline)
                        Text("A、C、D 和 B 已分别通过快捷指令真机测试。")
                        Text("推荐使用「显示天府通乘车码」（仅需 code），首次请用无敏感信息的测试字符串验证。")
                        Text("不要公开分享包含 Cookie、会话令牌或真实乘车码的快捷指令。")
                    }
                    .font(.subheadline)
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .sheet(item: $activeSheet) { test in
                NavigationStack {
                    Group {
                        switch test {
                        case .text:
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.green)
                                Text("SwiftUI 文字弹窗测试成功")
                                    .font(.headline)
                                Text("这是 App 的 sheet，并不是 App Intents Snippet。")
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(24)
                        case .qr:
                            TransitCodeSnippetView(payload: diagnosticPayload, demo: true)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(12)
                        }
                    }
                    .navigationTitle(test == .text ? "文字弹窗测试" : "二维码弹窗测试")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("关闭", systemImage: "xmark") { activeSheet = nil }
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                .presentationDetents([.height(test == .text ? 280 : 390)])
                .presentationDragIndicator(.visible)
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

            if demo {
                Label("演示数据 · 不能用于乘车", systemImage: "checkmark.shield")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .frame(maxWidth: 320)
    }
}
