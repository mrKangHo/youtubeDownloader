public struct FetchVideoInfoUseCase {
    private let repository: VideoInfoRepository

    public init(repository: VideoInfoRepository) {
        self.repository = repository
    }

    public func execute(url: String) async throws -> VideoInfo {
        try await repository.fetchInfo(url: url)
    }
}
