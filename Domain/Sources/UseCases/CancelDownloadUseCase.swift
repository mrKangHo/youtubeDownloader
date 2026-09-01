import Foundation

public struct CancelDownloadUseCase {
    private let repository: DownloadRepository

    public init(repository: DownloadRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) {
        repository.cancel(id: id)
    }
}
