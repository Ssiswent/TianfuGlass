import AppIntents
import SwiftUI
import Foundation

// This file intentionally uses OFFLINE DEMO data only. It tests two ways
// of displaying a fixed-height loading card before touching the real API.

private let loadingDemoPayload = "TIANFU-GLASS-LOADING-TEST-NOT-VALID-FOR-TRAVEL"

/// Both phases occupy exactly the same nominal SwiftUI layout space.
/// The iOS Snippet host itself controls the presentation animation.
private struct FixedHeightQRLoadingView: View {
    let matrix: QRCodeMatrix
    let isReady: Bool

    var body: some View {
        VStack(spacing: 9) {
            Image(systemName: "tram.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background {
                    Circle().glassEffect(.regular, in: .circle)
                }
                .frame(maxWidth: .infinity, alignment: .center)

            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(Color.white)
                if isReady {
                    QRCodeModulesShape(matrix: matrix)
                        .fill(Color.black)
                        .frame(width: 228, height: 228)
                } else {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("正在准备演示乘车码")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 228, height: 228)
            .frame(maxWidth: .infinity)

            Text("离线演示 · 不可乘车")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .frame(maxWidth: 320)
    }
}

/// Test A: SwiftUI .task updates in place, without calling snippet reload.
/// Some Shortcuts hosts may snapshot the initial view and never observe state.
private struct SwiftUILocalLoadingDemoView: View {
    let matrix: QRCodeMatrix
    @State private var isReady = false

    var body: some View {
        FixedHeightQRLoadingView(matrix: matrix, isReady: isReady)
            .task {
                do {
                    try await Task.sleep(for: .seconds(2))
                    isReady = true
                } catch {
                    // Dismissal cancels the view's task. Never re-open a
                    // dismissed snippet or show a stale result.
                }
            }
    }
}

struct InlineLoadingDiagnosticIntent: SnippetIntent {
    static let title: LocalizedStringResource = "诊断原位加载"
    static let description = IntentDescription("离线测试：固定高度占位，约两秒后由 SwiftUI 原位更新二维码。")
    static let isDiscoverable = true
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let matrix = QRCodeMatrix.encode(loadingDemoPayload) else {
            throw TransitCodeError.qrGenerationFailed
        }
        return .result(view: SwiftUILocalLoadingDemoView(matrix: matrix))
    }
}

/// Test B: Apple-supported SnippetIntent.reload() rendering.
/// This proof of concept intentionally avoids any Cookie or real QR content.
@MainActor
private enum ReloadLoadingDemoStore {
    static var phases: [String: Bool] = [:]

    static func begin(_ id: String) {
        phases[id] = false
        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(2))
                guard phases[id] == false else { return }
                phases[id] = true
                ReloadLoadingDemoSnippetIntent.reload()
            } catch {
                phases.removeValue(forKey: id)
            }
        }
    }

    static func isReady(_ id: String) -> Bool {
        phases[id] == true
    }
}

struct ReloadLoadingDemoLauncherIntent: AppIntent {
    static let title: LocalizedStringResource = "诊断重载加载"
    static let description = IntentDescription("离线测试：SnippetIntent.reload() 更新固定尺寸二维码卡片。")
    static var supportedModes: IntentModes { .background }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        let requestID = UUID().uuidString
        ReloadLoadingDemoStore.begin(requestID)
        return .result(
            snippetIntent: ReloadLoadingDemoSnippetIntent(requestID: requestID)
        )
    }
}

struct ReloadLoadingDemoSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "重载测试 Snippet"
    static let isDiscoverable = false

    @Parameter(title: "离线测试标识")
    var requestID: String

    init() {}

    init(requestID: String) {
        self.requestID = requestID
    }

    @MainActor
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let matrix = QRCodeMatrix.encode(loadingDemoPayload) else {
            throw TransitCodeError.qrGenerationFailed
        }
        let isReady = ReloadLoadingDemoStore.isReady(requestID)
        return .result(view: FixedHeightQRLoadingView(matrix: matrix, isReady: isReady))
    }
}
