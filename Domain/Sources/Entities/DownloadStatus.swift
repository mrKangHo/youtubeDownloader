public enum DownloadStatus: Equatable {
    case queued
    case fetchingInfo
    case downloading
    case paused
    case completed
    case failed(String)
    case cancelled
}
