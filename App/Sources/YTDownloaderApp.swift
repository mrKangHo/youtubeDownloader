import SwiftUI
import Domain
import Data
import Presentation

@main
struct YTDownloaderApp: App {
    @StateObject private var viewModel: DownloadListViewModel

    init() {
        let videoInfoRepository = YTDLPVideoInfoRepository()
        let downloadRepository = YTDLPDownloadRepository()

        let viewModel = DownloadListViewModel(
            isYTDLPAvailable: BinaryManager.isAvailable,
            fetchVideoInfo: FetchVideoInfoUseCase(repository: videoInfoRepository),
            startDownload: StartDownloadUseCase(repository: downloadRepository),
            pauseDownload: PauseDownloadUseCase(repository: downloadRepository),
            cancelDownload: CancelDownloadUseCase(repository: downloadRepository)
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowResizability(.contentSize)
    }
}
