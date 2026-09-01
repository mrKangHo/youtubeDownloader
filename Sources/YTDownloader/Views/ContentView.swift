import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: DownloadManager
    @State private var urlText: String = ""
    @State private var showSettings = false

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                HStack {
                    TextField("YouTube URL 붙여넣기", text: $urlText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addURL)
                    Button("추가", action: addURL)
                        .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()

                List(manager.pendingItems) { item in
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
                        Label("설정", systemImage: "gearshape")
                    }
                }
            }
        } detail: {
            if !BinaryManager.isAvailable {
                ContentUnavailableView(
                    "yt-dlp를 찾을 수 없음",
                    systemImage: "exclamationmark.triangle",
                    description: Text("터미널에서 실행: brew install yt-dlp")
                )
            } else if manager.activeItems.isEmpty {
                ContentUnavailableView(
                    "다운로드 중인 항목 없음",
                    systemImage: "arrow.down.circle"
                )
            } else {
                List(manager.activeItems) { item in
                    ActiveDownloadRowView(item: item)
                }
                .listStyle(.inset)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(manager)
        }
    }

    private func addURL() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        manager.addAndFetch(url: trimmed)
        urlText = ""
    }
}

#Preview {
    ContentView().environmentObject(DownloadManager())
}
