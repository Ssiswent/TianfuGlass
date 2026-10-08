import SwiftUI

/// Credential entry is the one-time foreground setup. The saved value is
/// never echoed back to the screen or passed as an App Shortcut parameter.
struct TransitCookieSettingsView: View {
    @State private var cookieInput = ""
    @State private var configured = false
    @State private var feedback: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("登录会话", systemImage: "lock.shield")
                .font(.headline)

            Text("首次使用请从自己登录后的官方请求中复制 Cookie 字符串，保存在本机钥匙串。不要输入到快捷指令参数或上传 GitHub。")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            SecureField("粘贴完整 Cookie（包含 TGT=…）", text: $cookieInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .privacySensitive()
                .padding(12)
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 10) {
                Button {
                    do {
                        try TransitCookieStore.save(cookieInput)
                        cookieInput = ""
                        configured = true
                        feedback = "登录会话已保存，可以从 Spotlight 或 Siri 直接获取乘车码。"
                    } catch {
                        feedback = error.localizedDescription
                    }
                } label: {
                    Label("保存 Cookie", systemImage: "checkmark.shield")
                }
                .buttonStyle(.glassProminent)
                .disabled(cookieInput.isEmpty)

                Button(role: .destructive) {
                    do {
                        try TransitCookieStore.clear()
                        configured = false
                        cookieInput = ""
                        feedback = "已清除本机保存的登录会话。"
                    } catch {
                        feedback = error.localizedDescription
                    }
                } label: {
                    Text("清除")
                }
                .buttonStyle(.glass)
                .disabled(!configured)
            }

            Label(
                configured ? "已在本机保存会话（不会显示原文）" : "未配置登录会话",
                systemImage: configured ? "checkmark.circle" : "circle.dotted"
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            if let feedback {
                Text(feedback)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("如果登录失效，请重新获取官方会话并在此覆盖保存。当前版本不支持自动续期。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
        .task {
            configured = TransitCookieStore.hasCookie()
        }
    }
}
