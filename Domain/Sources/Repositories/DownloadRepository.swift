import Foundation

public protocol DownloadRepository {
    /// id로 진행 중인 다운로드를 식별한다. 이미 같은 id로 실행 중이면 아무 것도 하지 않는다.
    func start(
        id: UUID,
        url: String,
        formatId: String?,
        outputDirectory: String,
        onProgress: @escaping (_ progress: Double, _ speedText: String, _ etaText: String) -> Void,
        onFinish: @escaping (DownloadOutcome) -> Void
    )

    /// 프로세스를 종료한다. yt-dlp는 기본적으로 이어받기(--continue)이므로
    /// 이후 같은 id로 start를 다시 호출하면 받던 지점부터 재개된다.
    func pause(id: UUID)

    func cancel(id: UUID)
}
