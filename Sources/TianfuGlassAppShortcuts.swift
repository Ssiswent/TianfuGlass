import AppIntents
import Foundation
import SwiftUI

/// App Shortcuts directly return a static view. v0.8.0's nested SnippetIntent
/// showed only Done when launched by the built-in Shortcuts entrypoint on iOS 27.
/// Keep the old nested V3 intent for existing user-created shortcuts.
struct FetchFreshTransitCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "获取天府通乘车码"
    static let description = IntentDescription("由天府通 Glass 自动联网取码，直接显示系统悬浮乘车二维码。")
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let code = try await TransitCodeAPIClient.fetchCode()
        guard let matrix = QRCodeMatrix.encode(code) else {
            throw TransitCodeError.qrGenerationFailed
        }
        return .result(view: VectorTransitCodeSnippetView(matrix: matrix, demo: false))
    }
}

/// Offline demonstration uses the same direct-view path as the real shortcut.
struct PreviewTransitCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "演示天府通乘车码"
    static let description = IntentDescription("无需网络或 Cookie，验证原生悬浮二维码显示。")
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let matrix = QRCodeMatrix.encode(
            "TIANFU-GLASS-DEMO-CODE-NOT-VALID-FOR-TRAVEL"
        ) else {
            throw TransitCodeError.qrGenerationFailed
        }
        return .result(view: VectorTransitCodeSnippetView(matrix: matrix, demo: true))
    }
}

struct TianfuGlassShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FetchFreshTransitCodeIntent(),
            phrases: [
                "使用\(.applicationName)获取乘车码",
                "用\(.applicationName)显示天府通乘车码"
            ],
            shortTitle: "获取乘车码",
            systemImageName: "tram.fill"
        )
        AppShortcut(
            intent: PreviewTransitCodeIntent(),
            phrases: [
                "用\(.applicationName)演示乘车码"
            ],
            shortTitle: "演示乘车码",
            systemImageName: "qrcode"
        )
        // Independent control: if both this and the QR view show only Done,
        // the host is dropping views rather than the QR renderer failing.
        AppShortcut(
            intent: GlassDirectViewDiagnosticIntent(),
            phrases: [
                "用\(.applicationName)测试文字显示"
            ],
            shortTitle: "诊断文字弹窗",
            systemImageName: "text.bubble"
        )
    }
}
