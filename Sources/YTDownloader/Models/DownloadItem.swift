import Foundation

enum DownloadStatus: Equatable {
    case queued
    case fetchingInfo
    case downloading
    case paused
    case completed
    case failed(String)
    case cancelled
}

@MainActor
final class DownloadItem: ObservableObject, Identifiable {
    let id = UUID()
    let url: String
    @Published var title: String
    @Published var thumbnailURL: URL?
    @Published var status: DownloadStatus = .queued
    @Published var progress: Double = 0
    @Published var speedText: String = ""
    @Published var etaText: String = ""
    @Published var selectedFormatId: String?
    @Published var formats: [VideoFormat] = []
    @Published var outputPath: String?

    var process: Process?

    init(url: String, title: String = "") {
        self.url = url
        self.title = title.isEmpty ? url : title
    }
}
