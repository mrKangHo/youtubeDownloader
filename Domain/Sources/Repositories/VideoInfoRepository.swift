public protocol VideoInfoRepository {
    func fetchInfo(url: String) async throws -> VideoInfo
}
