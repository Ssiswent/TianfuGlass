import AppIntents
import Foundation

/// One-tap, parameter-free shortcut registered by the app. The existing
/// parameterized V3 actions are intentionally retained for compatibility.
struct FetchFreshTransitCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "获取天府通乘车码"
    static let description = IntentDescription("由天府通 Glass 自动联网取码，并直接显示系统悬浮乘车二维码。")
    static var supportedModes: IntentModes { .background }

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        let code = try await TransitCodeAPIClient.fetchCode()
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(
                payload: code,
                demo: false
            )
        )
    }
}

/// Offline demonstration ensures the system entrypoint works before live
/// cookie setup and server-specific behavior are tested.
struct PreviewTransitCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "演示天府通乘车码"
    static let description = IntentDescription("不联网、不使用登录信息，测试自动注册的乘车码悬浮弹窗。")
    static var supportedModes: IntentModes { .background }

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(
                payload: "TIANFU-GLASS-DEMO-CODE-NOT-VALID-FOR-TRAVEL",
                demo: true
            )
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
    }
}
