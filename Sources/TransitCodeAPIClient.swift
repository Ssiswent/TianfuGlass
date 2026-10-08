import Foundation

/// Only contacts the transit endpoint supplied by the user. No telemetry,
/// cookie synchronization, redirects to third-party domains, or QR caching.
enum TransitCodeAPIClient {
    private static let endpoint = URL(
        string: "https://tfsmy.chengdu.gov.cn/scan-code-rh/api/front/code"
    )!

    enum APIError: LocalizedError {
        case unauthorized, serverResponse, notBound, malformedResponse, networkFailure

        var errorDescription: String? {
            switch self {
            case .unauthorized:
                "登录会话已失效。请在天府通 Glass 中更新 Cookie。"
            case .serverResponse:
                "天府通服务器未能返回乘车码，请稍后重试。"
            case .notBound:
                "当前账号尚未绑定乘车码，请先在官方渠道完成绑定。"
            case .malformedResponse:
                "乘车码接口返回了无法识别的数据，未展示二维码。"
            case .networkFailure:
                "网络请求失败，请检查网络连接后重新获取。"
            }
        }
    }

    static func fetchCode() async throws -> String {
        let cookie = try TransitCookieStore.load()
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = Data()
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 12
        request.httpShouldHandleCookies = false
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("zh-CN,zh-Hans;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("https://tfsmy.chengdu.gov.cn", forHTTPHeaderField: "Origin")
        request.setValue(
            "https://tfsmy.chengdu.gov.cn/scan-code-rh/",
            forHTTPHeaderField: "Referer"
        )
        // The endpoint was observed with this transport UA. Keep it confined
        // to the user's chosen transit host; do not copy browser-only :headers.
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_2_1 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 " +
            "iOS/17.2.1 Brand/iPhone Display/393.00*852.00 " +
            "smyapp/tfsmy tfsmy/5.2.1 UnionPay/1.0 tfsmy",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue(cookie, forHTTPHeaderField: "Cookie")

        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 12
        configuration.timeoutIntervalForResource = 15
        // A transit Cookie must never be forwarded to a redirected host.
        let session = URLSession(
            configuration: configuration,
            delegate: RejectTransitRedirects(),
            delegateQueue: nil
        )
        defer { session.invalidateAndCancel() }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            // Don't include URL or HTTP headers in surfaced error messages.
            throw APIError.networkFailure
        }
        guard let response = response as? HTTPURLResponse else {
            throw APIError.malformedResponse
        }
        if response.statusCode == 401 || response.statusCode == 403 {
            throw APIError.unauthorized
        }
        guard response.statusCode == 200 else { throw APIError.serverResponse }
        guard data.count <= 65_536,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let statusCode = json["code"] as? Int,
              statusCode == 1,
              let result = json["result"] as? [String: Any] else {
            throw APIError.malformedResponse
        }
        if let isBound = result["isBinded"] as? Bool, !isBound {
            throw APIError.notBound
        }
        guard let code = result["code"] as? String else {
            throw APIError.malformedResponse
        }
        try TransitCodePayloadValidation.check(code)
        // This must remain the exact server-provided string, not decoded
        // or trimmed, and must never be persisted or printed.
        return code
    }
}

/// Reject HTTP redirects rather than risking a credential-bearing request
/// being forwarded off the explicitly configured transit HTTPS endpoint.
private final class RejectTransitRedirects: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
