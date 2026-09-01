import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var viewModel: DownloadListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Save Location") {
                HStack {
                    Text(viewModel.saveDirectory)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Change") { chooseDirectory() }
                }
            }

            Section("Concurrent Downloads") {
                Stepper("Max \(viewModel.maxConcurrent)", value: $viewModel.maxConcurrent, in: 1...5)
            }
        }
        .padding()
        .frame(width: 420, height: 180)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Close") { dismiss() }
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
