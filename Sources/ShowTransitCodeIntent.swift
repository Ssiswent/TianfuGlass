import AppIntents
import Foundation
import SwiftUI

/// The only discoverable Shortcut action. The HTTP request stays in Shortcuts.
struct ShowTransitCodeSimpleIntent: AppIntent {
    static let title: LocalizedStringResource = "显示天府通乘车码"
    static let description = IntentDescription("显示快捷指令提供的乘车二维码，无需打开 App。")
    static let openAppWhenRun = false
    static let isDiscoverable = true

    @Parameter(title: "乘车码内容", description: "传入接口响应中 result.code 的原始字符串。")
    var payload: String

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        try TransitCodePayloadValidation.check(payload)
        return .result(
            snippetIntent: TransitCodePresentationSnippetIntent(payload: payload)
        )
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

enum TransitCodeError: LocalizedError {
    case emptyPayload
    case payloadTooLong
    case qrGenerationFailed

    var errorDescription: String? {
        switch self {
        case .emptyPayload:
            "没有收到乘车码内容，请检查 result.code。"
        case .payloadTooLong:
            "二维码文本超过 2000 字节，不能直接生成。"
        case .qrGenerationFailed:
            "无法生成二维码，请检查传入的内容。"
        }
    }
}
