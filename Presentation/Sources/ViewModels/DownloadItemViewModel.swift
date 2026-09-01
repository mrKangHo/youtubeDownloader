import Foundation
import Domain

@MainActor
public final class DownloadItemViewModel: ObservableObject, Identifiable {
    public let id: UUID
    public let url: String
    @Published public var title: String
    @Published public var thumbnailURL: URL?
    @Published public var status: DownloadStatus = .queued
    @Published public var progress: Double = 0
    @Published public var speedText: String = ""
    @Published public var etaText: String = ""
    @Published public var selectedFormatId: String?
    @Published public var formats: [VideoFormat] = []
    @Published public var outputPath: String?

    public init(id: UUID = UUID(), url: String, title: String = "") {
        self.id = id
        self.url = url
        self.title = title.isEmpty ? url : title
    }
}
