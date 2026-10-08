import SwiftUI

/// TianfuGlass is a display-only companion for the user's Shortcuts.
/// It never fetches transit codes, manages sessions, or stores QR payloads.
@main
struct TianfuGlassApp: App {
    var body: some Scene {
        WindowGroup {
            TianfuGlassHomeView()
        }
    }
}

private struct TianfuGlassHomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Label("天府通 · Glass", systemImage: "tram.fill")
                        .font(.title2.bold())

                    Text("用于通过 iPhone「快捷指令」显示原生悬浮乘车二维码。此 App 不联网取码，也不需要登录。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Label("在快捷指令中使用", systemImage: "bolt.fill")
                            .font(.headline)
                        Text("1. 在你自己的快捷指令中取得乘车码原始内容（例如 result.code）。")
                        Text("2. 添加「显示天府通乘车码」操作，将「乘车码内容」设为上一步返回的原始文本。")
                        Text("3. 运行快捷指令即可由 iOS 显示二维码，无需先打开 TianfuGlass。")
                        Text("旧版「显示天府通乘车码 V3」操作继续兼容已有快捷指令。")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    Text("二维码不在 App 内保存；悬浮窗口位置、展开动画和 Done 按钮由 iOS 系统控制。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}
