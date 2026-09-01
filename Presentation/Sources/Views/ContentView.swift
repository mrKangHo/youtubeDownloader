import SwiftUI

public struct ContentView: View {
    @EnvironmentObject var viewModel: DownloadListViewModel
    @State private var urlText: String = ""
    @State private var showSettings = false
    @State private var showBrowser = false

    public init() {}

    public var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                HStack {
                    TextField("Paste YouTube URL", text: $urlText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addURL)
                    Button("Add", action: addURL)
                        .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding([.top, .horizontal])

                Button {
                    showBrowser = true
                } label: {
                    Label("Browse YouTube", systemImage: "play.rectangle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.brandRed)
                .padding([.horizontal, .bottom])
                .padding(.top, 4)

                List(viewModel.pendingItems) { item in
                    DownloadRowView(item: item)
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
            .frame(minWidth: 420)
            .brandedBackground()
            .toolbar {
                ToolbarItem {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        } detail: {
            Group {
                if !viewModel.isYTDLPAvailable {
                    ContentUnavailableView(
                        "yt-dlp not found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Run in Terminal: brew install yt-dlp")
                    )
                } else if viewModel.activeItems.isEmpty {
                    ContentUnavailableView(
                        "No active downloads",
                        systemImage: "arrow.down.circle"
                    )
                } else {
                    List(viewModel.activeItems) { item in
                        ActiveDownloadRowView(item: item)
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .brandedBackground()
        }
        .tint(.brandRed)
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(viewModel)
        }
        .sheet(isPresented: $showBrowser) {
            YouTubeBrowserView().environmentObject(viewModel)
        }
    }

    private func addURL() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.addAndFetch(url: trimmed)
        urlText = ""
    }
}
