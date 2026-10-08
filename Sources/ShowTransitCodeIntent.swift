import AppIntents
import Foundation
import SwiftUI

struct ShowTransitCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "显示天府通乘车码 V3"
    static let description = IntentDescription("显示由快捷指令传入的二维码字符串，不读取或保存登录 Cookie。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    @Parameter(title: "乘车码内容", description: "传入接口返回的 result.code 原文。")
    var payload: String

    @Parameter(title: "有效期（秒）", default: 60)
    var expiresIn: Int

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        let code = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else { throw TransitCodeError.emptyPayload }
        guard code.utf8.count <= 2_000 else { throw TransitCodeError.payloadTooLong }
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(
                payload: code,
                lifetime: min(max(expiresIn, 1), 3_600),
                demo: false
            )
        )
    }
}

struct TransitCodePresentationSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "天府通乘车码 Snippet"
    static let isDiscoverable = false

    @Parameter(title: "二维码内容")
    var payload: String

    @Parameter(title: "有效期")
    var lifetime: Int

    @Parameter(title: "演示模式")
    var demo: Bool

    init() {}

    init(payload: String, lifetime: Int, demo: Bool) {
        self.payload = payload
        self.lifetime = lifetime
        self.demo = demo
    }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(view: TransitCodeSnippetView(
            payload: payload,
            lifetime: lifetime,
            demo: demo
        ))
    }
}

struct GlassPlainTextDiagnosticIntent: AppIntent {
    static let title: LocalizedStringResource = "Glass 诊断 A · 纯文字"
    static let openAppWhenRun = false
    static let isDiscoverable = true

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        return .result(snippetIntent: GlassPlainTextSnippetIntent())
    }
}

struct GlassPlainTextSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Glass 诊断文字 Snippet"
    static let isDiscoverable = false

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(view:
            VStack(alignment: .leading, spacing: 10) {
                Label("GLASS V3 · 测试通过", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                Text("如果看见这两行文字，说明系统已显示自定义 Snippet 视图。")
                    .font(.subheadline)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}

struct GlassQRDiagnosticIntent: AppIntent {
    static let title: LocalizedStringResource = "Glass 诊断 B · 测试二维码"
    static let openAppWhenRun = false
    static let isDiscoverable = true

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(
                payload: "TIANFU-GLASS-V3-TEST-ONLY-NOT-VALID-FOR-TRAVEL",
                lifetime: 60,
                demo: true
            )
        )
    }
}

enum TransitCodeError: LocalizedError {
    case emptyPayload
    case payloadTooLong

    var errorDescription: String? {
        switch self {
        case .emptyPayload:
            "没有收到乘车码内容，请检查 result.code。"
        case .payloadTooLong:
            "二维码文本超过 2000 字节，不能直接生成。"
        }
    }
}

    
/// A third, deliberately minimal diagnostic that returns a static snippet
/// directly, without chaining a secondary SnippetIntent.
struct GlassDirectViewDiagnosticIntent: AppIntent {
    static let title: LocalizedStringResource = "Glass 诊断 C · 直接返回文字"
    static let description = IntentDescription("离线诊断：直接返回一段 SwiftUI 文本，不请求二维码接口。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: VStack(alignment: .leading, spacing: 8) {
                Label("GLASS DIRECT VIEW · 测试通过", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                Text("这是直接返回的静态 SwiftUI Snippet。")
                    .font(.subheadline)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}
