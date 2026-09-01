import Foundation
import Domain

@MainActor
public final class DownloadListViewModel: ObservableObject {
    /// 아직 다운로드를 시작하지 않은 항목 (대기/조회중/실패/취소)
    @Published public var pendingItems: [DownloadItemViewModel] = []
    /// 다운로드가 시작된 항목 (진행중/일시정지/완료/실패)
    @Published public var activeItems: [DownloadItemViewModel] = []

    @Published public var maxConcurrent: Int = 2
    @Published public var saveDirectory: String = FileManager.default
        .urls(for: .downloadsDirectory, in: .userDomainMask).first?.path
        ?? NSHomeDirectory()

    /// yt-dlp 실행 파일 유무. Presentation은 Data(BinaryManager)를 직접 참조하지 않고
    /// 조립부(App)가 확인한 값을 주입받는다.
    public let isYTDLPAvailable: Bool

    private let fetchVideoInfo: FetchVideoInfoUseCase
    private let startDownload: StartDownloadUseCase
    private let pauseDownload: PauseDownloadUseCase
    private let cancelDownload: CancelDownloadUseCase

    public init(
        isYTDLPAvailable: Bool,
        fetchVideoInfo: FetchVideoInfoUseCase,
        startDownload: StartDownloadUseCase,
        pauseDownload: PauseDownloadUseCase,
        cancelDownload: CancelDownloadUseCase
    ) {
        self.isYTDLPAvailable = isYTDLPAvailable
        self.fetchVideoInfo = fetchVideoInfo
        self.startDownload = startDownload
        self.pauseDownload = pauseDownload
        self.cancelDownload = cancelDownload
    }

    public func addAndFetch(url: String) {
        let item = DownloadItemViewModel(url: url)
        pendingItems.insert(item, at: 0)
        item.status = .fetchingInfo
        Task {
            do {
                let info = try await fetchVideoInfo.execute(url: url)
                item.title = info.title
                item.formats = info.formats
                item.selectedFormatId = info.formats.first(where: { $0.hasVideo && $0.hasAudio })?.formatId
                    ?? info.formats.last(where: { $0.hasVideo })?.formatId
                item.thumbnailURL = info.thumbnailURL
                item.status = .queued
            } catch {
                item.status = .failed(error.localizedDescription)
            }
        }
    }

    public func start(_ item: DownloadItemViewModel) {
        guard downloadingCount() < maxConcurrent else { return }

        pendingItems.removeAll { $0.id == item.id }
        if !activeItems.contains(where: { $0.id == item.id }) {
            activeItems.insert(item, at: 0)
        }

        item.status = .downloading
        item.outputPath = saveDirectory

        startDownload.execute(
            id: item.id,
            url: item.url,
            formatId: item.selectedFormatId,
            outputDirectory: saveDirectory,
            onProgress: { [weak item] percent, speed, eta in
                guard let item else { return }
                item.progress = percent
                item.speedText = speed
                item.etaText = eta
            },
            onFinish: { [weak self, weak item] outcome in
                guard let self, let item else { return }
                switch outcome {
                case .completed:
                    item.status = .completed
                    item.progress = 1.0
                case .failed(let message):
                    if item.status != .cancelled, item.status != .paused {
                        item.status = .failed(message)
                    }
                case .terminatedByClient:
                    // pause()/delete()가 이미 로컬 상태를 정했으므로 그대로 둔다.
                    break
                }
                self.processQueue()
            }
        )
    }

    /// yt-dlp는 기본적으로 --continue이므로 재시작하면 받던 지점부터 이어받는다.
    public func pause(_ item: DownloadItemViewModel) {
        guard item.status == .downloading else { return }
        item.status = .paused
        pauseDownload.execute(id: item.id)
    }

    public func resume(_ item: DownloadItemViewModel) {
        guard item.status == .paused else { return }
        start(item)
    }

    public func delete(_ item: DownloadItemViewModel) {
        if item.status == .downloading || item.status == .paused {
            item.status = .cancelled
            cancelDownload.execute(id: item.id)
        }
        pendingItems.removeAll { $0.id == item.id }
        activeItems.removeAll { $0.id == item.id }
    }

    public func processQueue() {
        let queued = pendingItems.filter { $0.status == .queued }
        for item in queued {
            guard downloadingCount() < maxConcurrent else { break }
            start(item)
        }
    }

    private func downloadingCount() -> Int {
        activeItems.filter { $0.status == .downloading }.count
    }
}
