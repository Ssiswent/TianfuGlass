import AppIntents
import Foundation
import SwiftUI

/// The QR-producing App Shortcut must itself be a SnippetIntent.
/// On iOS 27, the direct-view AppIntent path showed only Done, while
/// PreviewTransitCodeIntent (SnippetIntent) displayed the complete QR view
/// in the user's v0.8.2 on-device tests. Preserve the request/QR pipeline.
struct FetchFreshTransitCodeIntent: SnippetIntent {
    static let title: LocalizedStringResource = "获取天府通乘车码"
    static let description = IntentDescription("由天府通 Glass 自动联网取码，直接显示系统悬浮乘车二维码。")
    static let isDiscoverable = true
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

/// Offline demonstration is explicitly a SnippetIntent: the previously
/// working user-created QR shortcut was hosted using a SnippetIntent.
struct PreviewTransitCodeIntent: SnippetIntent {
    static let title: LocalizedStringResource = "演示天府通乘车码"
    static let description = IntentDescription("无需网络或 Cookie，验证原生悬浮二维码显示。")
    static let isDiscoverable = true
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

/// Deliberately minimal control: separates QR Shape serialization from
/// the native glass icon and surrounding layout. Never carries a real code.
struct PlainQRShapeDiagnosticIntent: SnippetIntent {
    static let title: LocalizedStringResource = "诊断基础二维码"
    static let description = IntentDescription("离线对照：只绘制二维码和简单文字，不包含 Liquid Glass。")
    static let isDiscoverable = true
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let matrix = QRCodeMatrix.encode(
            "TIANFU-GLASS-PLAIN-QR-DIAGNOSTIC-NOT-VALID"
        ) else {
            throw TransitCodeError.qrGenerationFailed
        }
        return .result(
            view: VStack(spacing: 8) {
                Text("二维码渲染诊断")
                    .font(.headline)
                QRCodeModulesShape(matrix: matrix)
                    .fill(.black)
                    .frame(width: 228, height: 228)
                    .background(.white, in: RoundedRectangle(cornerRadius: 10))
                Text("离线演示 · 不能用于乘车")
                    .font(.caption)
            }
            .padding(12)
        )
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
        AppShortcut(
            intent: PlainQRShapeDiagnosticIntent(),
            phrases: [
                "用\(.applicationName)测试基础二维码"
            ],
            shortTitle: "诊断基础二维码",
            systemImageName: "qrcode.viewfinder"
        )
        AppShortcut(
            intent: InlineLoadingDiagnosticIntent(),
            phrases: [
                "用\(.applicationName)测试原位加载"
            ],
            shortTitle: "诊断原位加载",
            systemImageName: "hourglass"
        )
        AppShortcut(
            intent: ReloadLoadingDemoLauncherIntent(),
            phrases: [
                "用\(.applicationName)测试重载加载"
            ],
            shortTitle: "诊断重载加载",
            systemImageName: "arrow.clockwise"
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
