import AppIntents
import Foundation
import SwiftUI

/// Preferred Shortcuts action: receive the raw QR payload supplied by the
/// user's Shortcut. This application does not request or store transit data.
struct ShowTransitCodeSimpleIntent: AppIntent {
    static let title: LocalizedStringResource = "显示天府通乘车码"
    static let description = IntentDescription("把快捷指令传入的原始文本显示为原生悬浮二维码，不打开 App。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    @Parameter(title: "乘车码内容", description: "传入二维码原始内容，例如快捷指令获取的 result.code。")
    var payload: String

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        try TransitCodePayloadValidation.check(payload)
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(payload: payload)
        )
    }
}

/// Backwards-compatible action for existing V3 Shortcuts. The lifetime
/// parameter is accepted but isn't shown; the app never requests a new code.
struct ShowTransitCodeIntent: AppIntent {
    static let title: LocalizedStringResource = "显示天府通乘车码 V3"
    static let description = IntentDescription("兼容旧版快捷指令的二维码内容与有效期参数。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    @Parameter(title: "乘车码内容", description: "二维码原始文本。")
    var payload: String

    @Parameter(title: "有效期（秒）", default: 60)
    var expiresIn: Int

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        try TransitCodePayloadValidation.check(payload)
        guard (1...3_600).contains(expiresIn) else {
            throw TransitCodeError.invalidLifetime
        }
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(payload: payload)
        )
    }
}

/// Preserve the already-proven two-stage AppIntent → SnippetIntent
/// presentation path. The system owns the overlay, its Done button and
/// animation; no app screen needs to be opened.
struct TransitCodePresentationSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "天府通乘车码 Snippet"
    static let isDiscoverable = false

    @Parameter(title: "二维码内容")
    var payload: String

    init() {}

    init(payload: String) {
        self.payload = payload
    }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let matrix = QRCodeMatrix.encode(payload) else {
            throw TransitCodeError.qrGenerationFailed
        }
        return .result(view: VectorTransitCodeSnippetView(matrix: matrix))
    }
}

enum TransitCodePayloadValidation {
    static func check(_ payload: String) throws {
        guard !payload.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TransitCodeError.emptyPayload
        }
        guard payload.utf8.count <= 2_000 else {
            throw TransitCodeError.payloadTooLong
        }
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
            "没有收到二维码内容，请检查快捷指令传入的参数。"
        case .payloadTooLong:
            "二维码文本超过 2000 字节，不能直接生成。"
        case .invalidLifetime:
            "有效期必须介于 1～3600 秒之间，请检查旧版 expiresIn 参数。"
        case .qrGenerationFailed:
            "Core Image 未能生成二维码，请检查输入文本。"
        }
    }
}
