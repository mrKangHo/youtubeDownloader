import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var viewModel: DownloadListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("저장 위치") {
                HStack {
                    Text(viewModel.saveDirectory)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("변경") { chooseDirectory() }
                }
            }

            Section("동시 다운로드") {
                Stepper("최대 \(viewModel.maxConcurrent)개", value: $viewModel.maxConcurrent, in: 1...5)
            }
        }
        .padding()
        .frame(width: 420, height: 180)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("닫기") { dismiss() }
            }
        }
    }

    private func chooseDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.saveDirectory = url.path
        }
    }
}
