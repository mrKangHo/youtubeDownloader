import SwiftUI
import Domain

/// 왼쪽 목록에 쓰인다: 아직 다운로드를 시작하지 않은 항목(대기/조회중/실패/취소)만 여기 나타난다.
struct DownloadRowView: View {
    @ObservedObject var item: DownloadItemViewModel
    @EnvironmentObject var viewModel: DownloadListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                statusBadge
            }

            if !item.formats.isEmpty, item.status == .queued {
                HStack {
                    Picker("Quality", selection: Binding(
                        get: { item.selectedFormatId ?? "" },
                        set: { item.selectedFormatId = $0 }
                    )) {
                        ForEach(item.formats) { format in
                            Text(format.displayLabel).tag(format.formatId)
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 320)

                    Spacer()

                    Button("Download") {
                        viewModel.start(item)
                    }
                }
            }

            if case .failed(let message) = item.status {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button("Delete", role: .destructive) { viewModel.delete(item) }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch item.status {
        case .queued:
            Label("Queued", systemImage: "clock").font(.caption).foregroundStyle(.secondary)
        case .fetchingInfo:
            ProgressView().controlSize(.small)
        case .downloading, .paused, .completed:
            EmptyView()
        case .failed:
            Label("Failed", systemImage: "xmark.circle.fill").font(.caption).foregroundStyle(.red)
        case .cancelled:
            Label("Cancelled", systemImage: "slash.circle").font(.caption).foregroundStyle(.secondary)
        }
    }
}
