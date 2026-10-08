import AppIntents
import Foundation
import SwiftUI

struct ShowTransitCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "显示天府通乘车码 V3"
    static let description = IntentDescription("接收快捷指令提供的 result.code 原文和有效期，不需要打开 App。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    @Parameter(title: "乘车码内容", description: "传入接口返回的 result.code 原文。")
    var payload: String

    @Parameter(title: "有效期（秒）", default: 60)
    var expiresIn: Int

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        // Check for a blank input without changing the raw QR payload.
        // Even whitespace or a trailing newline can change a QR's contents.
        guard !payload.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TransitCodeError.emptyPayload
        }
        guard payload.utf8.count <= 2_000 else {
            throw TransitCodeError.payloadTooLong
        }
        guard (1...3_600).contains(expiresIn) else {
            throw TransitCodeError.invalidLifetime
        }
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(
                payload: payload,
                lifetime: expiresIn,
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
        guard let matrix = QRCodeMatrix.encode(payload) else {
            throw TransitCodeError.qrGenerationFailed
        }
        return .result(view: VectorTransitCodeSnippetView(
            matrix: matrix,
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
    case invalidLifetime
    case qrGenerationFailed

    var errorDescription: String? {
        switch self {
        case .emptyPayload:
            "没有收到乘车码内容，请检查 result.code。"
        case .payloadTooLong:
            "二维码文本超过 2000 字节，不能直接生成。"
        case .invalidLifetime:
            "有效期必须介于 1～3600 秒之间，请检查 expiresIn。"
        case .qrGenerationFailed:
            "Core Image 未能生成二维码，请检查输入文本。"
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


/// Differentiates SnippetIntent parameter transport from QR rendering.
struct GlassParameterizedTextDiagnosticIntent: AppIntent {
    static let title: LocalizedStringResource = "Glass 诊断 D · 参数化文字"
    static let description = IntentDescription("用固定示例字符串测试 SnippetIntent 的参数传递。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        return .result(
            snippetIntent: GlassParameterizedTextSnippetIntent(
                message: "GLASS-PARAMETER-TRANSFER-OK"
            )
        )
    }
}

struct GlassParameterizedTextSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "参数化文字 Snippet"
    static let isDiscoverable = false

    @Parameter(title: "诊断文本")
    var message: String

    init() {}

    init(message: String) {
        self.message = message
    }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(view:
            VStack(alignment: .leading, spacing: 6) {
                Text("参数化 Snippet 测试")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
            }
            .padding(16)

        )
    }
}
