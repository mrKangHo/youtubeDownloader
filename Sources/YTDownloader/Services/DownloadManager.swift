import Foundation

@MainActor
final class DownloadManager: ObservableObject {
    /// 아직 다운로드를 시작하지 않은 항목 (대기/조회중/실패/취소)
    @Published var pendingItems: [DownloadItem] = []
    /// 다운로드가 시작된 항목 (진행중/일시정지/완료/실패)
    @Published var activeItems: [DownloadItem] = []

    @Published var maxConcurrent: Int = 2
    @Published var saveDirectory: String = FileManager.default
        .urls(for: .downloadsDirectory, in: .userDomainMask).first?.path
        ?? NSHomeDirectory()

    func addAndFetch(url: String) {
        let item = DownloadItem(url: url)
        pendingItems.insert(item, at: 0)
        item.status = .fetchingInfo
        Task {
            do {
                let info = try await YTDLPService.fetchInfo(url: url)
                item.title = info.title
                item.formats = info.formats.filter { $0.hasVideo || $0.hasAudio }
                item.selectedFormatId = info.formats.first(where: { $0.hasVideo && $0.hasAudio })?.formatId
                    ?? info.formats.last(where: { $0.hasVideo })?.formatId
                if let thumb = info.thumbnail {
                    item.thumbnailURL = URL(string: thumb)
                }
                item.status = .queued
            } catch {
                item.status = .failed(error.localizedDescription)
            }
        }
    }

    func startDownload(_ item: DownloadItem) {
        guard downloadingCount() < maxConcurrent else { return }

        pendingItems.removeAll { $0.id == item.id }
        if !activeItems.contains(where: { $0.id == item.id }) {
            activeItems.insert(item, at: 0)
        }

        item.status = .downloading
        item.outputPath = saveDirectory

        let process = YTDLPService.download(
            url: item.url,
            formatId: item.selectedFormatId,
            outputDirectory: saveDirectory
        ) { [weak item] percent, speed, eta in
            guard let item else { return }
            item.progress = percent
            item.speedText = speed
            item.etaText = eta
        }
        item.process = process

        process.terminationHandler = { [weak self, weak item] proc in
            Task { @MainActor in
                guard let self, let item else { return }
                if item.status == .cancelled || item.status == .paused {
                    // 사용자가 이미 최종 상태를 정했으므로 그대로 둔다.
                } else if proc.terminationStatus == 0 {
                    item.status = .completed
                    item.progress = 1.0
                } else {
                    item.status = .failed("종료 코드 \(proc.terminationStatus)")
                }
                self.processQueue()
            }
        }

        do {
            try process.run()
        } catch {
            item.status = .failed(error.localizedDescription)
        }
    }

    /// yt-dlp는 기본적으로 --continue이므로 재시작하면 받던 지점부터 이어받는다.
    func pause(_ item: DownloadItem) {
        guard item.status == .downloading else { return }
        item.status = .paused
        item.process?.terminate()
    }

    func resume(_ item: DownloadItem) {
        guard item.status == .paused else { return }
        startDownload(item)
    }

    func delete(_ item: DownloadItem) {
        if item.status == .downloading || item.status == .paused {
            item.status = .cancelled
            item.process?.terminate()
        }
        pendingItems.removeAll { $0.id == item.id }
        activeItems.removeAll { $0.id == item.id }
    }

    func processQueue() {
        let queued = pendingItems.filter { $0.status == .queued }
        for item in queued {
            guard downloadingCount() < maxConcurrent else { break }
            startDownload(item)
        }
    }

    private func downloadingCount() -> Int {
        activeItems.filter { $0.status == .downloading }.count
    }
}
