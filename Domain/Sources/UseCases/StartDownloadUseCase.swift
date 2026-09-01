import Foundation

public struct StartDownloadUseCase {
    private let repository: DownloadRepository

    public init(repository: DownloadRepository) {
        self.repository = repository
    }

    public func execute(
        id: UUID,
        url: String,
        formatId: String?,
        outputDirectory: String,
        onProgress: @escaping (Double, String, String) -> Void,
        onFinish: @escaping (DownloadOutcome) -> Void
    ) {
        repository.start(
            id: id,
            url: url,
            formatId: formatId,
            outputDirectory: outputDirectory,
            onProgress: onProgress,
            onFinish: onFinish
        )
    }
}
