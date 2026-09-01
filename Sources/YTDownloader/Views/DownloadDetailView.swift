import SwiftUI

/// 오른쪽 목록에 쓰인다: 다운로드 시작(진행중/일시정지/완료)된 항목이 여기 나타난다.
/// 큰 썸네일을 배경으로 깔고, 하단에 그라데이션 스크림 위에 정보를 얹는 포스터 카드 형태.
struct ActiveDownloadRowView: View {
    @ObservedObject var item: DownloadItem
    @EnvironmentObject var manager: DownloadManager

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                thumbnail
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.55), .black.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: geo.size.height)

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .shadow(radius: 2)

                    Label(item.outputPath ?? manager.saveDirectory, systemImage: "folder")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    progressSection
                }
                .padding(14)
                .frame(width: geo.size.width, alignment: .leading)

                controls
                    .padding(14)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .topTrailing)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .listRowSeparator(.hidden)
        .contextMenu {
            if item.status == .downloading {
                Button("일시정지") { manager.pause(item) }
            } else if item.status == .paused {
                Button("재개") { manager.resume(item) }
            }
            Button("삭제", role: .destructive) { manager.delete(item) }
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let url = item.thumbnailURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(.quaternary)
                }
            }
        } else {
            Rectangle().fill(.quaternary)
                .overlay(Image(systemName: "film").font(.largeTitle).foregroundStyle(.secondary))
        }
    }

    @ViewBuilder
    private var progressSection: some View {
        switch item.status {
        case .downloading, .paused:
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: item.progress)
                    .tint(.white)
                HStack {
                    Text("\(Int(item.progress * 100))%")
                    Spacer()
                    if item.status == .downloading {
                        Text(item.speedText)
                        Text("ETA \(item.etaText)")
                    } else {
                        Text("일시정지됨")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.85))
            }
        case .completed:
            Label("완료", systemImage: "checkmark.circle.fill")
                .font(.caption.bold())
                .foregroundStyle(.green)
        case .failed(let message):
            Label(message, systemImage: "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.red)
                .lineLimit(1)
        case .cancelled, .queued, .fetchingInfo:
            EmptyView()
        }
    }

    @ViewBuilder
    private var controls: some View {
        HStack(spacing: 8) {
            switch item.status {
            case .downloading:
                controlButton("pause.fill") { manager.pause(item) }
            case .paused:
                controlButton("play.fill") { manager.resume(item) }
            default:
                EmptyView()
            }

            controlButton("trash", tint: .red) { manager.delete(item) }
        }
    }

    private func controlButton(_ systemImage: String, tint: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(.black.opacity(0.45), in: Circle())
        }
        .buttonStyle(.plain)
    }
}
