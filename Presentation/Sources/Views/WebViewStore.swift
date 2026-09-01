import AppKit
import SwiftUI
import WebKit

/// WKWebView 인스턴스를 SwiftUI 생명주기와 별개로 유지한다.
/// 뷰가 다시 그려져도 같은 웹뷰(탐색 상태 포함)를 계속 쓰기 위함.
///
/// 유튜브는 SPA라 영상을 클릭해도 대부분 History API(pushState)로 URL만 바뀌고
/// 새 네비게이션이 발생하지 않는다. WKNavigationDelegate 콜백만으로는 이걸 못 잡아서
/// KVO로 `url`/`canGoBack`/`canGoForward`/`isLoading`을 직접 관찰한다.
final class WebViewStore: NSObject, ObservableObject {
    @Published var currentURL: URL?
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false

    let webView: WKWebView
    private var observations: [NSKeyValueObservation] = []

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        observations = [
            webView.observe(\.url, options: [.new, .initial]) { [weak self] webView, _ in
                DispatchQueue.main.async { self?.currentURL = webView.url }
            },
            webView.observe(\.canGoBack, options: [.new, .initial]) { [weak self] webView, _ in
                DispatchQueue.main.async { self?.canGoBack = webView.canGoBack }
            },
            webView.observe(\.canGoForward, options: [.new, .initial]) { [weak self] webView, _ in
                DispatchQueue.main.async { self?.canGoForward = webView.canGoForward }
            },
            webView.observe(\.isLoading, options: [.new, .initial]) { [weak self] webView, _ in
                DispatchQueue.main.async { self?.isLoading = webView.isLoading }
            },
        ]
    }
}

struct WebViewRepresentable: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView { webView }
    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
