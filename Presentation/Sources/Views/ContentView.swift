import SwiftUI

public struct ContentView: View {
    @EnvironmentObject var viewModel: DownloadListViewModel
    @State private var urlText: String = ""
    @State private var showSettings = false

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
                .padding()

                List(viewModel.pendingItems) { item in
                    DownloadRowView(item: item)
                }
                .listStyle(.inset)
            }
            .frame(minWidth: 420)
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
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(viewModel)
        }
    }

    private func addURL() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.addAndFetch(url: trimmed)
        urlText = ""
    }
}
