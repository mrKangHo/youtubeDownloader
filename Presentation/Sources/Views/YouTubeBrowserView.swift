import SwiftUI

/// 앱 안에서 유튜브를 바로 둘러보다가, 보고 있는 영상을 즉시 다운로드 큐에 추가할 수 있게 한다.
/// 시트로 띄우면 `.toolbar`가 창 툴바에 안정적으로 붙지 않아, 컨트롤 바를 직접 그린다.
struct YouTubeBrowserView: View {
    @EnvironmentObject var viewModel: DownloadListViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = WebViewStore()
    @State private var justAdded = false

    private static let homeURL = URL(string: "https://www.youtube.com")!

    var body: some View {
        VStack(spacing: 0) {
            controlBar
            Divider()
            WebViewRepresentable(webView: store.webView)
        }
        .frame(minWidth: 960, minHeight: 680)
        .onAppear {
            if store.webView.url == nil {
                store.webView.load(URLRequest(url: Self.homeURL))
            }
        }
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            Button { store.webView.goBack() } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!store.canGoBack)

            Button { store.webView.goForward() } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!store.canGoForward)

            Button { store.webView.reload() } label: {
                Image(systemName: "arrow.clockwise")
            }

            Button { store.webView.load(URLRequest(url: Self.homeURL)) } label: {
                Image(systemName: "house")
            }

            if store.isLoading {
                ProgressView().controlSize(.small)
            }

            Text(store.currentURL?.absoluteString ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Button(action: addCurrentVideo) {
                Label(justAdded ? "Added" : "Add to Downloads", systemImage: justAdded ? "checkmark.circle.fill" : "plus.circle.fill")
            }
            .disabled(currentVideoURL == nil)
            .buttonStyle(.borderedProminent)

            Button { dismiss() } label: {
                Text("Close")
            }
        }
        .padding(10)
        .buttonStyle(.bordered)
    }

    private var currentVideoURL: URL? {
        guard let url = store.currentURL, let host = url.host?.lowercased() else { return nil }
        guard host.contains("youtube.com") || host.contains("youtu.be") else { return nil }

        if url.path.hasPrefix("/watch"), url.query?.contains("v=") == true {
            return url
        }
        if url.path.hasPrefix("/shorts/") {
            return url
        }
        if host.contains("youtu.be"), url.path.count > 1 {
            return url
        }
        return nil
    }

    private func addCurrentVideo() {
        guard let url = currentVideoURL else { return }
        viewModel.addAndFetch(url: url.absoluteString)
        justAdded = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            justAdded = false
        }
    }
}
