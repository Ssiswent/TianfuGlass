import AppIntents
import SwiftUI

/// Add this action to the Otherwise branch of the existing Shortcut.
struct ShowCookieUpdateHintIntent: AppIntent {
    static let title: LocalizedStringResource = "提示更新 Cookie"
    static let description = IntentDescription("未取得乘车码时，使用系统 Snippet 提示检查并更新 Cookie。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        return .result(snippetIntent: CookieUpdateHintSnippetIntent())
    }
}

struct CookieUpdateHintSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "更新 Cookie 提示 Snippet"
    static let isDiscoverable = false

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(view: CookieUpdateHintSnippetView())
    }
}

/// Snippet views are archived by iOS. Rely on the system Liquid Glass
/// container; do not embed .glassEffect in the content view.
private struct CookieUpdateHintSnippetView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.orange)

            Text("乘车码获取失败")
                .font(.headline)

            Text("Cookie 可能已经失效，请在快捷指令中更新 Cookie 后重试。")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text("如果更新后仍然失败，请检查网络和接口响应。")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 320)
        .padding(20)
    }
}
