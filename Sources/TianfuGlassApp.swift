import SwiftUI
import UIKit

@main
struct TianfuGlassApp: App {
    var body: some Scene {
        WindowGroup {
            TianfuGlassHomeView()
        }
    }
}

private struct TianfuGlassHomeView: View {
    private let cookieExample = "TGT=xxx; CNZZDATA1280142547=xxx; BA31C2997F81913F=xxx; UM_distinctid=xxx;"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("天府通乘车码")
                            .font(.title2.bold())

                        Text("通过快捷指令直接显示乘车二维码，无需预先打开 App。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 12) {
                        Label("快捷指令使用方法", systemImage: "bolt.fill")
                            .font(.headline)

                        Text("1. 在「获取 URL 内容」中请求接口，并在请求头的 Cookie 字段填写有效值。")
                        Text("2. 从接口响应中提取 result.code 原始字符串。")
                        Text("3. 添加「显示天府通乘车码」，将「乘车码内容」设置为 result.code。")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Label("Cookie 请求头格式", systemImage: "key.horizontal")
                                .font(.headline)

                            Spacer(minLength: 0)

                            Button {
                                UIPasteboard.general.string = cookieExample
                            } label: {
                                Label("复制示例", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.glass)
                            .font(.caption)
                        }

                        Text("将 xxx 替换为你自己的有效值：")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("""
                        TGT=xxx;
                        CNZZDATA1280142547=xxx;
                        BA31C2997F81913F=xxx;
                        UM_distinctid=xxx;
                        """)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            Color.primary.opacity(0.05),
                            in: RoundedRectangle(cornerRadius: 12)
                        )

                        Text("换行仅为方便阅读；点击「复制示例」会得到单行 Cookie 值，用于快捷指令的 HTTP 请求头。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    Text("Cookie 属于敏感凭据，请只保存在自己的设备上，不要公开分享快捷指令或截图。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("天府通 Glass")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
