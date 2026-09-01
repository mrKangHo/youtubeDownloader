import Foundation

public struct PauseDownloadUseCase {
    private let repository: DownloadRepository

    public init(repository: DownloadRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) {
        repository.pause(id: id)
    }
}
