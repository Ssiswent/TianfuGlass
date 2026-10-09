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
    // An example only: do not read or store the user's actual Cookie.
    private let cookieExample = "TGT=xxx; CNZZDATA1280142547=xxx; BA31C2997F81913F=xxx; UM_distinctid=xxx;"
    @State private var exampleCopied = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.primary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("天府通乘车码")
                                .font(.title3.bold())
                            Text("配置快捷指令后，即可直接显示乘车二维码。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 13) {
                        Label("快捷指令设置", systemImage: "bolt.fill")
                            .font(.headline)

                        Text("1. 在已有的天府通快捷指令中，将 Cookie 文本替换为有效值；其他接口步骤无需修改。")
                        Text("2. 在「如果 字典值 有任何值」的成功分支中，添加「显示天府通乘车码」。")
                        Text("3. 将「乘车码内容」选为「字典值」，开启「运行时显示」。")
                        Text("4. 在「否则」分支中添加「提示更新 Cookie」。")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 13) {
                        HStack(spacing: 8) {
                            Label("Cookie 填写格式", systemImage: "key.horizontal")
                                .font(.headline)

                            Spacer(minLength: 0)

                            Button {
                                UIPasteboard.general.string = cookieExample
                                exampleCopied = true
                            } label: {
                                Label(
                                    exampleCopied ? "已复制" : "复制格式",
                                    systemImage: exampleCopied ? "checkmark" : "doc.on.doc"
                                )
                            }
                            .buttonStyle(.glass)
                            .font(.caption)
                        }

                        Text("将每个 xxx 替换为自己的有效 Cookie 值：")
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

                        Text("复制的格式为单行文本；请粘贴到快捷指令原有的 Cookie 文本位置。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))

                    Text("Cookie 是敏感凭据。请勿分享包含真实 Cookie 的快捷指令或截图。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("天府通 Glass")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
