import AppIntents
import Foundation
import SwiftUI

/// Records ONLY the phase of a diagnostic App Intent, never HTTP data,
/// cookies, API responses, user identifiers, or the QR contents.
/// This intentionally persists to the app's local UserDefaults so a user can
/// inspect execution status even if Shortcuts shows an empty Done-only sheet.
@MainActor
enum TransitRecoveryStatus {
    enum Channel: String, CaseIterable {
        case text = "恢复文字"
        case demo = "恢复演示码"
        case live = "恢复真实码"
    }

    static func record(_ channel: Channel, _ phase: String) {
        let value = "\(Date().formatted(date: .numeric, time: .standard)) · \(phase)"
        UserDefaults.standard.set(value, forKey: key(channel))
    }

    static func read(_ channel: Channel) -> String {
        UserDefaults.standard.string(forKey: key(channel)) ?? "尚未执行"
    }

    private static func key(_ channel: Channel) -> String {
        "TianfuGlass.RecoveryStatus.\(channel.rawValue)"
    }
}

/// A brand-new intent identity, so a failing old App Shortcut does not
/// confound on-device diagnosis of the system's discovery/presentation state.
struct RecoveryTextSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "恢复验证 · 文字"
    static let description = IntentDescription("离线测试：全新系统操作的文字 Snippet。")
    static let isDiscoverable = true
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        TransitRecoveryStatus.record(.text, "执行成功，已向系统返回文字视图")
        return .result(
            view: VStack(spacing: 10) {
                Label("新的快捷操作已执行", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                Text("文字显示恢复验证 · 不涉及网络")
                    .font(.subheadline)
            }
            .padding(16)
        )
    }
}

struct RecoveryDemoSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "恢复验证 · 演示二维码"
    static let description = IntentDescription("离线测试：采用全新 Intent 标识但复用已验证的二维码视图。")
    static let isDiscoverable = true
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        TransitRecoveryStatus.record(.demo, "已开始执行")
        guard let matrix = QRCodeMatrix.encode(
            "TIANFU-GLASS-RECOVERY-DEMO-NOT-VALID-FOR-TRAVEL"
        ) else {
            TransitRecoveryStatus.record(.demo, "二维码生成失败")
            throw TransitCodeError.qrGenerationFailed
        }
        TransitRecoveryStatus.record(.demo, "二维码已生成，已向系统返回视图")
        return .result(view: VectorTransitCodeSnippetView(matrix: matrix, demo: true))
    }
}

/// The live recovery entry does exactly the same API call as the original
/// FetchFreshTransitCodeIntent. Running this is an explicit user action:
/// nothing is fetched automatically when installing or opening the app.
struct RecoveryLiveSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "恢复验证 · 获取乘车码"
    static let description = IntentDescription("由全新快捷操作获取新乘车码，确认是否受到旧操作缓存影响。")
    static let isDiscoverable = true
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        TransitRecoveryStatus.record(.live, "已开始执行，准备请求 API")
        let code: String
        do {
            code = try await TransitCodeAPIClient.fetchCode()
        } catch {
            TransitRecoveryStatus.record(.live, "请求失败，未返回二维码视图")
            throw error
        }
        TransitRecoveryStatus.record(.live, "API 请求成功，准备生成二维码")
        guard let matrix = QRCodeMatrix.encode(code) else {
            TransitRecoveryStatus.record(.live, "二维码生成失败")
            throw TransitCodeError.qrGenerationFailed
        }
        TransitRecoveryStatus.record(.live, "二维码已生成，已向系统返回视图")
        return .result(view: VectorTransitCodeSnippetView(matrix: matrix, demo: false))
    }
}

/// Read-only diagnostic display. No network request or sensitive information.
struct TransitRecoveryDiagnosticsView: View {
    @State private var textStatus = "尚未检查"
    @State private var demoStatus = "尚未检查"
    @State private var liveStatus = "尚未检查"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("系统快捷操作 · 执行诊断", systemImage: "stethoscope")
                .font(.headline)

            Text("如果快捷指令只有 Done，可回到此页面查看是否已生成并提交视图。这里不记录 Cookie、接口内容或二维码。")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("文字", value: textStatus)
                LabeledContent("演示码", value: demoStatus)
                LabeledContent("正式码", value: liveStatus)
            }
            .font(.caption)

            Button {
                refresh()
            } label: {
                Label("刷新执行状态", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)

            Text("注意：「已向系统返回视图」不代表系统真的把视图显示出来。请以屏幕上的内容为准。")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
        .onAppear(perform: refresh)
    }

    private func refresh() {
        textStatus = TransitRecoveryStatus.read(.text)
        demoStatus = TransitRecoveryStatus.read(.demo)
        liveStatus = TransitRecoveryStatus.read(.live)
    }
}
